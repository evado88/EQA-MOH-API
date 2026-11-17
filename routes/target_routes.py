"""Per-round targets: the stated correct answers a round is graded against.

Most EQA schemes (every one but Viral Load) work by comparing the result a
laboratory reports to a KNOWN answer for each sample - the 'target'. This
module lets a coordinator enter those targets for a round and reads them back,
driven by the same per-form map the evaluation grades on, so it serves every
scheme the same way:

  * bacteriology - Gram reaction, morphology, organism, and the Sample E AST
    table
  * TB Ultra / XDR - detection and the drug results
  * HIV EID - the qualitative result
  * HIV VL - a quantitative target may be entered, but is optional: viral load
    is graded by consensus z-score, not against a fixed value

A target entered here is tied to the round. The same catalogue sample is shipped
cycle after cycle, so a target has to belong to the round rather than the sample
- see models/evaluation_model.MethodSampleExpectedValueDB and migration 026.
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from database import get_db
from helpers import assist
from helpers.evaluation import AST_ATTRIBUTE, FORM_ATTRIBUTES
from models.evaluation_model import MethodSampleExpectedValueDB
from models.methodsample_model import MethodSampleDB
from models.method_model import MethodDB
from models.ptcycle_model import PTCycleDB
from models.scheme_model import SchemeDB
from models.user_model import UserDB

# the bacteriology controlled vocabularies, so a target is entered in exactly
# the words the worksheet records a result in and the two compare like for like
from models.bacteriologyresult_model import (
    ANTIBIOTIC_SUGGESTIONS,
    AST_INTERPRETATION_VALUES,
    AST_SUMMARY_PAIR_SEPARATOR,
    AST_SUMMARY_VALUE_SEPARATOR,
    GRAM_MORPHOLOGY_VALUES,
    GRAM_STAIN_REACTION_VALUES,
    ORGANISM_CATALOGUE,
    ast_interpretations,
)
from models.tbxpertultraresult_model import (
    TB_DETECTION_RESULT_VALUES as ULTRA_DETECTION_VALUES,
    RIF_RESULT_VALUES,
)
from models.tbxpertxdrresult_model import (
    TB_DETECTION_RESULT_VALUES as XDR_DETECTION_VALUES,
    DRUG_RESULT_VALUES,
)
from models.hiveidresult_model import HIV_RESULT_VALUES

router = APIRouter(prefix="/pt-cycle-targets", tags=["Targets"])


# How each graded field is entered, and from what list of choices. A field not
# listed here is entered as free text (qualitative) or a number (quantitative).
# The AST field is a table of its own, handled separately.
ATTRIBUTE_OPTIONS = {
    "gram_stain_reaction": GRAM_STAIN_REACTION_VALUES,
    "gram_morphology": GRAM_MORPHOLOGY_VALUES,
    "organism_identified": ORGANISM_CATALOGUE,
    "tb_detection_result": sorted(set(ULTRA_DETECTION_VALUES) | set(XDR_DETECTION_VALUES)),
    "rif_result": RIF_RESULT_VALUES,
    "inh_result": DRUG_RESULT_VALUES,
    "flq_result": DRUG_RESULT_VALUES,
    "amk_result": DRUG_RESULT_VALUES,
    "eth_result": DRUG_RESULT_VALUES,
    "hiv_result": HIV_RESULT_VALUES,
}

INPUT_AST = "ast"
INPUT_SELECT = "select"
INPUT_TEXT = "text"
INPUT_NUMBER = "number"


def _ast_summary_from_pairs(pairs):
    """Builds the canonical AST target string from {antibiotic, interpretation}.

    Kept identical to what the AST table on a worksheet reduces to, so the
    target and the participant's answer are written the same way and grade
    against each other - see bacteriologyresult_model.ast_summary.
    """
    definite = {v.upper() for v in AST_INTERPRETATION_VALUES}
    interpretations = {}
    for pair in pairs or []:
        agent = (pair.antibiotic or "").strip()
        interp = (pair.interpretation or "").strip().upper()
        # only a definite S/I/SDD/R is a gradable target; 'NE' or blank is not,
        # so it is left out of the target the AST section is scored against
        if agent and interp in definite:
            interpretations[agent.upper()] = interp
    if not interpretations:
        return None
    return AST_SUMMARY_PAIR_SEPARATOR.join(
        f"{agent}{AST_SUMMARY_VALUE_SEPARATOR}{interpretations[agent]}"
        for agent in sorted(interpretations)
    )


# ---------- Schemas ----------
class ASTPair(BaseModel):
    antibiotic: str
    interpretation: str


class TargetAttribute(BaseModel):
    attribute: str
    label: str
    kind: str                       # quantitative / qualitative
    input: str                      # select / text / number / ast
    options: Optional[List[str]] = None
    expected_value_text: Optional[str] = None
    expected_value_numeric: Optional[float] = None
    # where the value shown came from: this round, the sample default, or unset
    source: Optional[str] = None
    # only for the AST field: the target table as agent/interpretation pairs
    ast_pairs: Optional[List[ASTPair]] = None


class TargetSample(BaseModel):
    method_sample_id: int
    sample_name: str
    method_id: int
    method_name: Optional[str] = None
    result_form: str
    is_control: bool = False
    attributes: List[TargetAttribute] = []


class CycleTargets(BaseModel):
    pt_cycle_id: int
    cycle_code: Optional[str] = None
    cycle_name: Optional[str] = None
    scheme_id: int
    scheme_name: Optional[str] = None
    samples: List[TargetSample] = []
    # for the AST target editor
    antibiotic_options: List[str] = []
    ast_interpretation_options: List[str] = []


class TargetInput(BaseModel):
    method_sample_id: int
    attribute: str
    expected_value_text: Optional[str] = None
    expected_value_numeric: Optional[float] = None
    # an AST target may be sent as pairs instead of a pre-built summary string
    ast_pairs: Optional[List[ASTPair]] = None


class SaveTargets(BaseModel):
    user_id: int = Field(..., ge=1, description="User must be provided")
    targets: List[TargetInput] = []


class SaveTargetsResult(BaseModel):
    succeeded: bool
    message: str
    pt_cycle_id: int
    saved: int = 0
    cleared: int = 0


SOURCE_ROUND = "round"
SOURCE_DEFAULT = "default"


async def _get_admin_user(db: AsyncSession, user_id: int) -> UserDB:
    """Loads the acting user and checks they may set a round's targets."""
    result = await db.execute(select(UserDB).where(UserDB.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=400, detail=f"The user with id '{user_id}' does not exist"
        )
    if not assist.is_admin_role(user.role_id):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to set the targets for a PT Cycle",
        )
    return user


async def _load_cycle(db: AsyncSession, pt_cycle_id: int) -> PTCycleDB:
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == pt_cycle_id))
    cycle = result.scalar_one_or_none()
    if not cycle:
        raise HTTPException(
            status_code=404, detail=f"Unable to find PT Cycle with id '{pt_cycle_id}'"
        )
    return cycle


def _input_for(attribute: str, kind: str):
    if attribute == AST_ATTRIBUTE:
        return INPUT_AST, None
    options = ATTRIBUTE_OPTIONS.get(attribute)
    if options:
        return INPUT_SELECT, options
    if kind == assist.EVALUATION_QUANTITATIVE:
        return INPUT_NUMBER, None
    return INPUT_TEXT, None


@router.get("/{pt_cycle_id}", response_model=CycleTargets)
async def get_cycle_targets(pt_cycle_id: int, db: AsyncSession = Depends(get_db)):
    """The samples of a round, each with its graded fields and current target.

    The samples are the scheme's panel - the method samples belonging to the
    cycle's scheme - and the graded fields are read from the same per-form map
    the evaluation grades on, so this and the scoring never drift apart.
    """
    cycle = await _load_cycle(db, pt_cycle_id)

    result = await db.execute(select(SchemeDB).where(SchemeDB.id == cycle.scheme_id))
    scheme = result.scalar_one_or_none()

    # the panel: every approved sample of the cycle's scheme
    result = await db.execute(
        select(MethodSampleDB)
        .where(
            MethodSampleDB.scheme_id == cycle.scheme_id,
            MethodSampleDB.status_id == assist.STATUS_APPROVED,
        )
        .order_by(MethodSampleDB.method_id, MethodSampleDB.name)
    )
    samples = result.scalars().all()

    # the form each sample's method is captured on, for the graded field list
    method_ids = {s.method_id for s in samples}
    forms = {}
    names = {}
    if method_ids:
        result = await db.execute(
            select(MethodDB.id, MethodDB.name, MethodDB.result_form).where(
                MethodDB.id.in_(method_ids)
            )
        )
        for mid, mname, form in result.all():
            forms[mid] = form
            names[mid] = mname

    # the targets already set, this round's winning over any sample default
    sample_ids = {s.id for s in samples}
    expected = {}
    if sample_ids:
        result = await db.execute(
            select(MethodSampleExpectedValueDB).where(
                MethodSampleExpectedValueDB.method_sample_id.in_(sample_ids),
                or_(
                    MethodSampleExpectedValueDB.pt_cycle_id == cycle.id,
                    MethodSampleExpectedValueDB.pt_cycle_id.is_(None),
                ),
            )
        )
        rows = result.scalars().all()
        for e in rows:
            if e.pt_cycle_id is None:
                expected.setdefault((e.method_sample_id, e.attribute),
                                    (e, SOURCE_DEFAULT))
        for e in rows:
            if e.pt_cycle_id == cycle.id:
                expected[(e.method_sample_id, e.attribute)] = (e, SOURCE_ROUND)

    out_samples = []
    for s in samples:
        form = forms.get(s.method_id)
        attributes = FORM_ATTRIBUTES.get(form)
        if not attributes:
            # a method whose result form is not graded has no targets to enter
            continue

        attr_out = []
        for attribute, label, kind in attributes:
            input_kind, options = _input_for(attribute, kind)
            found = expected.get((s.id, attribute))
            value, source = (found[0], found[1]) if found else (None, None)

            item = TargetAttribute(
                attribute=attribute,
                label=label,
                kind=kind,
                input=input_kind,
                options=options,
                expected_value_text=value.expected_value_text if value else None,
                expected_value_numeric=value.expected_value_numeric if value else None,
                source=source,
            )
            if input_kind == INPUT_AST:
                pairs = ast_interpretations(
                    value.expected_value_text if value else None
                )
                item.ast_pairs = [
                    ASTPair(antibiotic=agent, interpretation=interp)
                    for agent, interp in sorted(pairs.items())
                ]
            attr_out.append(item)

        out_samples.append(TargetSample(
            method_sample_id=s.id,
            sample_name=s.name,
            method_id=s.method_id,
            method_name=names.get(s.method_id),
            result_form=form,
            is_control=bool(s.is_control),
            attributes=attr_out,
        ))

    return CycleTargets(
        pt_cycle_id=cycle.id,
        cycle_code=cycle.code,
        cycle_name=cycle.name,
        scheme_id=cycle.scheme_id,
        scheme_name=scheme.name if scheme else None,
        samples=out_samples,
        antibiotic_options=ANTIBIOTIC_SUGGESTIONS,
        ast_interpretation_options=AST_INTERPRETATION_VALUES,
    )


@router.put("/{pt_cycle_id}", response_model=SaveTargetsResult)
async def save_cycle_targets(
    pt_cycle_id: int, payload: SaveTargets, db: AsyncSession = Depends(get_db)
):
    """Sets, changes or clears a round's targets.

    A target carried on the payload with a value is written as this round's
    target; one sent with no value clears the round's target, so the field falls
    back to the sample default (or to consensus if there is none). Re-scoring the
    round afterwards is what makes a changed target take effect on the reports.
    """
    cycle = await _load_cycle(db, pt_cycle_id)
    user = await _get_admin_user(db, payload.user_id)

    # the targets already set for this round, so a save updates in place
    result = await db.execute(
        select(MethodSampleExpectedValueDB).where(
            MethodSampleExpectedValueDB.pt_cycle_id == cycle.id
        )
    )
    existing = {
        (e.method_sample_id, e.attribute): e for e in result.scalars().all()
    }

    saved = 0
    cleared = 0

    for t in payload.targets:
        if t.attribute == AST_ATTRIBUTE and t.ast_pairs is not None:
            text = _ast_summary_from_pairs(t.ast_pairs)
            numeric = None
        else:
            text = (t.expected_value_text or "").strip() or None
            numeric = t.expected_value_numeric

        key = (t.method_sample_id, t.attribute)
        row = existing.get(key)

        if text is None and numeric is None:
            # cleared: drop this round's target so the default takes over
            if row is not None:
                await db.delete(row)
                cleared += 1
            continue

        if row is None:
            row = MethodSampleExpectedValueDB(
                method_sample_id=t.method_sample_id,
                pt_cycle_id=cycle.id,
                attribute=t.attribute,
                created_by=user.email,
            )
            db.add(row)
        row.expected_value_text = text
        row.expected_value_numeric = numeric
        row.updated_by = user.email
        saved += 1

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to save the PT Cycle targets: {e}"
        )

    return SaveTargetsResult(
        succeeded=True,
        message=f"{saved} target(s) saved, {cleared} cleared.",
        pt_cycle_id=cycle.id,
        saved=saved,
        cleared=cleared,
    )
