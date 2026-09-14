from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.labtype_model import LabType, LabTypeWithDetail, ParamLabTypeEdit, LabTypeDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/lab-types", tags=["LabTypes"])


@router.post("/create", response_model=LabType)
async def post_labtype(labtype: LabType, db: AsyncSession = Depends(get_db)):


    db_context = LabTypeDB(
        # update
        name=labtype.name,
        description=labtype.description,
        # properties
        # approval
        user_id=labtype.user_id,
        status_id=labtype.status_id,
        stage_id=labtype.stage_id,
        approval_levels=labtype.approval_levels,
        # service
        created_by=labtype.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Lab Type: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Government'}, {'name': 'Private'}, {'name': 'Religious'}]

    for value in itemList:
        db_item = LabTypeDB(
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
            status_code=400, detail=f"Unable to initialize items for Lab Type: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Lab Type have been successfully initialized",
    }



@router.get("/list", response_model=List[LabTypeWithDetail])
async def list_labtypes(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            LabTypeDB
        ).options(
            selectinload(LabTypeDB.stage),
            selectinload(LabTypeDB.status),
            selectinload(LabTypeDB.user),
            
        )
    )
    labtypes = result.scalars().all()
    return labtypes

@router.put("/update/{id}", response_model=LabType)
async def update_labtype(
    id: int, labtype_update: LabType, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(LabTypeDB).where(LabTypeDB.id == id))
    labtype = result.scalar_one_or_none()

    if not labtype:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Lab Type with id '{id}'",
        )

    # Update fields that are not None
    for key, value in labtype_update.dict(exclude_unset=True).items():
        setattr(labtype, key, value)

    try:
        await db.commit()
        await db.refresh(labtype)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Lab Type {e}")
    return labtype


@router.get("/id/{id}", response_model=ParamLabTypeEdit)
async def get_labtype(id: int, db: AsyncSession = Depends(get_db)):
    labtypeItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(LabTypeDB
            ).options(
                selectinload(LabTypeDB.stage),
                selectinload(LabTypeDB.status),
                selectinload(LabTypeDB.user),
                
            )
            .filter(LabTypeDB.id == id)
        )
        labtypeItem = result.scalars().first()
        if not labtypeItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Lab Type with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamLabTypeEdit(
            labtype=labtypeItem,
    )

    return res


@router.put("/review-update/{id}", response_model=LabType)
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
    result = await db.execute(select(LabTypeDB).where(LabTypeDB.id == id))
    labtype = result.scalar_one_or_none()

    if not labtype:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Lab Type with id '{id}' not found",
        )

    if labtype.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Lab Type with id '{id}' has already been approved",
        )

    labtype.updated_by = user.email

    approveLabType = False

    if labtype.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if labtype.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Lab Type you created",
        )

        labtype.review1_at = assist.get_current_date(False)
        labtype.review1_by = user.email
        labtype.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            labtype.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if labtype.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve labtype
                approveLabType = True

            elif labtype.approval_levels == 2 or labtype.approval_levels == 3:
                # two or three levels, move to primary

                labtype.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif labtype.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if labtype.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        labtype.review2_at = assist.get_current_date(False)
        labtype.review2_by = user.email
        labtype.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            labtype.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if labtype.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveLabType = True

            elif labtype.approval_levels == 3:
                # three levels, move to secondary
                labtype.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif labtype.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if labtype.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        labtype.review3_at = assist.get_current_date(False)
        labtype.review3_by = user.email
        labtype.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            labtype.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveLabType = True

    if approveLabType:
        # change labtype status
        labtype.status_id = assist.STATUS_APPROVED
        labtype.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(labtype)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Lab Type: {e}")
    return labtype


