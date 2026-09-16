from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.hiveidresult_model import (
    HIV_RESULT_VALUES,
    OPTIONAL_VALUE_MAX,
    OPTIONAL_VALUE_MIN,
    PANEL_FIELDS,
    PANEL_LABELS,
    RESULT_REPORTED_VALUES,
    HIVEIDResult,
    HIVEIDResultWithDetail,
    ParamHIVEIDResultEdit,
    HIVEIDResultDB,
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

router = APIRouter(prefix="/hiv-eid-results", tags=["HIVEIDResults"])


@router.post("/create", response_model=HIVEIDResult)
async def post_hiveidresult(hiveidresult: HIVEIDResult, db: AsyncSession = Depends(get_db)):


    db_context = HIVEIDResultDB(
        # update
        name=hiveidresult.name,
        description=hiveidresult.description,
        # properties
        scheme_id=hiveidresult.scheme_id,
        lab_id=hiveidresult.lab_id,
        service_id=hiveidresult.service_id,
        enrollment_id=hiveidresult.enrollment_id,
        pt_cycle_id=hiveidresult.pt_cycle_id,
        method_id=hiveidresult.method_id,
        method_sample_id=hiveidresult.method_sample_id,
        date_panel_received=hiveidresult.date_panel_received,
        date_tested=hiveidresult.date_tested,
        detection_assay=hiveidresult.detection_assay,
        extraction_assay=hiveidresult.extraction_assay,
        assay_serial_number=hiveidresult.assay_serial_number,
        result_reported=hiveidresult.result_reported,
        hiv_result=hiveidresult.hiv_result,
        hiv_ct_od_value=hiveidresult.hiv_ct_od_value,
        ic_qs_value=hiveidresult.ic_qs_value,
        not_tested_reason=hiveidresult.not_tested_reason,
        tested_by=hiveidresult.tested_by,
        supervisor_name=hiveidresult.supervisor_name,
        # approval
        user_id=hiveidresult.user_id,
        status_id=hiveidresult.status_id,
        stage_id=hiveidresult.stage_id,
        approval_levels=hiveidresult.approval_levels,
        # service
        created_by=hiveidresult.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create HIV-1 EID Result: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = HIVEIDResultDB(
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
            status_code=400, detail=f"Unable to initialize items for HIV-1 EID Result: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for HIV-1 EID Result have been successfully initialized",
    }




@router.get("/cycles")
async def list_cycles_with_results(
    lab_id: Optional[int] = Query(
        default=None, description="Only rounds this laboratory has sheets for"
    ),
    db: AsyncSession = Depends(get_db),
):
    """The rounds a HIV-1 EID listing can be opened on, newest first."""
    return await resultquery.cycles_with_results(db, HIVEIDResultDB, lab_id=lab_id)


def _result_query():
    """The result query every listing shares, with its detail loaded"""
    return (
        select(HIVEIDResultDB)
        .options(
            selectinload(HIVEIDResultDB.stage),
            selectinload(HIVEIDResultDB.status),
            selectinload(HIVEIDResultDB.user),

            selectinload(HIVEIDResultDB.scheme),
            selectinload(HIVEIDResultDB.laboratory),
            selectinload(HIVEIDResultDB.service),
            selectinload(HIVEIDResultDB.enrollment),
            selectinload(HIVEIDResultDB.ptcycle),
            selectinload(HIVEIDResultDB.method),
            selectinload(HIVEIDResultDB.methodsample),
        )
        .order_by(
            HIVEIDResultDB.pt_cycle_id.desc(),
            HIVEIDResultDB.lab_id,
            HIVEIDResultDB.method_sample_id,
        )
    )


@router.get("/options")
async def get_hiveidresult_options():
    """The values form TF-012 allows, so the client offers exactly these"""
    return {
        "resultReportedList": RESULT_REPORTED_VALUES,
        "hivResultList": HIV_RESULT_VALUES,
        "panelFieldList": PANEL_FIELDS,
        "panelLabels": PANEL_LABELS,
        "optionalValueMin": OPTIONAL_VALUE_MIN,
        "optionalValueMax": OPTIONAL_VALUE_MAX,
    }


@router.get("/list", response_model=List[HIVEIDResultWithDetail])
async def list_hiveidresults(
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
        query = query.where(HIVEIDResultDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(HIVEIDResultDB.lab_id == lab_id)

    if pending:
        query = query.where(
            HIVEIDResultDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/{lab_id}", response_model=List[HIVEIDResultWithDetail])
async def list_lab_hiveidresults(lab_id: int , db: AsyncSession = Depends(get_db)):
    """Lists the result sheets opened for one laboratory"""
    result = await db.execute(
        _result_query().where(HIVEIDResultDB.lab_id == lab_id)
    )
    return result.scalars().all()

# the sheet is opened by the provider when the panel ships; the lab only ever
# fills in what it read off the instrument
EDITABLE_RESULT_FIELDS = [
    "description",
    *PANEL_FIELDS,
    "result_reported",
    "hiv_result",
    "hiv_ct_od_value",
    "ic_qs_value",
    "not_tested_reason",
    "tested_by",
    "supervisor_name",
    "status_id",
    "stage_id",
]


@router.put("/update/{id}", response_model=HIVEIDResult)
async def update_hiveidresult(
    id: int, hiveidresult_update: HIVEIDResult, db: AsyncSession = Depends(get_db)
):
    """Captures the results a laboratory read off its EID platform.

    Saving with a status of Draft parks a partly captured panel; saving as
    Submitted sends it for review and is what the completeness rules on
    HIVEIDResult are checked against.
    """
    result = await db.execute(
        select(HIVEIDResultDB)
        .options(
            selectinload(HIVEIDResultDB.ptcycle),
            selectinload(HIVEIDResultDB.enrollment),
        )
        .where(HIVEIDResultDB.id == id)
    )
    hiveidresult = result.scalars().first()

    if not hiveidresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find HIV-1 EID Result with id '{id}'",
        )

    result = await db.execute(
        select(UserDB).where(UserDB.id == hiveidresult_update.user_id)
    )
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{hiveidresult_update.user_id}' does not exist",
        )

    # a lab may only touch its own result sheets
    if (
        assist.is_laboratory_role(user.role_id)
        and user.laboratory_id != hiveidresult.lab_id
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to capture results for another laboratory",
        )

    if hiveidresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This result has been approved and can no longer be changed",
        )

    cycle_status = hiveidresult.ptcycle.pt_cyle_status_id
    if cycle_status not in assist.PT_CYCLE_RESULT_CAPTURE_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    if not hiveidresult.enrollment.samples_received_at:
        raise HTTPException(
            status_code=400,
            detail=(
                "Please confirm you have received the samples for this enrolment "
                "before capturing results"
            ),
        )

    # only the result itself is editable - the panel it belongs to is not
    changes = hiveidresult_update.dict(exclude_unset=True)
    for key in EDITABLE_RESULT_FIELDS:
        if key in changes:
            setattr(hiveidresult, key, changes[key])

    hiveidresult.updated_by = user.email

    try:
        await db.commit()
        await db.refresh(hiveidresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update HIV-1 EID Result {e}")
    return hiveidresult


@router.get("/id/{id}", response_model=ParamHIVEIDResultEdit)
async def get_hiveidresult(id: int, db: AsyncSession = Depends(get_db)):
    hiveidresultItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(HIVEIDResultDB
            ).options(
                selectinload(HIVEIDResultDB.stage),
                selectinload(HIVEIDResultDB.status),
                selectinload(HIVEIDResultDB.user),
                
                selectinload(HIVEIDResultDB.scheme),
                selectinload(HIVEIDResultDB.laboratory),
                selectinload(HIVEIDResultDB.service),
                selectinload(HIVEIDResultDB.enrollment),
                selectinload(HIVEIDResultDB.ptcycle),
                selectinload(HIVEIDResultDB.method),
                selectinload(HIVEIDResultDB.methodsample),
            )
            .filter(HIVEIDResultDB.id == id)
        )
        hiveidresultItem = result.scalars().first()
        if not hiveidresultItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'HIV-1 EID Result with id '{id}' not found"
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


    res = ParamHIVEIDResultEdit(
            hiveidresult=hiveidresultItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            enrollmentList = enrollmentItems,
            ptcycleList = ptcycleItems,
            methodList = methodItems,
            methodsampleList = methodsampleItems,
    )

    return res


@router.put("/review-update/{id}", response_model=HIVEIDResult)
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
    result = await db.execute(select(HIVEIDResultDB).where(HIVEIDResultDB.id == id))
    hiveidresult = result.scalar_one_or_none()

    if not hiveidresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find HIV-1 EID Result with id '{id}' not found",
        )

    if hiveidresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The HIV-1 EID Result with id '{id}' has already been approved",
        )

    hiveidresult.updated_by = user.email

    approveHIVEIDResult = False

    if hiveidresult.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if hiveidresult.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a HIV-1 EID Result you created",
        )

        hiveidresult.review1_at = assist.get_current_date(False)
        hiveidresult.review1_by = user.email
        hiveidresult.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hiveidresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if hiveidresult.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve hiveidresult
                approveHIVEIDResult = True

            elif hiveidresult.approval_levels == 2 or hiveidresult.approval_levels == 3:
                # two or three levels, move to primary

                hiveidresult.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif hiveidresult.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if hiveidresult.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        hiveidresult.review2_at = assist.get_current_date(False)
        hiveidresult.review2_by = user.email
        hiveidresult.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hiveidresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if hiveidresult.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveHIVEIDResult = True

            elif hiveidresult.approval_levels == 3:
                # three levels, move to secondary
                hiveidresult.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif hiveidresult.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if hiveidresult.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        hiveidresult.review3_at = assist.get_current_date(False)
        hiveidresult.review3_by = user.email
        hiveidresult.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            hiveidresult.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveHIVEIDResult = True

    if approveHIVEIDResult:
        # change hiveidresult status
        hiveidresult.status_id = assist.STATUS_APPROVED
        hiveidresult.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(hiveidresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update HIV-1 EID Result: {e}")
    return hiveidresult


