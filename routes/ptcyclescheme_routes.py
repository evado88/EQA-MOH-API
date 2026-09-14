from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.ptcyclescheme_model import PTCycleScheme, PTCycleSchemeWithDetail, ParamPTCycleSchemeEdit, PTCycleSchemeDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/pt-cycle-schemes", tags=["PTCycleSchemes"])


@router.post("/create", response_model=PTCycleScheme)
async def post_ptcyclescheme(ptcyclescheme: PTCycleScheme, db: AsyncSession = Depends(get_db)):


    db_context = PTCycleSchemeDB(
        # update
        name=ptcyclescheme.name,
        description=ptcyclescheme.description,
        # properties
        # approval
        user_id=ptcyclescheme.user_id,
        status_id=ptcyclescheme.status_id,
        stage_id=ptcyclescheme.stage_id,
        approval_levels=ptcyclescheme.approval_levels,
        # service
        created_by=ptcyclescheme.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create PT Cycle Scheme: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'ultra-CDL-2026-A-1'}, {'name': 'ultra-CDL-2026-A-2'}, {'name': 'ultra-CDL-2026-A-3'}, {'name': 'ultra-CDL-2026-A-4'}, {'name': 'ultra-CDL-2026-A-5'}]

    for value in itemList:
        db_item = PTCycleSchemeDB(
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
            status_code=400, detail=f"Unable to initialize items for PT Cycle Scheme: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for PT Cycle Scheme have been successfully initialized",
    }



@router.get("/list", response_model=List[PTCycleSchemeWithDetail])
async def list_ptcycleschemes(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            PTCycleSchemeDB
        ).options(
            selectinload(PTCycleSchemeDB.stage),
            selectinload(PTCycleSchemeDB.status),
            selectinload(PTCycleSchemeDB.user),
            
        )
    )
    ptcycleschemes = result.scalars().all()
    return ptcycleschemes

@router.put("/update/{id}", response_model=PTCycleScheme)
async def update_ptcyclescheme(
    id: int, ptcyclescheme_update: PTCycleScheme, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(PTCycleSchemeDB).where(PTCycleSchemeDB.id == id))
    ptcyclescheme = result.scalar_one_or_none()

    if not ptcyclescheme:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Scheme with id '{id}'",
        )

    # Update fields that are not None
    for key, value in ptcyclescheme_update.dict(exclude_unset=True).items():
        setattr(ptcyclescheme, key, value)

    try:
        await db.commit()
        await db.refresh(ptcyclescheme)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Scheme {e}")
    return ptcyclescheme


@router.get("/id/{id}", response_model=ParamPTCycleSchemeEdit)
async def get_ptcyclescheme(id: int, db: AsyncSession = Depends(get_db)):
    ptcycleschemeItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(PTCycleSchemeDB
            ).options(
                selectinload(PTCycleSchemeDB.stage),
                selectinload(PTCycleSchemeDB.status),
                selectinload(PTCycleSchemeDB.user),
                
            )
            .filter(PTCycleSchemeDB.id == id)
        )
        ptcycleschemeItem = result.scalars().first()
        if not ptcycleschemeItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'PT Cycle Scheme with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamPTCycleSchemeEdit(
            ptcyclescheme=ptcycleschemeItem,
    )

    return res


@router.put("/review-update/{id}", response_model=PTCycleScheme)
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
    result = await db.execute(select(PTCycleSchemeDB).where(PTCycleSchemeDB.id == id))
    ptcyclescheme = result.scalar_one_or_none()

    if not ptcyclescheme:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Scheme with id '{id}' not found",
        )

    if ptcyclescheme.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The PT Cycle Scheme with id '{id}' has already been approved",
        )

    ptcyclescheme.updated_by = user.email

    approvePTCycleScheme = False

    if ptcyclescheme.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if ptcyclescheme.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a PT Cycle Scheme you created",
        )

        ptcyclescheme.review1_at = assist.get_current_date(False)
        ptcyclescheme.review1_by = user.email
        ptcyclescheme.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclescheme.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclescheme.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve ptcyclescheme
                approvePTCycleScheme = True

            elif ptcyclescheme.approval_levels == 2 or ptcyclescheme.approval_levels == 3:
                # two or three levels, move to primary

                ptcyclescheme.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif ptcyclescheme.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if ptcyclescheme.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        ptcyclescheme.review2_at = assist.get_current_date(False)
        ptcyclescheme.review2_by = user.email
        ptcyclescheme.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclescheme.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclescheme.approval_levels == 2:
                # two levels, no furthur stage approvers

                approvePTCycleScheme = True

            elif ptcyclescheme.approval_levels == 3:
                # three levels, move to secondary
                ptcyclescheme.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif ptcyclescheme.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if ptcyclescheme.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        ptcyclescheme.review3_at = assist.get_current_date(False)
        ptcyclescheme.review3_by = user.email
        ptcyclescheme.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclescheme.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approvePTCycleScheme = True

    if approvePTCycleScheme:
        # change ptcyclescheme status
        ptcyclescheme.status_id = assist.STATUS_APPROVED
        ptcyclescheme.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(ptcyclescheme)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Scheme: {e}")
    return ptcyclescheme


