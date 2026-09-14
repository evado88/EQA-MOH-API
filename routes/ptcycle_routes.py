from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
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
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB
from models.ptcyclestatus_model import PTCycleStatusDB
from models.applications_model import ApplicationsDB
from models.enrollment_model import EnrollmentDB

router = APIRouter(prefix="/pt-cycles", tags=["PTCycles"])


@router.post("/create", response_model=PTCycle)
async def post_ptcycle(ptcycle: PTCycle, db: AsyncSession = Depends(get_db)):


    db_context = PTCycleDB(
        # update
        name=ptcycle.name,
        description=ptcycle.description,
        # properties
        code=ptcycle.code,
        scheme_id=ptcycle.scheme_id,
        effective_date=ptcycle.effective_date,
        pt_cyle_status_id=ptcycle.pt_cyle_status_id,
        closing_date=ptcycle.closing_date,
        shipping_date=ptcycle.shipping_date,
        reports_availability_date=ptcycle.reports_availability_date,
        # approval
        user_id=ptcycle.user_id,
        status_id=ptcycle.status_id,
        stage_id=ptcycle.stage_id,
        approval_levels=ptcycle.approval_levels,
        # service
        created_by=ptcycle.created_by,
    )
    db.add(db_context)
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
async def list_ptcycles(db: AsyncSession = Depends(get_db)):
    result = await db.execute(_ptcycle_query().order_by(PTCycleDB.effective_date.desc()))
    return result.scalars().all()

@router.put("/update/{id}", response_model=PTCycle)
async def update_ptcycle(
    id: int, ptcycle_update: PTCycle, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()

    if not ptcycle:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle with id '{id}'",
        )

    # Update fields that are not None
    for key, value in ptcycle_update.dict(exclude_unset=True).items():
        setattr(ptcycle, key, value)

    try:
        await db.commit()
        await db.refresh(ptcycle)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle {e}")
    return ptcycle


@router.put("/status/{id}", response_model=PTCycleStatusChangeResult)
async def change_ptcycle_status(
    id: int, change: ParamPTCycleStatusChange, db: AsyncSession = Depends(get_db)
):
    """Moves a PT cycle to its next status.

    The cycle life cycle is Upcoming -> Started -> Samples Shipped ->
    Report Available -> Closed, and it only ever moves forward one step at a
    time. Shipping the samples is the step that has a side effect: it opens a
    result sheet for every sample in every accepted enrolment.
    """
    result = await db.execute(select(PTCycleDB).where(PTCycleDB.id == id))
    ptcycle = result.scalar_one_or_none()

    if not ptcycle:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle with id '{id}'",
        )

    user = await _get_admin_user(db, change.user_id)

    current_status = ptcycle.pt_cyle_status_id
    next_status = change.pt_cyle_status_id

    if current_status == next_status:
        raise HTTPException(
            status_code=400,
            detail=(
                "The PT Cycle is already "
                f"'{assist.PT_CYCLE_STATUS_NAMES.get(next_status, next_status)}'"
            ),
        )

    allowed = assist.PT_CYCLE_TRANSITIONS.get(current_status, ())
    if next_status not in allowed:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(current_status, current_status)
        next_name = assist.PT_CYCLE_STATUS_NAMES.get(next_status, next_status)
        allowed_names = [assist.PT_CYCLE_STATUS_NAMES[value] for value in allowed]
        detail = (
            f"A PT Cycle that is '{current_name}' cannot be moved to '{next_name}'"
        )
        if allowed_names:
            detail += f". It can only be moved to {', '.join(allowed_names)}"
        else:
            detail += " because the cycle is complete"
        raise HTTPException(status_code=400, detail=detail)

    # a cycle has to be approved before it can be run
    if ptcycle.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="The PT Cycle must be approved before its status can be changed",
        )

    enrollment_count = 0
    result_count = 0

    if next_status == assist.PT_CYCLE_SAMPLES_SHIPPED:
        enrollment_count, result_count = await _ship_samples(db, ptcycle, user)

    ptcycle.pt_cyle_status_id = next_status
    ptcycle.updated_by = user.email

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle {e}")

    next_name = assist.PT_CYCLE_STATUS_NAMES.get(next_status, next_status)
    message = f"The PT Cycle is now '{next_name}'"
    if next_status == assist.PT_CYCLE_SAMPLES_SHIPPED:
        message += (
            f". {result_count} result sheet(s) were opened across "
            f"{enrollment_count} enrolment(s)"
        )

    return PTCycleStatusChangeResult(
        succeeded=True,
        message=message,
        pt_cycle_id=ptcycle.id,
        pt_cyle_status_id=next_status,
        enrollment_count=enrollment_count,
        result_count=result_count,
    )


@router.put("/samples-shipped/{id}", response_model=PTCycleStatusChangeResult)
async def ship_ptcycle_samples(
    id: int, change: ParamPTCycleStatusChange, db: AsyncSession = Depends(get_db)
):
    """Shorthand for moving a cycle to 'Samples Shipped'"""
    change.pt_cyle_status_id = assist.PT_CYCLE_SAMPLES_SHIPPED
    return await change_ptcycle_status(id, change, db)


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

    query = (
        _ptcycle_query()
        .where(
            PTCycleDB.scheme_id.in_(scheme_ids),
            PTCycleDB.status_id == assist.STATUS_APPROVED,
            PTCycleDB.pt_cyle_status_id.in_(assist.PT_CYCLE_ENROLLMENT_OPEN),
            PTCycleDB.closing_date >= assist.get_current_date().date(),
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
    result = await db.execute(
        select(
            TBXpertUltraResultDB.lab_id, TBXpertUltraResultDB.method_sample_id
        ).where(TBXpertUltraResultDB.pt_cycle_id == ptcycle.id)
    )
    existing = {(lab_id, sample_id) for lab_id, sample_id in result.all()}

    result_count = 0

    for enrollment in enrollments:
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
            if (enrollment.lab_id, sample.id) in existing:
                continue

            db.add(
                TBXpertUltraResultDB(
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
            existing.add((enrollment.lab_id, sample.id))
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


