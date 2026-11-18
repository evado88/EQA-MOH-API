from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from helpers.receipts import receipt_exists
from helpers.attachments import result_file_exists
from helpers.submissions import log_result_submission
from helpers.auth import get_current_user, CurrentUser
from models.tbxpertxdrresult_model import (
    CT_VALUE_FIELDS,
    CT_VALUE_LABELS,
    DRUG_RESULT_FIELDS,
    DRUG_RESULT_LABELS,
    DRUG_RESULT_VALUES,
    RESULT_INTERPRETABLE_VALUES,
    TB_DETECTION_RESULT_VALUES,
    UNINTERPRETABLE_RESULT_REQUIRING_CODE,
    UNINTERPRETABLE_RESULT_VALUES,
    TBXpertXDRResult,
    TBXpertXDRResultWithDetail,
    ParamTBXpertXDRResultEdit,
    TBXpertXDRResultDB,
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

router = APIRouter(prefix="/tb-xpert-xdr-results", tags=["TBXpertXDRResults"])


@router.post("/create", response_model=TBXpertXDRResult)
async def post_tbxpertxdrresult(tbxpertxdrresult: TBXpertXDRResult, db: AsyncSession = Depends(get_db)):


    db_context = TBXpertXDRResultDB(
        # update
        name=tbxpertxdrresult.name,
        description=tbxpertxdrresult.description,
        # properties
        scheme_id=tbxpertxdrresult.scheme_id,
        lab_id=tbxpertxdrresult.lab_id,
        service_id=tbxpertxdrresult.service_id,
        enrollment_id=tbxpertxdrresult.enrollment_id,
        pt_cycle_id=tbxpertxdrresult.pt_cycle_id,
        method_id=tbxpertxdrresult.method_id,
        method_sample_id=tbxpertxdrresult.method_sample_id,
        date_tested=tbxpertxdrresult.date_tested,
        result_interpretable=tbxpertxdrresult.result_interpretable,
        tb_detection_result=tbxpertxdrresult.tb_detection_result,
        inh_result=tbxpertxdrresult.inh_result,
        flq_result=tbxpertxdrresult.flq_result,
        amk_result=tbxpertxdrresult.amk_result,
        eth_result=tbxpertxdrresult.eth_result,
        uninterpretable_result=tbxpertxdrresult.uninterpretable_result,
        error_code=tbxpertxdrresult.error_code,
        spc_ahpc=tbxpertxdrresult.spc_ahpc,
        inha=tbxpertxdrresult.inha,
        katg=tbxpertxdrresult.katg,
        fabg1=tbxpertxdrresult.fabg1,
        gyra1=tbxpertxdrresult.gyra1,
        gyra2=tbxpertxdrresult.gyra2,
        gyra3=tbxpertxdrresult.gyra3,
        gyrb2=tbxpertxdrresult.gyrb2,
        rrs=tbxpertxdrresult.rrs,
        # approval
        user_id=tbxpertxdrresult.user_id,
        status_id=tbxpertxdrresult.status_id,
        stage_id=tbxpertxdrresult.stage_id,
        approval_levels=tbxpertxdrresult.approval_levels,
        # service
        created_by=tbxpertxdrresult.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create TB Xpert XDR Result: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = TBXpertXDRResultDB(
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
            status_code=400, detail=f"Unable to initialize items for TB Xpert XDR Result: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for TB Xpert XDR Result have been successfully initialized",
    }




@router.get("/cycles")
async def list_cycles_with_results(
    lab_id: Optional[int] = Query(
        default=None, description="Only rounds this laboratory has sheets for"
    ),
    db: AsyncSession = Depends(get_db),
):
    """The rounds a TB Xpert XDR listing can be opened on, newest first."""
    return await resultquery.cycles_with_results(db, TBXpertXDRResultDB, lab_id=lab_id)


def _result_query():
    """The result query every listing shares, with its detail loaded"""
    return (
        select(TBXpertXDRResultDB)
        .options(
            selectinload(TBXpertXDRResultDB.stage),
            selectinload(TBXpertXDRResultDB.status),
            selectinload(TBXpertXDRResultDB.user),

            selectinload(TBXpertXDRResultDB.scheme),
            selectinload(TBXpertXDRResultDB.laboratory),
            selectinload(TBXpertXDRResultDB.service),
            selectinload(TBXpertXDRResultDB.enrollment),
            selectinload(TBXpertXDRResultDB.ptcycle),
            selectinload(TBXpertXDRResultDB.method),
            selectinload(TBXpertXDRResultDB.methodsample),
        )
        .order_by(
            TBXpertXDRResultDB.pt_cycle_id.desc(),
            TBXpertXDRResultDB.lab_id,
            TBXpertXDRResultDB.method_sample_id,
        )
    )


@router.get("/options")
async def get_tbxpertxdrresult_options():
    """The values form CDL-PT-F-027 allows, so the client offers exactly these"""
    return {
        "resultInterpretableList": RESULT_INTERPRETABLE_VALUES,
        "tbDetectionResultList": TB_DETECTION_RESULT_VALUES,
        "drugResultList": DRUG_RESULT_VALUES,
        "drugResultFieldList": DRUG_RESULT_FIELDS,
        "drugResultLabels": DRUG_RESULT_LABELS,
        "uninterpretableResultList": UNINTERPRETABLE_RESULT_VALUES,
        "ctValueFieldList": CT_VALUE_FIELDS,
        "ctValueLabels": CT_VALUE_LABELS,
        "uninterpretableResultRequiringCode": UNINTERPRETABLE_RESULT_REQUIRING_CODE,
    }


@router.get("/list", response_model=List[TBXpertXDRResultWithDetail])
async def list_tbxpertxdrresults(
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
        query = query.where(TBXpertXDRResultDB.scheme_id == scope)

    if pt_cycle_id is not None:
        query = query.where(TBXpertXDRResultDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(TBXpertXDRResultDB.lab_id == lab_id)

    if pending:
        query = query.where(
            TBXpertXDRResultDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/{lab_id}", response_model=List[TBXpertXDRResultWithDetail])
async def list_lab_tbxpertxdrresults(lab_id: int , db: AsyncSession = Depends(get_db)):
    """Lists the result sheets opened for one laboratory"""
    result = await db.execute(
        _result_query().where(TBXpertXDRResultDB.lab_id == lab_id)
    )
    return result.scalars().all()

# the sheet is opened by the provider when the panel ships; the lab only ever
# fills in what it read off the instrument
EDITABLE_RESULT_FIELDS = [
    "description",
    "date_tested",
    "result_interpretable",
    "tb_detection_result",
    *DRUG_RESULT_FIELDS,
    "uninterpretable_result",
    "error_code",
    *CT_VALUE_FIELDS,
    "status_id",
    "stage_id",
]


@router.put("/update/{id}", response_model=TBXpertXDRResult)
async def update_tbxpertxdrresult(
    id: int, tbxpertxdrresult_update: TBXpertXDRResult, db: AsyncSession = Depends(get_db)
):
    """Captures the results a laboratory read off its Xpert MTB/XDR instrument.

    Saving with a status of Draft parks a partly captured panel; saving as
    Submitted sends it for review and is what the completeness rules on
    TBXpertXDRResult are checked against.
    """
    result = await db.execute(
        select(TBXpertXDRResultDB)
        .options(
            selectinload(TBXpertXDRResultDB.ptcycle),
            selectinload(TBXpertXDRResultDB.enrollment),
        )
        .where(TBXpertXDRResultDB.id == id)
    )
    tbxpertxdrresult = result.scalars().first()

    if not tbxpertxdrresult:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find TB Xpert XDR Result with id '{id}'",
        )

    result = await db.execute(
        select(UserDB).where(UserDB.id == tbxpertxdrresult_update.user_id)
    )
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{tbxpertxdrresult_update.user_id}' does not exist",
        )

    # a lab may only touch its own result sheets
    if (
        assist.is_laboratory_role(user.role_id)
        and user.laboratory_id != tbxpertxdrresult.lab_id
    ):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to capture results for another laboratory",
        )

    # result submission needs no approval; the lab may resubmit until the
    # cycle's result submission due date (enforced by pt_result_capture_open)

    cycle_status = tbxpertxdrresult.ptcycle.pt_cyle_status_id
    if not assist.pt_result_capture_open(tbxpertxdrresult.ptcycle):
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(cycle_status, cycle_status)
        raise HTTPException(
            status_code=400,
            detail=(
                f"The PT Cycle is '{current_name}', so results can no longer be "
                "captured for it"
            ),
        )

    # per-sample receipt details must be recorded before entering results
    if not await receipt_exists(db, tbxpertxdrresult.pt_cycle_id, tbxpertxdrresult.lab_id, tbxpertxdrresult.method_sample_id):
        raise HTTPException(
            status_code=400,
            detail=(
                "Please record this sample's receipt details (date received, "
                "condition and temperature) before entering results for it"
            ),
        )

    # the worksheet file is mandatory before the result can be submitted
    if tbxpertxdrresult_update.status_id == assist.STATUS_SUBMITTED and not await result_file_exists(
        db, tbxpertxdrresult.enrollment_id
    ):
        raise HTTPException(
            status_code=400,
            detail=(
                "Please attach the worksheet file for this panel before "
                "submitting the result"
            ),
        )

    # only the result itself is editable - the panel it belongs to is not
    changes = tbxpertxdrresult_update.dict(exclude_unset=True)
    for key in EDITABLE_RESULT_FIELDS:
        if key in changes:
            setattr(tbxpertxdrresult, key, changes[key])

    tbxpertxdrresult.updated_by = user.email

    # audit: record each submission (a lab may resubmit until the due date)
    if tbxpertxdrresult.status_id == assist.STATUS_SUBMITTED:
        await log_result_submission(db, "tb_xpert_xdr", tbxpertxdrresult, user.email)

    try:
        await db.commit()
        await db.refresh(tbxpertxdrresult)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update TB Xpert XDR Result {e}")
    return tbxpertxdrresult


@router.get("/id/{id}", response_model=ParamTBXpertXDRResultEdit)
async def get_tbxpertxdrresult(id: int, db: AsyncSession = Depends(get_db)):
    tbxpertxdrresultItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(TBXpertXDRResultDB
            ).options(
                selectinload(TBXpertXDRResultDB.stage),
                selectinload(TBXpertXDRResultDB.status),
                selectinload(TBXpertXDRResultDB.user),
                
                selectinload(TBXpertXDRResultDB.scheme),
                selectinload(TBXpertXDRResultDB.laboratory),
                selectinload(TBXpertXDRResultDB.service),
                selectinload(TBXpertXDRResultDB.enrollment),
                selectinload(TBXpertXDRResultDB.ptcycle),
                selectinload(TBXpertXDRResultDB.method),
                selectinload(TBXpertXDRResultDB.methodsample),
            )
            .filter(TBXpertXDRResultDB.id == id)
        )
        tbxpertxdrresultItem = result.scalars().first()
        if not tbxpertxdrresultItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'TB Xpert XDR Result with id '{id}' not found"
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


    res = ParamTBXpertXDRResultEdit(
            tbxpertxdrresult=tbxpertxdrresultItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            enrollmentList = enrollmentItems,
            ptcycleList = ptcycleItems,
            methodList = methodItems,
            methodsampleList = methodsampleItems,
    )

    return res

