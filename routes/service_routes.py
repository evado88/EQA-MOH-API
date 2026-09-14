from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.service_model import Service, ServiceWithDetail, ParamServiceEdit, ServiceDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB

router = APIRouter(prefix="/services", tags=["Services"])


@router.post("/create", response_model=Service)
async def post_service(service: Service, db: AsyncSession = Depends(get_db)):


    db_context = ServiceDB(
        # update
        name=service.name,
        description=service.description,
        # properties
        scheme_id=service.scheme_id,
        # approval
        user_id=service.user_id,
        status_id=service.status_id,
        stage_id=service.stage_id,
        approval_levels=service.approval_levels,
        # service
        created_by=service.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Service: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'TB Microscopy'}, {'name': 'TB Xpert'}]

    for value in itemList:
        db_item = ServiceDB(
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
            status_code=400, detail=f"Unable to initialize items for Service: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Service have been successfully initialized",
    }



@router.get("/list", response_model=List[ServiceWithDetail])
async def list_services(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            ServiceDB
        ).options(
            selectinload(ServiceDB.stage),
            selectinload(ServiceDB.status),
            selectinload(ServiceDB.user),
            
            selectinload(ServiceDB.scheme),
        )
    )
    services = result.scalars().all()
    return services

@router.put("/update/{id}", response_model=Service)
async def update_service(
    id: int, service_update: Service, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(ServiceDB).where(ServiceDB.id == id))
    service = result.scalar_one_or_none()

    if not service:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Service with id '{id}'",
        )

    # Update fields that are not None
    for key, value in service_update.dict(exclude_unset=True).items():
        setattr(service, key, value)

    try:
        await db.commit()
        await db.refresh(service)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Service {e}")
    return service


@router.get("/id/{id}", response_model=ParamServiceEdit)
async def get_service(id: int, db: AsyncSession = Depends(get_db)):
    serviceItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(ServiceDB
            ).options(
                selectinload(ServiceDB.stage),
                selectinload(ServiceDB.status),
                selectinload(ServiceDB.user),
                
                selectinload(ServiceDB.scheme),
            )
            .filter(ServiceDB.id == id)
        )
        serviceItem = result.scalars().first()
        if not serviceItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Service with id '{id}' not found"
            )

    # get supporting models if available

    # Scheme
    result = await db.execute(
        select(SchemeDB)
        .order_by(SchemeDB.name)
    )
    schemeItems =  result.scalars().all()


    res = ParamServiceEdit(
            service=serviceItem,
            schemeList = schemeItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Service)
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
    result = await db.execute(select(ServiceDB).where(ServiceDB.id == id))
    service = result.scalar_one_or_none()

    if not service:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Service with id '{id}' not found",
        )

    if service.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Service with id '{id}' has already been approved",
        )

    service.updated_by = user.email

    approveService = False

    if service.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if service.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Service you created",
        )

        service.review1_at = assist.get_current_date(False)
        service.review1_by = user.email
        service.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            service.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if service.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve service
                approveService = True

            elif service.approval_levels == 2 or service.approval_levels == 3:
                # two or three levels, move to primary

                service.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif service.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if service.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        service.review2_at = assist.get_current_date(False)
        service.review2_by = user.email
        service.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            service.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if service.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveService = True

            elif service.approval_levels == 3:
                # three levels, move to secondary
                service.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif service.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if service.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        service.review3_at = assist.get_current_date(False)
        service.review3_by = user.email
        service.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            service.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveService = True

    if approveService:
        # change service status
        service.status_id = assist.STATUS_APPROVED
        service.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(service)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Service: {e}")
    return service


