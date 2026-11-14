from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from helpers.auth import get_current_user, CurrentUser
from models.bacteriologyresult_model import (
    ANTIBIOTIC_SUGGESTIONS,
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
from models.review_model import Review
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
        date_submitted=bacteriologyresult.date_submitted,
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

    if bacteriologyresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This result has been approved and can no longer be changed",
        )

    cycle_status = bacteriologyresult.ptcycle.pt_cyle_status_id
    if cycle_status not in assist.PT_CYCLE_RESULT_CAPTURE_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    if not bacteriologyresult.enrollment.samples_received_at:
        raise HTTPException(
            status_code=400,
            detail=(
                "Please confirm you have received the samples for this enrolment "
                "before capturing results"
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


@router.put("/review-update/{id}", response_model=BacteriologyResult)
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
    result = await db.execute(
        select(BacteriologyResultDB)
        .options(selectinload(BacteriologyResultDB.astresult))
        .where(BacteriologyResultDB.id == id)
    )
    bacteriologyresult = result.scalar_one_or_none()

    if not bacteriologyresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Bacteriology Result with id '{id}' not found",
        )

    if bacteriologyresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Bacteriology Result with id '{id}' has already been approved",
        )

    bacteriologyresult.updated_by = user.email

    approveBacteriologyResult = False

    if bacteriologyresult.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage

        if bacteriologyresult.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Bacteriology Result you created",
        )

        bacteriologyresult.review1_at = assist.get_current_date(False)
        bacteriologyresult.review1_by = user.email
        bacteriologyresult.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            bacteriologyresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if bacteriologyresult.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve bacteriologyresult
                approveBacteriologyResult = True

            elif bacteriologyresult.approval_levels == 2 or bacteriologyresult.approval_levels == 3:
                # two or three levels, move to primary

                bacteriologyresult.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif bacteriologyresult.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage

        if bacteriologyresult.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        bacteriologyresult.review2_at = assist.get_current_date(False)
        bacteriologyresult.review2_by = user.email
        bacteriologyresult.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            bacteriologyresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if bacteriologyresult.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveBacteriologyResult = True

            elif bacteriologyresult.approval_levels == 3:
                # three levels, move to secondary
                bacteriologyresult.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif bacteriologyresult.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage

        if bacteriologyresult.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        bacteriologyresult.review3_at = assist.get_current_date(False)
        bacteriologyresult.review3_by = user.email
        bacteriologyresult.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            bacteriologyresult.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveBacteriologyResult = True

    if approveBacteriologyResult:
        # change bacteriologyresult status
        bacteriologyresult.status_id = assist.STATUS_APPROVED
        bacteriologyresult.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Bacteriology Result: {e}")
    return await _reload(db, id)
