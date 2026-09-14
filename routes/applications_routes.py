from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.applications_model import Applications, ApplicationsWithDetail, ParamApplicationsEdit, ApplicationsDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.laboratory_model import LaboratoryDB
from models.scheme_model import SchemeDB
from models.service_model import ServiceDB
from models.method_model import MethodDB

router = APIRouter(prefix="/applications", tags=["Applicationss"])


@router.post("/create", response_model=Applications)
async def post_applications(applications: Applications, db: AsyncSession = Depends(get_db)):


    db_context = ApplicationsDB(
        # update
        name=applications.name,
        description=applications.description,
        # properties
        lab_id=applications.lab_id,
        scheme_id=applications.scheme_id,
        service_id=applications.service_id,
        method_id=applications.method_id,
        # approval
        user_id=applications.user_id,
        status_id=applications.status_id,
        stage_id=applications.stage_id,
        approval_levels=applications.approval_levels,
        # service
        created_by=applications.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Application: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = ApplicationsDB(
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
            status_code=400, detail=f"Unable to initialize items for Application: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Application have been successfully initialized",
    }



def _application_query():
    """The application query every listing shares, with its detail loaded"""
    return (
        select(ApplicationsDB)
        .options(
            selectinload(ApplicationsDB.stage),
            selectinload(ApplicationsDB.status),
            selectinload(ApplicationsDB.user),

            selectinload(ApplicationsDB.laboratory),
            selectinload(ApplicationsDB.scheme),
            selectinload(ApplicationsDB.service),
            selectinload(ApplicationsDB.method),
        )
        .order_by(ApplicationsDB.created_at.desc(), ApplicationsDB.id.desc())
    )


@router.get("/list", response_model=List[ApplicationsWithDetail])
async def list_applicationss(
    status_id: Optional[int] = Query(
        default=None, description="Only return applications with this status"
    ),
    lab_id: Optional[int] = Query(
        default=None, description="Only return applications for this laboratory"
    ),
    scheme_id: Optional[int] = Query(
        default=None, description="Only return applications for this scheme"
    ),
    pending: bool = Query(
        default=False,
        description="Only return applications that still need a decision",
    ),
    db: AsyncSession = Depends(get_db),
):
    """Lists applications, newest first.

    An administrator reviewing the queue normally wants `pending=true`; the
    unfiltered listing is what the full register looks like.
    """
    query = _application_query()

    if status_id is not None:
        query = query.where(ApplicationsDB.status_id == status_id)

    if lab_id is not None:
        query = query.where(ApplicationsDB.lab_id == lab_id)

    if scheme_id is not None:
        query = query.where(ApplicationsDB.scheme_id == scheme_id)

    if pending:
        query = query.where(
            ApplicationsDB.status_id.in_(
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            )
        )

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/list/lab/{lab_id}", response_model=List[ApplicationsWithDetail])
async def list_lab_applicationss(lab_id: int, db: AsyncSession = Depends(get_db)):
    """Lists the applications belonging to one laboratory"""
    result = await db.execute(
        _application_query().where(ApplicationsDB.lab_id == lab_id)
    )
    return result.scalars().all()

@router.put("/update/{id}", response_model=Applications)
async def update_applications(
    id: int, applications_update: Applications, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(ApplicationsDB).where(ApplicationsDB.id == id))
    applications = result.scalar_one_or_none()

    if not applications:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Application with id '{id}'",
        )

    # Update fields that are not None
    for key, value in applications_update.dict(exclude_unset=True).items():
        setattr(applications, key, value)

    try:
        await db.commit()
        await db.refresh(applications)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Application {e}")
    return applications


@router.get("/id/{id}", response_model=ParamApplicationsEdit)
async def get_applications(id: int, db: AsyncSession = Depends(get_db)):
    applicationsItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(ApplicationsDB
            ).options(
                selectinload(ApplicationsDB.stage),
                selectinload(ApplicationsDB.status),
                selectinload(ApplicationsDB.user),
                
                selectinload(ApplicationsDB.laboratory),
                selectinload(ApplicationsDB.scheme),
                selectinload(ApplicationsDB.service),
                selectinload(ApplicationsDB.method),
            )
            .filter(ApplicationsDB.id == id)
        )
        applicationsItem = result.scalars().first()
        if not applicationsItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Application with id '{id}' not found"
            )

    # get supporting models if available

    # Laboratory
    result = await db.execute(
        select(LaboratoryDB)
        .order_by(LaboratoryDB.name)
    )
    laboratoryItems =  result.scalars().all()

    # Scheme
    result = await db.execute(
        select(SchemeDB)
        .order_by(SchemeDB.name)
    )
    schemeItems =  result.scalars().all()

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


    res = ParamApplicationsEdit(
            applications=applicationsItem,
            laboratoryList = laboratoryItems,
            schemeList = schemeItems,
            serviceList = serviceItems,
            methodList = methodItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Applications)
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
    result = await db.execute(select(ApplicationsDB).where(ApplicationsDB.id == id))
    applications = result.scalar_one_or_none()

    if not applications:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Application with id '{id}' not found",
        )

    if applications.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Application with id '{id}' has already been approved",
        )

    applications.updated_by = user.email

    approveApplications = False

    if applications.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if applications.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Application you created",
        )

        applications.review1_at = assist.get_current_date(False)
        applications.review1_by = user.email
        applications.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            applications.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if applications.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve applications
                approveApplications = True

            elif applications.approval_levels == 2 or applications.approval_levels == 3:
                # two or three levels, move to primary

                applications.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif applications.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if applications.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        applications.review2_at = assist.get_current_date(False)
        applications.review2_by = user.email
        applications.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            applications.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if applications.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveApplications = True

            elif applications.approval_levels == 3:
                # three levels, move to secondary
                applications.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif applications.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if applications.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        applications.review3_at = assist.get_current_date(False)
        applications.review3_by = user.email
        applications.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            applications.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveApplications = True

    if approveApplications:
        # change applications status
        applications.status_id = assist.STATUS_APPROVED
        applications.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(applications)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Application: {e}")
    return applications


