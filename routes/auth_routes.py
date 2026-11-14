from datetime import datetime, timedelta, timezone
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from jose import jwt

import helpers.assist as assist
from helpers import mailer
from models.facility_model import FacilityDB
from models.user_model import (
    UserDB,
    ParamUserSignup,
    UserSignupResult,
    ParamVerifyToken,
    ParamSetPassword,
)
from database import get_db

router = APIRouter(prefix="/auth", tags=["Auth"])

ZAMBIA_NAMES = {"zambia", "zm", "zmb"}


def _is_zambia(country: str) -> bool:
    return (country or "").strip().lower() in ZAMBIA_NAMES


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

    # a self-registered account has no password until the verification link is
    # used - until then there is nothing to sign in with
    if not user.password or not assist.verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=401, detail=f"The specified username or password is incorrect"
        )

    # an account that is still pending review, or that was rejected, cannot sign in
    if user.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=403,
            detail="Your account is not active. Please verify your email or contact the scheme administrator.",
        )

    to_encode = {
        "sub": user.email,
        "userid": user.id,
        "name": f"{user.fname} {user.lname}",
        "role": user.role_id,
        # the lab this user reports results for, absent for provider staff
        "lab": user.laboratory_id,
        # the scheme a scheme-team role is tied to; null for Administrator/MOH
        "scheme_id": user.scheme_id,
        "mobile": user.mobile,
        # the facility this user registered under, so the scheme-registration
        # page can link a new laboratory to it without a second lookup
        "facility_id": user.facility_id,
        "facility_name": user.facility_name,
        "position": user.position,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=30),
        "jti": uuid4().hex,
    }
    token = jwt.encode(to_encode, assist.SECRET_KEY, algorithm=assist.ALGORITHM)

    return {"access_token": token, "token_type": "bearer"}


# --------------------------------------------------------------------------
# Self-registration
#
# A person registers themselves with a handful of fields and proves their
# email through a verification link, which is also where they set a password.
# Registering a laboratory for a scheme happens later, once signed in - see
# routes/registration_routes.py.
# --------------------------------------------------------------------------
async def _issue_verification(db, user: UserDB):
    """Give the user a fresh token and email them the link.

    The row is committed before the send, so a user always exists to resend to;
    a send failure is surfaced to the caller but does not lose the account.
    """
    user.verification_token = uuid4().hex
    user.verification_sent_at = assist.get_current_date(False)
    await db.commit()

    try:
        await mailer.send_verification_email(
            user.email, f"{user.fname} {user.lname}".strip(), user.verification_token
        )
    except Exception as e:  # pragma: no cover - depends on the mail server
        raise HTTPException(
            status_code=502,
            detail=(
                "Your details were saved but the verification email could not be "
                "sent. Please try registering again in a few minutes."
            ),
        ) from e


@router.post("/signup", response_model=UserSignupResult)
async def signup(signup: ParamUserSignup, db: AsyncSession = Depends(get_db)):
    """Public self-registration. Captures the person, not a laboratory.

    Creates an unverified account and emails a verification link. The account
    cannot sign in until the link is followed and a password is set.
    """
    email = signup.email.lower().strip()
    is_zambia = _is_zambia(signup.country)

    # resolve the facility: Zambia picks from the MFL, elsewhere types a name
    facility = None
    facility_name = (signup.facility_name or "").strip() or None
    province_id = None
    district_id = None

    if signup.facility_id:
        result = await db.execute(
            select(FacilityDB).where(FacilityDB.id == signup.facility_id)
        )
        facility = result.scalars().first()
        if not facility:
            raise HTTPException(
                status_code=400, detail="The selected facility could not be found"
            )
        facility_name = facility.name
        province_id = facility.province_id
        district_id = facility.district_id
    elif is_zambia and not facility_name:
        raise HTTPException(
            status_code=400,
            detail="Please choose your facility from the master facility list",
        )
    elif not facility_name:
        raise HTTPException(
            status_code=400, detail="Please enter the name of your facility"
        )

    first_name, last_name = assist.extract_names(signup.name)

    # an account may already exist for this email
    result = await db.execute(select(UserDB).where(UserDB.email == email))
    existing = result.scalars().first()

    if existing and existing.email_verified:
        raise HTTPException(
            status_code=400,
            detail="This email address is already registered. Please sign in instead.",
        )

    if existing:
        # not yet verified - refresh the details and resend the link rather
        # than refusing, so a mistyped-then-retried sign up just works
        existing.fname = first_name
        existing.lname = last_name or first_name
        existing.position = signup.position.strip()
        existing.mobile = signup.phone_number.strip()
        existing.mobile_code = "+260" if is_zambia else "+"
        existing.country = signup.country.strip()
        existing.facility_id = facility.id if facility else None
        existing.facility_name = facility_name
        existing.province_id = province_id
        existing.district_id = district_id
        await _issue_verification(db, existing)
        return UserSignupResult(
            succeeded=True,
            message=(
                "You have already started registering with this email. We have sent "
                "a fresh verification link - please check your inbox."
            ),
            email=email,
        )

    user = UserDB(
        # personal details
        fname=first_name,
        lname=last_name or first_name,
        position=signup.position.strip(),
        # contact
        email=email,
        mobile_code="+260" if is_zambia else "+",
        mobile=signup.phone_number.strip(),
        # self-registration
        country=signup.country.strip(),
        facility_id=facility.id if facility else None,
        facility_name=facility_name,
        province_id=province_id,
        district_id=district_id,
        # account - a self-registered user is always a facility super user,
        # with no password and pending until the email is verified
        role_id=assist.ROLE_FACILITY_SUPER_USER,
        password=None,
        status_id=assist.STATUS_SUBMITTED,
        stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
        approval_levels=1,
        email_verified=False,
        created_by=email,
    )
    db.add(user)

    try:
        await db.flush()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not register: {e}")

    await _issue_verification(db, user)

    return UserSignupResult(
        succeeded=True,
        message=(
            "Registration received. Please check your email for a link to verify "
            "your address and set your password."
        ),
        email=email,
    )


async def _user_for_token(db, token: str) -> UserDB:
    result = await db.execute(
        select(UserDB).where(UserDB.verification_token == token)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=400,
            detail="This verification link is invalid or has already been used.",
        )
    return user


@router.get("/verify/{token}")
async def verify_lookup(token: str, db: AsyncSession = Depends(get_db)):
    """Check a verification token and return who it belongs to, so the
    set-password page can greet the user. Does not finalize anything."""
    user = await _user_for_token(db, token)
    return {
        "email": user.email,
        "name": f"{user.fname} {user.lname}".strip(),
        "already_verified": user.email_verified,
    }


@router.post("/set-password", response_model=UserSignupResult)
async def set_password(payload: ParamSetPassword, db: AsyncSession = Depends(get_db)):
    """Follow the verification link: prove the email and set the password.

    This is the one step that activates a self-registered account.
    """
    user = await _user_for_token(db, payload.token)

    user.password = assist.hash_password(payload.password)
    user.email_verified = True
    user.verified_at = assist.get_current_date(False)
    user.verification_token = None
    # the account is now active and may sign in
    user.status_id = assist.STATUS_APPROVED
    user.stage_id = assist.APPROVAL_STAGE_APPROVED
    user.updated_by = user.email

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not set your password: {e}")

    return UserSignupResult(
        succeeded=True,
        message="Your email is verified and your password is set. You can now sign in.",
        email=user.email,
    )
