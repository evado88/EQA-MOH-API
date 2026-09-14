from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.province_model import Province, ProvinceWithDetail, ParamProvinceEdit, ProvinceDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations

router = APIRouter(prefix="/provinces", tags=["Provinces"])


@router.post("/create", response_model=Province)
async def post_province(province: Province, db: AsyncSession = Depends(get_db)):


    db_context = ProvinceDB(
        # update
        name=province.name,
        description=province.description,
        # properties
        code=province.code,
        # approval
        user_id=province.user_id,
        status_id=province.status_id,
        stage_id=province.stage_id,
        approval_levels=province.approval_levels,
        # service
        created_by=province.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Province: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'id': 1, 'name': 'Central', 'iso_code': 'ZM-02'}, {'id': 2, 'name': 'Copperbelt', 'iso_code': 'ZM-08'}, {'id': 3, 'name': 'Eastern', 'iso_code': 'ZM-03'}, {'id': 4, 'name': 'Luapula', 'iso_code': 'ZM-04'}, {'id': 5, 'name': 'Lusaka', 'iso_code': 'ZM-09'}, {'id': 6, 'name': 'Muchinga', 'iso_code': 'ZM-10'}, {'id': 7, 'name': 'Northern', 'iso_code': 'ZM-05'}, {'id': 8, 'name': 'North-Western', 'iso_code': 'ZM-06'}, {'id': 9, 'name': 'Southern', 'iso_code': 'ZM-07'}, {'id': 10, 'name': 'Western', 'iso_code': 'ZM-01'}]

    for value in itemList:
        db_item = ProvinceDB(
            # add item
            name=value["name"],
            code=value["iso_code"],
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
            status_code=400, detail=f"Unable to initialize items for Province: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Province have been successfully initialized",
    }



@router.get("/list", response_model=List[ProvinceWithDetail])
async def list_provinces(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            ProvinceDB
        ).options(
            selectinload(ProvinceDB.stage),
            selectinload(ProvinceDB.status),
            selectinload(ProvinceDB.user),
            
        )
    )
    provinces = result.scalars().all()
    return provinces

@router.put("/update/{id}", response_model=Province)
async def update_province(
    id: int, province_update: Province, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(ProvinceDB).where(ProvinceDB.id == id))
    province = result.scalar_one_or_none()

    if not province:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Province with id '{id}'",
        )

    # Update fields that are not None
    for key, value in province_update.dict(exclude_unset=True).items():
        setattr(province, key, value)

    try:
        await db.commit()
        await db.refresh(province)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Province {e}")
    return province


@router.get("/id/{id}", response_model=ParamProvinceEdit)
async def get_province(id: int, db: AsyncSession = Depends(get_db)):
    provinceItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(ProvinceDB
            ).options(
                selectinload(ProvinceDB.stage),
                selectinload(ProvinceDB.status),
                selectinload(ProvinceDB.user),
                
            )
            .filter(ProvinceDB.id == id)
        )
        provinceItem = result.scalars().first()
        if not provinceItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Province with id '{id}' not found"
            )

    # get supporting models if available


    res = ParamProvinceEdit(
            province=provinceItem,
    )

    return res


@router.put("/review-update/{id}", response_model=Province)
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
    result = await db.execute(select(ProvinceDB).where(ProvinceDB.id == id))
    province = result.scalar_one_or_none()

    if not province:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Province with id '{id}' not found",
        )

    if province.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Province with id '{id}' has already been approved",
        )

    province.updated_by = user.email

    approveProvince = False

    if province.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if province.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Province you created",
        )

        province.review1_at = assist.get_current_date(False)
        province.review1_by = user.email
        province.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            province.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if province.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve province
                approveProvince = True

            elif province.approval_levels == 2 or province.approval_levels == 3:
                # two or three levels, move to primary

                province.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif province.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if province.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        province.review2_at = assist.get_current_date(False)
        province.review2_by = user.email
        province.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            province.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if province.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveProvince = True

            elif province.approval_levels == 3:
                # three levels, move to secondary
                province.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif province.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if province.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        province.review3_at = assist.get_current_date(False)
        province.review3_by = user.email
        province.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            province.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveProvince = True

    if approveProvince:
        # change province status
        province.status_id = assist.STATUS_APPROVED
        province.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(province)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Province: {e}")
    return province


