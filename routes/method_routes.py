from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.method_model import Method, MethodWithDetail, ParamMethodEdit, MethodDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.scheme_model import SchemeDB
from models.service_model import ServiceDB

router = APIRouter(prefix="/methods", tags=["Methods"])


@router.post("/create", response_model=Method)
async def post_method(method: Method, db: AsyncSession = Depends(get_db)):


    db_context = MethodDB(
        # update
        name=method.name,
        description=method.description,
        # properties
        scheme_id=method.scheme_id,
        service_id=method.service_id,
        # approval
        user_id=method.user_id,
        status_id=method.status_id,
        stage_id=method.stage_id,
        approval_levels=method.approval_levels,
        # service
        created_by=method.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Method: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Ultra'}, {'name': 'XDR'}]

    for value in itemList:
        db_item = MethodDB(
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
            status_code=400, detail=f"Unable to initialize items for Method: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Method have been successfully initialized",
    }



@router.get("/list", response_model=List[MethodWithDetail])
async def list_methods(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            MethodDB
        ).options(
            selectinload(MethodDB.stage),
            selectinload(MethodDB.status),
            selectinload(MethodDB.user),
            
            selectinload(MethodDB.scheme),
            selectinload(MethodDB.service),
        )
    )
    methods = result.scalars().all()
    return methods

@router.put("/update/{id}", response_model=Method)
async def update_method(
    id: int, method_update: Method, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MethodDB).where(MethodDB.id == id))
    method = result.scalar_one_or_none()

    if not method:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Method with id '{id}'",
        )

    # Update fields that are not None
    for key, value in method_update.dict(exclude_unset=True).items():
        setattr(method, key, value)

    try:
        await db.commit()
        await db.refresh(method)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Method {e}")
    return method


@router.get("/id/{id}", response_model=ParamMethodEdit)
async def get_method(id: int, db: AsyncSession = Depends(get_db)):
    methodItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(MethodDB
            ).options(
                selectinload(MethodDB.stage),
                selectinload(MethodDB.status),
                selectinload(MethodDB.user),
                
                selectinload(MethodDB.scheme),
                selectinload(MethodDB.service),
            )
            .filter(MethodDB.id == id)
        )
        methodItem = result.scalars().first()
        if not methodItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Method with id '{id}' not found"
            )

    # get supporting models if available

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


    res = ParamMethodEdit(
            method=methodItem,
            schemeList = schemeItems,
            serviceList = serviceItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Method)
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
    result = await db.execute(select(MethodDB).where(MethodDB.id == id))
    method = result.scalar_one_or_none()

    if not method:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Method with id '{id}' not found",
        )

    if method.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Method with id '{id}' has already been approved",
        )

    method.updated_by = user.email

    approveMethod = False

    if method.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if method.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Method you created",
        )

        method.review1_at = assist.get_current_date(False)
        method.review1_by = user.email
        method.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            method.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if method.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve method
                approveMethod = True

            elif method.approval_levels == 2 or method.approval_levels == 3:
                # two or three levels, move to primary

                method.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif method.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if method.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        method.review2_at = assist.get_current_date(False)
        method.review2_by = user.email
        method.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            method.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if method.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveMethod = True

            elif method.approval_levels == 3:
                # three levels, move to secondary
                method.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif method.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if method.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        method.review3_at = assist.get_current_date(False)
        method.review3_by = user.email
        method.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            method.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveMethod = True

    if approveMethod:
        # change method status
        method.status_id = assist.STATUS_APPROVED
        method.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(method)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Method: {e}")
    return method


