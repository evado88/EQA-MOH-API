from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.ptcyclesample_model import PTCycleSample, PTCycleSampleWithDetail, ParamPTCycleSampleEdit, PTCycleSampleDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.service_model import ServiceDB
from models.method_model import MethodDB

router = APIRouter(prefix="/pt-cycle-samples", tags=["PTCycleSamples"])


@router.post("/create", response_model=PTCycleSample)
async def post_ptcyclesample(ptcyclesample: PTCycleSample, db: AsyncSession = Depends(get_db)):


    db_context = PTCycleSampleDB(
        # update
        name=ptcyclesample.name,
        description=ptcyclesample.description,
        # properties
        service_id=ptcyclesample.service_id,
        method_id=ptcyclesample.method_id,
        # approval
        user_id=ptcyclesample.user_id,
        status_id=ptcyclesample.status_id,
        stage_id=ptcyclesample.stage_id,
        approval_levels=ptcyclesample.approval_levels,
        # service
        created_by=ptcyclesample.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create PT Cycle Sample: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'ultra-CDL-2026-A-1'}, {'name': 'ultra-CDL-2026-A-2'}, {'name': 'ultra-CDL-2026-A-3'}, {'name': 'ultra-CDL-2026-A-4'}, {'name': 'ultra-CDL-2026-A-5'}]

    for value in itemList:
        db_item = PTCycleSampleDB(
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
            status_code=400, detail=f"Unable to initialize items for PT Cycle Sample: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for PT Cycle Sample have been successfully initialized",
    }



@router.get("/list", response_model=List[PTCycleSampleWithDetail])
async def list_ptcyclesamples(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            PTCycleSampleDB
        ).options(
            selectinload(PTCycleSampleDB.stage),
            selectinload(PTCycleSampleDB.status),
            selectinload(PTCycleSampleDB.user),
            
            selectinload(PTCycleSampleDB.service),
            selectinload(PTCycleSampleDB.method),
        )
    )
    ptcyclesamples = result.scalars().all()
    return ptcyclesamples

@router.put("/update/{id}", response_model=PTCycleSample)
async def update_ptcyclesample(
    id: int, ptcyclesample_update: PTCycleSample, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(PTCycleSampleDB).where(PTCycleSampleDB.id == id))
    ptcyclesample = result.scalar_one_or_none()

    if not ptcyclesample:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Sample with id '{id}'",
        )

    # Update fields that are not None
    for key, value in ptcyclesample_update.dict(exclude_unset=True).items():
        setattr(ptcyclesample, key, value)

    try:
        await db.commit()
        await db.refresh(ptcyclesample)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Sample {e}")
    return ptcyclesample


@router.get("/id/{id}", response_model=ParamPTCycleSampleEdit)
async def get_ptcyclesample(id: int, db: AsyncSession = Depends(get_db)):
    ptcyclesampleItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(PTCycleSampleDB
            ).options(
                selectinload(PTCycleSampleDB.stage),
                selectinload(PTCycleSampleDB.status),
                selectinload(PTCycleSampleDB.user),
                
                selectinload(PTCycleSampleDB.service),
                selectinload(PTCycleSampleDB.method),
            )
            .filter(PTCycleSampleDB.id == id)
        )
        ptcyclesampleItem = result.scalars().first()
        if not ptcyclesampleItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'PT Cycle Sample with id '{id}' not found"
            )

    # get supporting models if available

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


    res = ParamPTCycleSampleEdit(
            ptcyclesample=ptcyclesampleItem,
            serviceList = serviceItems,
            methodList = methodItems,
    )

    return res


@router.put("/review-update/{id}", response_model=PTCycleSample)
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
    result = await db.execute(select(PTCycleSampleDB).where(PTCycleSampleDB.id == id))
    ptcyclesample = result.scalar_one_or_none()

    if not ptcyclesample:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Sample with id '{id}' not found",
        )

    if ptcyclesample.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The PT Cycle Sample with id '{id}' has already been approved",
        )

    ptcyclesample.updated_by = user.email

    approvePTCycleSample = False

    if ptcyclesample.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if ptcyclesample.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a PT Cycle Sample you created",
        )

        ptcyclesample.review1_at = assist.get_current_date(False)
        ptcyclesample.review1_by = user.email
        ptcyclesample.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclesample.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclesample.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve ptcyclesample
                approvePTCycleSample = True

            elif ptcyclesample.approval_levels == 2 or ptcyclesample.approval_levels == 3:
                # two or three levels, move to primary

                ptcyclesample.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif ptcyclesample.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if ptcyclesample.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        ptcyclesample.review2_at = assist.get_current_date(False)
        ptcyclesample.review2_by = user.email
        ptcyclesample.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclesample.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclesample.approval_levels == 2:
                # two levels, no furthur stage approvers

                approvePTCycleSample = True

            elif ptcyclesample.approval_levels == 3:
                # three levels, move to secondary
                ptcyclesample.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif ptcyclesample.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if ptcyclesample.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        ptcyclesample.review3_at = assist.get_current_date(False)
        ptcyclesample.review3_by = user.email
        ptcyclesample.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclesample.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approvePTCycleSample = True

    if approvePTCycleSample:
        # change ptcyclesample status
        ptcyclesample.status_id = assist.STATUS_APPROVED
        ptcyclesample.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(ptcyclesample)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Sample: {e}")
    return ptcyclesample


