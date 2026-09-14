from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.role_model import Role, RoleWithDetail, ParamRoleEdit, RoleDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/role", tags=["Roles"])


@router.post("/create", response_model=Role)
async def post_role(role: Role, db: AsyncSession = Depends(get_db)):


    db_context = RoleDB(
        # update
        name=role.name,
        description=role.description,
        # properties
        # approval
        user_id=role.user_id,
        status_id=role.status_id,
        stage_id=role.stage_id,
        approval_levels=role.approval_levels,
        # service
        created_by=role.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Role: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'name': 'Administrator'}, {'name': 'Scheme Head'}, {'name': 'Scheme Coordinator'}, {'name': 'Scheme Quality Officers'}, {'name': 'Finance Officers'}, {'name': 'Provincial Biomedical Scientists (PBs)'}, {'name': 'EQA/QMS Focal Point Persons (FPPs)'}, {'name': 'District Laboratory Coordinators '}, {'name': 'Facility Super User'}, {'name': 'Facility Staff'}]

    for value in itemList:
        db_item = RoleDB(
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
            status_code=400, detail=f"Unable to initialize items for Role: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Role have been successfully initialized",
    }



@router.get("/list", response_model=List[RoleWithDetail])
async def list_roles(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            RoleDB
        ).options(
            selectinload(RoleDB.stage),
            selectinload(RoleDB.status),
            selectinload(RoleDB.user),
            
        )
    )
    roles = result.scalars().all()
    return roles

@router.put("/update/{id}", response_model=Role)
async def update_role(
    id: int, role_update: Role, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(RoleDB).where(RoleDB.id == id))
    role = result.scalar_one_or_none()

    if not role:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Role with id '{id}'",
        )

    # Update fields that are not None
    for key, value in role_update.dict(exclude_unset=True).items():
        setattr(role, key, value)

    try:
        await db.commit()
        await db.refresh(role)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Role {e}")
    return role


@router.get("/id/{id}", response_model=ParamRoleEdit)
async def get_role(id: int, db: AsyncSession = Depends(get_db)):
    roleItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(RoleDB
            ).options(
                selectinload(RoleDB.stage),
                selectinload(RoleDB.status),
                selectinload(RoleDB.user),
                
            )
            .filter(RoleDB.id == id)
        )
        roleItem = result.scalars().first()
        if not roleItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Role with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamRoleEdit(
            role=roleItem,
    )

    return res


@router.put("/review-update/{id}", response_model=Role)
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
    result = await db.execute(select(RoleDB).where(RoleDB.id == id))
    role = result.scalar_one_or_none()

    if not role:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Role with id '{id}' not found",
        )

    if role.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Role with id '{id}' has already been approved",
        )

    role.updated_by = user.email

    approveRole = False

    if role.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if role.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Role you created",
        )

        role.review1_at = assist.get_current_date(False)
        role.review1_by = user.email
        role.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            role.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if role.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve role
                approveRole = True

            elif role.approval_levels == 2 or role.approval_levels == 3:
                # two or three levels, move to primary

                role.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif role.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if role.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        role.review2_at = assist.get_current_date(False)
        role.review2_by = user.email
        role.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            role.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if role.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveRole = True

            elif role.approval_levels == 3:
                # three levels, move to secondary
                role.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif role.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if role.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        role.review3_at = assist.get_current_date(False)
        role.review3_by = user.email
        role.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            role.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveRole = True

    if approveRole:
        # change role status
        role.status_id = assist.STATUS_APPROVED
        role.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(role)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Role: {e}")
    return role


