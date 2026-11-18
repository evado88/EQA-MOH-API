from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from helpers.receipts import receipt_exists
from helpers.attachments import result_file_exists
from helpers.submissions import log_result_submission
from helpers.auth import get_current_user, CurrentUser
from models.bacteriologyresult_model import (
    ANTIBIOTIC_SUGGESTIONS,
    ORGANISM_CATALOGUE,
    AST_GUIDELINE_VALUES,
    AST_INTERPRETATION_LABELS,
    AST_INTERPRETATION_VALUES,
    AST_MAX_ROWS,
    AST_METHOD_LABELS,
    AST_METHOD_VALUES,
    AST_MIC_METHOD_VALUES,
    GRAM_MORPHOLOGY_VALUES,
    GRAM_STAIN_REACTION_VALUES,
    RECEIPT_FIELDS,
    RECEIPT_LABELS,
    RECEIPT_TEMPERATURE_MAX,
    RECEIPT_TEMPERATURE_MIN,
    SAMPLE_CONDITION_VALUES,
    ZONE_DIAMETER_MAX,
    ZONE_DIAMETER_MIN,
    BacteriologyASTResultDB,
    BacteriologyResult,
    BacteriologyResultWithDetail,
    ParamBacteriologyResultEdit,
    BacteriologyResultDB,
)
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from helpers import assist, resultquery
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB
from models.laboratory_model import LaboratoryDB
from models.service_model import ServiceDB
from models.enrollment_model import EnrollmentDB
from models.ptcycle_model import PTCycleDB
from models.method_model import MethodDB
from models.methodsample_model import MethodSampleDB

router = APIRouter(prefix="/bacteriology-results", tags=["BacteriologyResults"])


async def _reload(db, id):
    """Reads a worksheet back with its AST table loaded.

    A plain refresh will not do: the AST table is a relationship, and the
    worksheet is answered with it, so it has to be selected rather than
    lazily reached for on the way out.
    """
    result = await db.execute(
        select(BacteriologyResultDB)
        .options(selectinload(BacteriologyResultDB.astresult))
        .where(BacteriologyResultDB.id == id)
    )
    return result.scalars().first()


def _ast_rows(bacteriologyresult, created_by=None):
    """The worksheet's AST table, as rows ready to be written.

    The participant fills the table in as a whole, so it arrives with the
    worksheet rather than a row at a time.
    """
    return [
        BacteriologyASTResultDB(
            ast_method=row.ast_method,
            row_no=row.row_no,
            antibiotic=row.antibiotic,
            zone_diameter=row.zone_diameter,
            mic_reading=row.mic_reading,
            interpretation=row.interpretation,
            created_by=created_by,
        )
        for row in (bacteriologyresult.astresult or [])
    ]


@router.post("/create", response_model=BacteriologyResult)
async def post_bacteriologyresult(bacteriologyresult: BacteriologyResult, db: AsyncSession = Depends(get_db)):


    db_context = BacteriologyResultDB(
        # update
        name=bacteriologyresult.name,
        description=bacteriologyresult.description,
        # properties
        scheme_id=bacteriologyresult.scheme_id,
        lab_id=bacteriologyresult.lab_id,
        service_id=bacteriologyresult.service_id,
        enrollment_id=bacteriologyresult.enrollment_id,
        pt_cycle_id=bacteriologyresult.pt_cycle_id,
        method_id=bacteriologyresult.method_id,
        method_sample_id=bacteriologyresult.method_sample_id,
        date_samples_received=bacteriologyresult.date_samples_received,
        receipt_temperature=bacteriologyresult.receipt_temperature,
        sample_condition=bacteriologyresult.sample_condition,
        sample_condition_reason=bacteriologyresult.sample_condition_reason,
        date_tested=bacteriologyresult.date_tested,
        testing_not_done=bacteriologyresult.testing_not_done,
        testing_not_done_reason=bacteriologyresult.testing_not_done_reason,
        gram_stain_reaction=bacteriologyresult.gram_stain_reaction,
        gram_morphology=bacteriologyresult.gram_morphology,
        gram_morphology_other=bacteriologyresult.gram_morphology_other,
        microscopy_comment=bacteriologyresult.microscopy_comment,
        organism_identified=bacteriologyresult.organism_identified,
        identification_comment=bacteriologyresult.identification_comment,
        ast_performed=bacteriologyresult.ast_performed,
        ast_guideline=bacteriologyresult.ast_guideline,
        ast_disk_diffusion=bacteriologyresult.ast_disk_diffusion,
        ast_mic_method=bacteriologyresult.ast_mic_method,
        ast_mic_method_other=bacteriologyresult.ast_mic_method_other,
        comments=bacteriologyresult.comments,
        reported_by=bacteriologyresult.reported_by,
        reported_on=bacteriologyresult.reported_on,
        reviewed_by=bacteriologyresult.reviewed_by,
        reviewed_on=bacteriologyresult.reviewed_on,
        # the AST table
        astresult=_ast_rows(bacteriologyresult, bacteriologyresult.created_by),
        # approval
        user_id=bacteriologyresult.user_id,
        status_id=bacteriologyresult.status_id,
        stage_id=bacteriologyresult.stage_id,
        approval_levels=bacteriologyresult.approval_levels,
        # service
        created_by=bacteriologyresult.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Bacteriology Result: {e}")

    return await _reload(db, db_context.id)

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):

    itemList = []

    for value in itemList:
        db_item = BacteriologyResultDB(
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
            status_code=400, detail=f"Unable to initialize items for Bacteriology Result: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Bacteriology Result have been successfully initialized",
    }




@router.get("/cycles")
async def list_cycles_with_results(
    lab_id: Optional[int] = Query(
        default=None, description="Only rounds this laboratory has sheets for"
    ),
    db: AsyncSession = Depends(get_db),
):
    """The rounds a Bacteriology listing can be opened on, newest first."""
    return await resultquery.cycles_with_results(db, BacteriologyResultDB, lab_id=lab_id)


def _result_query():
    """The result query every listing shares, with its detail loaded"""
    return (
        select(BacteriologyResultDB)
        .options(
            selectinload(BacteriologyResultDB.stage),
            selectinload(BacteriologyResultDB.status),
            selectinload(BacteriologyResultDB.user),

            selectinload(BacteriologyResultDB.scheme),
            selectinload(BacteriologyResultDB.laboratory),
            selectinload(BacteriologyResultDB.service),
            selectinload(BacteriologyResultDB.enrollment),
            selectinload(BacteriologyResultDB.ptcycle),
            selectinload(BacteriologyResultDB.method),
            selectinload(BacteriologyResultDB.methodsample),
            # the AST table is part of the worksheet, not a separate fetch
            selectinload(BacteriologyResultDB.astresult),
        )
        .order_by(
            BacteriologyResultDB.pt_cycle_id.desc(),
            BacteriologyResultDB.lab_id,
            BacteriologyResultDB.method_sample_id,
        )
    )


@router.get("/options")
async def get_bacteriologyresult_options():
    """The values worksheet TF-NHRTI-BACT-001 allows, so the client offers exactly these"""
    return {
        "sampleConditionList": SAMPLE_CONDITION_VALUES,
        "gramStainReactionList": GRAM_STAIN_REACTION_VALUES,
        "gramMorphologyList": GRAM_MORPHOLOGY_VALUES,
        "astGuidelineList": AST_GUIDELINE_VALUES,
        "astMicMethodList": AST_MIC_METHOD_VALUES,
        "astMethodList": AST_METHOD_VALUES,
        "astMethodLabels": AST_METHOD_LABELS,
        "astInterpretationList": AST_INTERPRETATION_VALUES,
        "astInterpretationLabels": AST_INTERPRETATION_LABELS,
        # a suggestion, not a restriction - an agent outside it is accepted
        "antibioticList": ANTIBIOTIC_SUGGESTIONS,
        # the bacterial identification menu, from the master organism catalogue
        "organismList": ORGANISM_CATALOGUE,
        "astMaxRows": AST_MAX_ROWS,
        "receiptFieldList": RECEIPT_FIELDS,
        "receiptLabels": RECEIPT_LABELS,
        "receiptTemperatureMin": RECEIPT_TEMPERATURE_MIN,
        "receiptTemperatureMax": RECEIPT_TEMPERATURE_MAX,
        "zoneDiameterMin": ZONE_DIAMETER_MIN,
        "zoneDiameterMax": ZONE_DIAMETER_MAX,
    }


@router.get("/list", response_model=List[BacteriologyResultWithDetail])
async def list_bacteriologyresults(
    pt_cycle_id: Optional[int] = Query(
        default=None, description="Only return results for this cycle"
    ),
    lab_id: Optional[int] = Query(
        default=None, description="Only return results for this laboratory"
    ),
    pending: bool = Query(
        default=False, description="Only return results that still need a decision"
    ),
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_current_user),
):
    query = _result_query()

    # a scheme-team member only sees their own scheme's results
    scope = assist.scheme_scope_for(user) if user else None
    if scope is not None:
        query = query.where(BacteriologyResultDB.scheme_id == scope)

    if pt_cycle_id is not None:
        query = query.where(BacteriologyResultDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(BacteriologyResultDB.lab_id == lab_id)

    if pending:
        query = query.where(
            BacteriologyResultDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/{lab_id}", response_model=List[BacteriologyResultWithDetail])
async def list_lab_bacteriologyresults(lab_id: int , db: AsyncSession = Depends(get_db)):
    """Lists the result sheets opened for one laboratory"""
    result = await db.execute(
        _result_query().where(BacteriologyResultDB.lab_id == lab_id)
    )
    return result.scalars().all()

# the sheet is opened by the provider when the panel ships; the lab only ever
# fills in what it worked off the specimen
EDITABLE_RESULT_FIELDS = [
    "description",
    *RECEIPT_FIELDS,
    "date_tested",
    "testing_not_done",
    "testing_not_done_reason",
    "gram_stain_reaction",
    "gram_morphology",
    "gram_morphology_other",
    "microscopy_comment",
    "organism_identified",
    "identification_comment",
    "ast_performed",
    "ast_guideline",
    "ast_disk_diffusion",
    "ast_mic_method",
    "ast_mic_method_other",
    "comments",
    "reported_by",
    "reported_on",
    "reviewed_by",
    "reviewed_on",
    "status_id",
    "stage_id",
]


@router.put("/update/{id}", response_model=BacteriologyResult)
async def update_bacteriologyresult(
    id: int, bacteriologyresult_update: BacteriologyResult, db: AsyncSession = Depends(get_db)
):
    """Captures the worksheet a laboratory filled in for one specimen.

    Saving with a status of Draft parks a part worked specimen; saving as
    Submitted sends it for review and is what the completeness rules on
    BacteriologyResult are checked against.
    """
    result = await db.execute(
        select(BacteriologyResultDB)
        .options(
            selectinload(BacteriologyResultDB.ptcycle),
            selectinload(BacteriologyResultDB.enrollment),
            selectinload(BacteriologyResultDB.astresult),
        )
        .where(BacteriologyResultDB.id == id)
    )
    bacteriologyresult = result.scalars().first()

    if not bacteriologyresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Bacteriology Result with id '{id}'",
        )

    result = await db.execute(
        select(UserDB).where(UserDB.id == bacteriologyresult_update.user_id)
    )
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{bacteriologyresult_update.user_id}' does not exist",
        )

    # a lab may only touch its own result sheets
    if (
        assist.is_laboratory_role(user.role_id)
        and user.laboratory_id != bacteriologyresult.lab_id
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to capture results for another laboratory",
        )

    # result submission needs no approval; the lab may resubmit until the
    # cycle's result submission due date (enforced by pt_result_capture_open)

    cycle_status = bacteriologyresult.ptcycle.pt_cyle_status_id
    if not assist.pt_result_capture_open(bacteriologyresult.ptcycle):
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    # per-sample receipt details must be recorded before entering results
    if not await receipt_exists(db, bacteriologyresult.pt_cycle_id, bacteriologyresult.lab_id, bacteriologyresult.method_sample_id):
        raise HTTPException(
            status_code=400,
            detail=(
                "Please record this sample's receipt details (date received, "
                "condition and temperature) before entering results for it"
            ),
        )

    # the worksheet file is mandatory before the result can be submitted
    if bacteriologyresult_update.status_id == assist.STATUS_SUBMITTED and not await result_file_exists(
        db, bacteriologyresult.enrollment_id
    ):
        raise HTTPException(
            status_code=400,
            detail=(
                "Please attach the worksheet file for this panel before "
                "submitting the result"
            ),
        )

    # only the worksheet itself is editable - the panel it belongs to is not
    changes = bacteriologyresult_update.dict(exclude_unset=True)
    for key in EDITABLE_RESULT_FIELDS:
        if key in changes:
            setattr(bacteriologyresult, key, changes[key])

    # The AST table is replaced rather than merged: the participant fills the
    # whole table in at once, so a row that is no longer on the worksheet they
    # sent is a row they removed.
    if "astresult" in changes:
        bacteriologyresult.astresult = _ast_rows(
            bacteriologyresult_update, user.email
        )

    bacteriologyresult.updated_by = user.email

    # audit: record each submission (a lab may resubmit until the due date)
    if bacteriologyresult.status_id == assist.STATUS_SUBMITTED:
        await log_result_submission(db, "bacteriology", bacteriologyresult, user.email)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Bacteriology Result {e}")
    return await _reload(db, id)


@router.get("/id/{id}", response_model=ParamBacteriologyResultEdit)
async def get_bacteriologyresult(id: int, db: AsyncSession = Depends(get_db)):
    bacteriologyresultItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(BacteriologyResultDB
            ).options(
                selectinload(BacteriologyResultDB.stage),
                selectinload(BacteriologyResultDB.status),
                selectinload(BacteriologyResultDB.user),

                selectinload(BacteriologyResultDB.scheme),
                selectinload(BacteriologyResultDB.laboratory),
                selectinload(BacteriologyResultDB.service),
                selectinload(BacteriologyResultDB.enrollment),
                selectinload(BacteriologyResultDB.ptcycle),
                selectinload(BacteriologyResultDB.method),
                selectinload(BacteriologyResultDB.methodsample),
                selectinload(BacteriologyResultDB.astresult),
            )
            .filter(BacteriologyResultDB.id == id)
        )
        bacteriologyresultItem = result.scalars().first()
        if not bacteriologyresultItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Bacteriology Result with id '{id}' not found"
            )

    # get supporting models if available

    # Scheme
    result = await db.execute(
        select(SchemeDB)
        .order_by(SchemeDB.name)
    )
    schemeItems =  result.scalars().all()

    # Laboratory
    result = await db.execute(
        select(LaboratoryDB)
        .order_by(LaboratoryDB.name)
    )
    laboratoryItems =  result.scalars().all()

    # Service
    result = await db.execute(
        select(ServiceDB)
        .order_by(ServiceDB.name)
    )
    serviceItems =  result.scalars().all()

    # Enrollment
    result = await db.execute(
        select(EnrollmentDB)
        .order_by(EnrollmentDB.name)
    )
    enrollmentItems =  result.scalars().all()

    # PT Cycle
    result = await db.execute(
        select(PTCycleDB)
        .order_by(PTCycleDB.name)
    )
    ptcycleItems =  result.scalars().all()

    # Method
    result = await db.execute(
        select(MethodDB)
        .order_by(MethodDB.name)
    )
    methodItems =  result.scalars().all()

    # Method Sample
    result = await db.execute(
        select(MethodSampleDB)
        .order_by(MethodSampleDB.name)
    )
    methodsampleItems =  result.scalars().all()


    res = ParamBacteriologyResultEdit(
            bacteriologyresult=bacteriologyresultItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            enrollmentList = enrollmentItems,
            ptcycleList = ptcycleItems,
            methodList = methodItems,
            methodsampleList = methodsampleItems,
    )

    return res

