from fastapi import APIRouter, Depends, Form, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List

from database import get_db
from helpers import assist
from models.user_model import User, UserDB

router = APIRouter(prefix="/users", tags=["Users"])

@router.post("/create", response_model=User)
async def create_user(user: User, db: AsyncSession = Depends(get_db)):
    # Check duplicate email
    db_user = UserDB(
        # id
        code=user.code,
        type=user.type,
        # personal details
        fname=user.fname,
        lname=user.lname,
        position=user.position,
        # contact, address
        email=user.email,
        mobile_code=user.mobile_code,
        mobile=user.mobile,
        address_physical=user.address_physical,
        address_postal=user.address_postal,
        # account
        role_id=user.role_id,
        password=assist.hash_password(user.password),
        # approval
        status_id=user.status_id,
        stage_id=user.stage_id,
        approval_levels=user.approval_levels,
        # service
        created_by=user.created_by,
    )
    db.add(db_user)
    try:
        await db.commit()
        await db.refresh(db_user)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to create user: f{e}")
    return db_user


@router.put("/update/{id}", response_model=User)
async def update_user(
    id: int, config_update: User, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(UserDB).where(UserDB.id == id))
    config = result.scalar_one_or_none()

    if not config:
        raise HTTPException(
            status_code=404, detail=f"Unable to find user with id '{id}'"
        )

    # Update fields that are not None
    for key, value in config_update.dict(exclude_unset=True).items():
        # if password, encrypt
        if key == "password":
            setattr(config, key, assist.hash_password(value))
        else:
            setattr(config, key, value)

    try:
        await db.commit()
        await db.refresh(config)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update user {e}")
    return config


@router.get("/id/{id}", response_model=User)
async def get_id(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserDB).filter(UserDB.id == id))
    transaction = result.scalars().first()
    if not transaction:
        raise HTTPException(
            status_code=404, detail=f"Unable to find user with specified id '{id}'"
        )
    return transaction


@router.get("/email/{user_email}", response_model=List[User])
async def get_user_email(user_email: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserDB).filter(UserDB.email == user_email))
    users = []

    user = result.scalars().first()
    if user:
        users.append(user)

    return users


@router.get("/list", response_model=List[User])
async def list_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(UserDB))
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