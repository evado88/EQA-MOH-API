"""Populates the moheqa development database with a coherent demo dataset.

The catalogue (provider -> scheme -> service -> method -> sample) is written
directly. Everything that has a workflow attached - registration, application
review, cycle status, enrolment, shipping, result capture - is driven through
the API, so the demo data is by construction exactly what the running system
produces.
"""
import asyncio
import sys
from datetime import date, timedelta

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

import database

DEV_URL = "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"
database.engine = create_async_engine(DEV_URL, echo=False)
database.AsyncSessionLocal = sessionmaker(
    bind=database.engine, class_=AsyncSession, expire_on_commit=False
)

import main  # noqa: E402  (must come after the engine swap)
from helpers import assist  # noqa: E402
from httpx import ASGITransport, AsyncClient  # noqa: E402

DEMO_PASSWORD = "12345678"
TODAY = date(2026, 9, 14)

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
                      "hiv_eid_results", "enrollments", "applications",
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
        # the dictionaries must match the constants the code reasons with
        for i, name in enumerate(["Upcoming", "Started", "Samples Shipped",
                                  "Report Available", "Closed"], 1):
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
]


async def register_labs(c):
    """Every lab registers itself through the public signup endpoint."""
    labs = {}
    for name, contact, email, lab_type, prov, dist, methods in LABS:
        r = await c.post("/auth/signup", json=dict(
            name=name, contact_person_name=contact, lab_type_id=lab_type,
            position="Laboratory In-charge", phone_number="+26097" + str(abs(hash(email)) % 10000000).zfill(7),
            province_id=prov, district_id=dist, email_address=email,
            physical_address=f"{name}, Zambia",
            method_list=[{"id": m} for m in methods]))
        if r.status_code != 200:
            fail(f"signup {name}", r)
            continue
        body = r.json()
        labs[email] = dict(id=body["laboratory_id"], code=body["code"], name=name)
        note(f"{body['code']}  {name}  ({body['application_count']} application(s))")
    print(f"4. {len(labs)} laboratories registered")
    return labs


async def approve_labs(c, labs):
    """The provider reviews each registration. One is left pending, one rejected."""
    pending = "brian.kunda@solwezi.health.zm"
    rejected = "naomi.sakala@livingstone.health.zm"
    users = {}

    import jose.jwt as jwt
    for email, lab in labs.items():
        if email == pending:
            note(f"{lab['name']}: left awaiting review")
            continue

        action = (assist.REVIEW_ACTION_REJECT if email == rejected
                  else assist.REVIEW_ACTION_APPROVE)
        r = await c.put(f"/laboratorys/review-update/{lab['id']}", json={
            "user_id": 1, "review_action": action,
            "comments": ("Documentation incomplete - please reapply"
                         if action == assist.REVIEW_ACTION_REJECT
                         else "Registration verified against the CDL register"),
            "content": None, "attachment_id": None})
        if r.status_code != 200:
            fail(f"review {lab['name']}", r)
            continue

        if action == assist.REVIEW_ACTION_REJECT:
            note(f"{lab['name']}: REJECTED")
            continue

        lr = await c.post("/auth/login", data={"username": email, "password": DEMO_PASSWORD})
        if lr.status_code != 200:
            fail(f"login {email}", lr)
            continue
        claims = jwt.decode(lr.json()["access_token"], assist.SECRET_KEY,
                            algorithms=[assist.ALGORITHM])
        users[email] = claims["userid"]
        note(f"{lab['name']}: approved, account {email} active")

    print(f"5. {len(users)} laboratories approved and able to sign in")
    return users


async def make_cycle(c, name, code, effective, closing, shipping, reports,
                     scheme_id=1):
    r = await c.post("/pt-cycles/create", json=dict(
        name=name, code=code, description=f"{name} proficiency testing round",
        scheme_id=scheme_id, effective_date=effective.isoformat(),
        pt_cyle_status_id=assist.PT_CYCLE_UPCOMING,
        closing_date=closing.isoformat(), shipping_date=shipping.isoformat(),
        reports_availability_date=reports.isoformat(),
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
    r = await c.put(f"/pt-cycles/status/{cycle_id}",
                    json={"pt_cyle_status_id": status_id, "user_id": 1})
    if r.status_code != 200:
        fail(f"{label} -> {assist.PT_CYCLE_STATUS_NAMES[status_id]}", r)
        return False
    note(f"{label}: {r.json()['message']}")
    return True


async def enrol(c, cycle_id, labs, users, emails):
    """Offers the cycle to each lab; the server decides who is eligible.

    A lab with no approved method for the cycle's scheme is turned away, which
    is the rule working rather than a seeding error - a TB-only lab has no
    business in a viral load round.
    """
    enrolled = skipped = 0
    for email in emails:
        if email not in users:
            continue
        r = await c.post("/enrollments/apply", json={
            "pt_cycle_id": cycle_id, "lab_id": labs[email]["id"],
            "user_id": users[email]})

        if r.status_code == 400 and "no approved methods for this scheme" in r.text:
            skipped += 1
            continue

        if r.status_code != 200:
            fail(f"enrol {labs[email]['name']}", r)
            continue

        enrolled += 1
        note(f"{labs[email]['name']} enrolled for {r.json()['enrollment_count']} method(s)")

    if skipped:
        note(f"{skipped} lab(s) not eligible for this scheme")
    return enrolled


async def accept_enrolments(c, cycle_id, skip_email=None, labs=None):
    r = await c.get(f"/enrollments/list/cycle/{cycle_id}")
    accepted = []
    for e in r.json():
        if skip_email and labs and e["lab_id"] == labs[skip_email]["id"]:
            note(f"{e['laboratory']['name']}: enrolment left pending")
            continue
        rr = await c.put(f"/enrollments/review-update/{e['id']}", json={
            "user_id": 1, "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "Enrolment accepted", "content": None, "attachment_id": None})
        if rr.status_code != 200:
            fail(f"accept enrolment {e['id']}", rr)
            continue
        accepted.append(e)
    note(f"{len(accepted)} enrolment(s) accepted")
    return accepted


async def receive_all(c, cycle_id, users, labs, when):
    r = await c.get(f"/enrollments/list/cycle/{cycle_id}")
    email_by_lab = {v["id"]: k for k, v in labs.items()}
    done = 0
    for e in r.json():
        if e["status"]["status_name"] != "Approved":
            continue
        email = email_by_lab.get(e["lab_id"])
        if email not in users:
            continue
        rr = await c.put(f"/enrollments/receive-samples/{e['id']}", json={
            "user_id": users[email],
            "samples_received_at": when.isoformat() + "T09:00:00"})
        if rr.status_code != 200:
            fail(f"receive {e['id']}", rr)
            continue
        done += 1
    note(f"{done} panel(s) marked received")


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
    email_by_lab = {v["id"]: k for k, v in labs.items()}

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
                user_id=users[email],
                date_panel_received=received_on.isoformat(),
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
                tested_by=labs[email]["name"].split()[0] + " Technologist",
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
    email_by_lab = {v["id"]: k for k, v in labs.items()}

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
                user_id=users[email],
                date_panel_received=received_on.isoformat(),
                date_tested=tested_on.isoformat() if tested else None,
                detection_assay=detection if tested else None,
                extraction_assay=extraction if tested else None,
                assay_kit_lot_number=f"LOT-{2600 + lab_id}" if tested else None,
                assay_kit_expiry_date="2027-06-30" if tested else None,
                assay_serial_number=f"SN-{9000 + lab_id}" if tested else None,
                tested_by=labs[email]["name"].split()[0] + " Technologist",
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
    email_by_lab = {v["id"]: k for k, v in labs.items()}

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
                user_id=users[email],
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
    email_by_lab = {v["id"]: k for k, v in labs.items()}

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
                user_id=users[email],
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


async def backdate(cycle_id, effective, closing, shipping, reports):
    """Pulls a finished cycle's dates into the past so it reads as historical."""
    async with database.AsyncSessionLocal() as db:
        await db.execute(text(
            "UPDATE pt_cycles SET effective_date=:e, closing_date=:c, "
            "shipping_date=:s, reports_availability_date=:r WHERE id=:id"),
            {"e": effective, "c": closing, "s": shipping, "r": reports, "id": cycle_id})
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
        labs = await register_labs(c)
        users = await approve_labs(c, labs)

        active = [e for e in users]

        # ---- a completed round, so there is history to look at ----------
        print("\n6. Round 2026-A (completed)")
        c1 = await make_cycle(c, "DTS Round One 2026", "2026-A",
                              TODAY + timedelta(days=10), TODAY + timedelta(days=40),
                              TODAY + timedelta(days=50), TODAY + timedelta(days=90))
        if c1:
            await advance(c, c1, assist.PT_CYCLE_STARTED, "2026-A")
            await enrol(c, c1, labs, users, active)
            await accept_enrolments(c, c1)
            await advance(c, c1, assist.PT_CYCLE_SAMPLES_SHIPPED, "2026-A")
            await receive_all(c, c1, users, labs, TODAY - timedelta(days=120))
            await capture_results(c, c1, users, labs, TODAY - timedelta(days=110),
                                  submit=True, approve=True)
            await capture_xdr_results(c, c1, users, labs, TODAY - timedelta(days=110),
                                      submit=True, approve=True)
            await advance(c, c1, assist.PT_CYCLE_REPORT_AVAILABLE, "2026-A")
            await advance(c, c1, assist.PT_CYCLE_CLOSED, "2026-A")
            await backdate(c1, TODAY - timedelta(days=200), TODAY - timedelta(days=160),
                           TODAY - timedelta(days=130), TODAY - timedelta(days=60))

        # ---- the round in flight, where labs are capturing now ----------
        print("\n7. Round 2026-B (samples shipped, results being captured)")
        c2 = await make_cycle(c, "DTS Round Two 2026", "2026-B",
                              TODAY - timedelta(days=30), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=5), TODAY + timedelta(days=75))
        if c2:
            await advance(c, c2, assist.PT_CYCLE_STARTED, "2026-B")
            await enrol(c, c2, labs, users, active)
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
            await enrol(c, c3, labs, users,
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
            await enrol(c, v1, labs, users, active)
            await accept_enrolments(c, v1)
            await advance(c, v1, assist.PT_CYCLE_SAMPLES_SHIPPED, "VL-2026-A")
            await receive_all(c, v1, users, labs, TODAY - timedelta(days=100))
            await capture_vl_results(c, v1, users, labs,
                                     TODAY - timedelta(days=100),
                                     TODAY - timedelta(days=95),
                                     submit=True, approve=True)
            await advance(c, v1, assist.PT_CYCLE_REPORT_AVAILABLE, "VL-2026-A")
            await advance(c, v1, assist.PT_CYCLE_CLOSED, "VL-2026-A")
            await backdate(v1, TODAY - timedelta(days=180), TODAY - timedelta(days=140),
                           TODAY - timedelta(days=110), TODAY - timedelta(days=40))

        print("\n11. HIV-1 VL Round 2026-B (samples shipped)")
        v2 = await make_cycle(c, "HIV-1 VL Round Two 2026", "VL-2026-B",
                              TODAY - timedelta(days=20), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=4), TODAY + timedelta(days=80),
                              scheme_id=2)
        if v2:
            await advance(c, v2, assist.PT_CYCLE_STARTED, "VL-2026-B")
            await enrol(c, v2, labs, users, active)
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
            await enrol(c, e1, labs, users, active)
            await accept_enrolments(c, e1)
            await advance(c, e1, assist.PT_CYCLE_SAMPLES_SHIPPED, "EID-2026-A")
            await receive_all(c, e1, users, labs, TODAY - timedelta(days=90))
            await capture_eid_results(c, e1, users, labs,
                                      TODAY - timedelta(days=90),
                                      TODAY - timedelta(days=86),
                                      submit=True, approve=True)
            await advance(c, e1, assist.PT_CYCLE_REPORT_AVAILABLE, "EID-2026-A")
            await advance(c, e1, assist.PT_CYCLE_CLOSED, "EID-2026-A")
            await backdate(e1, TODAY - timedelta(days=170), TODAY - timedelta(days=130),
                           TODAY - timedelta(days=100), TODAY - timedelta(days=30))

        print("\n14. HIV-1 EID Round 2026-B (samples shipped)")
        e2 = await make_cycle(c, "HIV-1 EID Round Two 2026", "EID-2026-B",
                              TODAY - timedelta(days=18), TODAY + timedelta(days=30),
                              TODAY - timedelta(days=3), TODAY + timedelta(days=85),
                              scheme_id=3)
        if e2:
            await advance(c, e2, assist.PT_CYCLE_STARTED, "EID-2026-B")
            await enrol(c, e2, labs, users, active)
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
                                + (select count(*) from hiv_eid_results d where d.pt_cycle_id=c.id) res
                                from pt_cycles c
                                join pt_cycle_statuses p on p.id=c.pt_cyle_status_id
                                join schemes sc on sc.id=c.scheme_id
                                order by c.id"""):
        print(f"   {r['code']:11} {r['scheme'][:34]:34} {r['status']:17} "
              f"closes {r['closing_date']}  {r['enr']} enr  {r['res']} results")

    print("\nRow counts")
    for t in ("providers", "schemes", "services", "methods", "method_samples",
              "laboratorys", "applications", "pt_cycles", "enrollments",
              "tb_xpert_ultra_results", "tb_xpert_xdr_results",
              "hiv_vl_results", "hiv_eid_results", "pt_sample_statistics",
              "pt_result_evaluations", "pt_enrollment_performance", "users"):
        n = await con.fetchval(f"select count(*) from {t}")
        print(f"   {t:26} {n}")

    for label, table in (("Ultra", "tb_xpert_ultra_results"),
                         ("XDR", "tb_xpert_xdr_results"),
                         ("EID", "hiv_eid_results")):
        print(f"\n{label} results by status")
        for r in await con.fetch(f"""select s.status_name, count(*) c
                                     from {table} t
                                     join list_statuses s on s.id=t.status_id
                                     group by 1 order by 1"""):
            print(f"   {r['status_name']:16} {r['c']}")

        outcome = ("coalesce(hiv_result, not_tested_reason, '(not captured)')"
                   if table == "hiv_eid_results"
                   else "coalesce(tb_detection_result, uninterpretable_result, "
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


async def main_():
    await reset()
    await staff()
    await catalogue()
    await resolve_grader()
    await workflow()
    await summary()

    if FAILURES:
        print("\n" + "!" * 72)
        print(f"{len(FAILURES)} step(s) failed:")
        for f in FAILURES:
            print("  -", f)
        return 1
    print("\nAll seeding steps succeeded.")
    return 0


sys.exit(asyncio.run(main_()))
