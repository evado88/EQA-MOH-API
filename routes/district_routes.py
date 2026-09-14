from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.district_model import District, DistrictWithDetail, ParamDistrictEdit, DistrictDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.province_model import ProvinceDB

router = APIRouter(prefix="/districts", tags=["Districts"])


@router.post("/create", response_model=District)
async def post_district(district: District, db: AsyncSession = Depends(get_db)):


    db_context = DistrictDB(
        # update
        name=district.name,
        description=district.description,
        # properties
        province_id=district.province_id,
        # approval
        user_id=district.user_id,
        status_id=district.status_id,
        stage_id=district.stage_id,
        approval_levels=district.approval_levels,
        # service
        created_by=district.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create District: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = [{'id': 1, 'name': 'Chililabombwe', 'province': 'Copperbelt', 'province_id': 2}, {'id': 2, 'name': 'Chingola', 'province': 'Copperbelt', 'province_id': 2}, {'id': 3, 'name': 'Kalulushi', 'province': 'Copperbelt', 'province_id': 2}, {'id': 4, 'name': 'Kitwe', 'province': 'Copperbelt', 'province_id': 2}, {'id': 5, 'name': 'Luanshya', 'province': 'Copperbelt', 'province_id': 2}, {'id': 6, 'name': 'Lufwanyama', 'province': 'Copperbelt', 'province_id': 2}, {'id': 7, 'name': 'Masaiti', 'province': 'Copperbelt', 'province_id': 2}, {'id': 8, 'name': 'Mpongwe', 'province': 'Copperbelt', 'province_id': 2}, {'id': 9, 'name': 'Mufulira', 'province': 'Copperbelt', 'province_id': 2}, {'id': 10, 'name': 'Ndola', 'province': 'Copperbelt', 'province_id': 2}, {'id': 11, 'name': 'Chadiza', 'province': 'Eastern', 'province_id': 3}, {'id': 12, 'name': 'Chama', 'province': 'Eastern', 'province_id': 3}, {'id': 13, 'name': 'Chasefu', 'province': 'Eastern', 'province_id': 3}, {'id': 14, 'name': 'Chipangali', 'province': 'Eastern', 'province_id': 3}, {'id': 15, 'name': 'Chipata', 'province': 'Eastern', 'province_id': 3}, {'id': 16, 'name': 'Kasenengwa', 'province': 'Eastern', 'province_id': 3}, {'id': 17, 'name': 'Katete', 'province': 'Eastern', 'province_id': 3}, {'id': 18, 'name': 'Lumezi', 'province': 'Eastern', 'province_id': 3}, {'id': 19, 'name': 'Lundazi', 'province': 'Eastern', 'province_id': 3}, {'id': 20, 'name': 'Mambwe', 'province': 'Eastern', 'province_id': 3}, {'id': 21, 'name': 'Nyimba', 'province': 'Eastern', 'province_id': 3}, {'id': 22, 'name': 'Petauke', 'province': 'Eastern', 'province_id': 3}, {'id': 23, 'name': 'Sinda', 'province': 'Eastern', 'province_id': 3}, {'id': 24, 'name': 'Vubwi', 'province': 'Eastern', 'province_id': 3}, {'id': 25, 'name': 'Itezhi-Tezhi', 'province': 'Central', 'province_id': 1}, {'id': 26, 'name': 'Kabwe', 'province': 'Central', 'province_id': 1}, {'id': 27, 'name': 'Kapiri Mposhi', 'province': 'Central', 'province_id': 1}, {'id': 28, 'name': 'Luano', 'province': 'Central', 'province_id': 1}, {'id': 29, 'name': 'Mkushi', 'province': 'Central', 'province_id': 1}, {'id': 30, 'name': 'Mumbwa', 'province': 'Central', 'province_id': 1}, {'id': 31, 'name': 'Ngabwe', 'province': 'Central', 'province_id': 1}, {'id': 32, 'name': 'Serenje', 'province': 'Central', 'province_id': 1}, {'id': 33, 'name': 'Shibuyunji', 'province': 'Central', 'province_id': 1}, {'id': 34, 'name': 'Chibombo', 'province': 'Lusaka', 'province_id': 5}, {'id': 35, 'name': 'Chilanga', 'province': 'Lusaka', 'province_id': 5}, {'id': 36, 'name': 'Chirundu', 'province': 'Lusaka', 'province_id': 5}, {'id': 37, 'name': 'Kafue', 'province': 'Lusaka', 'province_id': 5}, {'id': 38, 'name': 'Luangwa', 'province': 'Lusaka', 'province_id': 5}, {'id': 39, 'name': 'Lusaka', 'province': 'Lusaka', 'province_id': 5}, {'id': 40, 'name': 'Rufunsa', 'province': 'Lusaka', 'province_id': 5}, {'id': 41, 'name': 'Choma', 'province': 'Southern', 'province_id': 9}, {'id': 42, 'name': 'Gwembe', 'province': 'Southern', 'province_id': 9}, {'id': 43, 'name': 'Kalomo', 'province': 'Southern', 'province_id': 9}, {'id': 44, 'name': 'Kazungula', 'province': 'Southern', 'province_id': 9}, {'id': 45, 'name': 'Livingstone', 'province': 'Southern', 'province_id': 9}, {'id': 46, 'name': 'Mazabuka', 'province': 'Southern', 'province_id': 9}, {'id': 47, 'name': 'Monze', 'province': 'Southern', 'province_id': 9}, {'id': 48, 'name': 'Namwala', 'province': 'Southern', 'province_id': 9}, {'id': 49, 'name': 'Pemba', 'province': 'Southern', 'province_id': 9}, {'id': 50, 'name': 'Siavonga', 'province': 'Southern', 'province_id': 9}, {'id': 51, 'name': 'Sinazongwe', 'province': 'Southern', 'province_id': 9}, {'id': 52, 'name': 'Zimba', 'province': 'Southern', 'province_id': 9}, {'id': 53, 'name': 'Isoka', 'province': 'Muchinga', 'province_id': 6}, {'id': 54, 'name': 'Kanchibiya', 'province': 'Muchinga', 'province_id': 6}, {'id': 55, 'name': 'Lavushimanda', 'province': 'Muchinga', 'province_id': 6}, {'id': 56, 'name': 'Mafinga', 'province': 'Muchinga', 'province_id': 6}, {'id': 57, 'name': 'Mpika', 'province': 'Muchinga', 'province_id': 6}, {'id': 58, 'name': 'Nakonde', 'province': 'Muchinga', 'province_id': 6}, {'id': 59, 'name': "Shiwang'andu", 'province': 'Muchinga', 'province_id': 6}, {'id': 60, 'name': 'Chinsali', 'province': 'Muchinga', 'province_id': 6}, {'id': 61, 'name': 'Kasama', 'province': 'Northern', 'province_id': 7}, {'id': 62, 'name': 'Chilubi', 'province': 'Northern', 'province_id': 7}, {'id': 63, 'name': 'Kaputa', 'province': 'Northern', 'province_id': 7}, {'id': 64, 'name': 'Luwingu', 'province': 'Northern', 'province_id': 7}, {'id': 65, 'name': 'Mbala', 'province': 'Northern', 'province_id': 7}, {'id': 66, 'name': 'Mporokoso', 'province': 'Northern', 'province_id': 7}, {'id': 67, 'name': 'Mpulungu', 'province': 'Northern', 'province_id': 7}, {'id': 68, 'name': 'Nsama', 'province': 'Northern', 'province_id': 7}, {'id': 69, 'name': 'Senga Hill', 'province': 'Northern', 'province_id': 7}, {'id': 70, 'name': 'Lunte', 'province': 'Northern', 'province_id': 7}, {'id': 71, 'name': 'Mansa', 'province': 'Luapula', 'province_id': 4}, {'id': 72, 'name': 'Chembe', 'province': 'Luapula', 'province_id': 4}, {'id': 73, 'name': 'Chiengi', 'province': 'Luapula', 'province_id': 4}, {'id': 74, 'name': 'Chipili', 'province': 'Luapula', 'province_id': 4}, {'id': 75, 'name': 'Kawambwa', 'province': 'Luapula', 'province_id': 4}, {'id': 76, 'name': 'Lunga', 'province': 'Luapula', 'province_id': 4}, {'id': 77, 'name': 'Milenge', 'province': 'Luapula', 'province_id': 4}, {'id': 78, 'name': 'Mwansabombwe', 'province': 'Luapula', 'province_id': 4}, {'id': 79, 'name': 'Mwense', 'province': 'Luapula', 'province_id': 4}, {'id': 80, 'name': 'Nchelenge', 'province': 'Luapula', 'province_id': 4}, {'id': 81, 'name': 'Samfya', 'province': 'Luapula', 'province_id': 4}, {'id': 82, 'name': 'Mongu', 'province': 'Western', 'province_id': 10}, {'id': 83, 'name': 'Kalabo', 'province': 'Western', 'province_id': 10}, {'id': 84, 'name': 'Kaoma', 'province': 'Western', 'province_id': 10}, {'id': 85, 'name': 'Limulunga', 'province': 'Western', 'province_id': 10}, {'id': 86, 'name': 'Lukulu', 'province': 'Western', 'province_id': 10}, {'id': 87, 'name': 'Mitete', 'province': 'Western', 'province_id': 10}, {'id': 88, 'name': 'Nalolo', 'province': 'Western', 'province_id': 10}, {'id': 89, 'name': 'Nkeyema', 'province': 'Western', 'province_id': 10}, {'id': 90, 'name': 'Senanga', 'province': 'Western', 'province_id': 10}, {'id': 91, 'name': 'Sesheke', 'province': 'Western', 'province_id': 10}, {'id': 92, 'name': 'Shangombo', 'province': 'Western', 'province_id': 10}, {'id': 93, 'name': 'Sikongo', 'province': 'Western', 'province_id': 10}, {'id': 94, 'name': 'Sioma', 'province': 'Western', 'province_id': 10}, {'id': 95, 'name': 'Kabompo', 'province': 'North-Western', 'province_id': 8}, {'id': 96, 'name': 'Chavuma', 'province': 'North-Western', 'province_id': 8}, {'id': 97, 'name': 'Ikelenge', 'province': 'North-Western', 'province_id': 8}, {'id': 98, 'name': 'Kalumbila', 'province': 'North-Western', 'province_id': 8}, {'id': 99, 'name': 'Kasempa', 'province': 'North-Western', 'province_id': 8}, {'id': 100, 'name': 'Manyinga', 'province': 'North-Western', 'province_id': 8}, {'id': 101, 'name': 'Mufumbwe', 'province': 'North-Western', 'province_id': 8}, {'id': 102, 'name': 'Mwinilunga', 'province': 'North-Western', 'province_id': 8}, {'id': 103, 'name': 'Solwezi', 'province': 'North-Western', 'province_id': 8}, {'id': 104, 'name': 'Zambezi', 'province': 'North-Western', 'province_id': 8}]

    for value in itemList:
        db_item = DistrictDB(
            # add item
            name=value["name"],
            province_id=value["province_id"],
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
            status_code=400, detail=f"Unable to initialize items for District: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for District have been successfully initialized",
    }



@router.get("/list", response_model=List[DistrictWithDetail])
async def list_districts(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            DistrictDB
        ).options(
            selectinload(DistrictDB.stage),
            selectinload(DistrictDB.status),
            selectinload(DistrictDB.user),
            
            selectinload(DistrictDB.province),
        )
    )
    districts = result.scalars().all()
    return districts

@router.put("/update/{id}", response_model=District)
async def update_district(
    id: int, district_update: District, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(DistrictDB).where(DistrictDB.id == id))
    district = result.scalar_one_or_none()

    if not district:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find District with id '{id}'",
        )

    # Update fields that are not None
    for key, value in district_update.dict(exclude_unset=True).items():
        setattr(district, key, value)

    try:
        await db.commit()
        await db.refresh(district)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update District {e}")
    return district


@router.get("/id/{id}", response_model=ParamDistrictEdit)
async def get_district(id: int, db: AsyncSession = Depends(get_db)):
    districtItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(DistrictDB
            ).options(
                selectinload(DistrictDB.stage),
                selectinload(DistrictDB.status),
                selectinload(DistrictDB.user),
                
                selectinload(DistrictDB.province),
            )
            .filter(DistrictDB.id == id)
        )
        districtItem = result.scalars().first()
        if not districtItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'District with id '{id}' not found"
            )

    # get supporting models if available

    # Province
    result = await db.execute(
        select(ProvinceDB)
        .order_by(ProvinceDB.name)
    )
    provinceItems =  result.scalars().all()


    res = ParamDistrictEdit(
            district=districtItem,
            provinceList = provinceItems,
    )

    return res


@router.put("/review-update/{id}", response_model=District)
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
    result = await db.execute(select(DistrictDB).where(DistrictDB.id == id))
    district = result.scalar_one_or_none()

    if not district:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find District with id '{id}' not found",
        )

    if district.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The District with id '{id}' has already been approved",
        )

    district.updated_by = user.email

    approveDistrict = False

    if district.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if district.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a District you created",
        )

        district.review1_at = assist.get_current_date(False)
        district.review1_by = user.email
        district.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            district.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if district.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve district
                approveDistrict = True

            elif district.approval_levels == 2 or district.approval_levels == 3:
                # two or three levels, move to primary

                district.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif district.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if district.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        district.review2_at = assist.get_current_date(False)
        district.review2_by = user.email
        district.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            district.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if district.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveDistrict = True

            elif district.approval_levels == 3:
                # three levels, move to secondary
                district.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif district.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if district.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        district.review3_at = assist.get_current_date(False)
        district.review3_by = user.email
        district.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            district.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveDistrict = True

    if approveDistrict:
        # change district status
        district.status_id = assist.STATUS_APPROVED
        district.stage_id = assist.APPROVAL_STAGE_APPROVED

        # attachment may or may not be provided

    try:
        await db.commit()
        await db.refresh(district)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update District: {e}")
    return district


