from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.methodsample_model import MethodSample, MethodSampleWithDetail, ParamMethodSampleEdit, MethodSampleDB
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
from models.method_model import MethodDB

router = APIRouter(prefix="/method-samples", tags=["MethodSamples"])


@router.post("/create", response_model=MethodSample)
async def post_methodsample(methodsample: MethodSample, db: AsyncSession = Depends(get_db)):


    db_context = MethodSampleDB(
        # update
        name=methodsample.name,
        description=methodsample.description,
        # properties
        scheme_id=methodsample.scheme_id,
        service_id=methodsample.service_id,
        method_id=methodsample.method_id,
        # approval
        user_id=methodsample.user_id,
        status_id=methodsample.status_id,
        stage_id=methodsample.stage_id,
        approval_levels=methodsample.approval_levels,
        # service
        created_by=methodsample.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Method Sample: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Ultra'}, {'name': 'XDR'}]

    for value in itemList:
        db_item = MethodSampleDB(
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
            status_code=400, detail=f"Unable to initialize items for Method Sample: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Method Sample have been successfully initialized",
    }



@router.get("/list", response_model=List[MethodSampleWithDetail])
async def list_methodsamples(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            MethodSampleDB
        ).options(
            selectinload(MethodSampleDB.stage),
            selectinload(MethodSampleDB.status),
            selectinload(MethodSampleDB.user),
            
            selectinload(MethodSampleDB.scheme),
            selectinload(MethodSampleDB.service),
            selectinload(MethodSampleDB.method),
        )
    )
    methodsamples = result.scalars().all()
    return methodsamples

@router.put("/update/{id}", response_model=MethodSample)
async def update_methodsample(
    id: int, methodsample_update: MethodSample, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MethodSampleDB).where(MethodSampleDB.id == id))
    methodsample = result.scalar_one_or_none()

    if not methodsample:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Method Sample with id '{id}'",
        )

    # Update fields that are not None
    for key, value in methodsample_update.dict(exclude_unset=True).items():
        setattr(methodsample, key, value)

    try:
        await db.commit()
        await db.refresh(methodsample)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Method Sample {e}")
    return methodsample


@router.get("/id/{id}", response_model=ParamMethodSampleEdit)
async def get_methodsample(id: int, db: AsyncSession = Depends(get_db)):
    methodsampleItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(MethodSampleDB
            ).options(
                selectinload(MethodSampleDB.stage),
                selectinload(MethodSampleDB.status),
                selectinload(MethodSampleDB.user),
                
                selectinload(MethodSampleDB.scheme),
                selectinload(MethodSampleDB.service),
                selectinload(MethodSampleDB.method),
            )
            .filter(MethodSampleDB.id == id)
        )
        methodsampleItem = result.scalars().first()
        if not methodsampleItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Method Sample with id '{id}' not found"
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

    # Method
    result = await db.execute(
        select(MethodDB)
        .order_by(MethodDB.name)
    )
    methodItems =  result.scalars().all()


    res = ParamMethodSampleEdit(
            methodsample=methodsampleItem,
            schemeList = schemeItems,
            serviceList = serviceItems,
            methodList = methodItems,
    )

    return res


@router.put("/review-update/{id}", response_model=MethodSample)
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
    result = await db.execute(select(MethodSampleDB).where(MethodSampleDB.id == id))
    methodsample = result.scalar_one_or_none()

    if not methodsample:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Method Sample with id '{id}' not found",
        )

    if methodsample.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Method Sample with id '{id}' has already been approved",
        )

    methodsample.updated_by = user.email

    approveMethodSample = False

    if methodsample.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if methodsample.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Method Sample you created",
        )

        methodsample.review1_at = assist.get_current_date(False)
        methodsample.review1_by = user.email
        methodsample.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            methodsample.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if methodsample.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve methodsample
                approveMethodSample = True

            elif methodsample.approval_levels == 2 or methodsample.approval_levels == 3:
                # two or three levels, move to primary

                methodsample.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif methodsample.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if methodsample.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        methodsample.review2_at = assist.get_current_date(False)
        methodsample.review2_by = user.email
        methodsample.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            methodsample.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if methodsample.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveMethodSample = True

            elif methodsample.approval_levels == 3:
                # three levels, move to secondary
                methodsample.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif methodsample.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if methodsample.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        methodsample.review3_at = assist.get_current_date(False)
        methodsample.review3_by = user.email
        methodsample.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            methodsample.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveMethodSample = True

    if approveMethodSample:
        # change methodsample status
        methodsample.status_id = assist.STATUS_APPROVED
        methodsample.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(methodsample)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Method Sample: {e}")
    return methodsample


