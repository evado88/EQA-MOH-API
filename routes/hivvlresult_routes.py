from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.hivvlresult_model import (
    PANEL_FIELDS,
    PANEL_LABELS,
    RESULT_REPORTED_VALUES,
    VIRAL_LOAD_MAX,
    VIRAL_LOAD_MIN,
    HIVVLResult,
    HIVVLResultWithDetail,
    ParamHIVVLResultEdit,
    HIVVLResultDB,
)
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB
from models.laboratory_model import LaboratoryDB
from models.service_model import ServiceDB
from models.enrollment_model import EnrollmentDB
from models.ptcycle_model import PTCycleDB
from models.method_model import MethodDB
from models.methodsample_model import MethodSampleDB

router = APIRouter(prefix="/hiv-vl-results", tags=["HIVVLResults"])


@router.post("/create", response_model=HIVVLResult)
async def post_hivvlresult(hivvlresult: HIVVLResult, db: AsyncSession = Depends(get_db)):


    db_context = HIVVLResultDB(
        # update
        name=hivvlresult.name,
        description=hivvlresult.description,
        # properties
        scheme_id=hivvlresult.scheme_id,
        lab_id=hivvlresult.lab_id,
        service_id=hivvlresult.service_id,
        enrollment_id=hivvlresult.enrollment_id,
        pt_cycle_id=hivvlresult.pt_cycle_id,
        method_id=hivvlresult.method_id,
        method_sample_id=hivvlresult.method_sample_id,
        date_panel_received=hivvlresult.date_panel_received,
        date_tested=hivvlresult.date_tested,
        detection_assay=hivvlresult.detection_assay,
        extraction_assay=hivvlresult.extraction_assay,
        assay_kit_lot_number=hivvlresult.assay_kit_lot_number,
        assay_kit_expiry_date=hivvlresult.assay_kit_expiry_date,
        assay_serial_number=hivvlresult.assay_serial_number,
        result_reported=hivvlresult.result_reported,
        viral_load_log10=hivvlresult.viral_load_log10,
        not_tested_reason=hivvlresult.not_tested_reason,
        tested_by=hivvlresult.tested_by,
        supervisor_name=hivvlresult.supervisor_name,
        # approval
        user_id=hivvlresult.user_id,
        status_id=hivvlresult.status_id,
        stage_id=hivvlresult.stage_id,
        approval_levels=hivvlresult.approval_levels,
        # service
        created_by=hivvlresult.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create HIV-1 Viral Load Result: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = HIVVLResultDB(
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
            status_code=400, detail=f"Unable to initialize items for HIV-1 Viral Load Result: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for HIV-1 Viral Load Result have been successfully initialized",
    }



def _result_query():
    """The result query every listing shares, with its detail loaded"""
    return (
        select(HIVVLResultDB)
        .options(
            selectinload(HIVVLResultDB.stage),
            selectinload(HIVVLResultDB.status),
            selectinload(HIVVLResultDB.user),

            selectinload(HIVVLResultDB.scheme),
            selectinload(HIVVLResultDB.laboratory),
            selectinload(HIVVLResultDB.service),
            selectinload(HIVVLResultDB.enrollment),
            selectinload(HIVVLResultDB.ptcycle),
            selectinload(HIVVLResultDB.method),
            selectinload(HIVVLResultDB.methodsample),
        )
        .order_by(
            HIVVLResultDB.pt_cycle_id.desc(),
            HIVVLResultDB.lab_id,
            HIVVLResultDB.method_sample_id,
        )
    )


@router.get("/options")
async def get_hivvlresult_options():
    """The values form TF-009 allows, so the client offers exactly these"""
    return {
        "resultReportedList": RESULT_REPORTED_VALUES,
        "panelFieldList": PANEL_FIELDS,
        "panelLabels": PANEL_LABELS,
        "viralLoadMin": VIRAL_LOAD_MIN,
        "viralLoadMax": VIRAL_LOAD_MAX,
    }


@router.get("/list", response_model=List[HIVVLResultWithDetail])
async def list_hivvlresults(
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
):
    query = _result_query()

    if pt_cycle_id is not None:
        query = query.where(HIVVLResultDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(HIVVLResultDB.lab_id == lab_id)

    if pending:
        query = query.where(
            HIVVLResultDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/{lab_id}", response_model=List[HIVVLResultWithDetail])
async def list_lab_hivvlresults(lab_id: int , db: AsyncSession = Depends(get_db)):
    """Lists the result sheets opened for one laboratory"""
    result = await db.execute(
        _result_query().where(HIVVLResultDB.lab_id == lab_id)
    )
    return result.scalars().all()

# the sheet is opened by the provider when the panel ships; the lab only ever
# fills in what it read off the instrument
EDITABLE_RESULT_FIELDS = [
    "description",
    *PANEL_FIELDS,
    "result_reported",
    "viral_load_log10",
    "not_tested_reason",
    "tested_by",
    "supervisor_name",
    "status_id",
    "stage_id",
]


@router.put("/update/{id}", response_model=HIVVLResult)
async def update_hivvlresult(
    id: int, hivvlresult_update: HIVVLResult, db: AsyncSession = Depends(get_db)
):
    """Captures the results a laboratory read off its viral load platform.

    Saving with a status of Draft parks a partly captured panel; saving as
    Submitted sends it for review and is what the completeness rules on
    HIVVLResult are checked against.
    """
    result = await db.execute(
        select(HIVVLResultDB)
        .options(
            selectinload(HIVVLResultDB.ptcycle),
            selectinload(HIVVLResultDB.enrollment),
        )
        .where(HIVVLResultDB.id == id)
    )
    hivvlresult = result.scalars().first()

    if not hivvlresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find HIV-1 Viral Load Result with id '{id}'",
        )

    result = await db.execute(
        select(UserDB).where(UserDB.id == hivvlresult_update.user_id)
    )
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{hivvlresult_update.user_id}' does not exist",
        )

    # a lab may only touch its own result sheets
    if (
        assist.is_laboratory_role(user.role_id)
        and user.laboratory_id != hivvlresult.lab_id
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to capture results for another laboratory",
        )

    if hivvlresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This result has been approved and can no longer be changed",
        )

    cycle_status = hivvlresult.ptcycle.pt_cyle_status_id
    if cycle_status not in assist.PT_CYCLE_RESULT_CAPTURE_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    if not hivvlresult.enrollment.samples_received_at:
        raise HTTPException(
            status_code=400,
            detail=(
                "Please confirm you have received the samples for this enrolment "
                "before capturing results"
            ),
        )

    # only the result itself is editable - the panel it belongs to is not
    changes = hivvlresult_update.dict(exclude_unset=True)
    for key in EDITABLE_RESULT_FIELDS:
        if key in changes:
            setattr(hivvlresult, key, changes[key])

    hivvlresult.updated_by = user.email

    try:
        await db.commit()
        await db.refresh(hivvlresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update HIV-1 Viral Load Result {e}")
    return hivvlresult


@router.get("/id/{id}", response_model=ParamHIVVLResultEdit)
async def get_hivvlresult(id: int, db: AsyncSession = Depends(get_db)):
    hivvlresultItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(HIVVLResultDB
            ).options(
                selectinload(HIVVLResultDB.stage),
                selectinload(HIVVLResultDB.status),
                selectinload(HIVVLResultDB.user),
                
                selectinload(HIVVLResultDB.scheme),
                selectinload(HIVVLResultDB.laboratory),
                selectinload(HIVVLResultDB.service),
                selectinload(HIVVLResultDB.enrollment),
                selectinload(HIVVLResultDB.ptcycle),
                selectinload(HIVVLResultDB.method),
                selectinload(HIVVLResultDB.methodsample),
            )
            .filter(HIVVLResultDB.id == id)
        )
        hivvlresultItem = result.scalars().first()
        if not hivvlresultItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'HIV-1 Viral Load Result with id '{id}' not found"
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


    res = ParamHIVVLResultEdit(
            hivvlresult=hivvlresultItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            enrollmentList = enrollmentItems,
            ptcycleList = ptcycleItems,
            methodList = methodItems,
            methodsampleList = methodsampleItems,
    )

    return res


@router.put("/review-update/{id}", response_model=HIVVLResult)
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
    result = await db.execute(select(HIVVLResultDB).where(HIVVLResultDB.id == id))
    hivvlresult = result.scalar_one_or_none()

    if not hivvlresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find HIV-1 Viral Load Result with id '{id}' not found",
        )

    if hivvlresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The HIV-1 Viral Load Result with id '{id}' has already been approved",
        )

    hivvlresult.updated_by = user.email

    approveHIVVLResult = False

    if hivvlresult.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if hivvlresult.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a HIV-1 Viral Load Result you created",
        )

        hivvlresult.review1_at = assist.get_current_date(False)
        hivvlresult.review1_by = user.email
        hivvlresult.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hivvlresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if hivvlresult.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve hivvlresult
                approveHIVVLResult = True

            elif hivvlresult.approval_levels == 2 or hivvlresult.approval_levels == 3:
                # two or three levels, move to primary

                hivvlresult.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif hivvlresult.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if hivvlresult.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        hivvlresult.review2_at = assist.get_current_date(False)
        hivvlresult.review2_by = user.email
        hivvlresult.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hivvlresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if hivvlresult.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveHIVVLResult = True

            elif hivvlresult.approval_levels == 3:
                # three levels, move to secondary
                hivvlresult.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif hivvlresult.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if hivvlresult.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        hivvlresult.review3_at = assist.get_current_date(False)
        hivvlresult.review3_by = user.email
        hivvlresult.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hivvlresult.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveHIVVLResult = True

    if approveHIVVLResult:
        # change hivvlresult status
        hivvlresult.status_id = assist.STATUS_APPROVED
        hivvlresult.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(hivvlresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update HIV-1 Viral Load Result: {e}")
    return hivvlresult


