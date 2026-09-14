from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.ptcyclestatus_model import PTCycleStatus, PTCycleStatusWithDetail, ParamPTCycleStatusEdit, PTCycleStatusDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/pt-cycle-statuses", tags=["PTCycleStatuss"])


@router.post("/create", response_model=PTCycleStatus)
async def post_ptcyclestatus(ptcyclestatus: PTCycleStatus, db: AsyncSession = Depends(get_db)):


    db_context = PTCycleStatusDB(
        # update
        name=ptcyclestatus.name,
        description=ptcyclestatus.description,
        # properties
        # approval
        user_id=ptcyclestatus.user_id,
        status_id=ptcyclestatus.status_id,
        stage_id=ptcyclestatus.stage_id,
        approval_levels=ptcyclestatus.approval_levels,
        # service
        created_by=ptcyclestatus.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create PT Cycle Status: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Upcoming'}, {'name': 'Started'}, {'name': 'Samples Shipped'}, {'name': 'Report Available'}, {'name': 'Closed'}]

    for value in itemList:
        db_item = PTCycleStatusDB(
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
            status_code=400, detail=f"Unable to initialize items for PT Cycle Status: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for PT Cycle Status have been successfully initialized",
    }



@router.get("/list", response_model=List[PTCycleStatusWithDetail])
async def list_ptcyclestatuss(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            PTCycleStatusDB
        ).options(
            selectinload(PTCycleStatusDB.stage),
            selectinload(PTCycleStatusDB.status),
            selectinload(PTCycleStatusDB.user),
            
        )
    )
    ptcyclestatuss = result.scalars().all()
    return ptcyclestatuss

@router.put("/update/{id}", response_model=PTCycleStatus)
async def update_ptcyclestatus(
    id: int, ptcyclestatus_update: PTCycleStatus, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(PTCycleStatusDB).where(PTCycleStatusDB.id == id))
    ptcyclestatus = result.scalar_one_or_none()

    if not ptcyclestatus:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Status with id '{id}'",
        )

    # Update fields that are not None
    for key, value in ptcyclestatus_update.dict(exclude_unset=True).items():
        setattr(ptcyclestatus, key, value)

    try:
        await db.commit()
        await db.refresh(ptcyclestatus)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Status {e}")
    return ptcyclestatus


@router.get("/id/{id}", response_model=ParamPTCycleStatusEdit)
async def get_ptcyclestatus(id: int, db: AsyncSession = Depends(get_db)):
    ptcyclestatusItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(PTCycleStatusDB
            ).options(
                selectinload(PTCycleStatusDB.stage),
                selectinload(PTCycleStatusDB.status),
                selectinload(PTCycleStatusDB.user),
                
            )
            .filter(PTCycleStatusDB.id == id)
        )
        ptcyclestatusItem = result.scalars().first()
        if not ptcyclestatusItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'PT Cycle Status with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamPTCycleStatusEdit(
            ptcyclestatus=ptcyclestatusItem,
    )

    return res


@router.put("/review-update/{id}", response_model=PTCycleStatus)
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
    result = await db.execute(select(PTCycleStatusDB).where(PTCycleStatusDB.id == id))
    ptcyclestatus = result.scalar_one_or_none()

    if not ptcyclestatus:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find PT Cycle Status with id '{id}' not found",
        )

    if ptcyclestatus.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The PT Cycle Status with id '{id}' has already been approved",
        )

    ptcyclestatus.updated_by = user.email

    approvePTCycleStatus = False

    if ptcyclestatus.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if ptcyclestatus.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a PT Cycle Status you created",
        )

        ptcyclestatus.review1_at = assist.get_current_date(False)
        ptcyclestatus.review1_by = user.email
        ptcyclestatus.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclestatus.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclestatus.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve ptcyclestatus
                approvePTCycleStatus = True

            elif ptcyclestatus.approval_levels == 2 or ptcyclestatus.approval_levels == 3:
                # two or three levels, move to primary

                ptcyclestatus.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif ptcyclestatus.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if ptcyclestatus.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        ptcyclestatus.review2_at = assist.get_current_date(False)
        ptcyclestatus.review2_by = user.email
        ptcyclestatus.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclestatus.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if ptcyclestatus.approval_levels == 2:
                # two levels, no furthur stage approvers

                approvePTCycleStatus = True

            elif ptcyclestatus.approval_levels == 3:
                # three levels, move to secondary
                ptcyclestatus.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif ptcyclestatus.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if ptcyclestatus.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        ptcyclestatus.review3_at = assist.get_current_date(False)
        ptcyclestatus.review3_by = user.email
        ptcyclestatus.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            ptcyclestatus.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approvePTCycleStatus = True

    if approvePTCycleStatus:
        # change ptcyclestatus status
        ptcyclestatus.status_id = assist.STATUS_APPROVED
        ptcyclestatus.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(ptcyclestatus)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update PT Cycle Status: {e}")
    return ptcyclestatus


