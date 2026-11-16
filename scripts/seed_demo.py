"""Populates the moheqa development database with a coherent demo dataset.

The catalogue (provider -> scheme -> service -> method -> sample) is written
directly. Everything that has a workflow attached - registration, application
review, cycle status, enrolment, shipping, result capture - is driven through
the API, so the demo data is by construction exactly what the running system
produces.

Usage (always targets the local dev database, never production):
    python scripts/seed_demo.py            rebuild the full demo dataset
    python scripts/seed_demo.py --clear    wipe demo data only, no reseeding
                                           (catalogue and provider staff kept,
                                           ready for manual testing)
"""
import asyncio
import os
import sys
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

import database

# the seed drives the date-derived lifecycle through the dev phase-jump helper,
# so make sure it is switched on before the routers are imported
os.environ["ENABLE_DEV_TOOLS"] = "1"

DEV_URL = "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"
database.engine = create_async_engine(DEV_URL, echo=False)
database.AsyncSessionLocal = sessionmaker(
    bind=database.engine, class_=AsyncSession, expire_on_commit=False
)

import main  # noqa: E402  (must come after the engine swap)
from helpers import assist  # noqa: E402
from httpx import ASGITransport, AsyncClient  # noqa: E402

DEMO_PASSWORD = "12345678"
# lifecycle status is derived from the schedule against the real clock, so the
# demo calendar is anchored to today rather than a fixed date
TODAY = assist.get_current_date().date()

APPROVED = dict(status_id=assist.STATUS_APPROVED,
                stage_id=assist.APPROVAL_STAGE_APPROVED,
                approval_levels=1)

FAILURES = []

# resolved at run time; the quality officer grades submitted results
GRADER_ID = None


def note(msg):
    print(f"   {msg}")


def fail(what, r):
    FAILURES.append(f"{what}: {r.status_code} {r.text[:300]}")
    print(f"   !! {what} -> {r.status_code} {r.text[:300]}")


# --------------------------------------------------------------------------
# 1. reset the transactional layer
# --------------------------------------------------------------------------
async def reset():
    async with database.engine.begin() as conn:
        # create anything the models declare but the database lacks
        await conn.run_sync(database.Base.metadata.create_all)

    async with database.AsyncSessionLocal() as db:
        # everything below is rebuilt through the API further down
        for table in ("pt_result_evaluations", "pt_enrollment_performance",
                      "pt_sample_statistics", "tb_xpert_ultra_results",
                      "tb_xpert_xdr_results", "hiv_vl_results",
                      "hiv_eid_results", "bacteriology_ast_results",
                      "bacteriology_results", "announcements",
                      "enrollments", "applications",
                      "pt_cycles", "laboratorys"):
            await db.execute(text(f"TRUNCATE {table} RESTART IDENTITY CASCADE"))

        # lab accounts go with their labs; provider staff are kept
        await db.execute(text(
            "DELETE FROM users WHERE role_id = ANY(:roles)"
        ), {"roles": list(assist.LABORATORY_ROLES)})
        await db.commit()
    print("1. transactional data cleared (catalogue and provider staff kept)")


# --------------------------------------------------------------------------
# 2. provider staff
# --------------------------------------------------------------------------
async def staff():
    from models.user_model import UserDB
    from sqlalchemy.future import select

    wanted = [
        ("nkoleevans@gmail.com", "John", "Doe", assist.ROLE_ADMINISTRATOR, "System Administrator"),
        ("nkoleevans@hotmail.com", "Jane", "Doe", assist.ROLE_SCHEME_COORDINATOR, "Scheme Coordinator"),
        ("head@cdl.moh.gov.zm", "Mutende", "Wina", assist.ROLE_SCHEME_HEAD, "Scheme Head"),
        ("quality@cdl.moh.gov.zm", "Esther", "Nyendwa", assist.ROLE_SCHEME_QUALITY_OFFICER, "Quality Officer"),
    ]

    async with database.AsyncSessionLocal() as db:
        for email, fname, lname, role_id, position in wanted:
            existing = (await db.execute(
                select(UserDB).where(UserDB.email == email))).scalars().first()

            if existing:
                # these accounts predate the approval check on sign in
                existing.role_id = role_id
                existing.status_id = assist.STATUS_APPROVED
                existing.stage_id = assist.APPROVAL_STAGE_APPROVED
                existing.password = assist.hash_password(DEMO_PASSWORD)
                existing.position = position
                note(f"updated {email} -> role {role_id}, approved")
            else:
                db.add(UserDB(
                    fname=fname, lname=lname, position=position, email=email,
                    mobile_code="+260", mobile="+26097700" + str(4000 + role_id),
                    role_id=role_id, password=assist.hash_password(DEMO_PASSWORD),
                    province_id=5, district_id=39,
                    created_by="demo-seed", **APPROVED))
                note(f"created {email} -> role {role_id}")
        await db.commit()
    print("2. provider staff ready")


# --------------------------------------------------------------------------
# 3. the scheme catalogue
# --------------------------------------------------------------------------
async def catalogue():
    from sqlalchemy.future import select
    from models.provider_model import ProviderDB
    from models.scheme_model import SchemeDB
    from models.service_model import ServiceDB
    from models.method_model import MethodDB
    from models.methodsample_model import MethodSampleDB
    from models.ptcyclestatus_model import PTCycleStatusDB
    from models.labtype_model import LabTypeDB

    async def upsert(db, model, match, **fields):
        row = (await db.execute(select(model).filter_by(**match))).scalars().first()
        if row:
            for k, v in fields.items():
                setattr(row, k, v)
        else:
            row = model(**match, **fields)
            db.add(row)
        await db.flush()
        return row

    async with database.AsyncSessionLocal() as db:
        # the lifecycle statuses must match the derived-status constants exactly
        # (id -> name), so the seven date-driven phases line up with the model
        for i, name in assist.PT_CYCLE_STATUS_NAMES.items():
            await upsert(db, PTCycleStatusDB, {"id": i}, name=name, user_id=1, **APPROVED)
        for i, name in enumerate(["Government", "Private", "Religious", "Mine"], 1):
            await upsert(db, LabTypeDB, {"id": i}, name=name, user_id=1, **APPROVED)

        provider = await upsert(db, ProviderDB, {"id": 1}, name="CDL",
                                description="Chest Diseases Laboratory",
                                user_id=1, **APPROVED)

        tb = await upsert(db, SchemeDB, {"id": 1}, name="Tuberculosis (TB)",
                          description="TB proficiency testing scheme",
                          provider_id=provider.id, user_id=1, **APPROVED)

        # Ultra and XDR are Xpert methods - the existing rows had Ultra sitting
        # under microscopy
        micro = await upsert(db, ServiceDB, {"id": 1}, name="TB Microscopy",
                             description="Sputum smear microscopy",
                             scheme_id=tb.id, user_id=1, **APPROVED)
        xpert = await upsert(db, ServiceDB, {"id": 2}, name="TB Xpert",
                             description="GeneXpert molecular testing",
                             scheme_id=tb.id, user_id=1, **APPROVED)

        ultra = await upsert(db, MethodDB, {"id": 1}, name="Ultra",
                             description="Xpert MTB/RIF Ultra",
                             result_form="tb_xpert_ultra",
                             scheme_id=tb.id, service_id=xpert.id, user_id=1, **APPROVED)
        xdr = await upsert(db, MethodDB, {"id": 2}, name="XDR",
                           description="Xpert MTB/XDR",
                           result_form="tb_xpert_xdr",
                           scheme_id=tb.id, service_id=xpert.id, user_id=1, **APPROVED)
        zn = await upsert(db, MethodDB, {"id": 3}, name="Ziehl-Neelsen",
                          description="ZN stain microscopy",
                          scheme_id=tb.id, service_id=micro.id, user_id=1, **APPROVED)
        await upsert(db, MethodDB, {"id": 4}, name="LED Fluorescence",
                     description="LED fluorescence microscopy",
                     scheme_id=tb.id, service_id=micro.id, user_id=1, **APPROVED)

        # the panel each method ships, named as on form CDL-PT-F-008
        sid = 1
        for method, prefix in ((ultra, "ultra"), (xdr, "xdr"), (zn, "micro")):
            for n in range(1, 6):
                await upsert(db, MethodSampleDB, {"id": sid},
                             name=f"{prefix}-CDL-2026-A-{n}",
                             description=f"{method.name} panel sample {n}",
                             scheme_id=tb.id, service_id=method.service_id,
                             method_id=method.id, user_id=1, **APPROVED)
                sid += 1


        # Virology PT runs the HIV work out of LMUTH, alongside CDL's TB scheme
        virology = await upsert(db, ProviderDB, {"id": 2}, name="Virology PT",
                                description="Virology PT Scheme, Levy Mwanawasa "
                                            "University Teaching Hospital",
                                user_id=1, **APPROVED)

        vl = await upsert(db, SchemeDB, {"id": 2},
                          name="HIV-1 Viral Load- Conventional PCR",
                          description="HIV-1 viral load proficiency testing by "
                                      "conventional PCR",
                          provider_id=virology.id, user_id=1, **APPROVED)

        vl_service = await upsert(db, ServiceDB, {"id": 3},
                                  name="HIV-1 Viral Load",
                                  description="Quantitative HIV-1 RNA testing",
                                  scheme_id=vl.id, user_id=1, **APPROVED)

        # the platforms a participating lab runs the panel on
        vl_methods = []
        for mid, mname, mdesc in (
            (5, "Abbott m2000", "Abbott RealTime HIV-1 on m2000"),
            (6, "Roche Cobas 6800", "Roche Cobas HIV-1 on the 6800 system"),
            (7, "Hologic Panther", "Hologic Aptima HIV-1 Quant on Panther"),
        ):
            vl_methods.append(await upsert(
                db, MethodDB, {"id": mid}, name=mname, description=mdesc,
                result_form="hiv_vl", scheme_id=vl.id,
                service_id=vl_service.id, user_id=1, **APPROVED))

        # form TF-009 ships five samples, named VL 20yy-A1 to A5
        for method in vl_methods:
            for n in range(1, 6):
                await upsert(db, MethodSampleDB, {"id": sid},
                             name=f"VL 2026-A{n}",
                             description=f"HIV-1 VL panel sample {n} for {method.name}",
                             scheme_id=vl.id, service_id=vl_service.id,
                             method_id=method.id, user_id=1, **APPROVED)
                sid += 1



        # the second Virology PT scheme, from the MF006 application form
        eid = await upsert(db, SchemeDB, {"id": 3},
                           name="HIV EID-Conventional PCR",
                           description="HIV-1 early infant diagnosis by "
                                       "conventional PCR",
                           provider_id=virology.id, user_id=1, **APPROVED)

        eid_service = await upsert(db, ServiceDB, {"id": 4},
                                   name="Early Infant Diagnosis",
                                   description="Qualitative HIV-1 DNA/RNA "
                                               "detection in infants",
                                   scheme_id=eid.id, user_id=1, **APPROVED)

        eid_methods = []
        for mid, mname, mdesc in (
            (8, "Cobas 4800", "Roche Cobas 4800 HIV-1 Qualitative"),
            (9, "GeneXpert HIV-1 Qual", "Cepheid Xpert HIV-1 Qual"),
        ):
            eid_methods.append(await upsert(
                db, MethodDB, {"id": mid}, name=mname, description=mdesc,
                result_form="hiv_eid", scheme_id=eid.id,
                service_id=eid_service.id, user_id=1, **APPROVED))

        # form TF-012 ships two kit controls alongside the five samples. The
        # controls are recorded but never scored.
        eid_panel = [
            ("Kit Negative Control", True),
            ("Kit Positive Control", True),
            ("2026-01", False),
            ("2026-02", False),
            ("2026-03", False),
            ("2026-04", False),
            ("2026-05", False),
        ]
        for method in eid_methods:
            for sample_name, is_control in eid_panel:
                await upsert(db, MethodSampleDB, {"id": sid},
                             name=sample_name,
                             description=f"HIV-1 EID panel item for {method.name}",
                             is_control=is_control,
                             scheme_id=eid.id, service_id=eid_service.id,
                             method_id=method.id, user_id=1, **APPROVED)
                sid += 1

        # NHRTI runs the bacteriology scheme out of Ndola, from application
        # form MF006 and scheme protocol TP-NHRTI-BACT-001
        nhrti = await upsert(db, ProviderDB, {"id": 3},
                             name="NHRTI PT Services",
                             description="National Health Research and Training "
                                         "Institute, Ndola",
                             user_id=1, **APPROVED)

        bact = await upsert(db, SchemeDB, {"id": 4}, name="Bacteriology",
                            description="NHRTI-Bacteriology proficiency testing "
                                        "scheme",
                            provider_id=nhrti.id, user_id=1, **APPROVED)

        # One worksheet covers the Gram stain, the identification and the AST,
        # and protocol section 17.1 scores all three together out of 100, so
        # the scheme has one service rather than one per test. What the
        # application form ticks per test is the METHOD column: manual or
        # automated.
        bact_service = await upsert(db, ServiceDB, {"id": 5},
                                    name="Bacteriology (MCS)",
                                    description="Microscopy, Culture and "
                                                "Sensitivity Testing",
                                    scheme_id=bact.id, user_id=1, **APPROVED)

        bact_methods = []
        for mid, mname, mdesc in (
            (10, "Manual", "Manual bacteriology, conventional biochemicals and "
                           "disk diffusion"),
            (11, "Automated", "Automated identification and susceptibility "
                              "testing, e.g. Vitek 2"),
        ):
            bact_methods.append(await upsert(
                db, MethodDB, {"id": mid}, name=mname, description=mdesc,
                result_form="bacteriology", scheme_id=bact.id,
                service_id=bact_service.id, user_id=1, **APPROVED))

        # five swabs in Amies transport medium, as in TF-NHRTI-BACT-003
        BACT_PANEL = [
            ("NHRTIBACT A01-26", "Urine, pathogen identification"),
            ("NHRTIBACT B01-26", "Peritoneal fluid, culture"),
            ("NHRTIBACT C01-26", "High vaginal swab, culture"),
            ("NHRTIBACT D01-26", "Wound swab, culture"),
            ("NHRTIBACT E01-26", "Sputum, culture and AST"),
        ]
        for method in bact_methods:
            for sample_name, scenario in BACT_PANEL:
                await upsert(db, MethodSampleDB, {"id": sid},
                             name=sample_name,
                             description=f"{scenario} ({method.name})",
                             scheme_id=bact.id, service_id=bact_service.id,
                             method_id=method.id, user_id=1, **APPROVED)
                sid += 1

        await db.commit()

        # A TB panel is manufactured, so the provider knows the answer up
        # front. The viral load panel is graded against the consensus of the
        # participants instead, so it gets no stated value.
        from models.evaluation_model import MethodSampleExpectedValueDB

        await db.execute(text("TRUNCATE method_sample_expected_values RESTART IDENTITY"))

        ULTRA_EXPECTED = [
            ("NOT DETECTED", "N/A"),
            ("HIGH", "NOT DETECTED"),
            ("MEDIUM", "DETECTED"),
            ("TRACE", "N/A"),
            ("LOW", "NOT DETECTED"),
        ]
        # the target result for each EID panel item
        DETECTED = "HIV-1 Detected"
        NOT_DETECTED = "HIV-1 Not Detected"
        EID_EXPECTED = {
            "Kit Negative Control": NOT_DETECTED,
            "Kit Positive Control": DETECTED,
            "2026-01": DETECTED,
            "2026-02": NOT_DETECTED,
            "2026-03": NOT_DETECTED,
            "2026-04": NOT_DETECTED,
            "2026-05": DETECTED,
        }

        # Protocol section 18: the bacteriology answers come from
        # characterisation of the strains and the reference laboratories, for
        # the AST as much as for the identification. The organisms match the
        # clinical scenarios in TF-NHRTI-BACT-003.
        BACT_EXPECTED = {
            "NHRTIBACT A01-26": ("Gram negative", "Bacilli",
                                 "Escherichia coli", None),
            "NHRTIBACT B01-26": ("Gram positive", "Cocci",
                                 "Staphylococcus epidermidis", None),
            "NHRTIBACT C01-26": ("Gram positive", "Diplococci",
                                 "Streptococcus agalactiae", None),
            "NHRTIBACT D01-26": ("Gram positive", "Cocci",
                                 "Staphylococcus aureus", None),
            # sample E is the one shipped for identification and AST
            "NHRTIBACT E01-26": ("Gram negative", "Bacilli",
                                 "Klebsiella pneumoniae",
                                 "AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|"
                                 "GENTAMICIN:S|MEROPENEM:S"),
        }

        XDR_EXPECTED = [
            ("NOT DETECTED", "N/A", "N/A", "N/A", "N/A"),
            ("DETECTED", "NOT DETECTED", "NOT DETECTED", "NOT DETECTED", "NOT DETECTED"),
            ("DETECTED", "DETECTED", "NOT DETECTED", "NOT DETECTED", "DETECTED"),
            ("DETECTED", "DETECTED", "DETECTED", "NOT DETECTED", "DETECTED"),
            ("DETECTED", "NOT DETECTED", "NOT DETECTED", "DETECTED", "NOT DETECTED"),
        ]

        result = await db.execute(select(MethodSampleDB).order_by(MethodSampleDB.id))
        for sample in result.scalars().all():
            # the TB panels are numbered; the EID panel includes named controls
            index = (int(sample.name[-1]) - 1
                     if sample.name[-1].isdigit() else None)

            if sample.method_id == 1:          # Ultra
                sample.assigned_value_source = "predefined"
                tb, rif = ULTRA_EXPECTED[index]
                db.add(MethodSampleExpectedValueDB(
                    method_sample_id=sample.id, attribute="tb_detection_result",
                    expected_value_text=tb, created_by="demo-seed"))
                db.add(MethodSampleExpectedValueDB(
                    method_sample_id=sample.id, attribute="rif_result",
                    expected_value_text=rif, created_by="demo-seed"))

            elif sample.method_id == 2:        # XDR
                sample.assigned_value_source = "predefined"
                tb, inh, flq, amk, eth = XDR_EXPECTED[index]
                for attribute, value in (("tb_detection_result", tb),
                                         ("inh_result", inh),
                                         ("flq_result", flq),
                                         ("amk_result", amk),
                                         ("eth_result", eth)):
                    db.add(MethodSampleExpectedValueDB(
                        method_sample_id=sample.id, attribute=attribute,
                        expected_value_text=value, created_by="demo-seed"))

            elif sample.method_id in (10, 11):    # the bacteriology methods
                sample.assigned_value_source = "predefined"
                stain, morphology, organism, ast = BACT_EXPECTED[sample.name]
                for attribute, value in (("gram_stain_reaction", stain),
                                         ("gram_morphology", morphology),
                                         ("organism_identified", organism),
                                         ("ast_result", ast)):
                    if not value:
                        # only sample E is asked for AST
                        continue
                    db.add(MethodSampleExpectedValueDB(
                        method_sample_id=sample.id, attribute=attribute,
                        expected_value_text=value, created_by="demo-seed"))

            elif sample.method_id in (5, 6, 7):  # the viral load platforms
                sample.assigned_value_source = "consensus"

            elif sample.method_id in (8, 9):     # the EID platforms
                # TF-006: the assigned result comes from LMUTH verification,
                # homogeneity and stability testing, not from the participants
                sample.assigned_value_source = "predefined"
                expected = EID_EXPECTED.get(sample.name)
                if expected:
                    db.add(MethodSampleExpectedValueDB(
                        method_sample_id=sample.id, attribute="hiv_result",
                        expected_value_text=expected, created_by="demo-seed"))

        await db.commit()

        # the upserts wrote explicit ids, so move the sequences past them
        for table in ("providers", "schemes", "services", "methods",
                      "method_samples", "pt_cycle_statuses", "lab_types"):
            await db.execute(text(
                f"SELECT setval(pg_get_serial_sequence('{table}','id'), "
                f"COALESCE((SELECT MAX(id) FROM {table}), 1))"))
        await db.commit()

    print("3. catalogue built:")
    print("     CDL / Tuberculosis (TB) / {Microscopy, Xpert} / 4 methods / 15 samples")
    print("     Virology PT / HIV-1 Viral Load- Conventional PCR / 3 methods / 15 samples")
    print("     NHRTI PT Services / Bacteriology / 1 service / 2 methods / 10 samples")


# --------------------------------------------------------------------------
# 4-8. the workflow, driven through the API
# --------------------------------------------------------------------------
LABS = [
    # name, contact, email, type, province, district, methods
    ("Levy Mwanawasa University Teaching Hospital", "Musa Choolwe",
     "musachoolwe@gmail.com", 1, 5, 39, [1, 2, 7, 9]),
    ("Levy Lusaka Laboratory", "Jane Banda",
     "jane@gmail.com", 1, 5, 39, [1]),
    ("Private Lab 1", "Mark Doe",
     "markdoe@gmail.com", 2, 2, 10, [1, 3]),
    ("UTH New Lab", "Alan Phiri",
     "alanphiri@gmail.com", 1, 5, 39, [1, 2]),
    ("Ndola Teaching Hospital Lab", "Grace Mulenga",
     "grace.mulenga@ndola.health.zm", 1, 2, 10, [1]),
    ("Kitwe Central Hospital Lab", "Peter Zulu",
     "peter.zulu@kitwe.health.zm", 1, 2, 4, [1, 2]),
    ("Livingstone Central Hospital Lab", "Naomi Sakala",
     "naomi.sakala@livingstone.health.zm", 1, 9, 45, [1]),
    ("Solwezi Mine Clinic Lab", "Brian Kunda",
     "brian.kunda@solwezi.health.zm", 4, 8, 103, [1]),
    # these three register for the Virology PT viral load scheme
    ("Arthur Davison Childrens Hospital Lab", "Chanda Mwape",
     "chanda.mwape@adch.health.zm", 1, 2, 10, [5]),
    ("Chipata Central Hospital Lab", "Foster Tembo",
     "foster.tembo@chipata.health.zm", 1, 3, 15, [6]),
    ("Kabwe General Hospital Lab", "Idah Nsofwa",
     "idah.nsofwa@kabwe.health.zm", 1, 1, 26, [5, 7, 8]),
    # these two register for the early infant diagnosis scheme
    ("Mansa General Hospital Lab", "Chola Mumba",
     "chola.mumba@mansa.health.zm", 1, 4, 71, [8]),
    ("Mongu Provincial Hospital Lab", "Situmbeko Imwiko",
     "situmbeko.imwiko@mongu.health.zm", 1, 10, 82, [9]),
    # and these take the NHRTI bacteriology scheme
    ("Ndola Teaching Hospital Microbiology", "Mwila Chibesa",
     "mwila.chibesa@ndolamicro.health.zm", 1, 2, 10, [10]),
    ("Kitwe Teaching Hospital Microbiology", "Rachel Banda",
     "rachel.banda@kitwemicro.health.zm", 1, 2, 4, [10, 11]),
    ("Lusaka Trust Hospital Laboratory", "Davies Simukonda",
     "davies.simukonda@lth.co.zm", 2, 5, 39, [11]),
]


async def _one(sql, **params):
    """Fetch a single row for the small lookups the registration flow needs."""
    async with database.AsyncSessionLocal() as db:
        return (await db.execute(text(sql), params)).first()


async def _pick_facilities(n):
    """A distinct Zambian facility (from the MFL) for each demo laboratory.

    Drawn from the high end of the list so the low-numbered facilities stay
    free for ad-hoc and automated signup testing.
    """
    async with database.AsyncSessionLocal() as db:
        rows = (await db.execute(text(
            "SELECT id FROM facilities WHERE district_id IS NOT NULL "
            "ORDER BY id DESC LIMIT :n"), {"n": n})).all()
    return [r[0] for r in rows]


async def _method_scheme_map():
    """method id -> scheme id, so a lab's methods can be grouped by scheme."""
    async with database.AsyncSessionLocal() as db:
        rows = (await db.execute(text("SELECT id, scheme_id FROM methods"))).all()
    return {mid: sid for mid, sid in rows}


async def register_labs(c):
    """Each person self-registers through the live four-step flow (signup ->
    verify -> set password) and then registers a laboratory for every scheme
    their methods belong to - registration is per scheme now.

    Returns the per-scheme laboratory records and the user id for each email.
    """
    import jose.jwt as jwt
    facilities = await _pick_facilities(len(LABS))
    scheme_of = await _method_scheme_map()

    labs = []          # one record per (person, scheme) laboratory
    users = {}         # email -> user id (the person)

    for (name, contact, email, lab_type, prov, dist, methods), facility_id in zip(
            LABS, facilities):
        phone = "+26097" + str(abs(hash(email)) % 10000000).zfill(7)

        # 1. the person signs themselves up against a facility
        r = await c.post("/auth/signup", json=dict(
            country="Zambia", name=contact, position="Laboratory In-charge",
            phone_number=phone, email=email, facility_id=facility_id))
        if r.status_code != 200:
            fail(f"signup {name}", r)
            continue

        # 2+3. verification token (email is suppressed), then set the password
        token_row = await _one(
            "SELECT verification_token FROM users WHERE email=:e", e=email)
        r = await c.post("/auth/set-password",
                         json={"token": token_row[0], "password": DEMO_PASSWORD})
        if r.status_code != 200:
            fail(f"set-password {name}", r)
            continue

        lr = await c.post("/auth/login",
                          data={"username": email, "password": DEMO_PASSWORD})
        if lr.status_code != 200:
            fail(f"login {email}", lr)
            continue
        users[email] = jwt.decode(lr.json()["access_token"], assist.SECRET_KEY,
                                  algorithms=[assist.ALGORITHM])["userid"]

        # 4. a laboratory registration per scheme the methods belong to
        by_scheme = {}
        for m in methods:
            by_scheme.setdefault(scheme_of[m], []).append(m)

        for scheme_id, ms in sorted(by_scheme.items()):
            r = await c.post("/registration/register-scheme", json={
                "user_email": email, "scheme_id": scheme_id, "name": name,
                "lab_type_id": lab_type, "physical_address": f"{name}, Zambia",
                "method_list": [{"id": m} for m in ms], "facility_id": facility_id,
                "terms_accepted": True, "confidentiality_waiver": False})
            if r.status_code != 200:
                fail(f"register {name} scheme {scheme_id}", r)
                continue
            body = r.json()
            labs.append(dict(email=email, user_id=users.get(email), scheme_id=scheme_id,
                             lab_id=body["laboratory_id"], code=body["code"],
                             name=name, approved=False))
        note(f"{name}: {len([l for l in labs if l['email'] == email])} "
             f"scheme registration(s)")

    print(f"4. {len(labs)} laboratory registration(s) across {len(users)} people")
    return labs, users


async def approve_labs(c, labs):
    """The provider reviews each laboratory registration. One person is left
    awaiting review and one is rejected; the rest are accepted. Marks the
    accepted records so only they go on to enrol."""
    pending = "brian.kunda@solwezi.health.zm"
    rejected = "naomi.sakala@livingstone.health.zm"
    accepted = 0

    for lab in labs:
        if lab["email"] == pending:
            continue  # left awaiting review

        action = (assist.REVIEW_ACTION_REJECT if lab["email"] == rejected
                  else assist.REVIEW_ACTION_APPROVE)
        r = await c.put(f"/laboratorys/review-update/{lab['lab_id']}", json={
            "user_id": 1, "review_action": action,
            "comments": ("Documentation incomplete - please reapply"
                         if action == assist.REVIEW_ACTION_REJECT
                         else "Registration verified against the CDL register"),
            "content": None, "attachment_id": None})
        if r.status_code != 200:
            fail(f"review {lab['name']} ({lab['code']})", r)
            continue

        if action == assist.REVIEW_ACTION_APPROVE:
            lab["approved"] = True
            accepted += 1

    note(f"{pending} left awaiting review; {rejected} rejected")
    print(f"5. {accepted} laboratory registration(s) accepted")


def _full_schedule(effective, closing, shipping, reports):
    """Builds the complete seven-date schedule the API now requires.

    Only four anchors are supplied per round; the test-event window and the
    result-submission due date are placed between shipping and reports. The
    anchors are sorted first so a round written in the old order still produces
    a valid, strictly ascending schedule - the final dates are set precisely by
    advance()/backdate() anyway.
    """
    eff, close, ship, rep = sorted([effective, closing, shipping, reports])
    span = max((rep - ship).days, 6)
    return {
        "effective_date": eff.isoformat(),
        "closing_date": close.isoformat(),
        "shipping_date": ship.isoformat(),
        "test_event_start_date": (ship + timedelta(days=span // 5)).isoformat(),
        "test_event_stop_date": (ship + timedelta(days=(span * 2) // 5)).isoformat(),
        "result_submission_due_date": (ship + timedelta(days=(span * 4) // 5)).isoformat(),
        "reports_availability_date": rep.isoformat(),
    }


async def make_cycle(c, name, code, effective, closing, shipping, reports,
                     scheme_id=1):
    r = await c.post("/pt-cycles/create", json=dict(
        name=name, code=code, description=f"{name} proficiency testing round",
        scheme_id=scheme_id,
        **_full_schedule(effective, closing, shipping, reports),
        user_id=1, status_id=assist.STATUS_SUBMITTED,
        stage_id=assist.APPROVAL_STAGE_SUBMITTED, approval_levels=1))
    if r.status_code != 200:
        fail(f"create cycle {name}", r)
        return None
    cycle_id = r.json()["id"]

    # a different member of staff approves it
    r = await c.put(f"/pt-cycles/review-update/{cycle_id}", json={
        "user_id": 2, "review_action": assist.REVIEW_ACTION_APPROVE,
        "comments": "Calendar confirmed", "content": None, "attachment_id": None})
    if r.status_code != 200:
        fail(f"approve cycle {name}", r)
        return None
    return cycle_id


async def advance(c, cycle_id, status_id, label):
    """Moves a cycle to a lifecycle phase.

    Status is derived from the schedule, so the two manual gates use their real
    endpoints (shipping opens the result sheets; publishing scores the round),
    and the date-driven phases (enrolment open, etc.) are reached with the dev
    phase-jump helper, which back-dates the schedule around today.
    """
    if status_id == assist.PT_CYCLE_SAMPLES_SHIPPED:
        r = await c.put(f"/pt-cycles/samples-shipped/{cycle_id}", json={"user_id": 1})
    elif status_id == assist.PT_CYCLE_REPORT_AVAILABLE:
        r = await c.put(f"/pt-cycles/publish-reports/{cycle_id}", json={"user_id": 1})
    else:
        r = await c.put(f"/pt-cycles/dev-set-phase/{cycle_id}",
                        json={"pt_cyle_status_id": status_id, "user_id": 1})
    if r.status_code != 200:
        fail(f"{label} -> {assist.PT_CYCLE_STATUS_NAMES[status_id]}", r)
        return False
    note(f"{label}: {r.json()['message']}")
    return True


async def enrol(c, cycle_id, scheme_id, labs, users, emails):
    """Offers the cycle to each approved laboratory registered for its scheme.

    Registration is per scheme now, so only the laboratory a person registered
    for this cycle's scheme is offered - a TB lab has no business in a viral
    load round.
    """
    enrolled = 0
    for lab in labs:
        if lab["scheme_id"] != scheme_id or not lab["approved"]:
            continue
        if lab["email"] not in emails:
            continue

        # a coordinator enrols on the lab's behalf: a person who registered for
        # several schemes has several laboratories but their account is tied to
        # only one, so self-enrolment cannot reach the others
        r = await c.post("/enrollments/apply", json={
            "pt_cycle_id": cycle_id, "lab_id": lab["lab_id"], "user_id": 1})

        if r.status_code == 400 and "no approved methods" in r.text:
            continue
        if r.status_code != 200:
            fail(f"enrol {lab['name']} ({lab['code']})", r)
            continue

        enrolled += 1
        note(f"{lab['name']} enrolled for {r.json()['enrollment_count']} method(s)")

    note(f"{enrolled} laboratory(ies) enrolled")
    return enrolled


async def accept_enrolments(c, cycle_id, skip_email=None, labs=None):
    skip_lab_ids = set()
    if skip_email and labs:
        skip_lab_ids = {lab["lab_id"] for lab in labs if lab["email"] == skip_email}
    r = await c.get(f"/enrollments/list/cycle/{cycle_id}")
    accepted = []
    for e in r.json():
        if e["lab_id"] in skip_lab_ids:
            note(f"{e['laboratory']['name']}: enrolment left pending")
            continue
        # a different member of staff reviews it; the coordinator who applied on
        # the lab's behalf (user 1) cannot also be its first reviewer
        rr = await c.put(f"/enrollments/review-update/{e['id']}", json={
            "user_id": 2, "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "Enrolment accepted", "content": None, "attachment_id": None})
        if rr.status_code != 200:
            fail(f"accept enrolment {e['id']}", rr)
            continue
        accepted.append(e)
    note(f"{len(accepted)} enrolment(s) accepted")
    return accepted


# the result sheets that shipping opens, one row per (cycle, lab, sample)
_RESULT_TABLES = ("tb_xpert_ultra_results", "tb_xpert_xdr_results",
                  "hiv_vl_results", "hiv_eid_results", "bacteriology_results")


async def receive_all(c, cycle_id, users, labs, when):
    """Records each sample's receipt, which the lab must do before entering
    results. A receipt is logged per (cycle, lab, sample) against every result
    sheet the shipping opened."""
    user_by_lab = {lab["lab_id"]: lab["user_id"] for lab in labs}

    pairs = set()
    async with database.AsyncSessionLocal() as db:
        for table in _RESULT_TABLES:
            rows = (await db.execute(text(
                f"SELECT DISTINCT lab_id, method_sample_id FROM {table} "
                "WHERE pt_cycle_id=:c"), {"c": cycle_id})).all()
            pairs |= {(lab_id, sample_id) for lab_id, sample_id in rows}

    done = 0
    for lab_id, sample_id in pairs:
        if lab_id not in user_by_lab:
            continue
        # recorded on the lab's behalf by a coordinator (user 1): a person who
        # registered several schemes is tied to only one of their laboratories
        rr = await c.post("/sample-receipts", json={
            "user_id": 1, "pt_cycle_id": cycle_id, "lab_id": lab_id,
            "method_sample_id": sample_id, "date_received": when.isoformat(),
            "condition": "Suitable", "temperature_c": 4.0,
            "comments": "Received in good condition"})
        if rr.status_code != 200:
            fail(f"receipt lab {lab_id} sample {sample_id}", rr)
            continue
        done += 1
    note(f"{done} sample receipt(s) recorded")


# a spread of results that exercises every branch of the form
RESULT_PATTERNS = [
    dict(result_interpretable="Yes", tb_detection_result="NOT DETECTED",
         rif_result="N/A", ultra_spc=23.4, is1081_is6110=0.0,
         rpob1=0.0, rpob2=0.0, rpob3=0.0, rpob4=0.0),
    dict(result_interpretable="Yes", tb_detection_result="HIGH",
         rif_result="NOT DETECTED", ultra_spc=22.8, is1081_is6110=16.2,
         rpob1=17.1, rpob2=16.9, rpob3=18.5, rpob4=17.3),
    dict(result_interpretable="Yes", tb_detection_result="MEDIUM",
         rif_result="DETECTED", ultra_spc=23.1, is1081_is6110=21.4,
         rpob1=22.1, rpob2=21.9, rpob3=24.5, rpob4=22.1),
    dict(result_interpretable="Yes", tb_detection_result="TRACE",
         rif_result="N/A", ultra_spc=24.0, is1081_is6110=27.8,
         rpob1=28.4, rpob2=28.1, rpob3=29.9, rpob4=28.6),
    dict(result_interpretable="No", uninterpretable_result="ERROR",
         error_code="5007"),
]


# a spread of viral loads: undetectable, low, mid, high, and one not tested
# what each laboratory reports for an EID panel item
EID_ASSAYS = {
    "Cobas 4800": ("Cobas 4800", "Cobas 4800"),
    "GeneXpert HIV-1 Qual": ("GeneXpert", "GeneXpert"),
}

EID_TARGETS = {
    "Kit Negative Control": "HIV-1 Not Detected",
    "Kit Positive Control": "HIV-1 Detected",
    "2026-01": "HIV-1 Detected",
    "2026-02": "HIV-1 Not Detected",
    "2026-03": "HIV-1 Not Detected",
    "2026-04": "HIV-1 Not Detected",
    "2026-05": "HIV-1 Detected",
}


async def capture_eid_results(c, cycle_id, users, labs, received_on, tested_on,
                              submit=True, approve=False, leave_last_draft=False):
    """The same walk as the other forms, against the EID form."""
    r = await c.get("/hiv-eid-results/list", params={"pt_cycle_id": cycle_id})
    sheets = r.json()
    email_by_lab = {lab["lab_id"]: lab["email"] for lab in labs}
    name_by_email = {lab["email"]: lab["name"] for lab in labs}

    by_lab = {}
    for sheet in sheets:
        by_lab.setdefault(sheet["lab_id"], []).append(sheet)

    submitted = drafted = 0
    for lab_id, items in by_lab.items():
        email = email_by_lab.get(lab_id)
        if email not in users:
            continue

        for i, sheet in enumerate(sorted(items, key=lambda x: x["method_sample_id"])):
            sample_name = sheet["methodsample"]["name"]
            target = EID_TARGETS.get(sample_name, "HIV-1 Not Detected")

            last = leave_last_draft and i == len(items) - 1
            as_draft = (not submit) or last

            # one laboratory misses a positive, and one cannot test a sample
            reported = "Yes"
            result = target
            reason = None

            scored = not sample_name.startswith("Kit")

            # only some laboratories miss a call, so the round has a mix of
            # satisfactory and unsatisfactory participants
            if scored and (lab_id * 5 + i * 3) % 17 == 0:
                result = ("HIV-1 Not Detected" if target == "HIV-1 Detected"
                          else "HIV-1 Detected")

            # and one could not test a sample at all
            if scored and (lab_id * 7 + i * 2) % 23 == 0:
                reported, result, reason = "No", None, (
                    "Insufficient sample volume received")

            detection, extraction = EID_ASSAYS.get(
                sheet["method"]["name"], ("Cobas 4800", "Cobas 4800"))

            body = {k: v for k, v in sheet.items() if k not in (
                "stage", "status", "user", "scheme", "laboratory", "service",
                "enrollment", "ptcycle", "method", "methodsample")}
            body.update(
                user_id=1,
                date_tested=tested_on.isoformat() if reported == "Yes" else None,
                detection_assay=detection if reported == "Yes" else None,
                extraction_assay=extraction if reported == "Yes" else None,
                assay_serial_number=f"SN-{4000 + lab_id}" if reported == "Yes" else None,
                result_reported=reported,
                hiv_result=result,
                hiv_ct_od_value=(round(24.0 + spread(lab_id, i, 0.4), 2)
                                 if reported == "Yes" and result == "HIV-1 Detected"
                                 else None),
                ic_qs_value=(round(30.0 + spread(lab_id, i, 0.3), 2)
                             if reported == "Yes" else None),
                not_tested_reason=reason,
                tested_by=name_by_email.get(email, "").split()[0] + " Technologist",
                supervisor_name="Laboratory In-charge",
                status_id=assist.STATUS_DRAFT if as_draft else assist.STATUS_SUBMITTED,
                stage_id=(assist.APPROVAL_STAGE_AWAIT_SUBMISSION if as_draft
                          else assist.APPROVAL_STAGE_SUBMITTED))

            rr = await c.put(f"/hiv-eid-results/update/{sheet['id']}", json=body)
            if rr.status_code != 200:
                fail(f"eid result {sheet['id']}", rr)
                continue

            if as_draft:
                drafted += 1
                continue
            submitted += 1

            if approve:
                ar = await c.put(f"/hiv-eid-results/review-update/{sheet['id']}", json={
                    "user_id": GRADER_ID,
                    "review_action": assist.REVIEW_ACTION_APPROVE,
                    "comments": "Checked against the target result",
                    "content": None, "attachment_id": None})
                if ar.status_code != 200:
                    fail(f"grade eid {sheet['id']}", ar)

    note(f"HIV-1 EID: {submitted} result(s) submitted, {drafted} left as draft"
         + (", all submitted results graded" if approve else ""))


# what each laboratory reports for a viral load panel item
VL_RESULT_PATTERNS = [
    dict(result_reported="Yes", viral_load_log10=0.0),
    dict(result_reported="Yes", viral_load_log10=2.68),
    dict(result_reported="Yes", viral_load_log10=3.94),
    dict(result_reported="Yes", viral_load_log10=5.21),
    dict(result_reported="No",
         not_tested_reason="Panel arrived thawed, sample integrity compromised"),
]

VL_PLATFORMS = {
    "Abbott m2000": ("Abbott m2000", "Abbott m2000"),
    "Roche Cobas 6800": ("Roche Cobas 6800", "Roche Cobas 6800"),
    "Hologic Panther": ("Hologic Panther", "Hologic Panther"),
}


async def capture_vl_results(c, cycle_id, users, labs, received_on, tested_on,
                             submit=True, approve=False, leave_last_draft=False):
    """The same walk as the TB results, against the HIV-1 viral load form."""
    r = await c.get("/hiv-vl-results/list", params={"pt_cycle_id": cycle_id})
    sheets = r.json()
    email_by_lab = {lab["lab_id"]: lab["email"] for lab in labs}
    name_by_email = {lab["email"]: lab["name"] for lab in labs}

    by_lab = {}
    for sheet in sheets:
        by_lab.setdefault(sheet["lab_id"], []).append(sheet)

    submitted = drafted = 0
    for lab_id, items in by_lab.items():
        email = email_by_lab.get(lab_id)
        if email not in users:
            continue

        for i, sheet in enumerate(sorted(items, key=lambda x: x["method_sample_id"])):
            pattern = VL_RESULT_PATTERNS[i % len(VL_RESULT_PATTERNS)]
            last = leave_last_draft and i == len(items) - 1
            as_draft = (not submit) or last
            tested = pattern["result_reported"] == "Yes"

            detection, extraction = VL_PLATFORMS.get(
                sheet["method"]["name"], ("GeneXpert", "GeneXpert"))

            body = {k: v for k, v in sheet.items() if k not in (
                "stage", "status", "user", "scheme", "laboratory", "service",
                "enrollment", "ptcycle", "method", "methodsample")}
            body.update(pattern)

            # spread the participants out so the round has a distribution
            if body.get("viral_load_log10"):
                value = body["viral_load_log10"] + spread(lab_id, i)
                # one laboratory is a genuine outlier on one sample, so the
                # report has an Unacceptable z-score to show
                if miscalls(lab_id, i) and i == 2:
                    value += 1.4
                body["viral_load_log10"] = round(max(value, 0.0), 2)

            body.update(
                user_id=1,
                date_tested=tested_on.isoformat() if tested else None,
                detection_assay=detection if tested else None,
                extraction_assay=extraction if tested else None,
                assay_kit_lot_number=f"LOT-{2600 + lab_id}" if tested else None,
                assay_kit_expiry_date="2027-06-30" if tested else None,
                assay_serial_number=f"SN-{9000 + lab_id}" if tested else None,
                tested_by=name_by_email.get(email, "").split()[0] + " Technologist",
                supervisor_name="Laboratory In-charge",
                status_id=assist.STATUS_DRAFT if as_draft else assist.STATUS_SUBMITTED,
                stage_id=(assist.APPROVAL_STAGE_AWAIT_SUBMISSION if as_draft
                          else assist.APPROVAL_STAGE_SUBMITTED))

            rr = await c.put(f"/hiv-vl-results/update/{sheet['id']}", json=body)
            if rr.status_code != 200:
                fail(f"vl result {sheet['id']}", rr)
                continue

            if as_draft:
                drafted += 1
                continue
            submitted += 1

            if approve:
                ar = await c.put(f"/hiv-vl-results/review-update/{sheet['id']}", json={
                    "user_id": GRADER_ID,
                    "review_action": assist.REVIEW_ACTION_APPROVE,
                    "comments": "Within the assigned value +/- the allowable range",
                    "content": None, "attachment_id": None})
                if ar.status_code != 200:
                    fail(f"grade vl {sheet['id']}", ar)

    note(f"HIV-1 VL: {submitted} result(s) submitted, {drafted} left as draft"
         + (", all submitted results graded" if approve else ""))


def spread(lab_id, index, width=0.08):
    """A small, repeatable per-laboratory offset.

    Real participants do not all report the same number; without some spread
    the interquartile range is zero and no z-score exists.
    """
    return (((lab_id * 3 + index * 5) % 7) - 3) * width


def miscalls(lab_id, index):
    """True for the handful of lab/sample pairs that get the answer wrong."""
    return (lab_id * 3 + index) % 5 == 0


XDR_CT = dict(spc_ahpc=22.1, inha=22.3, katg=24.0, fabg1=23.0,
              gyra1=23.2, gyra2=21.0, gyra3=22.0, gyrb2=22.0, rrs=21.0)

# the XDR assay reports presence or absence, then resistance against four drugs
XDR_RESULT_PATTERNS = [
    # no complex detected, so there is nothing to test resistance against
    dict(result_interpretable="Yes", tb_detection_result="NOT DETECTED",
         inh_result="N/A", flq_result="N/A", amk_result="N/A", eth_result="N/A",
         **XDR_CT),
    # fully susceptible
    dict(result_interpretable="Yes", tb_detection_result="DETECTED",
         inh_result="NOT DETECTED", flq_result="NOT DETECTED",
         amk_result="NOT DETECTED", eth_result="NOT DETECTED", **XDR_CT),
    # isoniazid resistance
    dict(result_interpretable="Yes", tb_detection_result="DETECTED",
         inh_result="DETECTED", flq_result="NOT DETECTED",
         amk_result="NOT DETECTED", eth_result="DETECTED", **XDR_CT),
    # pre-XDR: fluoroquinolone resistance on top of isoniazid
    dict(result_interpretable="Yes", tb_detection_result="DETECTED",
         inh_result="DETECTED", flq_result="DETECTED",
         amk_result="NOT DETECTED", eth_result="DETECTED", **XDR_CT),
    # an instrument error
    dict(result_interpretable="No", uninterpretable_result="ERROR",
         error_code="5011"),
]


async def capture_xdr_results(c, cycle_id, users, labs, tested_on, submit=True,
                              approve=False, leave_last_draft=False):
    """The same walk as the Ultra results, against the XDR form."""
    r = await c.get("/tb-xpert-xdr-results/list", params={"pt_cycle_id": cycle_id})
    sheets = r.json()
    email_by_lab = {lab["lab_id"]: lab["email"] for lab in labs}
    name_by_email = {lab["email"]: lab["name"] for lab in labs}

    by_lab = {}
    for sheet in sheets:
        by_lab.setdefault(sheet["lab_id"], []).append(sheet)

    submitted = drafted = 0
    for lab_id, items in by_lab.items():
        email = email_by_lab.get(lab_id)
        if email not in users:
            continue
        for i, sheet in enumerate(sorted(items, key=lambda x: x["method_sample_id"])):
            pattern = XDR_RESULT_PATTERNS[i % len(XDR_RESULT_PATTERNS)]
            last = leave_last_draft and i == len(items) - 1
            as_draft = (not submit) or last

            body = {k: v for k, v in sheet.items() if k not in (
                "stage", "status", "user", "scheme", "laboratory", "service",
                "enrollment", "ptcycle", "method", "methodsample")}
            body.update(pattern)

            # a few laboratories miss the isoniazid call
            if miscalls(lab_id, i) and body.get("inh_result") == "DETECTED":
                body["inh_result"] = "NOT DETECTED"

            body.update(
                user_id=1,
                date_tested=tested_on.isoformat(),
                status_id=assist.STATUS_DRAFT if as_draft else assist.STATUS_SUBMITTED,
                stage_id=(assist.APPROVAL_STAGE_AWAIT_SUBMISSION if as_draft
                          else assist.APPROVAL_STAGE_SUBMITTED))

            rr = await c.put(f"/tb-xpert-xdr-results/update/{sheet['id']}", json=body)
            if rr.status_code != 200:
                fail(f"xdr result {sheet['id']}", rr)
                continue

            if as_draft:
                drafted += 1
                continue
            submitted += 1

            if approve:
                ar = await c.put(
                    f"/tb-xpert-xdr-results/review-update/{sheet['id']}", json={
                        "user_id": GRADER_ID,
                        "review_action": assist.REVIEW_ACTION_APPROVE,
                        "comments": "Graded against the expected panel result",
                        "content": None, "attachment_id": None})
                if ar.status_code != 200:
                    fail(f"grade xdr {sheet['id']}", ar)

    note(f"XDR: {submitted} result(s) submitted, {drafted} left as draft"
         + (", all submitted results graded" if approve else ""))


async def capture_results(c, cycle_id, users, labs, tested_on, submit=True,
                          approve=False, leave_last_draft=False):
    r = await c.get(f"/tb-xpert-ultra-results/list", params={"pt_cycle_id": cycle_id})
    sheets = r.json()
    email_by_lab = {lab["lab_id"]: lab["email"] for lab in labs}
    name_by_email = {lab["email"]: lab["name"] for lab in labs}

    by_lab = {}
    for s in sheets:
        by_lab.setdefault(s["lab_id"], []).append(s)

    submitted = drafted = 0
    for lab_id, items in by_lab.items():
        email = email_by_lab.get(lab_id)
        if email not in users:
            continue
        for i, sheet in enumerate(sorted(items, key=lambda x: x["method_sample_id"])):
            pattern = RESULT_PATTERNS[i % len(RESULT_PATTERNS)]
            last = leave_last_draft and i == len(items) - 1
            as_draft = (not submit) or last

            body = {k: v for k, v in sheet.items() if k not in (
                "stage", "status", "user", "scheme", "laboratory", "service",
                "enrollment", "ptcycle", "method", "methodsample")}
            body.update(pattern)

            # a few laboratories grade the smear one step away from the panel
            if miscalls(lab_id, i) and body.get("tb_detection_result") in (
                    "HIGH", "MEDIUM", "TRACE"):
                body["tb_detection_result"] = {
                    "HIGH": "MEDIUM", "MEDIUM": "LOW", "TRACE": "NOT DETECTED",
                }[body["tb_detection_result"]]

            body.update(
                user_id=1,
                date_tested=tested_on.isoformat(),
                xpert_module_number=f"A{(i % 4) + 1}",
                status_id=assist.STATUS_DRAFT if as_draft else assist.STATUS_SUBMITTED,
                stage_id=(assist.APPROVAL_STAGE_AWAIT_SUBMISSION if as_draft
                          else assist.APPROVAL_STAGE_SUBMITTED))

            rr = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=body)
            if rr.status_code != 200:
                fail(f"result {sheet['id']}", rr)
                continue

            if as_draft:
                drafted += 1
                continue
            submitted += 1

            if approve:
                ar = await c.put(f"/tb-xpert-ultra-results/review-update/{sheet['id']}", json={
                    "user_id": GRADER_ID, "review_action": assist.REVIEW_ACTION_APPROVE,
                    "comments": "Graded against the expected panel result",
                    "content": None, "attachment_id": None})
                if ar.status_code != 200:
                    fail(f"grade {sheet['id']}", ar)

    note(f"{submitted} result(s) submitted, {drafted} left as draft"
         + (", all submitted results graded" if approve else ""))


# What the NHRTI bacteriology panel should come back as, from protocol
# TP-NHRTI-BACT-001 and the scenarios in TF-NHRTI-BACT-003:
# stain reaction, morphology, organism, and the AST answer for sample E.
BACT_TARGETS = {
    "NHRTIBACT A01-26": ("Gram negative", "Bacilli", "Escherichia coli", None),
    "NHRTIBACT B01-26": ("Gram positive", "Cocci",
                         "Staphylococcus epidermidis", None),
    "NHRTIBACT C01-26": ("Gram positive", "Diplococci",
                         "Streptococcus agalactiae", None),
    "NHRTIBACT D01-26": ("Gram positive", "Cocci", "Staphylococcus aureus",
                         None),
    "NHRTIBACT E01-26": ("Gram negative", "Bacilli", "Klebsiella pneumoniae",
                         [("AMIKACIN", 20.0, "S"),
                          ("CEFTRIAXONE", 10.0, "R"),
                          ("CIPROFLOXACIN", 24.0, "S"),
                          ("GENTAMICIN", 21.0, "S"),
                          ("MEROPENEM", 26.0, "S")]),
}

# a wrong answer that is still a plausible one, so an unsatisfactory
# participant looks like a real laboratory rather than a typing error
BACT_MISCALLS = {
    "Escherichia coli": "Klebsiella pneumoniae",
    "Staphylococcus epidermidis": "Staphylococcus aureus",
    "Streptococcus agalactiae": "Streptococcus pyogenes",
    "Staphylococcus aureus": "Staphylococcus epidermidis",
    "Klebsiella pneumoniae": "Enterobacter cloacae",
}


async def capture_bacteriology_results(c, cycle_id, users, labs, received_on,
                                       tested_on, submit=True, approve=False,
                                       leave_last_draft=False):
    """The same walk as the other forms, against the bacteriology worksheet."""
    r = await c.get("/bacteriology-results/list", params={"pt_cycle_id": cycle_id})
    sheets = r.json()
    email_by_lab = {lab["lab_id"]: lab["email"] for lab in labs}
    name_by_email = {lab["email"]: lab["name"] for lab in labs}

    by_lab = {}
    for sheet in sheets:
        by_lab.setdefault(sheet["lab_id"], []).append(sheet)

    submitted = drafted = 0
    for lab_id, items in by_lab.items():
        email = email_by_lab.get(lab_id)
        if email not in users:
            continue

        for i, sheet in enumerate(sorted(items, key=lambda x: x["method_sample_id"])):
            sample_name = sheet["methodsample"]["name"]
            stain, morphology, organism, ast = BACT_TARGETS.get(
                sample_name, ("Gram negative", "Bacilli", "Escherichia coli", None))

            last = leave_last_draft and i == len(items) - 1
            as_draft = (not submit) or last

            not_done = False
            reason = None

            # one laboratory in the round names the wrong organism
            if (lab_id * 5 + i * 3) % 13 == 0:
                organism = BACT_MISCALLS.get(organism, organism)

            # and one receives a swab it cannot work at all
            if (lab_id * 7 + i * 2) % 19 == 0:
                not_done = True
                reason = "Swab arrived dry, transport medium had leaked"

            rows = []
            if ast and not not_done:
                for row_no, (agent, zone, interpretation) in enumerate(ast, 1):
                    # the same laboratory that misnames an organism also calls
                    # one susceptibility wrong
                    if (lab_id * 3 + row_no) % 11 == 0:
                        interpretation = "S" if interpretation == "R" else "R"
                        zone = 24.0 if interpretation == "S" else 10.0
                    rows.append(dict(
                        ast_method="disk_diffusion", row_no=row_no,
                        antibiotic=agent,
                        zone_diameter=round(zone + spread(lab_id, row_no, 1.5), 1),
                        mic_reading=None, interpretation=interpretation))

            body = {k: v for k, v in sheet.items() if k not in (
                "stage", "status", "user", "scheme", "laboratory", "service",
                "enrollment", "ptcycle", "method", "methodsample")}
            body.update(
                user_id=1,
                date_samples_received=received_on.isoformat(),
                receipt_temperature=round(5.0 + spread(lab_id, i, 0.5), 1),
                sample_condition="Unsuitable" if not_done else "Suitable",
                sample_condition_reason=reason,
                date_submitted=tested_on.isoformat(),
                testing_not_done=not_done,
                testing_not_done_reason=reason,
                gram_stain_reaction=None if not_done else stain,
                gram_morphology=None if not_done else morphology,
                gram_morphology_other=None,
                microscopy_comment=None,
                organism_identified=None if not_done else organism,
                identification_comment=None,
                ast_performed=bool(rows),
                ast_guideline="CLSI" if rows else None,
                ast_disk_diffusion=bool(rows),
                ast_mic_method=None,
                ast_mic_method_other=None,
                astresult=rows,
                comments=None,
                reported_by=name_by_email.get(email, "").split()[0] + " Technologist",
                reported_on=tested_on.isoformat(),
                reviewed_by="Laboratory In-charge",
                reviewed_on=tested_on.isoformat(),
                status_id=assist.STATUS_DRAFT if as_draft else assist.STATUS_SUBMITTED,
                stage_id=(assist.APPROVAL_STAGE_AWAIT_SUBMISSION if as_draft
                          else assist.APPROVAL_STAGE_SUBMITTED))

            rr = await c.put(f"/bacteriology-results/update/{sheet['id']}", json=body)
            if rr.status_code != 200:
                fail(f"bacteriology result {sheet['id']}", rr)
                continue

            if as_draft:
                drafted += 1
                continue
            submitted += 1

            if approve:
                ar = await c.put(
                    f"/bacteriology-results/review-update/{sheet['id']}", json={
                        "user_id": GRADER_ID,
                        "review_action": assist.REVIEW_ACTION_APPROVE,
                        "comments": "Checked against the characterised strain",
                        "content": None, "attachment_id": None})
                if ar.status_code != 200:
                    fail(f"grade bacteriology {sheet['id']}", ar)

    note(f"Bacteriology: {submitted} worksheet(s) submitted, {drafted} left as draft"
         + (", all submitted worksheets graded" if approve else ""))


async def backdate(cycle_id, effective, closing, shipping, reports):
    """Pulls a cycle's dates into the past so it reads as historical.

    Writes the full seven-date schedule (the test window and due date are
    derived the same way make_cycle does) and refreshes the cached lifecycle
    status, since listings read the stored status rather than recomputing it.
    The manual gates are left as they are, so a published round stays published.
    """
    from sqlalchemy.future import select
    from models.ptcycle_model import PTCycleDB

    sched = _full_schedule(effective, closing, shipping, reports)
    async with database.AsyncSessionLocal() as db:
        await db.execute(text(
            "UPDATE pt_cycles SET effective_date=:effective_date, "
            "closing_date=:closing_date, shipping_date=:shipping_date, "
            "test_event_start_date=:test_event_start_date, "
            "test_event_stop_date=:test_event_stop_date, "
            "result_submission_due_date=:result_submission_due_date, "
            "reports_availability_date=:reports_availability_date WHERE id=:id"),
            {**{k: date.fromisoformat(v) for k, v in sched.items()}, "id": cycle_id})
        cyc = (await db.execute(
            select(PTCycleDB).where(PTCycleDB.id == cycle_id))).scalars().first()
        if cyc:
            cyc.pt_cyle_status_id = assist.compute_pt_cycle_status(cyc)
        await db.commit()


async def resolve_grader():
    """The quality officer who grades submitted results."""
    global GRADER_ID
    from sqlalchemy.future import select
    from models.user_model import UserDB
    async with database.AsyncSessionLocal() as db:
        user = (await db.execute(select(UserDB).where(
            UserDB.email == "quality@cdl.moh.gov.zm"))).scalars().first()
        GRADER_ID = user.id
        note(f"results will be graded by {user.email} (user {user.id})")


async def workflow():
    transport = ASGITransport(app=main.app)
    async with AsyncClient(transport=transport, base_url="http://seed", timeout=60) as c:
        labs, users = await register_labs(c)
        await approve_labs(c, labs)

        active = [e for e in users]

        # ---- a completed round, so there is history to look at ----------
        print("\n6. Round 2026-A (completed)")
        c1 = await make_cycle(c, "DTS Round One 2026", "2026-A",
                              TODAY + timedelta(days=10), TODAY + timedelta(days=40),
                              TODAY + timedelta(days=50), TODAY + timedelta(days=90))
        if c1:
            await advance(c, c1, assist.PT_CYCLE_STARTED, "2026-A")
            await enrol(c, c1, 1, labs, users, active)
            await accept_enrolments(c, c1)
            await advance(c, c1, assist.PT_CYCLE_SAMPLES_SHIPPED, "2026-A")
            await receive_all(c, c1, users, labs, TODAY - timedelta(days=120))
            await capture_results(c, c1, users, labs, TODAY - timedelta(days=110),
                                  submit=True, approve=True)
            await capture_xdr_results(c, c1, users, labs, TODAY - timedelta(days=110),
                                      submit=True, approve=True)
            await advance(c, c1, assist.PT_CYCLE_REPORT_AVAILABLE, "2026-A")
            await backdate(c1, TODAY - timedelta(days=200), TODAY - timedelta(days=160),
                           TODAY - timedelta(days=130), TODAY - timedelta(days=60))

        # ---- the round in flight, where labs are capturing now ----------
        print("\n7. Round 2026-B (samples shipped, results being captured)")
        c2 = await make_cycle(c, "DTS Round Two 2026", "2026-B",
                              TODAY - timedelta(days=30), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=5), TODAY + timedelta(days=75))
        if c2:
            await advance(c, c2, assist.PT_CYCLE_STARTED, "2026-B")
            await enrol(c, c2, 1, labs, users, active)
            # one lab's enrolment is deliberately still awaiting a decision
            await accept_enrolments(c, c2, skip_email="peter.zulu@kitwe.health.zm", labs=labs)
            await advance(c, c2, assist.PT_CYCLE_SAMPLES_SHIPPED, "2026-B")
            await receive_all(c, c2, users, labs, TODAY - timedelta(days=3))
            await capture_results(c, c2, users, labs, TODAY - timedelta(days=1),
                                  submit=True, approve=False, leave_last_draft=True)
            await capture_xdr_results(c, c2, users, labs, TODAY - timedelta(days=1),
                                      submit=True, approve=False, leave_last_draft=True)
            await backdate(c2, TODAY - timedelta(days=30), TODAY - timedelta(days=10),
                           TODAY - timedelta(days=5), TODAY + timedelta(days=75))

        # ---- the round labs can still join ------------------------------
        print("\n8. Round 2027-A (open for enrolment)")
        c3 = await make_cycle(c, "DTS Round One 2027", "2027-A",
                              TODAY + timedelta(days=100), TODAY + timedelta(days=60),
                              TODAY + timedelta(days=120), TODAY + timedelta(days=180))
        if c3:
            await advance(c, c3, assist.PT_CYCLE_STARTED, "2027-A")
            # two labs have already put their names down
            await enrol(c, c3, 1, labs, users,
                        ["musachoolwe@gmail.com", "jane@gmail.com"])
            note("the remaining labs can still enrol from My Enrolments")

        # ---- one cycle that has not opened yet ---------------------------
        print("\n9. Round 2027-B (upcoming)")
        await make_cycle(c, "DTS Round Two 2027", "2027-B",
                         TODAY + timedelta(days=280), TODAY + timedelta(days=240),
                         TODAY + timedelta(days=300), TODAY + timedelta(days=360))
        note("created and approved, still Upcoming")

        # ---- the Virology PT viral load rounds --------------------------
        print("\n10. HIV-1 VL Round 2026-A (completed)")
        v1 = await make_cycle(c, "HIV-1 VL Round One 2026", "VL-2026-A",
                              TODAY + timedelta(days=10), TODAY + timedelta(days=40),
                              TODAY + timedelta(days=50), TODAY + timedelta(days=90),
                              scheme_id=2)
        if v1:
            await advance(c, v1, assist.PT_CYCLE_STARTED, "VL-2026-A")
            await enrol(c, v1, 2, labs, users, active)
            await accept_enrolments(c, v1)
            await advance(c, v1, assist.PT_CYCLE_SAMPLES_SHIPPED, "VL-2026-A")
            await receive_all(c, v1, users, labs, TODAY - timedelta(days=100))
            await capture_vl_results(c, v1, users, labs,
                                     TODAY - timedelta(days=100),
                                     TODAY - timedelta(days=95),
                                     submit=True, approve=True)
            await advance(c, v1, assist.PT_CYCLE_REPORT_AVAILABLE, "VL-2026-A")
            await backdate(v1, TODAY - timedelta(days=180), TODAY - timedelta(days=140),
                           TODAY - timedelta(days=110), TODAY - timedelta(days=40))

        print("\n11. HIV-1 VL Round 2026-B (samples shipped)")
        v2 = await make_cycle(c, "HIV-1 VL Round Two 2026", "VL-2026-B",
                              TODAY - timedelta(days=20), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=4), TODAY + timedelta(days=80),
                              scheme_id=2)
        if v2:
            await advance(c, v2, assist.PT_CYCLE_STARTED, "VL-2026-B")
            await enrol(c, v2, 2, labs, users, active)
            await accept_enrolments(c, v2)
            await advance(c, v2, assist.PT_CYCLE_SAMPLES_SHIPPED, "VL-2026-B")
            await receive_all(c, v2, users, labs, TODAY - timedelta(days=2))
            await capture_vl_results(c, v2, users, labs,
                                     TODAY - timedelta(days=2),
                                     TODAY - timedelta(days=1),
                                     submit=True, approve=False,
                                     leave_last_draft=True)
            await backdate(v2, TODAY - timedelta(days=20), TODAY - timedelta(days=8),
                           TODAY - timedelta(days=4), TODAY + timedelta(days=80))


        # ---- the early infant diagnosis rounds --------------------------
        print("\n13. HIV-1 EID Round 2026-A (completed)")
        e1 = await make_cycle(c, "HIV-1 EID Round One 2026", "EID-2026-A",
                              TODAY + timedelta(days=10), TODAY + timedelta(days=40),
                              TODAY + timedelta(days=50), TODAY + timedelta(days=90),
                              scheme_id=3)
        if e1:
            await advance(c, e1, assist.PT_CYCLE_STARTED, "EID-2026-A")
            await enrol(c, e1, 3, labs, users, active)
            await accept_enrolments(c, e1)
            await advance(c, e1, assist.PT_CYCLE_SAMPLES_SHIPPED, "EID-2026-A")
            await receive_all(c, e1, users, labs, TODAY - timedelta(days=90))
            await capture_eid_results(c, e1, users, labs,
                                      TODAY - timedelta(days=90),
                                      TODAY - timedelta(days=86),
                                      submit=True, approve=True)
            await advance(c, e1, assist.PT_CYCLE_REPORT_AVAILABLE, "EID-2026-A")
            await backdate(e1, TODAY - timedelta(days=170), TODAY - timedelta(days=130),
                           TODAY - timedelta(days=100), TODAY - timedelta(days=30))

        print("\n14. HIV-1 EID Round 2026-B (samples shipped)")
        e2 = await make_cycle(c, "HIV-1 EID Round Two 2026", "EID-2026-B",
                              TODAY - timedelta(days=18), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=3), TODAY + timedelta(days=85),
                              scheme_id=3)
        if e2:
            await advance(c, e2, assist.PT_CYCLE_STARTED, "EID-2026-B")
            await enrol(c, e2, 3, labs, users, active)
            await accept_enrolments(c, e2)
            await advance(c, e2, assist.PT_CYCLE_SAMPLES_SHIPPED, "EID-2026-B")
            await receive_all(c, e2, users, labs, TODAY - timedelta(days=2))
            await capture_eid_results(c, e2, users, labs,
                                      TODAY - timedelta(days=2),
                                      TODAY - timedelta(days=1),
                                      submit=True, approve=False,
                                      leave_last_draft=True)
            await backdate(e2, TODAY - timedelta(days=18), TODAY - timedelta(days=7),
                           TODAY - timedelta(days=3), TODAY + timedelta(days=85))

        print("\n12. HIV-1 VL Round 2027-A (open for enrolment)")
        v3 = await make_cycle(c, "HIV-1 VL Round One 2027", "VL-2027-A",
                              TODAY + timedelta(days=110), TODAY + timedelta(days=70),
                              TODAY + timedelta(days=130), TODAY + timedelta(days=190),
                              scheme_id=2)
        if v3:
            await advance(c, v3, assist.PT_CYCLE_STARTED, "VL-2027-A")
            note("labs enrolled in the viral load scheme can enrol from My Enrolments")

        # ---- the NHRTI bacteriology surveys ------------------------------
        # two surveys a year, per the calendar in TF-NHRTI-BACT-002
        print("\n15. Bacteriology Survey 01-2026 (completed)")
        b1 = await make_cycle(c, "Bacteriology Survey One 2026", "BACT-01-2026",
                              TODAY + timedelta(days=10), TODAY + timedelta(days=40),
                              TODAY + timedelta(days=50), TODAY + timedelta(days=90),
                              scheme_id=4)
        if b1:
            await advance(c, b1, assist.PT_CYCLE_STARTED, "BACT-01-2026")
            await enrol(c, b1, 4, labs, users, active)
            await accept_enrolments(c, b1)
            await advance(c, b1, assist.PT_CYCLE_SAMPLES_SHIPPED, "BACT-01-2026")
            await receive_all(c, b1, users, labs, TODAY - timedelta(days=90))
            await capture_bacteriology_results(
                c, b1, users, labs,
                TODAY - timedelta(days=90), TODAY - timedelta(days=80),
                submit=True, approve=True)
            await advance(c, b1, assist.PT_CYCLE_REPORT_AVAILABLE, "BACT-01-2026")
            await backdate(b1, TODAY - timedelta(days=160), TODAY - timedelta(days=120),
                           TODAY - timedelta(days=95), TODAY - timedelta(days=30))

        print("\n16. Bacteriology Survey 02-2026 (samples shipped)")
        b2 = await make_cycle(c, "Bacteriology Survey Two 2026", "BACT-02-2026",
                              TODAY - timedelta(days=25), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=6), TODAY + timedelta(days=80),
                              scheme_id=4)
        if b2:
            await advance(c, b2, assist.PT_CYCLE_STARTED, "BACT-02-2026")
            await enrol(c, b2, 4, labs, users, active)
            await accept_enrolments(c, b2)
            await advance(c, b2, assist.PT_CYCLE_SAMPLES_SHIPPED, "BACT-02-2026")
            await receive_all(c, b2, users, labs, TODAY - timedelta(days=3))
            await capture_bacteriology_results(
                c, b2, users, labs,
                TODAY - timedelta(days=3), TODAY - timedelta(days=1),
                submit=True, approve=False, leave_last_draft=True)
            await backdate(b2, TODAY - timedelta(days=25), TODAY - timedelta(days=9),
                           TODAY - timedelta(days=6), TODAY + timedelta(days=80))



async def summary():
    import asyncpg
    con = await asyncpg.connect("postgresql://postgres:Abc123@localhost:5432/moheqa")
    print("\n" + "=" * 72)
    print("DEMO DATA SUMMARY")
    print("=" * 72)

    print("\nProvider staff (password: %s)" % DEMO_PASSWORD)
    for r in await con.fetch("""select u.email, r.name role from users u
                                join roles r on r.id=u.role_id
                                where u.role_id = ANY($1::int[]) order by u.id""",
                             list(assist.ADMIN_ROLES)):
        print(f"   {r['email']:42} {r['role']}")

    print("\nLaboratory accounts (password: %s)" % DEMO_PASSWORD)
    for r in await con.fetch("""select u.email, l.code, l.name from users u
                                join laboratorys l on l.id=u.laboratory_id
                                order by l.id"""):
        print(f"   {r['email']:42} {r['code']}  {r['name']}")

    print("\nLaboratory registrations")
    for r in await con.fetch("""select l.code, l.name, s.status_name from laboratorys l
                                join list_statuses s on s.id=l.status_id order by l.id"""):
        print(f"   {r['code']}  {r['name'][:46]:46} {r['status_name']}")

    print("\nEvaluation - grades awarded")
    for r in await con.fetch("""select sc.name scheme, e.grade, count(*) c
                                from pt_result_evaluations e
                                join schemes sc on sc.id = e.scheme_id
                                group by 1,2 order by 1,2"""):
        print(f"   {r['scheme'][:34]:34} {r['grade']:15} {r['c']}")

    print("\nEvaluation - participant standing")
    for r in await con.fetch("""select c.code, l.code lab_code, l.name lab, m.name method,
                                       pf.total_score, pf.max_score,
                                       round((pf.percent_score*100)::numeric,0) pct,
                                       pf.overall_performance
                                from pt_enrollment_performance pf
                                join pt_cycles c on c.id = pf.pt_cycle_id
                                join laboratorys l on l.id = pf.lab_id
                                join methods m on m.id = pf.method_id
                                order by c.code, l.code, m.name"""):
        print(f"   {r['code']:11} {r['lab_code']:8} {r['lab'][:30]:30} "
              f"{r['method'][:16]:16} {r['total_score']:3}/{r['max_score']:<3} "
              f"{str(r['pct'] or '-'):>4}%  {r['overall_performance']}")

    print("\nEvaluation - viral load sample statistics")
    for r in await con.fetch("""select c.code, ms.name sample, m.name method,
                                       st.reported_count, st.group_mean,
                                       st.group_median, st.robust_sd,
                                       st.assigned_value_numeric, st.assigned_value_source,
                                       st.evaluated, st.not_evaluated_reason
                                from pt_sample_statistics st
                                join pt_cycles c on c.id = st.pt_cycle_id
                                join method_samples ms on ms.id = st.method_sample_id
                                join methods m on m.id = st.method_id
                                where st.evaluation_kind = 'quantitative'
                                order by c.code, m.name, ms.name"""):
        if r["evaluated"]:
            print(f"   {r['code']:11} {r['method'][:16]:16} {r['sample']:12} "
                  f"n={r['reported_count']}  mean={r['group_mean']:6}  "
                  f"median={r['group_median']:6}  nIQR={r['robust_sd']:6}  "
                  f"assigned={r['assigned_value_numeric']} ({r['assigned_value_source']})")
        else:
            print(f"   {r['code']:11} {r['method'][:16]:16} {r['sample']:12} "
                  f"n={r['reported_count']}  not evaluated: {r['not_evaluated_reason'][:48]}")

    print("\nPT cycles")
    for r in await con.fetch("""select c.code, sc.name scheme, c.name, p.name status, c.closing_date,
                                (select count(*) from enrollments e where e.pt_cycle_id=c.id) enr,
                                (select count(*) from tb_xpert_ultra_results t where t.pt_cycle_id=c.id)
                                + (select count(*) from tb_xpert_xdr_results x where x.pt_cycle_id=c.id)
                                + (select count(*) from hiv_vl_results v where v.pt_cycle_id=c.id)
                                + (select count(*) from hiv_eid_results d where d.pt_cycle_id=c.id)
                                + (select count(*) from bacteriology_results b where b.pt_cycle_id=c.id) res
                                from pt_cycles c
                                join pt_cycle_statuses p on p.id=c.pt_cyle_status_id
                                join schemes sc on sc.id=c.scheme_id
                                order by c.id"""):
        print(f"   {r['code']:11} {r['scheme'][:34]:34} {r['status']:17} "
              f"closes {r['closing_date']}  {r['enr']} enr  {r['res']} results")

    print("\nNoticeboard")
    for r in await con.fetch("""select a.category, s.status_name,
                                       count(*) c,
                                       count(*) filter (
                                           where a.status_id = 4
                                             and (a.publish_from is null
                                                  or a.publish_from <= current_date)
                                             and (a.publish_until is null
                                                  or a.publish_until >= current_date)
                                       ) live
                                from announcements a
                                join list_statuses s on s.id = a.status_id
                                group by 1,2 order by 1,2"""):
        print(f"   {r['category']:10} {r['status_name']:12} {r['c']} "
              f"({r['live']} on the board today)")

    print("\nRow counts")
    for t in ("providers", "schemes", "services", "methods", "method_samples",
              "laboratorys", "applications", "pt_cycles", "enrollments",
              "tb_xpert_ultra_results", "tb_xpert_xdr_results",
              "hiv_vl_results", "hiv_eid_results", "bacteriology_results",
              "bacteriology_ast_results", "announcements",
              "pt_sample_statistics",
              "pt_result_evaluations", "pt_enrollment_performance", "users"):
        n = await con.fetchval(f"select count(*) from {t}")
        print(f"   {t:26} {n}")

    for label, table in (("Ultra", "tb_xpert_ultra_results"),
                         ("XDR", "tb_xpert_xdr_results"),
                         ("EID", "hiv_eid_results"),
                         ("Bacteriology", "bacteriology_results")):
        print(f"\n{label} results by status")
        for r in await con.fetch(f"""select s.status_name, count(*) c
                                     from {table} t
                                     join list_statuses s on s.id=t.status_id
                                     group by 1 order by 1"""):
            print(f"   {r['status_name']:16} {r['c']}")

        if table == "hiv_eid_results":
            outcome = "coalesce(hiv_result, not_tested_reason, '(not captured)')"
        elif table == "bacteriology_results":
            outcome = ("coalesce(organism_identified, testing_not_done_reason, "
                       "'(not captured)')")
        else:
            outcome = ("coalesce(tb_detection_result, uninterpretable_result, "
                       "'(not captured)')")

        print(f"{label} results by outcome")
        for r in await con.fetch(f"""select {outcome} v, count(*) c
                                     from {table} group by 1 order by 2 desc"""):
            print(f"   {str(r['v'])[:30]:30} {r['c']}")

    print("\nHIV-1 VL results by status")
    for r in await con.fetch("""select s.status_name, count(*) c
                                from hiv_vl_results t
                                join list_statuses s on s.id=t.status_id
                                group by 1 order by 1"""):
        print(f"   {r['status_name']:16} {r['c']}")

    print("HIV-1 VL results by outcome")
    for r in await con.fetch("""select case
                                  when result_reported = 'No' then 'Not tested'
                                  when viral_load_log10 = 0 then 'Undetectable'
                                  when viral_load_log10 < 3 then 'Low (<3 log10)'
                                  when viral_load_log10 < 5 then 'Mid (3-5 log10)'
                                  when viral_load_log10 is not null then 'High (>5 log10)'
                                  else '(not captured)' end v, count(*) c
                                from hiv_vl_results group by 1 order by 2 desc"""):
        print(f"   {r['v']:18} {r['c']}")

    print("\nXDR drug resistance patterns")
    for r in await con.fetch("""select inh_result, flq_result, amk_result, eth_result,
                                count(*) c from tb_xpert_xdr_results
                                where inh_result is not null
                                group by 1,2,3,4 order by 5 desc"""):
        print(f"   INH {r['inh_result']:13} FLQ {r['flq_result']:13} "
              f"AMK {r['amk_result']:13} ETH {r['eth_result']:13} {r['c']}")

    await con.close()


# --------------------------------------------------------------------------
# 17. the noticeboard
# --------------------------------------------------------------------------
# What the provider tells its participants. Written through the API like
# everything else, so a seeded notice is one the running system would accept.
#
# scheme ids: 1 TB, 2 HIV-1 VL, 3 HIV EID, 4 Bacteriology
NOTICES = [
    # name, category, audience, scheme_id, pinned, body, extras, how it ends up
    dict(
        name="Annual EQA Participants Training Day",
        category="Event", audience="All Participants", pinned=True,
        description="One day, all schemes, Ndola. Registration closes two weeks before.",
        body="The annual training day covers result capture on the new platform, "
             "reading your performance report, and corrective action for "
             "unsatisfactory results. One place per participating laboratory is "
             "funded; further places are at the laboratory's own cost.",
        event_at=TODAY + timedelta(days=45),
        event_ends_at=TODAY + timedelta(days=45),
        location="Ndola Teaching Hospital, 7th Floor Conference Room",
        publish=True,
    ),
    dict(
        name="EQA System Development Meeting",
        category="Meeting", audience="All Participants",
        description="Quarterly review of the platform with participating laboratories.",
        body="Agenda: progress on the result forms now live, the bacteriology "
             "scheme's first survey, and what participants want next. Laboratories "
             "unable to attend in person may join on the link below.",
        event_at=TODAY + timedelta(days=12),
        location="Hybrid - NHRTI Ndola and Teams",
        publish=True,
    ),
    dict(
        name="Bacteriology Scheme Protocol TP-NHRTI-BACT-001",
        category="Resource", audience="Scheme", scheme_id=4,
        description="The scheme protocol, including the complaints and appeals procedures.",
        body="Every laboratory enrolled in the bacteriology scheme should hold a "
             "current copy of the scheme protocol. It sets out the panel, the "
             "reporting format, how results are scored, and how to appeal an "
             "evaluation. Section 17 covers the scoring criteria and the "
             "acceptable performance score.",
        link_url="https://nhrti.moh.gov.zm/eqa/bacteriology/TP-NHRTI-BACT-001.pdf",
        publish=True,
    ),
    dict(
        name="Bacteriology Participant Instructions and Worksheet",
        category="Resource", audience="Scheme", scheme_id=4,
        description="TF-NHRTI-BACT-003 and the worksheet TF-NHRTI-BACT-001.",
        body="Sample condition must be documented on the worksheet on receipt of "
             "the PT panel. Swabs are to be stored at room temperature for five "
             "minutes before inoculating directly onto the applicable media. "
             "Process the PT samples exactly as you would routine samples.",
        link_url="https://nhrti.moh.gov.zm/eqa/bacteriology/TF-NHRTI-BACT-003.pdf",
        publish=True,
    ),
    dict(
        name="Xpert Module Verification Reminder",
        category="General", audience="Scheme", scheme_id=1,
        description="Record the module number on every Xpert result you report.",
        body="Several results in the last round were submitted without a module "
             "number. The module is needed to investigate an unacceptable result, "
             "so a result reported without one cannot be followed up. Please "
             "check the field before submitting.",
        publish=True,
    ),
    dict(
        name="Courier Delay Affecting Northern and Muchinga Shipments",
        category="General", audience="All Participants",
        description="Panels dispatched last week are running about four days late.",
        body="The courier has advised of a delay on the northern route. "
             "Laboratories affected should record the actual date of receipt on "
             "their worksheets as usual; the trial closing date will be extended "
             "where the delay materially reduces testing time. Contact the scheme "
             "coordinator if your panel arrives in an unsuitable condition.",
        publish_until=TODAY + timedelta(days=20),
        publish=True,
    ),
    dict(
        name="Viral Load Round VL-2027-A Opens for Enrolment",
        category="General", audience="Scheme", scheme_id=2,
        description="Enrol from My Enrolments before the closing date.",
        body="Enrolment for the first viral load round of 2027 is now open. "
             "Laboratories running more than one platform should enrol each "
             "platform separately, as each receives its own panel.",
        publish_from=TODAY + timedelta(days=30),
        publish=True,
    ),
    dict(
        name="Draft - Scheme Fee Schedule 2027",
        category="General", audience="All Participants",
        description="Not for circulation until finance has signed it off.",
        body="The 2027 fee schedule is being finalised and will be circulated "
             "once approved.",
        publish=False,
    ),
    dict(
        name="Withdrawal of Survey BACT-01-2026 Feedback Report",
        category="General", audience="Scheme", scheme_id=4,
        description="An earlier version of the report was issued in error.",
        body="The feedback report circulated for survey BACT-01-2026 contained an "
             "error in the AST evaluation table. A corrected report has been "
             "issued. Please discard the earlier version.",
        publish_until=TODAY - timedelta(days=5),
        publish=True,
    ),
    dict(
        # this one wants a second pair of eyes before it goes out
        name="Change to the Acceptable Performance Score",
        category="General", audience="All Participants",
        description="Reviewed by a second officer before circulation.",
        body="Participants are reminded that the acceptable performance score for "
             "the bacteriology scheme is 100%. Laboratories scoring below this "
             "should initiate corrective action in line with their own quality "
             "management procedures and retain the PT samples until the "
             "performance report is received.",
        approval_levels=2,
        publish=True,
    ),
]


async def noticeboard():
    transport = ASGITransport(app=main.app)
    async with AsyncClient(transport=transport, base_url="http://seed", timeout=60) as c:
        # The coordinator writes the board. Where a notice asks to be
        # reviewed, the reviewers are taken in turn from here: a reviewer may
        # not review what they wrote, nor review their own earlier decision, so
        # two levels of approval genuinely needs two other people.
        author = await _user_id("nkoleevans@hotmail.com")
        reviewers = [
            GRADER_ID,
            await _user_id("head@cdl.moh.gov.zm"),
        ]

        published = drafted = reviewed = 0

        for notice in NOTICES:
            wants_publishing = notice.get("publish", False)
            levels = notice.get("approval_levels", 1)

            body = dict(
                name=notice["name"],
                description=notice.get("description"),
                body=notice.get("body"),
                category=notice["category"],
                audience=notice["audience"],
                scheme_id=notice.get("scheme_id"),
                pinned=notice.get("pinned", False),
                publish_from=_day(notice.get("publish_from")),
                publish_until=_day(notice.get("publish_until")),
                event_at=_moment(notice.get("event_at")),
                event_ends_at=_moment(notice.get("event_ends_at")),
                location=notice.get("location"),
                link_url=notice.get("link_url"),
                user_id=author,
                status_id=assist.STATUS_DRAFT,
                stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
                approval_levels=levels,
            )

            r = await c.post("/announcements/create", json=body)
            if r.status_code != 200:
                fail(f"announcement '{notice['name']}'", r)
                continue

            announcement_id = r.json()["id"]

            if not wants_publishing:
                drafted += 1
                continue

            if levels == 1:
                r = await c.put(f"/announcements/publish/{announcement_id}",
                                json={"user_id": author, "comments": None})
                if r.status_code != 200:
                    fail(f"publish '{notice['name']}'", r)
                    continue
                published += 1
            else:
                # the gated path: submitted by its author, then approved once
                # per level by someone else
                r = await c.put(f"/announcements/submit/{announcement_id}",
                                json={"user_id": author, "comments": None})
                if r.status_code != 200:
                    fail(f"submit '{notice['name']}'", r)
                    continue

                approved = False
                for reviewer in reviewers[:levels]:
                    r = await c.put(
                        f"/announcements/review-update/{announcement_id}",
                        json={"user_id": reviewer,
                              "review_action": assist.REVIEW_ACTION_APPROVE,
                              "comments": "Wording agreed with the scheme head",
                              "content": None, "attachment_id": None})
                    if r.status_code != 200:
                        fail(f"review '{notice['name']}'", r)
                        break
                    approved = r.json()["status_id"] == assist.STATUS_APPROVED

                if not approved:
                    fail(f"review '{notice['name']}' did not publish it",
                         type("R", (), {"status_code": 0,
                                        "text": f"{levels} level(s) of approval"})())
                    continue

                published += 1
                reviewed += 1

        note(f"{published} notice(s) published ({reviewed} through review), "
             f"{drafted} left as draft")

        r = await c.get("/announcements/feed")
        note(f"the board for everyone shows {len(r.json())} notice(s)")

    print("17. noticeboard ready")


async def _user_id(email):
    from sqlalchemy.future import select
    from models.user_model import UserDB
    async with database.AsyncSessionLocal() as db:
        user = (await db.execute(
            select(UserDB).where(UserDB.email == email))).scalars().first()
        return user.id


def _day(value):
    return value.isoformat() if value else None


def _moment(value):
    """A seeded event sits mid morning, so it reads as a real appointment.

    The offset is written out rather than left implicit: a bare 09:30 is only
    half past nine to a database whose session timezone happens to agree, and
    a meeting invitation that moves with the server's settings is worse than
    no invitation at all.
    """
    if not value:
        return None
    return datetime(
        value.year, value.month, value.day, 9, 30,
        tzinfo=ZoneInfo(assist.CURRENT_TIME_ZONE),
    ).isoformat()


async def main_(clear_only=False):
    # the clean slate every run starts from: transactional data wiped, the
    # catalogue and provider staff rebuilt
    await reset()
    await staff()
    await catalogue()

    if clear_only:
        # stop here - an empty transactional layer on top of the catalogue and
        # staff, ready for manual end-to-end testing from scratch
        if FAILURES:
            print("\n" + "!" * 72)
            print(f"{len(FAILURES)} step(s) failed:")
            for f in FAILURES:
                print("  -", f)
            return 1
        print("\nDemo data cleared. Catalogue and provider staff kept; no demo "
              "labs, cycles or results seeded.")
        return 0

    await resolve_grader()
    await workflow()
    await noticeboard()
    await summary()

    if FAILURES:
        print("\n" + "!" * 72)
        print(f"{len(FAILURES)} step(s) failed:")
        for f in FAILURES:
            print("  -", f)
        return 1
    print("\nAll seeding steps succeeded.")
    return 0


# `--clear` (or `--clear-only`) wipes the demo data without reseeding it;
# with no argument the full demo dataset is rebuilt.
_CLEAR_ONLY = any(a in ("--clear", "--clear-only") for a in sys.argv[1:])
sys.exit(asyncio.run(main_(clear_only=_CLEAR_ONLY)))
