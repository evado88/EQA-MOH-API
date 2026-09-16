from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.tbxpertultraresult_model import (
    CT_VALUE_FIELDS,
    CT_VALUE_LABELS,
    RESULT_INTERPRETABLE_VALUES,
    RIF_RESULT_VALUES,
    TB_DETECTION_RESULT_VALUES,
    UNINTERPRETABLE_RESULT_REQUIRING_CODE,
    UNINTERPRETABLE_RESULT_VALUES,
    TBXpertUltraResult,
    TBXpertUltraResultWithDetail,
    ParamTBXpertUltraResultEdit,
    TBXpertUltraResultDB,
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

router = APIRouter(prefix="/tb-xpert-ultra-results", tags=["TBXpertUltraResults"])


@router.post("/create", response_model=TBXpertUltraResult)
async def post_tbxpertultraresult(tbxpertultraresult: TBXpertUltraResult, db: AsyncSession = Depends(get_db)):


    db_context = TBXpertUltraResultDB(
        # update
        name=tbxpertultraresult.name,
        description=tbxpertultraresult.description,
        # properties
        scheme_id=tbxpertultraresult.scheme_id,
        lab_id=tbxpertultraresult.lab_id,
        service_id=tbxpertultraresult.service_id,
        enrollment_id=tbxpertultraresult.enrollment_id,
        pt_cycle_id=tbxpertultraresult.pt_cycle_id,
        method_id=tbxpertultraresult.method_id,
        method_sample_id=tbxpertultraresult.method_sample_id,
        date_tested=tbxpertultraresult.date_tested,
        result_interpretable=tbxpertultraresult.result_interpretable,
        tb_detection_result=tbxpertultraresult.tb_detection_result,
        rif_result=tbxpertultraresult.rif_result,
        uninterpretable_result=tbxpertultraresult.uninterpretable_result,
        error_code=tbxpertultraresult.error_code,
        ultra_spc=tbxpertultraresult.ultra_spc,
        is1081_is6110=tbxpertultraresult.is1081_is6110,
        rpob1=tbxpertultraresult.rpob1,
        rpob2=tbxpertultraresult.rpob2,
        rpob3=tbxpertultraresult.rpob3,
        rpob4=tbxpertultraresult.rpob4,
        xpert_module_number=tbxpertultraresult.xpert_module_number,
        # approval
        user_id=tbxpertultraresult.user_id,
        status_id=tbxpertultraresult.status_id,
        stage_id=tbxpertultraresult.stage_id,
        approval_levels=tbxpertultraresult.approval_levels,
        # service
        created_by=tbxpertultraresult.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create TB Xpert Ultra Result: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = TBXpertUltraResultDB(
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
            status_code=400, detail=f"Unable to initialize items for TB Xpert Ultra Result: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for TB Xpert Ultra Result have been successfully initialized",
    }




@router.get("/cycles")
async def list_cycles_with_results(
    lab_id: Optional[int] = Query(
        default=None, description="Only rounds this laboratory has sheets for"
    ),
    db: AsyncSession = Depends(get_db),
):
    """The rounds a TB Xpert Ultra listing can be opened on, newest first."""
    return await resultquery.cycles_with_results(db, TBXpertUltraResultDB, lab_id=lab_id)


def _result_query():
    """The result query every listing shares, with its detail loaded"""
    return (
        select(TBXpertUltraResultDB)
        .options(
            selectinload(TBXpertUltraResultDB.stage),
            selectinload(TBXpertUltraResultDB.status),
            selectinload(TBXpertUltraResultDB.user),

            selectinload(TBXpertUltraResultDB.scheme),
            selectinload(TBXpertUltraResultDB.laboratory),
            selectinload(TBXpertUltraResultDB.service),
            selectinload(TBXpertUltraResultDB.enrollment),
            selectinload(TBXpertUltraResultDB.ptcycle),
            selectinload(TBXpertUltraResultDB.method),
            selectinload(TBXpertUltraResultDB.methodsample),
        )
        .order_by(
            TBXpertUltraResultDB.pt_cycle_id.desc(),
            TBXpertUltraResultDB.lab_id,
            TBXpertUltraResultDB.method_sample_id,
        )
    )


@router.get("/options")
async def get_tbxpertultraresult_options():
    """The values form CDL-PT-F-008 allows, so the client offers exactly these"""
    return {
        "resultInterpretableList": RESULT_INTERPRETABLE_VALUES,
        "tbDetectionResultList": TB_DETECTION_RESULT_VALUES,
        "rifResultList": RIF_RESULT_VALUES,
        "uninterpretableResultList": UNINTERPRETABLE_RESULT_VALUES,
        "ctValueFieldList": CT_VALUE_FIELDS,
        "ctValueLabels": CT_VALUE_LABELS,
        "uninterpretableResultRequiringCode": UNINTERPRETABLE_RESULT_REQUIRING_CODE,
    }


@router.get("/list", response_model=List[TBXpertUltraResultWithDetail])
async def list_tbxpertultraresults(
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
        query = query.where(TBXpertUltraResultDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(TBXpertUltraResultDB.lab_id == lab_id)

    if pending:
        query = query.where(
            TBXpertUltraResultDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/{lab_id}", response_model=List[TBXpertUltraResultWithDetail])
async def list_lab_tbxpertultraresults(lab_id: int , db: AsyncSession = Depends(get_db)):
    """Lists the result sheets opened for one laboratory"""
    result = await db.execute(
        _result_query().where(TBXpertUltraResultDB.lab_id == lab_id)
    )
    return result.scalars().all()

# the sheet is opened by the provider when the panel ships; the lab only ever
# fills in what it read off the instrument
EDITABLE_RESULT_FIELDS = [
    "description",
    "date_tested",
    "result_interpretable",
    "tb_detection_result",
    "rif_result",
    "uninterpretable_result",
    "error_code",
    *CT_VALUE_FIELDS,
    "xpert_module_number",
    "status_id",
    "stage_id",
]


@router.put("/update/{id}", response_model=TBXpertUltraResult)
async def update_tbxpertultraresult(
    id: int, tbxpertultraresult_update: TBXpertUltraResult, db: AsyncSession = Depends(get_db)
):
    """Captures the results a laboratory read off its Xpert instrument.

    Saving with a status of Draft parks a partly captured panel; saving as
    Submitted sends it for review and is what the completeness rules on
    TBXpertUltraResult are checked against.
    """
    result = await db.execute(
        select(TBXpertUltraResultDB)
        .options(
            selectinload(TBXpertUltraResultDB.ptcycle),
            selectinload(TBXpertUltraResultDB.enrollment),
        )
        .where(TBXpertUltraResultDB.id == id)
    )
    tbxpertultraresult = result.scalars().first()

    if not tbxpertultraresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find TB Xpert Ultra Result with id '{id}'",
        )

    result = await db.execute(
        select(UserDB).where(UserDB.id == tbxpertultraresult_update.user_id)
    )
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{tbxpertultraresult_update.user_id}' does not exist",
        )

    # a lab may only touch its own result sheets
    if (
        assist.is_laboratory_role(user.role_id)
        and user.laboratory_id != tbxpertultraresult.lab_id
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to capture results for another laboratory",
        )

    if tbxpertultraresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This result has been approved and can no longer be changed",
        )

    cycle_status = tbxpertultraresult.ptcycle.pt_cyle_status_id
    if cycle_status not in assist.PT_CYCLE_RESULT_CAPTURE_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    if not tbxpertultraresult.enrollment.samples_received_at:
        raise HTTPException(
            status_code=400,
            detail=(
                "Please confirm you have received the samples for this enrolment "
                "before capturing results"
            ),
        )

    # only the result itself is editable - the panel it belongs to is not
    changes = tbxpertultraresult_update.dict(exclude_unset=True)
    for key in EDITABLE_RESULT_FIELDS:
        if key in changes:
            setattr(tbxpertultraresult, key, changes[key])

    tbxpertultraresult.updated_by = user.email

    try:
        await db.commit()
        await db.refresh(tbxpertultraresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update TB Xpert Ultra Result {e}")
    return tbxpertultraresult


@router.get("/id/{id}", response_model=ParamTBXpertUltraResultEdit)
async def get_tbxpertultraresult(id: int, db: AsyncSession = Depends(get_db)):
    tbxpertultraresultItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(TBXpertUltraResultDB
            ).options(
                selectinload(TBXpertUltraResultDB.stage),
                selectinload(TBXpertUltraResultDB.status),
                selectinload(TBXpertUltraResultDB.user),
                
                selectinload(TBXpertUltraResultDB.scheme),
                selectinload(TBXpertUltraResultDB.laboratory),
                selectinload(TBXpertUltraResultDB.service),
                selectinload(TBXpertUltraResultDB.enrollment),
                selectinload(TBXpertUltraResultDB.ptcycle),
                selectinload(TBXpertUltraResultDB.method),
                selectinload(TBXpertUltraResultDB.methodsample),
            )
            .filter(TBXpertUltraResultDB.id == id)
        )
        tbxpertultraresultItem = result.scalars().first()
        if not tbxpertultraresultItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'TB Xpert Ultra Result with id '{id}' not found"
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


    res = ParamTBXpertUltraResultEdit(
            tbxpertultraresult=tbxpertultraresultItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            enrollmentList = enrollmentItems,
            ptcycleList = ptcycleItems,
            methodList = methodItems,
            methodsampleList = methodsampleItems,
    )

    return res


@router.put("/review-update/{id}", response_model=TBXpertUltraResult)
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
    result = await db.execute(select(TBXpertUltraResultDB).where(TBXpertUltraResultDB.id == id))
    tbxpertultraresult = result.scalar_one_or_none()

    if not tbxpertultraresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find TB Xpert Ultra Result with id '{id}' not found",
        )

    if tbxpertultraresult.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The TB Xpert Ultra Result with id '{id}' has already been approved",
        )

    tbxpertultraresult.updated_by = user.email

    approveTBXpertUltraResult = False

    if tbxpertultraresult.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if tbxpertultraresult.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a TB Xpert Ultra Result you created",
        )

        tbxpertultraresult.review1_at = assist.get_current_date(False)
        tbxpertultraresult.review1_by = user.email
        tbxpertultraresult.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            tbxpertultraresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if tbxpertultraresult.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve tbxpertultraresult
                approveTBXpertUltraResult = True

            elif tbxpertultraresult.approval_levels == 2 or tbxpertultraresult.approval_levels == 3:
                # two or three levels, move to primary

                tbxpertultraresult.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif tbxpertultraresult.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if tbxpertultraresult.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        tbxpertultraresult.review2_at = assist.get_current_date(False)
        tbxpertultraresult.review2_by = user.email
        tbxpertultraresult.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            tbxpertultraresult.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if tbxpertultraresult.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveTBXpertUltraResult = True

            elif tbxpertultraresult.approval_levels == 3:
                # three levels, move to secondary
                tbxpertultraresult.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif tbxpertultraresult.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if tbxpertultraresult.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        tbxpertultraresult.review3_at = assist.get_current_date(False)
        tbxpertultraresult.review3_by = user.email
        tbxpertultraresult.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            tbxpertultraresult.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveTBXpertUltraResult = True

    if approveTBXpertUltraResult:
        # change tbxpertultraresult status
        tbxpertultraresult.status_id = assist.STATUS_APPROVED
        tbxpertultraresult.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(tbxpertultraresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update TB Xpert Ultra Result: {e}")
    return tbxpertultraresult


