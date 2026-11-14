from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func, distinct
from typing import List

import helpers.assist as assist
from database import get_db
from models.scheme_model import (
    SchemeDB,
    SchemeTile,
    CatalogueService,
    CatalogueMethod,
)
from models.method_model import MethodDB
from models.service_model import ServiceDB
from models.provider_model import ProviderDB
from models.facility_model import FacilityDB
from models.user_model import UserDB
from models.laboratory_model import (
    LaboratoryDB,
    ParamSchemeRegistration,
    SchemeRegistrationResult,
)
from models.applications_model import ApplicationsDB
from routes.laboratory_routes import _next_laboratory_code

router = APIRouter(prefix="/registration", tags=["Registration"])


@router.get("/schemes", response_model=List[SchemeTile])
async def scheme_catalogue(db: AsyncSession = Depends(get_db)):
    """Every scheme a lab can register for, with its methods grouped by service.

    Drives the scheme-selection tiles and, once a scheme is picked, the method
    picker on the registration form - replacing the old cross-scheme tree.
    """
    # providers for the tile subtitle
    providers = {
        p.id: p.name
        for p in (await db.execute(select(ProviderDB))).scalars().all()
    }
    services = {
        s.id: s.name
        for s in (await db.execute(select(ServiceDB))).scalars().all()
    }

    schemes = (
        await db.execute(select(SchemeDB).order_by(SchemeDB.name))
    ).scalars().all()

    methods = (
        await db.execute(select(MethodDB).order_by(MethodDB.name))
    ).scalars().all()

    # methods grouped under their scheme, then their service
    by_scheme: dict[int, dict[int, CatalogueService]] = {}
    count_by_scheme: dict[int, int] = {}
    for m in methods:
        svc_map = by_scheme.setdefault(m.scheme_id, {})
        svc = svc_map.get(m.service_id)
        if svc is None:
            svc = CatalogueService(
                id=m.service_id,
                name=services.get(m.service_id, "Service"),
                methods=[],
            )
            svc_map[m.service_id] = svc
        svc.methods.append(
            CatalogueMethod(id=m.id, name=m.name, service_id=m.service_id)
        )
        count_by_scheme[m.scheme_id] = count_by_scheme.get(m.scheme_id, 0) + 1

    tiles = []
    for scheme in schemes:
        tiles.append(
            SchemeTile(
                id=scheme.id,
                name=scheme.name,
                code=scheme.code,
                description=scheme.description,
                provider_name=providers.get(scheme.provider_id),
                method_count=count_by_scheme.get(scheme.id, 0),
                services=list(by_scheme.get(scheme.id, {}).values()),
                form_control_number=scheme.form_control_number,
                form_version=scheme.form_version,
                form_terms_authority=scheme.form_terms_authority
                or providers.get(scheme.provider_id),
                requires_confidentiality_waiver=bool(
                    scheme.requires_confidentiality_waiver
                ),
            )
        )
    return tiles


async def _next_registration_number(db: AsyncSession, scheme: SchemeDB) -> str:
    """The next per-scheme registration number, e.g. TB-001.

    Sequential in the number of distinct laboratories that have applied to this
    scheme, so every lab gets its own number within the scheme.
    """
    result = await db.execute(
        select(func.count(distinct(ApplicationsDB.lab_id))).where(
            ApplicationsDB.scheme_id == scheme.id
        )
    )
    used = result.scalar() or 0
    code = (scheme.code or "REG").upper()
    return f"{code}-{used + 1:03d}"


@router.post("/register-scheme", response_model=SchemeRegistrationResult)
async def register_scheme(
    param: ParamSchemeRegistration, db: AsyncSession = Depends(get_db)
):
    """A signed-in, verified user registers their facility for one scheme.

    Produces a laboratory row and one application per selected method, all
    submitted for review and carrying the scheme's registration number. If the
    facility was already registered for this scheme by someone else, the
    submission still goes through (flagged) for the administrator to decide.
    """
    email = param.user_email.lower().strip()

    # the registering user must exist and be active (verified)
    user = (
        await db.execute(select(UserDB).where(UserDB.email == email))
    ).scalars().first()
    if not user:
        raise HTTPException(status_code=401, detail="Please sign in to register a scheme")
    if not user.email_verified or user.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=403,
            detail="Please verify your email before registering a scheme",
        )

    # the scheme
    scheme = (
        await db.execute(select(SchemeDB).where(SchemeDB.id == param.scheme_id))
    ).scalars().first()
    if not scheme:
        raise HTTPException(status_code=400, detail="The selected scheme was not found")

    # controlled-document agreement: terms must be accepted, and TB (or any
    # scheme that asks) must have an explicit confidentiality waiver answer
    if not param.terms_accepted:
        raise HTTPException(
            status_code=400,
            detail="You must accept the terms and conditions to register",
        )
    if scheme.requires_confidentiality_waiver and param.confidentiality_waiver is None:
        raise HTTPException(
            status_code=400,
            detail="Please answer the confidentiality waiver question",
        )
    # ignore a waiver answer for a scheme that does not ask one
    waiver = (
        param.confidentiality_waiver
        if scheme.requires_confidentiality_waiver
        else None
    )

    # the methods, which must all belong to the chosen scheme
    method_ids = sorted({item.id for item in param.method_list})
    methods = (
        await db.execute(select(MethodDB).where(MethodDB.id.in_(method_ids)))
    ).scalars().all()

    if len(methods) != len(method_ids):
        found = {m.id for m in methods}
        missing = [str(i) for i in method_ids if i not in found]
        raise HTTPException(
            status_code=400,
            detail=f"Unable to find the selected method(s): {', '.join(missing)}",
        )

    wrong_scheme = [m.name for m in methods if m.scheme_id != scheme.id]
    if wrong_scheme:
        raise HTTPException(
            status_code=400,
            detail=f"These methods do not belong to {scheme.name}: {', '.join(wrong_scheme)}",
        )

    # resolve the facility and the derived location
    facility = None
    facility_name = (param.facility_name or "").strip() or None
    if param.facility_id:
        facility = (
            await db.execute(
                select(FacilityDB).where(FacilityDB.id == param.facility_id)
            )
        ).scalars().first()
        if not facility:
            raise HTTPException(status_code=400, detail="The selected facility was not found")
        facility_name = facility.name

    province_id = (
        param.province_id
        or (facility.province_id if facility else None)
        or user.province_id
    )
    district_id = (
        param.district_id
        or (facility.district_id if facility else None)
        or user.district_id
    )
    if not province_id or not district_id:
        raise HTTPException(
            status_code=400,
            detail="Could not determine the province and district for this registration",
        )

    contact_person_name = (param.contact_person_name or f"{user.fname} {user.lname}").strip()
    position = (param.position or user.position or "").strip()
    phone_number = (param.phone_number or user.mobile or "").strip()

    # has another user already registered this facility for this scheme?
    duplicate = False
    if facility:
        existing = (
            await db.execute(
                select(LaboratoryDB.id)
                .join(ApplicationsDB, ApplicationsDB.lab_id == LaboratoryDB.id)
                .where(
                    LaboratoryDB.facility_id == facility.id,
                    ApplicationsDB.scheme_id == scheme.id,
                    func.coalesce(LaboratoryDB.registered_by_user_id, -1) != user.id,
                )
            )
        ).first()
        duplicate = existing is not None

    registration_number = await _next_registration_number(db, scheme)

    lab = LaboratoryDB(
        name=param.name.strip(),
        description=param.description,
        contact_person_name=contact_person_name,
        code=await _next_laboratory_code(db),
        lab_type_id=param.lab_type_id,
        position=position or "Not specified",
        phone_number=phone_number or "Not specified",
        province_id=province_id,
        email_address=user.email,
        district_id=district_id,
        physical_address=param.physical_address.strip(),
        method_list=[
            {
                "id": m.id,
                "name": m.name,
                "scheme_id": m.scheme_id,
                "service_id": m.service_id,
            }
            for m in methods
        ],
        facility_id=facility.id if facility else None,
        registered_by_user_id=user.id,
        # snapshot the controlled-document version the lab agreed to
        form_control_number=scheme.form_control_number,
        form_version=scheme.form_version,
        terms_accepted=True,
        terms_accepted_at=assist.get_current_date(False),
        confidentiality_waiver=waiver,
        # a registration always arrives awaiting review; the owning user and
        # account linkage are settled when an administrator approves it
        user_id=None,
        status_id=assist.STATUS_SUBMITTED,
        stage_id=assist.APPROVAL_STAGE_SUBMITTED,
        approval_levels=1,
        created_by=user.email,
    )
    db.add(lab)

    try:
        await db.flush()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not register the scheme: {e}")

    for m in methods:
        db.add(
            ApplicationsDB(
                name=f"{lab.name} - {m.name}",
                description=f"Application by {lab.name} to take part in {m.name}",
                lab_id=lab.id,
                scheme_id=m.scheme_id,
                service_id=m.service_id,
                method_id=m.id,
                registration_number=registration_number,
                user_id=None,
                status_id=assist.STATUS_SUBMITTED,
                stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                approval_levels=1,
                created_by=user.email,
            )
        )

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not register the scheme: {e}")

    message = (
        f"Your registration for {scheme.name} has been submitted for review. "
        f"Your registration number is {registration_number}."
    )
    if duplicate:
        message = (
            f"This facility has already been registered for {scheme.name} by another "
            f"user. Your submission ({registration_number}) has still been sent to the "
            f"administrator, who will make the final decision."
        )

    return SchemeRegistrationResult(
        succeeded=True,
        message=message,
        laboratory_id=lab.id,
        code=lab.code,
        registration_number=registration_number,
        application_count=len(methods),
        duplicate_warning=duplicate,
    )
