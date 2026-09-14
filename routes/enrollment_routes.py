from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.enrollment_model import (
    Enrollment,
    EnrollmentApplyResult,
    EnrollmentWithDetail,
    ParamEnrollmentApply,
    ParamEnrollmentEdit,
    ParamEnrollmentReceiveSamples,
    EnrollmentDB,
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
from models.method_model import MethodDB
from models.ptcycle_model import PTCycleDB
from models.applications_model import ApplicationsDB

router = APIRouter(prefix="/enrollments", tags=["Enrollments"])


@router.post("/create", response_model=Enrollment)
async def post_enrollment(enrollment: Enrollment, db: AsyncSession = Depends(get_db)):


    db_context = EnrollmentDB(
        # update
        name=enrollment.name,
        description=enrollment.description,
        # properties
        scheme_id=enrollment.scheme_id,
        lab_id=enrollment.lab_id,
        service_id=enrollment.service_id,
        method_id=enrollment.method_id,
        pt_cycle_id=enrollment.pt_cycle_id,
        # approval
        user_id=enrollment.user_id,
        status_id=enrollment.status_id,
        stage_id=enrollment.stage_id,
        approval_levels=enrollment.approval_levels,
        # service
        created_by=enrollment.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Enrollment: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = EnrollmentDB(
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
            status_code=400, detail=f"Unable to initialize items for Enrollment: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Enrollment have been successfully initialized",
    }



def _enrollment_query():
    """The enrolment query every listing shares, with its detail loaded"""
    return (
        select(EnrollmentDB)
        .options(
            selectinload(EnrollmentDB.stage),
            selectinload(EnrollmentDB.status),
            selectinload(EnrollmentDB.user),

            selectinload(EnrollmentDB.scheme),
            selectinload(EnrollmentDB.laboratory),
            selectinload(EnrollmentDB.service),
            selectinload(EnrollmentDB.method),
            selectinload(EnrollmentDB.ptcycle),
        )
        .order_by(EnrollmentDB.created_at.desc(), EnrollmentDB.id.desc())
    )


@router.get("/list", response_model=List[EnrollmentWithDetail])
async def list_enrollments(
    pt_cycle_id: Optional[int] = Query(
        default=None, description="Only return enrolments for this cycle"
    ),
    lab_id: Optional[int] = Query(
        default=None, description="Only return enrolments for this laboratory"
    ),
    pending: bool = Query(
        default=False, description="Only return enrolments that still need a decision"
    ),
    db: AsyncSession = Depends(get_db),
):
    query = _enrollment_query()

    if pt_cycle_id is not None:
        query = query.where(EnrollmentDB.pt_cycle_id == pt_cycle_id)

    if lab_id is not None:
        query = query.where(EnrollmentDB.lab_id == lab_id)

    if pending:
        query = query.where(
            EnrollmentDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/lab/{lab_id}", response_model=List[EnrollmentWithDetail])
async def list_lab_enrollments(lab_id: int, db: AsyncSession = Depends(get_db)):
    """Lists the enrolments belonging to one laboratory"""
    result = await db.execute(_enrollment_query().where(EnrollmentDB.lab_id == lab_id))
    return result.scalars().all()


@router.get("/list/cycle/{pt_cycle_id}", response_model=List[EnrollmentWithDetail])
async def list_cycle_enrollments(
    pt_cycle_id: int, db: AsyncSession = Depends(get_db)
):
    """Lists the enrolments received for one PT cycle"""
    result = await db.execute(
        _enrollment_query().where(EnrollmentDB.pt_cycle_id == pt_cycle_id)
    )
    return result.scalars().all()


@router.post("/apply", response_model=EnrollmentApplyResult)
async def apply_for_ptcycle(
    apply: ParamEnrollmentApply, db: AsyncSession = Depends(get_db)
):
    """Enrols a laboratory in an open PT cycle.

    The lab does not pick methods here. It gets one enrolment per approved
    application it holds for the cycle's scheme, which is what stops a lab
    enrolling for a method it was never accepted for.
    """
    result = await db.execute(
        select(PTCycleDB).where(PTCycleDB.id == apply.pt_cycle_id)
    )
    ptcycle = result.scalars().first()

    if not ptcycle:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle with id '{apply.pt_cycle_id}'",
        )

    result = await db.execute(
        select(LaboratoryDB).where(LaboratoryDB.id == apply.lab_id)
    )
    laboratory = result.scalars().first()

    if not laboratory:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Laboratory with id '{apply.lab_id}'",
        )

    if laboratory.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="Your laboratory registration has not been approved yet",
        )

    result = await db.execute(select(UserDB).where(UserDB.id == apply.user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{apply.user_id}' does not exist",
        )

    # a lab user may only enrol its own lab
    if assist.is_laboratory_role(user.role_id) and user.laboratory_id != laboratory.id:
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to enrol on behalf of another laboratory",
        )

    if ptcycle.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400, detail="This PT Cycle is not open for enrolment yet"
        )

    if ptcycle.pt_cyle_status_id not in assist.PT_CYCLE_ENROLLMENT_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(
            ptcycle.pt_cyle_status_id, ptcycle.pt_cyle_status_id
        )
        raise HTTPException(
            status_code=400,
            detail=f"This PT Cycle is '{current_name}' and is not open for enrolment",
        )

    if ptcycle.closing_date and ptcycle.closing_date < assist.get_current_date().date():
        raise HTTPException(
            status_code=400,
            detail=(
                "Enrolment for this PT Cycle closed on "
                f"{ptcycle.closing_date:%d %b %Y}"
            ),
        )

    # the methods this lab was accepted for, within the cycle's scheme
    result = await db.execute(
        select(ApplicationsDB).where(
            ApplicationsDB.lab_id == laboratory.id,
            ApplicationsDB.scheme_id == ptcycle.scheme_id,
            ApplicationsDB.status_id == assist.STATUS_APPROVED,
        )
    )
    applications = result.scalars().all()

    if not applications:
        raise HTTPException(
            status_code=400,
            detail=(
                "Your laboratory has no approved methods for this scheme, so it "
                "cannot enrol in this PT Cycle"
            ),
        )

    # what the lab already enrolled for, so re-applying just adds what is new
    result = await db.execute(
        select(EnrollmentDB.method_id).where(
            EnrollmentDB.pt_cycle_id == ptcycle.id,
            EnrollmentDB.lab_id == laboratory.id,
        )
    )
    enrolled_method_ids = {value for value in result.scalars().all()}

    created = 0
    for application in applications:
        if application.method_id in enrolled_method_ids:
            continue

        db.add(
            EnrollmentDB(
                name=f"{ptcycle.name} - {laboratory.name} - {application.name}",
                description=apply.comments,
                # properties
                scheme_id=ptcycle.scheme_id,
                lab_id=laboratory.id,
                service_id=application.service_id,
                method_id=application.method_id,
                pt_cycle_id=ptcycle.id,
                # approval - an enrolment is a request the provider accepts
                user_id=user.id,
                status_id=assist.STATUS_SUBMITTED,
                stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                approval_levels=1,
                # service
                created_by=user.email,
            )
        )
        created += 1

    if created == 0:
        raise HTTPException(
            status_code=400,
            detail="Your laboratory has already enrolled in this PT Cycle",
        )

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Could not enrol in the PT Cycle: {e}"
        )

    return EnrollmentApplyResult(
        succeeded=True,
        message=(
            f"You have enrolled in {ptcycle.name} for {created} method(s). You will "
            "be informed once your enrolment has been accepted."
        ),
        pt_cycle_id=ptcycle.id,
        lab_id=laboratory.id,
        enrollment_count=created,
    )


@router.put("/receive-samples/{id}", response_model=Enrollment)
async def receive_samples(
    id: int,
    receive: ParamEnrollmentReceiveSamples,
    db: AsyncSession = Depends(get_db),
):
    """Records that a laboratory has received its shipped panel.

    Until this is done the lab has no date to work from, and the results it
    captures cannot be put in the context of when the panel arrived.
    """
    result = await db.execute(
        _enrollment_query().where(EnrollmentDB.id == id)
    )
    enrollment = result.scalars().first()

    if not enrollment:
        raise HTTPException(
            status_code=404, detail=f"Unable to find Enrollment with id '{id}'"
        )

    result = await db.execute(select(UserDB).where(UserDB.id == receive.user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{receive.user_id}' does not exist",
        )

    if assist.is_laboratory_role(user.role_id) and user.laboratory_id != enrollment.lab_id:
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to receive samples for another laboratory",
        )

    if enrollment.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This enrolment has not been accepted, so no samples were shipped",
        )

    if enrollment.ptcycle.pt_cyle_status_id not in assist.PT_CYCLE_RESULT_CAPTURE_OPEN:
        current_name = assist.PT_CYCLE_STATUS_NAMES.get(
            enrollment.ptcycle.pt_cyle_status_id, enrollment.ptcycle.pt_cyle_status_id
        )
        raise HTTPException(
            status_code=400,
            detail=f"The samples for this PT Cycle have not been shipped yet (the cycle is '{current_name}')",
        )

    if enrollment.samples_received_at:
        raise HTTPException(
            status_code=400,
            detail=(
                "The samples for this enrolment were already received on "
                f"{enrollment.samples_received_at:%d %b %Y}"
            ),
        )

    enrollment.samples_received_at = (
        receive.samples_received_at or assist.get_current_date(False)
    )
    enrollment.samples_received_by = user.email
    enrollment.updated_by = user.email

    if receive.comments:
        enrollment.description = receive.comments

    try:
        await db.commit()
        await db.refresh(enrollment)
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to receive the samples: {e}"
        )

    return enrollment

@router.put("/update/{id}", response_model=Enrollment)
async def update_enrollment(
    id: int, enrollment_update: Enrollment, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(EnrollmentDB).where(EnrollmentDB.id == id))
    enrollment = result.scalar_one_or_none()

    if not enrollment:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Enrollment with id '{id}'",
        )

    # Update fields that are not None
    for key, value in enrollment_update.dict(exclude_unset=True).items():
        setattr(enrollment, key, value)

    try:
        await db.commit()
        await db.refresh(enrollment)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Enrollment {e}")
    return enrollment


@router.get("/id/{id}", response_model=ParamEnrollmentEdit)
async def get_enrollment(id: int, db: AsyncSession = Depends(get_db)):
    enrollmentItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(EnrollmentDB
            ).options(
                selectinload(EnrollmentDB.stage),
                selectinload(EnrollmentDB.status),
                selectinload(EnrollmentDB.user),
                
                selectinload(EnrollmentDB.scheme),
                selectinload(EnrollmentDB.laboratory),
                selectinload(EnrollmentDB.service),
                selectinload(EnrollmentDB.method),
                selectinload(EnrollmentDB.ptcycle),
            )
            .filter(EnrollmentDB.id == id)
        )
        enrollmentItem = result.scalars().first()
        if not enrollmentItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Enrollment with id '{id}' not found"
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

    # Method
    result = await db.execute(
        select(MethodDB)
        .order_by(MethodDB.name)
    )
    methodItems =  result.scalars().all()

    # PT Cycle
    result = await db.execute(
        select(PTCycleDB)
        .order_by(PTCycleDB.name)
    )
    ptcycleItems =  result.scalars().all()


    res = ParamEnrollmentEdit(
            enrollment=enrollmentItem,
            schemeList = schemeItems,
            laboratoryList = laboratoryItems,
            serviceList = serviceItems,
            methodList = methodItems,
            ptcycleList = ptcycleItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Enrollment)
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
    result = await db.execute(select(EnrollmentDB).where(EnrollmentDB.id == id))
    enrollment = result.scalar_one_or_none()

    if not enrollment:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Enrollment with id '{id}' not found",
        )

    if enrollment.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Enrollment with id '{id}' has already been approved",
        )

    enrollment.updated_by = user.email

    approveEnrollment = False

    if enrollment.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if enrollment.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Enrollment you created",
        )

        enrollment.review1_at = assist.get_current_date(False)
        enrollment.review1_by = user.email
        enrollment.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            enrollment.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if enrollment.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve enrollment
                approveEnrollment = True

            elif enrollment.approval_levels == 2 or enrollment.approval_levels == 3:
                # two or three levels, move to primary

                enrollment.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif enrollment.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if enrollment.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        enrollment.review2_at = assist.get_current_date(False)
        enrollment.review2_by = user.email
        enrollment.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            enrollment.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if enrollment.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveEnrollment = True

            elif enrollment.approval_levels == 3:
                # three levels, move to secondary
                enrollment.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif enrollment.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if enrollment.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        enrollment.review3_at = assist.get_current_date(False)
        enrollment.review3_by = user.email
        enrollment.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            enrollment.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveEnrollment = True

    if approveEnrollment:
        # change enrollment status
        enrollment.status_id = assist.STATUS_APPROVED
        enrollment.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(enrollment)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Enrollment: {e}")
    return enrollment


