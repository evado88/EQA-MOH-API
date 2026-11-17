from fastapi import APIRouter, Depends, Form, HTTPException, Query
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List, Optional

from database import get_db
from helpers import assist
from helpers.auth import require_system_admin, require_user, CurrentUser
from models.user_model import (
    ParamFacilityUser,
    ParamUserEdit,
    User,
    UserDB,
    UserSave,
    UserWithDetail,
)
from models.district_model import DistrictDB
from models.facility_model import FacilityDB
from models.laboratory_model import LaboratoryDB
from models.province_model import ProvinceDB
from models.role_model import RoleDB
from models.scheme_model import SchemeDB

router = APIRouter(prefix="/users", tags=["Users"])

async def _find_by_email(db: AsyncSession, email: str, ignore_id=None):
    """The account already using this email, if any.

    The column is unique, so without this a duplicate surfaces as a constraint
    violation rather than as something an admin can act on.
    """
    query = select(UserDB).where(UserDB.email == email)
    if ignore_id is not None:
        query = query.where(UserDB.id != ignore_id)

    result = await db.execute(query)
    return result.scalars().first()


# the fields the form owns; everything else about an account is set by the
# workflow that created it
EDITABLE_USER_FIELDS = [
    "code",
    "fname",
    "lname",
    "position",
    "email",
    "mobile_code",
    "mobile",
    "address_physical",
    "address_postal",
    "role_id",
    "laboratory_id",
    "scheme_id",
    "province_id",
    "district_id",
]


@router.post("/create", response_model=UserWithDetail)
async def create_user(
    user: UserSave,
    db: AsyncSession = Depends(get_db),
    _admin: CurrentUser = Depends(require_system_admin),
):
    """Opens an account for a member of staff.

    A laboratory normally gets its account when its registration is approved;
    this is how everybody else gets one, and how a laboratory gets a second.
    """
    if not user.password:
        raise HTTPException(
            status_code=400, detail="A password must be set for a new account"
        )

    if await _find_by_email(db, user.email):
        raise HTTPException(
            status_code=400,
            detail=f"An account already exists for '{user.email}'",
        )

    db_user = UserDB(
        type=user.type or assist.USER_MEMBER,
        password=assist.hash_password(user.password),
        # an account opened by an administrator is already settled; a user is
        # not an item that goes out for review
        status_id=assist.STATUS_APPROVED,
        stage_id=assist.APPROVAL_STAGE_APPROVED,
        approval_levels=1,
        created_by=user.created_by,
    )

    for field in EDITABLE_USER_FIELDS:
        setattr(db_user, field, getattr(user, field))

    db.add(db_user)
    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to create user: {e}")

    return await _load_detail(db, db_user.id)


@router.post("/create-facility", response_model=UserWithDetail)
async def create_facility_user(
    param: ParamFacilityUser,
    db: AsyncSession = Depends(get_db),
    caller: CurrentUser = Depends(require_user),
):
    """Opens an account for facility staff.

    A facility Super User may do this for their own facility only; an
    Administrator may do it for any facility. The role is restricted to the
    facility roles, and the account's facility/laboratory/location is set from
    the creator (Super User) or the chosen facility (admin) - never from the
    form - so staff always land on the right laboratory's work.
    """
    is_admin = assist.is_system_admin(caller.role_id)
    is_super = caller.role_id == assist.ROLE_FACILITY_SUPER_USER
    if not (is_admin or is_super):
        raise HTTPException(
            status_code=403,
            detail="Only an administrator or a facility super user may open facility accounts",
        )

    if param.role_id not in assist.LABORATORY_ROLES:
        raise HTTPException(
            status_code=400,
            detail="A facility account must be a Facility Super User or Facility Staff",
        )

    if await _find_by_email(db, param.email):
        raise HTTPException(
            status_code=400,
            detail=f"An account already exists for '{param.email}'",
        )

    # resolve which facility (and laboratory/location) the account belongs to
    if is_super:
        creator = (
            await db.execute(select(UserDB).where(UserDB.id == caller.id))
        ).scalar_one_or_none()
        if not creator or not creator.facility_id:
            raise HTTPException(
                status_code=400,
                detail="Your account is not linked to a facility, so you cannot open facility accounts",
            )
        facility_id = creator.facility_id
        facility_name = creator.facility_name
        laboratory_id = creator.laboratory_id
        province_id = creator.province_id
        district_id = creator.district_id
    else:
        if not param.facility_id:
            raise HTTPException(
                status_code=400,
                detail="Please choose the facility this account belongs to",
            )
        facility = (
            await db.execute(
                select(FacilityDB).where(FacilityDB.id == param.facility_id)
            )
        ).scalar_one_or_none()
        if not facility:
            raise HTTPException(
                status_code=400, detail="The selected facility was not found"
            )
        facility_id = facility.id
        facility_name = facility.name
        laboratory_id = param.laboratory_id
        province_id = facility.province_id
        district_id = facility.district_id

    db_user = UserDB(
        type=assist.USER_MEMBER,
        fname=param.fname.strip(),
        lname=param.lname.strip(),
        position=(param.position or "").strip() or None,
        email=param.email.lower().strip(),
        mobile_code=(param.mobile_code or "+260").strip(),
        mobile=param.mobile.strip(),
        role_id=param.role_id,
        password=assist.hash_password(param.password),
        # opened on someone's behalf: active at once, no verification step
        status_id=assist.STATUS_APPROVED,
        stage_id=assist.APPROVAL_STAGE_APPROVED,
        approval_levels=1,
        email_verified=True,
        laboratory_id=laboratory_id,
        facility_id=facility_id,
        facility_name=facility_name,
        province_id=province_id,
        district_id=district_id,
        created_by=caller.email,
    )
    db.add(db_user)
    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to create the account: {e}")

    return await _load_detail(db, db_user.id)


@router.get("/facility-list", response_model=List[UserWithDetail])
async def list_facility_users(
    facility_id: Optional[int] = Query(default=None),
    db: AsyncSession = Depends(get_db),
    caller: CurrentUser = Depends(require_user),
):
    """The accounts belonging to a facility.

    A Super User sees their own facility's accounts (the query param is
    ignored); an Administrator sees the accounts of the facility they ask for.
    """
    is_admin = assist.is_system_admin(caller.role_id)
    is_super = caller.role_id == assist.ROLE_FACILITY_SUPER_USER
    if not (is_admin or is_super):
        raise HTTPException(
            status_code=403,
            detail="Only an administrator or a facility super user may view facility accounts",
        )

    if is_super:
        creator = (
            await db.execute(select(UserDB).where(UserDB.id == caller.id))
        ).scalar_one_or_none()
        target = creator.facility_id if creator else None
    else:
        target = facility_id

    if not target:
        return []

    result = await db.execute(
        select(UserDB)
        .options(selectinload(UserDB.role), selectinload(UserDB.laboratory))
        .where(UserDB.facility_id == target)
        .order_by(UserDB.fname, UserDB.lname)
    )
    return result.scalars().all()


@router.put("/update/{id}", response_model=UserWithDetail)
async def update_user(
    id: int,
    user_update: UserSave,
    db: AsyncSession = Depends(get_db),
    _admin: CurrentUser = Depends(require_system_admin),
):
    """Changes an account. A password left blank is left alone."""
    result = await db.execute(select(UserDB).where(UserDB.id == id))
    db_user = result.scalar_one_or_none()

    if not db_user:
        raise HTTPException(
            status_code=404, detail=f"Unable to find user with id '{id}'"
        )

    existing = await _find_by_email(db, user_update.email, ignore_id=id)
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Another account already uses '{user_update.email}'",
        )

    for field in EDITABLE_USER_FIELDS:
        setattr(db_user, field, getattr(user_update, field))

    # only touched when a new one was actually typed
    if user_update.password:
        db_user.password = assist.hash_password(user_update.password)

    db_user.updated_by = user_update.updated_by

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update user: {e}")

    return await _load_detail(db, id)


async def _load_detail(db: AsyncSession, id: int):
    result = await db.execute(
        select(UserDB)
        .options(selectinload(UserDB.role), selectinload(UserDB.laboratory))
        .where(UserDB.id == id)
    )
    return result.scalars().first()


@router.get("/id/{id}", response_model=ParamUserEdit)
async def get_id(id: int, db: AsyncSession = Depends(get_db)):
    """One account and everything its form offers as a choice.

    An id of 0 means a new account, so only the choices come back.
    """
    userItem = None

    if id != 0:
        userItem = await _load_detail(db, id)
        if not userItem:
            raise HTTPException(
                status_code=404,
                detail=f"Unable to find user with specified id '{id}'",
            )

    result = await db.execute(select(RoleDB).order_by(RoleDB.id))
    roleItems = result.scalars().all()

    # only a laboratory that is taking part can have an account against it
    result = await db.execute(
        select(LaboratoryDB)
        .where(LaboratoryDB.status_id == assist.STATUS_APPROVED)
        .order_by(LaboratoryDB.name)
    )
    laboratoryItems = result.scalars().all()

    result = await db.execute(select(SchemeDB).order_by(SchemeDB.name))
    schemeItems = result.scalars().all()

    result = await db.execute(select(ProvinceDB).order_by(ProvinceDB.name))
    provinceItems = result.scalars().all()

    result = await db.execute(select(DistrictDB).order_by(DistrictDB.name))
    districtItems = result.scalars().all()

    return ParamUserEdit(
        user=userItem,
        roleList=roleItems,
        laboratoryList=laboratoryItems,
        schemeList=schemeItems,
        provinceList=provinceItems,
        districtList=districtItems,
    )


@router.get("/email/{user_email}", response_model=List[UserWithDetail])
async def get_user_email(user_email: str, db: AsyncSession = Depends(get_db)):
    """Whether an email is already taken.

    The public signup form calls this before it lets somebody register, so it
    answers anonymously and must not hand back the account itself - hence the
    listing model, which carries no password.
    """
    # the detail is loaded up front because the response carries it; left to
    # itself it would lazy load after the request is done with the session
    result = await db.execute(
        select(UserDB)
        .options(selectinload(UserDB.role), selectinload(UserDB.laboratory))
        .filter(UserDB.email == user_email)
    )
    users = []

    user = result.scalars().first()
    if user:
        users.append(user)

    return users


@router.get("/list", response_model=List[UserWithDetail])
async def list_users(db: AsyncSession = Depends(get_db)):
    """Every account, with the role it holds and the laboratory it belongs to.

    Both are loaded up front - a listing that resolved them a row at a time
    would issue a query per user.
    """
    result = await db.execute(
        select(UserDB)
        .options(
            selectinload(UserDB.role),
            selectinload(UserDB.laboratory),
        )
        .order_by(UserDB.fname, UserDB.lname)
    )
    return result.scalars().all()


@router.put("/update-password", response_model=User)
async def login(
    username: str = Form(...),
    current_password: str = Form(...),
    new_password: str = Form(...),
    db: AsyncSession = Depends(get_db),
):
    # check user exists
    result = await db.execute(select(UserDB).where(UserDB.email == username))
    user = result.scalars().first()

    if not user:
        # user not found
        raise HTTPException(status_code=401, detail=f"The specified username incorrect")

    if not assist.verify_password(current_password, user.password):
        raise HTTPException(
            status_code=401, detail=f"The specified current password is incorrect"
        )

    user.password = assist.hash_password(new_password)

    try:
        await db.commit()
        await db.refresh(user)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update user: {e}")
    return user