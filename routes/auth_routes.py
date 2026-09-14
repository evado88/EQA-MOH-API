from datetime import datetime, timedelta, timezone
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List
from jose import JWTError, jwt
import helpers.assist as assist
from models.applications_model import ApplicationsDB
from models.laboratory_model import (
    LaboratoryDB,
    LaboratorySignupResult,
    ParamLaboratorySignup,
)
from models.method_model import MethodDB
from models.user_model import UserDB
from routes.laboratory_routes import _next_laboratory_code
from database import get_db

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)
):
    # check user exists
    result = await db.execute(select(UserDB).where(UserDB.email == form_data.username))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
                status_code=401,
                detail=f"The specified username or password is incorrect",
        )

    if not assist.verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=401, detail=f"The specified username or password is incorrect"
        )

    # an account that is still pending review, or that was rejected, cannot sign in
    if user.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=403,
            detail="Your account is not active. Please contact the scheme administrator.",
        )

    to_encode = {
        "sub": user.email,
        "userid": user.id,
        "name": f"{user.fname} {user.lname}",
        "role": user.role_id,
        # the lab this user reports results for, absent for provider staff
        "lab": user.laboratory_id,
        "mobile": user.mobile,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=30),
        "jti": uuid4().hex,
    }
    token = jwt.encode(to_encode, assist.SECRET_KEY, algorithm=assist.ALGORITHM)

    return {"access_token": token, "token_type": "bearer"}


@router.post("/signup", response_model=LaboratorySignupResult)
async def signup(
    signup: ParamLaboratorySignup, db: AsyncSession = Depends(get_db)
):
    """Registers a laboratory for EQA.

    This is the only public way into the system, and it only ever produces a
    laboratory - never a provider or administrator account. The registration is
    created as submitted for review; the user account itself is only created
    once an administrator approves it (see /laboratorys/review-update).
    """
    email = signup.email_address.lower().strip()

    # the contact email doubles as the eventual sign in name, so it has to be
    # free on both sides
    result = await db.execute(select(UserDB).where(UserDB.email == email))
    if result.scalars().first():
        raise HTTPException(
            status_code=400,
            detail="The email address has already been registered",
        )

    result = await db.execute(
        select(LaboratoryDB).where(LaboratoryDB.email_address == email)
    )
    if result.scalars().first():
        raise HTTPException(
            status_code=400,
            detail="The email address has already been registered",
        )

    # resolve the selected methods so the application rows carry the whole
    # scheme -> service -> method chain rather than the client's word for it
    method_ids = sorted({item.id for item in signup.method_list})
    result = await db.execute(select(MethodDB).where(MethodDB.id.in_(method_ids)))
    methods = result.scalars().all()

    if len(methods) != len(method_ids):
        found = {method.id for method in methods}
        missing = [str(id) for id in method_ids if id not in found]
        raise HTTPException(
            status_code=400,
            detail=f"Unable to find the selected method(s): {', '.join(missing)}",
        )

    db_laboratory = LaboratoryDB(
        # name
        name=signup.name.strip(),
        description=signup.description,
        # properties
        contact_person_name=signup.contact_person_name.strip(),
        code=await _next_laboratory_code(db),
        lab_type_id=signup.lab_type_id,
        position=signup.position.strip(),
        phone_number=signup.phone_number.strip(),
        province_id=signup.province_id,
        email_address=email,
        district_id=signup.district_id,
        physical_address=signup.physical_address.strip(),
        # the methods as selected, kept for the reviewer to see
        method_list=[
            {
                "id": method.id,
                "name": method.name,
                "scheme_id": method.scheme_id,
                "service_id": method.service_id,
            }
            for method in methods
        ],
        # approval - a registration always arrives awaiting review
        user_id=None,
        status_id=assist.STATUS_SUBMITTED,
        stage_id=assist.APPROVAL_STAGE_SUBMITTED,
        approval_levels=1,
        # service
        created_by=email,
    )
    db.add(db_laboratory)

    try:
        await db.flush()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Could not register the laboratory: {e}"
        )

    # one application per method, so each method can be accepted or rejected
    # on its own merits
    for method in methods:
        db.add(
            ApplicationsDB(
                name=f"{db_laboratory.name} - {method.name}",
                description=f"Application by {db_laboratory.name} to take part in {method.name}",
                lab_id=db_laboratory.id,
                scheme_id=method.scheme_id,
                service_id=method.service_id,
                method_id=method.id,
                user_id=None,
                status_id=assist.STATUS_SUBMITTED,
                stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                approval_levels=1,
                created_by=email,
            )
        )

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Could not register the laboratory: {e}"
        )

    return LaboratorySignupResult(
        succeeded=True,
        message=(
            "You have successfully registered. You will be informed by email once "
            "your registration has been reviewed."
        ),
        laboratory_id=db_laboratory.id,
        code=db_laboratory.code,
        application_count=len(methods),
    )


