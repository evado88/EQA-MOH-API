from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from helpers.auth import get_current_user, CurrentUser
from typing import Optional
from models.laboratory_model import LaboratoryDB
from models.methodsample_model import MethodSampleDB
from models.ptcycle_model import (
    PTCycle,
    PTCycleWithDetail,
    ParamPTCycleEdit,
    ParamPTCycleStatusChange,
    PTCycleStatusChangeResult,
    PTCycleDB,
)
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.tbxpertultraresult_model import TBXpertUltraResultDB
from models.tbxpertxdrresult_model import TBXpertXDRResultDB
from models.hivvlresult_model import HIVVLResultDB
from models.hiveidresult_model import HIVEIDResultDB
from models.bacteriologyresult_model import BacteriologyResultDB
from models.evaluation_model import ParamEvaluateCycle, EvaluateCycleResult
from helpers import evaluation
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB
from models.ptcyclestatus_model import PTCycleStatusDB
from models.applications_model import ApplicationsDB
from models.method_model import (
    MethodDB,
    RESULT_FORM_TB_XPERT_ULTRA,
    RESULT_FORM_TB_XPERT_XDR,
    RESULT_FORM_HIV_VL,
    RESULT_FORM_HIV_EID,
    RESULT_FORM_BACTERIOLOGY,
)
from models.enrollment_model import EnrollmentDB
from models.attachment_model import Attachment, AttachmentDB
from models.ptcycle_model import (
    ParamPTCycleSave,
    ParamPTCycleAction,
    PTCycleReminderResult,
    ParamPTCycleExtend,
    PTCycleExtension,
    PTCycleExtensionDB,
    PTCycleExtendResult,
    EXTENDABLE_DATE_FIELDS,
)
from helpers import mailer
from datetime import timedelta
from sqlalchemy import text
import os

router = APIRouter(prefix="/pt-cycles", tags=["PTCycles"])

# which result sheet a method's participants fill in. A method whose form is
# not listed here ships no sheets, rather than being given the wrong form.
RESULT_MODEL_BY_FORM = {
    RESULT_FORM_TB_XPERT_ULTRA: TBXpertUltraResultDB,
    RESULT_FORM_TB_XPERT_XDR: TBXpertXDRResultDB,
    RESULT_FORM_HIV_VL: HIVVLResultDB,
    RESULT_FORM_HIV_EID: HIVEIDResultDB,
    RESULT_FORM_BACTERIOLOGY: BacteriologyResultDB,
}


def _recompute_status(ptcycle: PTCycleDB):
    """Refresh the cached lifecycle status from the cycle's dates and gates."""
    ptcycle.pt_cyle_status_id = assist.compute_pt_cycle_status(ptcycle)


# A testing convenience is only offered when explicitly switched on. Leave
# ENABLE_DEV_TOOLS unset in production to keep the phase-jump endpoint off.
DEV_TOOLS_ENABLED = os.environ.get("ENABLE_DEV_TOOLS", "1") != "0"

# Lifecycle status is derived live from the seven schedule dates (see
# assist.compute_pt_cycle_status), so the only way to put a cycle into a given
# phase is to position those dates either side of "today". For each phase this
# maps the seven dates, in schedule order, to a day offset from today that
# lands the derived status exactly on that phase, together with the two manual
# gates (samples shipped / reports published) that phase implies.
_DEV_PHASE_OFFSETS = {
    #                     eff  close  ship  tstart  tstop   due  reports
    assist.PT_CYCLE_UPCOMING:         (  5,   15,   25,    35,    45,   55,   65),
    assist.PT_CYCLE_ENROLMENT_OPEN:   ( -5,   15,   25,    35,    45,   55,   65),
    assist.PT_CYCLE_ENROLMENT_CLOSED: (-25,   -5,    5,    15,    25,   35,   45),
    assist.PT_CYCLE_SAMPLES_SHIPPED:  (-35,  -25,   -5,     5,    15,   25,   35),
    assist.PT_CYCLE_TESTING:          (-45,  -35,  -25,    -5,    15,   25,   35),
    assist.PT_CYCLE_RESULTS_DUE:      (-55,  -45,  -35,   -25,    -5,   15,   25),
    assist.PT_CYCLE_REPORT_AVAILABLE: (-75,  -65,  -55,   -45,   -35,  -25,   -5),
}

# the schedule fields, in the order the offsets above are listed
_DEV_DATE_FIELDS = (
    "effective_date",
    "closing_date",
    "shipping_date",
    "test_event_start_date",
    "test_event_stop_date",
    "result_submission_due_date",
    "reports_availability_date",
)


def _apply_dev_phase(ptcycle: PTCycleDB, phase: int):
    """Back-dates a cycle's schedule around today so its derived status lands on
    `phase`, and sets the manual gates that phase implies. Testing only."""
    today = assist.get_current_date().date()
    offsets = _DEV_PHASE_OFFSETS[phase]

    for field, offset in zip(_DEV_DATE_FIELDS, offsets):
        setattr(ptcycle, field, today + timedelta(days=offset))

    # a cycle can only sit in a lifecycle phase once it has been approved
    ptcycle.status_id = assist.STATUS_APPROVED
    ptcycle.stage_id = assist.APPROVAL_STAGE_APPROVED

    shipped = phase >= assist.PT_CYCLE_SAMPLES_SHIPPED
    published = phase == assist.PT_CYCLE_REPORT_AVAILABLE

    ptcycle.samples_shipped = shipped
    ptcycle.samples_shipped_at = assist.get_current_date(False) if shipped else None
    ptcycle.reports_published = published
    ptcycle.reports_published_at = assist.get_current_date(False) if published else None

    _recompute_status(ptcycle)


async def _reuse_participants(db: AsyncSession, ptcycle: PTCycleDB, source_id: int, user: UserDB):
    """Copy every accepted participant of an earlier round of the same scheme
    into this one, enrolled and accepted, and tell each lab by email.

    Returns the number of laboratories carried over.
    """
    source = (
        await db.execute(select(PTCycleDB).where(PTCycleDB.id == source_id))
    ).scalars().first()
    if not source:
        raise HTTPException(status_code=400, detail="The round to reuse participants from was not found")
    if source.scheme_id != ptcycle.scheme_id:
        raise HTTPException(
            status_code=400,
            detail="Participants can only be reused from a round of the same scheme",
        )

    source_enrollments = (
        await db.execute(
            select(EnrollmentDB).where(
                EnrollmentDB.pt_cycle_id == source_id,
                EnrollmentDB.status_id == assist.STATUS_APPROVED,
            )
        )
    ).scalars().all()

    lab_ids = set()
    for src in source_enrollments:
        db.add(
            EnrollmentDB(
                name=f"{ptcycle.name} - reused",
                description="Carried over from a previous round",
                scheme_id=src.scheme_id,
                lab_id=src.lab_id,
                service_id=src.service_id,
                method_id=src.method_id,
                pt_cycle_id=ptcycle.id,
                user_id=user.id,
                # reused participants are enrolled and accepted straight away
                status_id=assist.STATUS_APPROVED,
                stage_id=assist.APPROVAL_STAGE_APPROVED,
                approval_levels=1,
                created_by=user.email,
            )
        )
        lab_ids.add(src.lab_id)

    # email each carried-over laboratory
    if lab_ids:
        labs = (
            await db.execute(
                select(LaboratoryDB.name, LaboratoryDB.email_address).where(
                    LaboratoryDB.id.in_(lab_ids)
                )
            )
        ).all()
        for name, email in labs:
            if not email:
                continue
            try:
                await mailer.send_email(
                    email,
                    f"You have been enrolled in {ptcycle.name}",
                    (
                        f"Dear {name},\n\n"
                        f"Your laboratory has been automatically enrolled in the new "
                        f"round '{ptcycle.name}', carried over from a previous round. "
                        f"No action is needed to enrol.\n\n"
                        f"Enrollment opens {ptcycle.effective_date:%d %b %Y}; results "
                        f"are due {ptcycle.result_submission_due_date:%d %b %Y}.\n"
                    ),
                    f"<p>Dear {name},</p><p>Your laboratory has been automatically "
                    f"enrolled in the new round <strong>{ptcycle.name}</strong>, carried "
                    f"over from a previous round. No action is needed to enrol.</p>",
                )
            except Exception as e:  # pragma: no cover - mail server dependent
                print(f"[pt-cycle reuse] could not email {email}: {e}")

    return len(lab_ids)


@router.post("/create", response_model=PTCycle)
async def post_ptcycle(param: ParamPTCycleSave, db: AsyncSession = Depends(get_db)):
    """Opens a PT Cycle from its schedule of dates.

    The lifecycle status is derived from the dates, not chosen here. The cycle
    still goes through the normal approval before it can run. Optionally reuses
    all accepted participants from an earlier round of the same scheme.
    """
    scheme = (
        await db.execute(select(SchemeDB).where(SchemeDB.id == param.scheme_id))
    ).scalars().first()
    if not scheme:
        raise HTTPException(status_code=400, detail="The selected scheme was not found")

    user = await _get_admin_user(db, param.user_id)

    db_context = PTCycleDB(
        name=f"{scheme.name} - {param.code}",
        description=param.notes,
        notes=param.notes,
        code=param.code,
        scheme_id=param.scheme_id,
        effective_date=param.effective_date,
        closing_date=param.closing_date,
        shipping_date=param.shipping_date,
        test_event_start_date=param.test_event_start_date,
        test_event_stop_date=param.test_event_stop_date,
        result_submission_due_date=param.result_submission_due_date,
        reports_availability_date=param.reports_availability_date,
        samples_shipped=False,
        reports_published=False,
        # approval: a new cycle is submitted for review, like before
        user_id=param.user_id,
        status_id=assist.STATUS_SUBMITTED,
        stage_id=assist.APPROVAL_STAGE_SUBMITTED,
        approval_levels=1,
        created_by=user.email,
    )
    _recompute_status(db_context)
    db.add(db_context)

    try:
        await db.flush()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create PT Cycle: {e}")

    if param.reuse_from_pt_cycle_id:
        await _reuse_participants(db, db_context, param.reuse_from_pt_cycle_id, user)

    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create PT Cycle: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Cycle 1'}, {'name': 'Cycle 2'}, {'name': 'Cycle 3'}, {'name': 'Cycle 4'}, {'name': 'Cycle 5'}]

    for value in itemList:
        db_item = PTCycleDB(
            # add item
            name=value["name"],
            user_id=1,
            status_id=4,
            stage_id=5,
            approval_levels=1
        )
        db.add(db_item)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to initialize items for PT Cycle: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for PT Cycle have been successfully initialized",
    }



def _ptcycle_query():
    """The PT cycle query every listing shares, with its detail loaded"""
    return select(PTCycleDB).options(
        selectinload(PTCycleDB.stage),
        selectinload(PTCycleDB.status),
        selectinload(PTCycleDB.user),

        selectinload(PTCycleDB.scheme),
        selectinload(PTCycleDB.ptcyclestatus),
    )


@router.get("/list", response_model=List[PTCycleWithDetail])
async def list_ptcycles(
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_current_user),
):
    query = _ptcycle_query().order_by(PTCycleDB.effective_date.desc())
    # a scheme-team member only sees their own scheme's cycles
    scope = assist.scheme_scope_for(user) if user else None
    if scope is not None:
        query = query.where(PTCycleDB.scheme_id == scope)
    result = await db.execute(query)
    return result.scalars().all()

@router.put("/update/{id}", response_model=PTCycle)
async def update_ptcycle(
    id: int, param: ParamPTCycleSave, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()

    if not ptcycle:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle with id '{id}'",
        )

    scheme = (
        await db.execute(select(SchemeDB).where(SchemeDB.id == param.scheme_id))
    ).scalars().first()

    # the schedule of dates and the notes are editable; the lifecycle status is
    # derived and the manual gates are moved from their own actions
    ptcycle.scheme_id = param.scheme_id
    ptcycle.code = param.code
    ptcycle.name = f"{scheme.name} - {param.code}" if scheme else ptcycle.name
    ptcycle.effective_date = param.effective_date
    ptcycle.closing_date = param.closing_date
    ptcycle.shipping_date = param.shipping_date
    ptcycle.test_event_start_date = param.test_event_start_date
    ptcycle.test_event_stop_date = param.test_event_stop_date
    ptcycle.result_submission_due_date = param.result_submission_due_date
    ptcycle.reports_availability_date = param.reports_availability_date
    ptcycle.notes = param.notes
    ptcycle.description = param.notes
    ptcycle.updated_by = (await _get_admin_user(db, param.user_id)).email

    _recompute_status(ptcycle)

    try:
        await db.commit()
        await db.refresh(ptcycle)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle {e}")
    return ptcycle


@router.put("/samples-shipped/{id}", response_model=PTCycleStatusChangeResult)
async def ship_ptcycle_samples(
    id: int, change: ParamPTCycleAction, db: AsyncSession = Depends(get_db)
):
    """Marks a cycle's samples as shipped - the one manual step before testing.

    This opens a result sheet for every sample in every accepted enrolment, and
    moves the derived status into the post-shipping phases.
    """
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()
    if not ptcycle:
        raise HTTPException(status_code=404, detail=f"Unable to find PT Cycle with id '{id}'")

    user = await _get_admin_user(db, change.user_id)

    if ptcycle.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="The PT Cycle must be approved before samples can be shipped",
        )
    if ptcycle.samples_shipped:
        raise HTTPException(status_code=400, detail="This PT Cycle's samples are already shipped")

    enrollment_count, result_count = await _ship_samples(db, ptcycle, user)

    ptcycle.samples_shipped = True
    ptcycle.samples_shipped_at = assist.get_current_date(False)
    if not ptcycle.shipping_date:
        ptcycle.shipping_date = assist.get_current_date().date()
    ptcycle.updated_by = user.email
    _recompute_status(ptcycle)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle {e}")

    return PTCycleStatusChangeResult(
        succeeded=True,
        message=(
            f"Samples marked shipped. {result_count} result sheet(s) were opened "
            f"across {enrollment_count} enrolment(s)."
        ),
        pt_cycle_id=ptcycle.id,
        pt_cyle_status_id=ptcycle.pt_cyle_status_id,
        enrollment_count=enrollment_count,
        result_count=result_count,
    )


@router.put("/publish-reports/{id}", response_model=PTCycleStatusChangeResult)
async def publish_ptcycle_reports(
    id: int, change: ParamPTCycleAction, db: AsyncSession = Depends(get_db)
):
    """Scores the round and makes its reports available - the final manual step.

    Scoring is frozen at publication, so a report issued now still says the same
    thing if the round is re-run later.
    """
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()
    if not ptcycle:
        raise HTTPException(status_code=404, detail=f"Unable to find PT Cycle with id '{id}'")

    user = await _get_admin_user(db, change.user_id)

    if not ptcycle.samples_shipped:
        raise HTTPException(
            status_code=400,
            detail="Samples must be shipped before reports can be published",
        )
    if ptcycle.reports_published:
        raise HTTPException(status_code=400, detail="This PT Cycle's reports are already published")

    evaluated = None
    if not await evaluation.cycle_is_evaluated(db, ptcycle):
        evaluated = await evaluation.evaluate_cycle(db, ptcycle, user)

    ptcycle.reports_published = True
    ptcycle.reports_published_at = assist.get_current_date(False)
    ptcycle.updated_by = user.email
    _recompute_status(ptcycle)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle {e}")

    message = "Reports published and now available to the laboratories."
    if evaluated:
        stats, evals, performances = evaluated
        message += (
            f" {evals} result(s) were scored against {stats} sample statistic(s), "
            f"giving {performances} participant report(s)."
        )

    return PTCycleStatusChangeResult(
        succeeded=True,
        message=message,
        pt_cycle_id=ptcycle.id,
        pt_cyle_status_id=ptcycle.pt_cyle_status_id,
    )


# --------------------------------------------------------------------------
# Testing convenience
# --------------------------------------------------------------------------
@router.put("/dev-set-phase/{id}", response_model=PTCycleStatusChangeResult)
async def dev_set_ptcycle_phase(
    id: int, change: ParamPTCycleStatusChange, db: AsyncSession = Depends(get_db)
):
    """Jump a cycle straight to a lifecycle phase, for manual end-to-end testing.

    Because status is derived from the schedule dates, there is otherwise no way
    to exercise a phase without hand-editing those dates. This back-dates the
    whole schedule around today so the derived status lands on the requested
    phase, flips the manual gates (samples shipped / reports published) to match,
    and - for any post-shipping phase - opens the result sheets so results can be
    entered. It does NOT score the round; use /publish-reports or /evaluate for
    scoring. Switched off unless ENABLE_DEV_TOOLS is enabled.
    """
    if not DEV_TOOLS_ENABLED:
        raise HTTPException(
            status_code=403,
            detail="The phase-jump testing endpoint is disabled on this environment",
        )

    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()
    if not ptcycle:
        raise HTTPException(status_code=404, detail=f"Unable to find PT Cycle with id '{id}'")

    user = await _get_admin_user(db, change.user_id)

    phase = change.pt_cyle_status_id
    if phase not in _DEV_PHASE_OFFSETS:
        raise HTTPException(
            status_code=400,
            detail=(
                "Unknown phase. Choose one of: "
                + ", ".join(
                    f"{pid}={assist.PT_CYCLE_STATUS_NAMES[pid]}"
                    for pid in _DEV_PHASE_OFFSETS
                )
            ),
        )

    _apply_dev_phase(ptcycle, phase)
    ptcycle.updated_by = user.email
    cycle_id = ptcycle.id  # keep a handle; attributes expire after commit

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to set the PT Cycle phase: {e}")

    # from shipping onward there should be result sheets to enter against; open
    # any that are missing, but do not fail the phase jump if there are none yet
    enrollment_count = result_count = 0
    sheet_note = ""
    if phase >= assist.PT_CYCLE_SAMPLES_SHIPPED:
        result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == cycle_id))
        fresh = result.scalar_one_or_none()
        try:
            enrollment_count, result_count = await _ship_samples(db, fresh, user)
            await db.commit()
            sheet_note = (
                f" {result_count} result sheet(s) opened across "
                f"{enrollment_count} enrolment(s)."
            )
        except HTTPException as e:
            await db.rollback()
            sheet_note = f" No result sheets opened: {e.detail}"

    return PTCycleStatusChangeResult(
        succeeded=True,
        message=(
            f"PT Cycle moved to '{assist.PT_CYCLE_STATUS_NAMES[phase]}'."
            + sheet_note
        ),
        pt_cycle_id=cycle_id,
        pt_cyle_status_id=phase,
        enrollment_count=enrollment_count,
        result_count=result_count,
    )


# --------------------------------------------------------------------------
# Documents and reminders
# --------------------------------------------------------------------------
@router.put("/extend/{id}", response_model=PTCycleExtendResult)
async def extend_ptcycle_date(
    id: int, param: ParamPTCycleExtend, db: AsyncSession = Depends(get_db)
):
    """Extend a round's enrollment closing or result submission due date.

    Moving the date forward re-opens the window (gating is derived live from the
    dates). Every enrolled laboratory is notified - including those that have
    already finished - and the change is written to the extension audit trail.
    """
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()
    if not ptcycle:
        raise HTTPException(status_code=404, detail=f"Unable to find PT Cycle with id '{id}'")

    user = await _get_admin_user(db, param.user_id)

    label = EXTENDABLE_DATE_FIELDS.get(param.field)
    if not label:
        raise HTTPException(
            status_code=400,
            detail=f"Only these dates can be extended: {', '.join(EXTENDABLE_DATE_FIELDS)}",
        )
    if ptcycle.status_id != assist.STATUS_APPROVED:
        raise HTTPException(status_code=400, detail="The PT Cycle must be approved first")
    if ptcycle.reports_published:
        raise HTTPException(
            status_code=400,
            detail="Reports are already published, so dates can no longer be extended",
        )

    old = getattr(ptcycle, param.field)
    new = param.new_date
    if old and new <= old:
        raise HTTPException(
            status_code=400,
            detail=f"The new date must be later than the current one ({old:%d %b %Y})",
        )

    # keep the schedule in order
    if param.field == "closing_date":
        if ptcycle.effective_date and new < ptcycle.effective_date:
            raise HTTPException(status_code=400, detail="Closing cannot be before enrollment opens")
        if ptcycle.shipping_date and new > ptcycle.shipping_date:
            raise HTTPException(
                status_code=400,
                detail="Closing cannot be after the sample shipping date - adjust shipping first",
            )
    else:  # result_submission_due_date
        if ptcycle.test_event_stop_date and new < ptcycle.test_event_stop_date:
            raise HTTPException(status_code=400, detail="The due date cannot be before the test event ends")
        if ptcycle.reports_availability_date and new > ptcycle.reports_availability_date:
            raise HTTPException(
                status_code=400,
                detail="The due date cannot be after the report availability date - adjust that first",
            )

    setattr(ptcycle, param.field, new)
    ptcycle.updated_by = user.email
    _recompute_status(ptcycle)

    # notify every enrolled laboratory, finished or not
    rows = (
        await db.execute(
            text(
                "SELECT DISTINCT l.name, l.email_address FROM laboratorys l "
                "JOIN enrollments e ON e.lab_id = l.id "
                "WHERE e.pt_cycle_id = :c AND l.email_address IS NOT NULL"
            ),
            {"c": ptcycle.id},
        )
    ).all()
    recipients = [(r[0], r[1]) for r in rows if r[1]]
    await _notify_extension(ptcycle, label, old, new, param.reason, recipients)

    db.add(
        PTCycleExtensionDB(
            pt_cycle_id=ptcycle.id,
            field=param.field,
            field_label=label,
            old_value=old,
            new_value=new,
            reason=param.reason,
            recipients_notified=len(recipients),
            extended_by=user.email,
        )
    )

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not extend the date: {e}")

    return PTCycleExtendResult(
        succeeded=True,
        message=(
            f"{label} extended to {new:%d %b %Y}. {len(recipients)} laboratory(ies) "
            f"were notified."
        ),
        pt_cycle_id=ptcycle.id,
        field=param.field,
        new_date=new,
        recipients_notified=len(recipients),
    )


async def _notify_extension(cycle, label, old, new, reason, recipients):
    old_text = f"{old:%d %b %Y}" if old else "(not set)"
    reason_text = f"\n\nReason: {reason}" if reason else ""
    subject = f"Date extended: {cycle.name}"
    for name, email in recipients:
        try:
            await mailer.send_email(
                email,
                subject,
                (
                    f"Dear {name},\n\n"
                    f"For the round '{cycle.name}', the {label} has been extended "
                    f"from {old_text} to {new:%d %b %Y}.{reason_text}\n\n"
                    f"If you have already completed your tasks, no further action is "
                    f"needed.\n"
                ),
                f"<p>Dear {name},</p><p>For the round <strong>{cycle.name}</strong>, "
                f"the <strong>{label}</strong> has been extended from {old_text} to "
                f"<strong>{new:%d %b %Y}</strong>.{('<br>Reason: ' + reason) if reason else ''}</p>"
                f"<p>If you have already completed your tasks, no further action is needed.</p>",
            )
        except Exception as e:  # pragma: no cover - mail server dependent
            print(f"[pt-cycle extension] could not email {email}: {e}")


@router.get("/extensions/{id}", response_model=List[PTCycleExtension])
async def list_ptcycle_extensions(id: int, db: AsyncSession = Depends(get_db)):
    """The audit trail of date extensions for a round, newest first."""
    result = await db.execute(
        select(PTCycleExtensionDB)
        .where(PTCycleExtensionDB.pt_cycle_id == id)
        .order_by(PTCycleExtensionDB.extended_at.desc())
    )
    return result.scalars().all()


# result tables that hold a cycle's sample result sheets
_RESULT_TABLES = [
    "tb_xpert_ultra_results",
    "tb_xpert_xdr_results",
    "hiv_vl_results",
    "hiv_eid_results",
    "bacteriology_results",
]


def _progress_status(total: int, entered: int) -> str:
    if total == 0 or entered == 0:
        return "not_started"
    if entered >= total:
        return "complete"
    return "in_progress"


@router.get("/statistics/{id}")
async def ptcycle_statistics(id: int, db: AsyncSession = Depends(get_db)):
    """Quick progress stats for a round: samples entered vs total, overall
    completion, and a per-lab breakdown - with a status (not_started /
    in_progress / complete) for colour coding. Used by scheme coordinators and
    administrators."""
    ptcycle = (
        await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ).scalars().first()
    if not ptcycle:
        raise HTTPException(status_code=404, detail=f"Unable to find PT Cycle with id '{id}'")

    per_lab = {}  # lab_id -> [total, entered]
    total = 0
    entered = 0
    for table in _RESULT_TABLES:
        rows = (
            await db.execute(
                text(
                    f"SELECT lab_id, count(*) AS total, "
                    f"count(*) FILTER (WHERE status_id IN (:sub, :app)) AS entered "
                    f"FROM {table} WHERE pt_cycle_id = :c GROUP BY lab_id"
                ),
                {"c": id, "sub": assist.STATUS_SUBMITTED, "app": assist.STATUS_APPROVED},
            )
        ).all()
        for lab_id, t, e in rows:
            agg = per_lab.setdefault(lab_id, [0, 0])
            agg[0] += t
            agg[1] += e
            total += t
            entered += e

    names = {}
    if per_lab:
        nrows = (
            await db.execute(
                text("SELECT id, name, code FROM laboratorys WHERE id = ANY(:ids)"),
                {"ids": list(per_lab)},
            )
        ).all()
        names = {i: (n, c) for i, n, c in nrows}

    labs = []
    for lab_id, (t, e) in per_lab.items():
        name, code = names.get(lab_id, (f"Lab {lab_id}", None))
        labs.append(
            {
                "lab_id": lab_id,
                "lab_name": name,
                "lab_code": code,
                "total": t,
                "entered": e,
                "pending": t - e,
                "completion_pct": round(e / t * 100) if t else 0,
                "status": _progress_status(t, e),
            }
        )
    labs.sort(key=lambda x: x["lab_name"] or "")

    return {
        "pt_cycle_id": id,
        "total": total,
        "entered": entered,
        "pending": total - entered,
        "completion_pct": round(entered / total * 100) if total else 0,
        "status": _progress_status(total, entered),
        "lab_count": len(labs),
        "labs_complete": sum(1 for l in labs if l["status"] == "complete"),
        "labs": labs,
    }


@router.get("/documents/{id}", response_model=List[Attachment])
async def list_ptcycle_documents(id: int, db: AsyncSession = Depends(get_db)):
    """Documents attached to a round (instructions, resources). Uploaded via
    /attachments/create/type/PTCycleDocument/parent/{id}."""
    result = await db.execute(
        select(AttachmentDB)
        .where(AttachmentDB.type == "PTCycleDocument", AttachmentDB.parent == id)
        .order_by(AttachmentDB.id)
    )
    return result.scalars().all()


async def run_pt_cycle_reminders(db: AsyncSession, dry_run: bool = False, as_of=None):
    """Send any date reminders that fall due today, and refresh cached statuses.

    Idempotent: each (cycle, date, lead) reminder is recorded once in
    pt_cycle_reminders and never sent again. Enrolment-opening reminders go to
    every approved lab in the scheme; all other dates go to the enrolled labs.

    dry_run=True previews without side effects: it computes exactly what would
    be sent (and to whom - recipient emails are added to each detail line) but
    sends no email, records nothing, and rolls back, so a later real run still
    sends everything. Use it to see what a run would do before firing it.

    as_of (a date) evaluates the run as if that were today, to preview a future
    day's reminders - e.g. what tomorrow's 07:00 job will send. It is honoured
    ONLY together with dry_run; a real run always uses the real clock, so it can
    never record a future date's reminders and silently suppress the real send.
    """
    today = as_of if (dry_run and as_of) else assist.get_current_date().date()
    details = []
    sent = 0

    cycles = (
        await db.execute(
            select(PTCycleDB).where(PTCycleDB.status_id == assist.STATUS_APPROVED)
        )
    ).scalars().all()

    for cycle in cycles:
        # keep the cached status fresh while we are here
        new_status = assist.compute_pt_cycle_status(cycle, today)
        if cycle.pt_cyle_status_id != new_status:
            cycle.pt_cyle_status_id = new_status

        for field in assist.PT_CYCLE_REMINDER_FIELDS:
            when = getattr(cycle, field, None)
            if not when:
                continue
            for lead in assist.PT_CYCLE_REMINDER_LEAD_DAYS:
                if when - timedelta(days=lead) != today:
                    continue
                key = f"{field}:{lead}"
                already = (
                    await db.execute(
                        text(
                            "SELECT 1 FROM pt_cycle_reminders "
                            "WHERE pt_cycle_id=:c AND reminder_key=:k"
                        ),
                        {"c": cycle.id, "k": key},
                    )
                ).first()
                if already:
                    continue

                recipients = await _reminder_recipients(db, cycle, field)
                if not dry_run:
                    await _send_reminders(cycle, field, lead, when, recipients)
                    await db.execute(
                        text(
                            "INSERT INTO pt_cycle_reminders (pt_cycle_id, reminder_key, recipients) "
                            "VALUES (:c, :k, :n)"
                        ),
                        {"c": cycle.id, "k": key, "n": len(recipients)},
                    )
                sent += 1
                line = f"{cycle.name}: {field} (-{lead}d) -> {len(recipients)} lab(s)"
                if dry_run and recipients:
                    line += " [" + ", ".join(recipients) + "]"
                details.append(line)

    # a preview leaves no trace: discard the status refresh too, so nothing is
    # committed and the next real run still sends everything
    if dry_run:
        await db.rollback()
    else:
        await db.commit()
    return PTCycleReminderResult(
        succeeded=True, cycles_checked=len(cycles), reminders_sent=sent, details=details
    )


async def _reminder_recipients(db: AsyncSession, cycle: PTCycleDB, field: str):
    """Email addresses to remind for a given date field."""
    if field == "effective_date":
        # enrolment opening: every approved lab in the scheme (they can't enrol yet)
        rows = (
            await db.execute(
                text(
                    "SELECT DISTINCT l.email_address FROM laboratorys l "
                    "JOIN applications a ON a.lab_id = l.id "
                    "WHERE a.scheme_id = :s AND a.status_id = :approved "
                    "AND l.email_address IS NOT NULL"
                ),
                {"s": cycle.scheme_id, "approved": assist.STATUS_APPROVED},
            )
        ).all()
    else:
        # everything else: the labs enrolled in this cycle
        rows = (
            await db.execute(
                text(
                    "SELECT DISTINCT l.email_address FROM laboratorys l "
                    "JOIN enrollments e ON e.lab_id = l.id "
                    "WHERE e.pt_cycle_id = :c AND l.email_address IS NOT NULL"
                ),
                {"c": cycle.id},
            )
        ).all()
    return [r[0] for r in rows if r[0]]


_REMINDER_LABELS = {
    "effective_date": "enrollment opens",
    "closing_date": "enrollment closes",
    "shipping_date": "samples ship",
    "test_event_start_date": "the test event starts",
    "result_submission_due_date": "results are due",
    "reports_availability_date": "reports become available",
}


async def _send_reminders(cycle, field, lead, when, recipients):
    label = _REMINDER_LABELS.get(field, field)
    subject = f"Reminder: {cycle.name} - {label} on {when:%d %b %Y}"
    for email in recipients:
        try:
            await mailer.send_email(
                email,
                subject,
                (
                    f"This is a reminder that for the round '{cycle.name}', "
                    f"{label} on {when:%d %b %Y} ({lead} day(s) from now).\n"
                ),
                f"<p>This is a reminder that for the round <strong>{cycle.name}</strong>, "
                f"{label} on <strong>{when:%d %b %Y}</strong> ({lead} day(s) from now).</p>",
            )
        except Exception as e:  # pragma: no cover - mail server dependent
            print(f"[pt-cycle reminder] could not email {email}: {e}")


@router.post("/run-reminders", response_model=PTCycleReminderResult)
async def trigger_pt_cycle_reminders(db: AsyncSession = Depends(get_db)):
    """Send due reminders now. Also run daily by the in-app scheduler."""
    return await run_pt_cycle_reminders(db)


@router.get("/open/{lab_id}", response_model=List[PTCycleWithDetail])
async def list_open_ptcycles(lab_id: int, db: AsyncSession = Depends(get_db)):
    """Lists the cycles a laboratory may still enrol in.

    A cycle qualifies when it is approved, open for enrolment, still inside its
    closing date, runs a scheme the lab holds an approved application for, and
    the lab has not already enrolled.
    """
    result = await db.execute(
        select(ApplicationsDB.scheme_id).where(
            ApplicationsDB.lab_id == lab_id,
            ApplicationsDB.status_id == assist.STATUS_APPROVED,
        )
    )
    scheme_ids = {value for value in result.scalars().all()}

    if not scheme_ids:
        return []

    result = await db.execute(
        select(EnrollmentDB.pt_cycle_id).where(EnrollmentDB.lab_id == lab_id)
    )
    enrolled_cycle_ids = {value for value in result.scalars().all()}

    today = assist.get_current_date().date()
    query = (
        _ptcycle_query()
        .where(
            PTCycleDB.scheme_id.in_(scheme_ids),
            PTCycleDB.status_id == assist.STATUS_APPROVED,
            # enrolment is open (live from dates): opened, not yet closed, not shipped
            PTCycleDB.samples_shipped == False,
            PTCycleDB.effective_date <= today,
            PTCycleDB.closing_date >= today,
        )
        .order_by(PTCycleDB.closing_date)
    )

    if enrolled_cycle_ids:
        query = query.where(PTCycleDB.id.notin_(enrolled_cycle_ids))

    result = await db.execute(query)
    return result.scalars().all()


async def _get_admin_user(db: AsyncSession, user_id: int) -> UserDB:
    """Loads the acting user and checks they may administer a cycle"""
    result = await db.execute(select(UserDB).where(UserDB.id == user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{user_id}' does not exist",
        )

    if not assist.is_admin_role(user.role_id):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to change the status of a PT Cycle",
        )

    return user


async def _ship_samples(db: AsyncSession, ptcycle: PTCycleDB, user: UserDB):
    """Opens a result sheet for every sample of every accepted enrolment.

    Which sheet depends on the method: each method declares the result form its
    participants fill in, and a method whose form has not been built yet is
    skipped rather than being given the wrong one.

    Re-running this is safe: a sheet that already exists is left alone, so an
    enrolment accepted late still picks up its samples on the next attempt.
    """
    result = await db.execute(
        select(EnrollmentDB).options(
            selectinload(EnrollmentDB.laboratory),
        ).where(
            EnrollmentDB.pt_cycle_id == ptcycle.id,
            EnrollmentDB.status_id == assist.STATUS_APPROVED,
        )
    )
    enrollments = result.scalars().all()

    if not enrollments:
        raise HTTPException(
            status_code=400,
            detail=(
                "There are no accepted enrolments for this PT Cycle, so there is "
                "nothing to ship. Accept at least one enrolment first."
            ),
        )

    # the form each enrolled method is captured on
    result = await db.execute(
        select(MethodDB.id, MethodDB.result_form).where(
            MethodDB.id.in_({e.method_id for e in enrollments})
        )
    )
    form_by_method = {id: form for id, form in result.all()}

    enrollments = [
        e for e in enrollments
        if form_by_method.get(e.method_id) in RESULT_MODEL_BY_FORM
    ]

    if not enrollments:
        raise HTTPException(
            status_code=400,
            detail=(
                "None of the accepted enrolments for this PT Cycle use a method "
                "with a result form, so no result sheets can be opened."
            ),
        )

    # the samples that make up the panel for each enrolled method
    method_ids = {enrollment.method_id for enrollment in enrollments}
    result = await db.execute(
        select(MethodSampleDB)
        .where(
            MethodSampleDB.method_id.in_(method_ids),
            MethodSampleDB.status_id == assist.STATUS_APPROVED,
        )
        .order_by(MethodSampleDB.name)
    )
    samples_by_method = {}
    for sample in result.scalars().all():
        samples_by_method.setdefault(sample.method_id, []).append(sample)

    # what has already been opened, so a repeat run does not duplicate
    existing = {}
    for form, model in RESULT_MODEL_BY_FORM.items():
        result = await db.execute(
            select(model.lab_id, model.method_sample_id)
            .where(model.pt_cycle_id == ptcycle.id)
        )
        existing[form] = {(lab_id, sample_id) for lab_id, sample_id in result.all()}

    result_count = 0

    for enrollment in enrollments:
        form = form_by_method[enrollment.method_id]
        model = RESULT_MODEL_BY_FORM[form]
        samples = samples_by_method.get(enrollment.method_id, [])

        if not samples:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"The method enrolled by '{enrollment.laboratory.name}' has no "
                    "approved method samples, so no panel can be shipped. Add the "
                    "samples for the method first."
                ),
            )

        for sample in samples:
            if (enrollment.lab_id, sample.id) in existing[form]:
                continue

            db.add(
                model(
                    name=f"{sample.name} - {enrollment.laboratory.name}",
                    description=(
                        f"{ptcycle.name} panel sample {sample.name} for "
                        f"{enrollment.laboratory.name}"
                    ),
                    # properties
                    scheme_id=enrollment.scheme_id,
                    lab_id=enrollment.lab_id,
                    service_id=enrollment.service_id,
                    enrollment_id=enrollment.id,
                    pt_cycle_id=ptcycle.id,
                    method_id=enrollment.method_id,
                    method_sample_id=sample.id,
                    # approval - the lab has not entered anything yet
                    user_id=enrollment.user_id,
                    status_id=assist.STATUS_DRAFT,
                    stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
                    approval_levels=1,
                    # service
                    created_by=user.email,
                )
            )
            existing[form].add((enrollment.lab_id, sample.id))
            result_count += 1

    return len(enrollments), result_count



@router.get("/id/{id}", response_model=ParamPTCycleEdit)
async def get_ptcycle(id: int, db: AsyncSession = Depends(get_db)):
    ptcycleItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(PTCycleDB
            ).options(
                selectinload(PTCycleDB.stage),
                selectinload(PTCycleDB.status),
                selectinload(PTCycleDB.user),
                
                selectinload(PTCycleDB.scheme),
                selectinload(PTCycleDB.ptcyclestatus),
            )
            .filter(PTCycleDB.id == id)
        )
        ptcycleItem = result.scalars().first()
        if not ptcycleItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'PT Cycle with id '{id}' not found"
            )

    # get supporting models if available

    # Scheme
    result = await db.execute(
        select(SchemeDB)
        .order_by(SchemeDB.name)
    )
    schemeItems =  result.scalars().all()

    # PT Cycle Status
    result = await db.execute(
        select(PTCycleStatusDB)
        .order_by(PTCycleStatusDB.name)
    )
    ptcyclestatusItems =  result.scalars().all()


    res = ParamPTCycleEdit(
            ptcycle=ptcycleItem,
            schemeList = schemeItems,
            ptcyclestatusList = ptcyclestatusItems,
    )

    return res


@router.put("/review-update/{id}", response_model=PTCycle)
async def review_posting(
    id: int, review: Review, db: AsyncSession = Depends(get_db)
):
    # check user exists
    result = await db.execute(select(UserDB).where(UserDB.id == review.user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{review.user_id}' does not exist",
        )

    # check if item exists
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()

    if not ptcycle:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle with id '{id}' not found",
        )

    if ptcycle.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The PT Cycle with id '{id}' has already been approved",
        )

    ptcycle.updated_by = user.email

    approvePTCycle = False

    if ptcycle.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if ptcycle.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a PT Cycle you created",
        )

        ptcycle.review1_at = assist.get_current_date(False)
        ptcycle.review1_by = user.email
        ptcycle.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcycle.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcycle.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve ptcycle
                approvePTCycle = True

            elif ptcycle.approval_levels == 2 or ptcycle.approval_levels == 3:
                # two or three levels, move to primary

                ptcycle.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif ptcycle.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if ptcycle.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        ptcycle.review2_at = assist.get_current_date(False)
        ptcycle.review2_by = user.email
        ptcycle.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcycle.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcycle.approval_levels == 2:
                # two levels, no furthur stage approvers

                approvePTCycle = True

            elif ptcycle.approval_levels == 3:
                # three levels, move to secondary
                ptcycle.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif ptcycle.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if ptcycle.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        ptcycle.review3_at = assist.get_current_date(False)
        ptcycle.review3_by = user.email
        ptcycle.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcycle.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approvePTCycle = True

    if approvePTCycle:
        # change ptcycle status
        ptcycle.status_id = assist.STATUS_APPROVED
        ptcycle.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(ptcycle)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle: {e}")
    return ptcycle




@router.put("/evaluate/{id}", response_model=EvaluateCycleResult)
async def evaluate_ptcycle(
    id: int, request: ParamEvaluateCycle, db: AsyncSession = Depends(get_db)
):
    """Scores a round and freezes what it concluded.

    This normally runs by itself when the cycle moves to 'Report Available'.
    It is exposed separately so a round can be re-scored after a correction -
    which rewrites reports that have already been issued, so it has to be
    asked for explicitly.
    """
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()

    if not ptcycle:
        raise HTTPException(
            status_code=404, detail=f"Unable to find PT Cycle with id '{id}'"
        )

    user = await _get_admin_user(db, request.user_id)

    if ptcycle.pt_cyle_status_id < assist.PT_CYCLE_SAMPLES_SHIPPED:
        raise HTTPException(
            status_code=400,
            detail=(
                "The samples for this PT Cycle have not been shipped yet, so "
                "there is nothing to score"
            ),
        )

    already = await evaluation.cycle_is_evaluated(db, ptcycle)

    if already and not request.recompute:
        raise HTTPException(
            status_code=400,
            detail=(
                "This PT Cycle has already been scored. Re-scoring changes "
                "reports that have already been issued, so send recompute=true "
                "if that is what you intend."
            ),
        )

    if already:
        await evaluation.clear_cycle_evaluation(db, ptcycle)

    stats, evals, performances = await evaluation.evaluate_cycle(db, ptcycle, user)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to score the PT Cycle: {e}"
        )

    return EvaluateCycleResult(
        succeeded=True,
        message=(
            f"{evals} result(s) were scored against {stats} sample statistic(s), "
            f"giving {performances} participant report(s)"
        ),
        pt_cycle_id=ptcycle.id,
        sample_statistics=stats,
        result_evaluations=evals,
        enrollment_performances=performances,
    )
