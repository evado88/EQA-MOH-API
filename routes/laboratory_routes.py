from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from database import get_db
from models.laboratory_model import Laboratory, LaboratoryWithDetail, ParamLaboratoryEdit, LaboratoryDB
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.labtype_model import LabTypeDB
from models.province_model import ProvinceDB
from models.district_model import DistrictDB
from models.applications_model import ApplicationsDB

router = APIRouter(prefix="/laboratorys", tags=["Laboratorys"])


async def _next_laboratory_code(db: AsyncSession) -> str:
    """Builds the next sequential registration code, e.g. REG0007"""
    result = await db.execute(select(LaboratoryDB.id).order_by(LaboratoryDB.id.desc()))
    last_id = result.scalars().first() or 0
    return f"REG{last_id + 1:04d}"


@router.post("/create", response_model=Laboratory)
async def post_laboratory(laboratory: Laboratory, db: AsyncSession = Depends(get_db)):


    db_context = LaboratoryDB(
        # update
        name=laboratory.name,
        description=laboratory.description,
        # properties
        contact_person_name=laboratory.contact_person_name,
        # an admin may supply a code, otherwise take the next one in sequence
        code=laboratory.code or await _next_laboratory_code(db),
        lab_type_id=laboratory.lab_type_id,
        position=laboratory.position,
        phone_number=laboratory.phone_number,
        province_id=laboratory.province_id,
        email_address=laboratory.email_address,
        district_id=laboratory.district_id,
        physical_address=laboratory.physical_address,
        # method list
        method_list = laboratory.method_list,
        # approval
        user_id=laboratory.user_id,
        status_id=laboratory.status_id,
        stage_id=laboratory.stage_id,
        approval_levels=laboratory.approval_levels,
        # service
        created_by=laboratory.created_by,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Laboratory: {e}")

    return db_context

@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):
    
    itemList = []

    for value in itemList:
        db_item = LaboratoryDB(
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
            status_code=400, detail=f"Unable to initialize items for Laboratory: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Laboratory have been successfully initialized",
    }



@router.get("/list", response_model=List[LaboratoryWithDetail])
async def list_laboratorys(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            LaboratoryDB
        ).options(
            selectinload(LaboratoryDB.stage),
            selectinload(LaboratoryDB.status),
            selectinload(LaboratoryDB.user),
            
            selectinload(LaboratoryDB.labtype),
            selectinload(LaboratoryDB.province),
            selectinload(LaboratoryDB.district),
        )
    )
    laboratorys = result.scalars().all()
    return laboratorys

@router.put("/update/{id}", response_model=Laboratory)
async def update_laboratory(
    id: int, laboratory_update: Laboratory, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(LaboratoryDB).where(LaboratoryDB.id == id))
    laboratory = result.scalar_one_or_none()

    if not laboratory:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Laboratory with id '{id}'",
        )

    # Update fields that are not None
    for key, value in laboratory_update.dict(exclude_unset=True).items():
        setattr(laboratory, key, value)

    try:
        await db.commit()
        await db.refresh(laboratory)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Laboratory {e}")
    return laboratory


@router.get("/id/{id}", response_model=ParamLaboratoryEdit)
async def get_laboratory(id: int, db: AsyncSession = Depends(get_db)):
    laboratoryItem = None
    # only load if not zero
    if id !=0:
        result = await db.execute(
            select(LaboratoryDB
            ).options(
                selectinload(LaboratoryDB.stage),
                selectinload(LaboratoryDB.status),
                selectinload(LaboratoryDB.user),
                
                selectinload(LaboratoryDB.labtype),
                selectinload(LaboratoryDB.province),
                selectinload(LaboratoryDB.district),
            )
            .filter(LaboratoryDB.id == id)
        )
        laboratoryItem = result.scalars().first()
        if not laboratoryItem:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Laboratory with id '{id}' not found"
            )

    # get supporting models if available

    # Lab Type
    result = await db.execute(
        select(LabTypeDB)
        .order_by(LabTypeDB.name)
    )
    labtypeItems =  result.scalars().all()

    # Province
    result = await db.execute(
        select(ProvinceDB)
        .order_by(ProvinceDB.name)
    )
    provinceItems =  result.scalars().all()

    # District
    result = await db.execute(
        select(DistrictDB)
        .order_by(DistrictDB.name)
    )
    districtItems =  result.scalars().all()


    res = ParamLaboratoryEdit(
            laboratory=laboratoryItem,
            labtypeList = labtypeItems,
            provinceList = provinceItems,
            districtList = districtItems,
    )

    return res


@router.put("/review-update/{id}", response_model=Laboratory)
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
    result = await db.execute(select(LaboratoryDB).where(LaboratoryDB.id == id))
    laboratory = result.scalar_one_or_none()

    if not laboratory:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Laboratory with id '{id}' not found",
        )

    if laboratory.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Laboratory with id '{id}' has already been approved",
        )

    laboratory.updated_by = user.email

    approveLaboratory = False

    if laboratory.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage
        
        if laboratory.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of a Laboratory you created",
        )

        laboratory.review1_at = assist.get_current_date(False)
        laboratory.review1_by = user.email
        laboratory.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            laboratory.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if laboratory.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve laboratory
                approveLaboratory = True

            elif laboratory.approval_levels == 2 or laboratory.approval_levels == 3:
                # two or three levels, move to primary

                laboratory.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif laboratory.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage
        
        if laboratory.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        laboratory.review2_at = assist.get_current_date(False)
        laboratory.review2_by = user.email
        laboratory.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            laboratory.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if laboratory.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveLaboratory = True

            elif laboratory.approval_levels == 3:
                # three levels, move to secondary
                laboratory.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif laboratory.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage
        
        if laboratory.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        laboratory.review3_at = assist.get_current_date(False)
        laboratory.review3_by = user.email
        laboratory.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            laboratory.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveLaboratory = True

    if laboratory.status_id == assist.STATUS_REJECTED:
        # a rejected registration takes its applications down with it, so the
        # lab is not left with methods it can enrol for
        await _set_application_status(
            db, laboratory.id, assist.STATUS_REJECTED, assist.APPROVAL_STAGE_SUBMITTED, user
        )

    if approveLaboratory:
        # change laboratory status
        laboratory.status_id = assist.STATUS_APPROVED
        laboratory.stage_id = assist.APPROVAL_STAGE_APPROVED

        # give the lab its super user account, the only way a lab gets in
        result = await db.execute(
            select(UserDB).where(UserDB.email == laboratory.email_address)
        )
        lab_user = result.scalars().first()

        if lab_user:
            # the contact already has an account - point it at this lab rather
            # than failing on the unique email
            lab_user.laboratory_id = laboratory.id
            lab_user.status_id = assist.STATUS_APPROVED
            lab_user.stage_id = assist.APPROVAL_STAGE_APPROVED
            lab_user.updated_by = user.email
        else:
            first_name, last_name = assist.extract_names(laboratory.contact_person_name)

            lab_user = UserDB(
                # id
                type=assist.USER_MEMBER,
                # personal details
                fname=first_name,
                lname=last_name or first_name,
                position=laboratory.position,
                # contact, address
                email=laboratory.email_address,
                mobile_code="+260",
                mobile=laboratory.phone_number,
                address_physical=laboratory.physical_address,
                address_postal=laboratory.physical_address,
                # account - a lab registration only ever grants a lab role
                role_id=assist.ROLE_FACILITY_SUPER_USER,
                password=assist.hash_password(assist.DEFAULT_LAB_PASSWORD),
                # the lab this account reports results for
                laboratory_id=laboratory.id,
                province_id=laboratory.province_id,
                district_id=laboratory.district_id,
                # approval
                status_id=assist.STATUS_APPROVED,
                stage_id=assist.APPROVAL_STAGE_APPROVED,
                approval_levels=1,
                # service
                created_by=user.email,
            )
            db.add(lab_user)
            try:
                await db.flush()
            except Exception as e:
                await db.rollback()
                raise HTTPException(
                    status_code=400,
                    detail=f"Could not create the account for this Laboratory: {e}",
                )

        # the lab record is now owned by its own super user
        laboratory.user_id = lab_user.id

        # the methods the lab registered for become approved applications, and
        # those are what it can enrol against in a cycle
        await _set_application_status(
            db, laboratory.id, assist.STATUS_APPROVED, assist.APPROVAL_STAGE_APPROVED, user
        )

    try:
        await db.commit()
        await db.refresh(laboratory)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Laboratory: {e}")
    return laboratory



async def _set_application_status(
    db: AsyncSession, lab_id: int, status_id: int, stage_id: int, user: UserDB
):
    """Carries a laboratory registration decision over to its applications.

    Only the applications still awaiting a decision are touched, so a
    re-review never overwrites a method an administrator has already ruled on
    individually.
    """
    result = await db.execute(
        select(ApplicationsDB).where(
            ApplicationsDB.lab_id == lab_id,
            ApplicationsDB.status_id.in_(
                [assist.STATUS_DRAFT, assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW]
            ),
        )
    )

    for application in result.scalars().all():
        application.status_id = status_id
        application.stage_id = stage_id
        application.review1_at = assist.get_current_date(False)
        application.review1_by = user.email
        application.review1_comments = "Set by the laboratory registration review"
        application.updated_by = user.email
        if application.user_id is None:
            application.user_id = user.id
