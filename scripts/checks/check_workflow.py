"""The full participation workflow, end to end.

Builds its own throwaway database, walks signup -> approval -> cycle ->
enrolment -> shipping -> receipt -> capture -> close-out, then drops it. The
development database is never touched.

Run directly:  venv\Scripts\python.exe scripts\checks\check_workflow.py
"""
import asyncio
import sys

import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import (
    create_test_database, drop_test_database, use_test_database,
)

# the app has to be pointed at the throwaway database before main is imported,
# because the routes bind to the session factory at import time
use_test_database()

import database  # noqa: E402
from sqlalchemy import text  # noqa: E402

import main  # noqa: E402
from helpers import assist
from httpx import ASGITransport, AsyncClient

OK, FAIL = [], []


def check(label, cond, detail=""):
    (OK if cond else FAIL).append(label)
    print(("  PASS  " if cond else "  FAIL  ") + label + (f"   <- {detail}" if detail and not cond else ""))


async def seed():
    from models.status_model import StatusDB
    from models.stage_model import StageDB
    from models.role_model import RoleDB
    from models.labtype_model import LabTypeDB
    from models.province_model import ProvinceDB
    from models.district_model import DistrictDB
    from models.ptcyclestatus_model import PTCycleStatusDB
    from models.user_model import UserDB
    from models.provider_model import ProviderDB
    from models.scheme_model import SchemeDB
    from models.service_model import ServiceDB
    from models.method_model import MethodDB
    from models.methodsample_model import MethodSampleDB

    async with database.engine.begin() as conn:
        await conn.run_sync(database.Base.metadata.create_all)

    APPROVED = dict(status_id=4, stage_id=5, approval_levels=1)
    async with database.AsyncSessionLocal() as db:
        for i, n in enumerate(["Draft", "Submitted", "Under Review", "Approved", "Rejected"], 1):
            db.add(StatusDB(id=i, status_name=n))
        for i, n in enumerate(["Awaiting Submission", "Submitted", "Primary Approval",
                               "Secondary Approval", "Approved"], 1):
            db.add(StageDB(id=i, stage_name=n))
        await db.commit()

        db.add(UserDB(id=1, fname="Admin", lname="User", email="admin@cdl.zm",
                      mobile_code="+260", mobile="+260970000001",
                      role_id=assist.ROLE_ADMINISTRATOR,
                      password=assist.hash_password("12345678"), **APPROVED))
        db.add(UserDB(id=2, fname="Scheme", lname="Coordinator", email="coord@cdl.zm",
                      mobile_code="+260", mobile="+260970000002",
                      role_id=assist.ROLE_SCHEME_COORDINATOR,
                      password=assist.hash_password("12345678"), **APPROVED))
        await db.commit()

        for i, n in enumerate(["Administrator", "Scheme Head", "Scheme Coordinator",
                               "Scheme Quality Officers", "Finance Officers", "PBs", "FPPs",
                               "District Lab Coordinators", "Facility Super User",
                               "Facility Staff"], 1):
            db.add(RoleDB(id=i, name=n, user_id=1, **APPROVED))
        for i, n in enumerate(["Upcoming", "Started", "Samples Shipped",
                               "Report Available", "Closed"], 1):
            db.add(PTCycleStatusDB(id=i, name=n, user_id=1, **APPROVED))
        db.add(LabTypeDB(id=1, name="Government", user_id=1, **APPROVED))
        db.add(ProvinceDB(id=1, name="Lusaka", code="ZM-09", user_id=1, **APPROVED))
        await db.commit()
        db.add(DistrictDB(id=1, name="Lusaka", province_id=1, user_id=1, **APPROVED))
        db.add(ProviderDB(id=1, name="CDL", user_id=1, **APPROVED))
        await db.commit()
        db.add(SchemeDB(id=1, name="Tuberculosis (TB)", provider_id=1, user_id=1, **APPROVED))
        await db.commit()
        db.add(ServiceDB(id=1, name="TB Xpert", scheme_id=1, user_id=1, **APPROVED))
        await db.commit()
        db.add(MethodDB(id=1, name="Ultra", scheme_id=1, service_id=1, user_id=1,
                        result_form="tb_xpert_ultra", **APPROVED))
        db.add(MethodDB(id=2, name="XDR", scheme_id=1, service_id=1, user_id=1,
                        result_form="tb_xpert_xdr", **APPROVED))
        await db.commit()
        for i in range(1, 6):
            db.add(MethodSampleDB(id=i, name=f"ultra-CDL-2026-A-{i}", scheme_id=1,
                                  service_id=1, method_id=1, user_id=1, **APPROVED))
        for i in range(6, 11):
            db.add(MethodSampleDB(id=i, name=f"xdr-CDL-2026-A-{i - 5}", scheme_id=1,
                                  service_id=1, method_id=2, user_id=1, **APPROVED))
        await db.commit()

        # the seed inserts explicit ids, which leaves the identity sequences
        # behind - move them past what was seeded
        for table in ("users", "roles", "list_statuses", "list_stages", "lab_types",
                      "provinces", "districts", "providers", "schemes", "services",
                      "methods", "method_samples", "pt_cycle_statuses"):
            await db.execute(text(
                f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), "
                f"COALESCE((SELECT MAX(id) FROM {table}), 1))"
            ))
        await db.commit()
    print("seeded\n")


async def run():
    await seed()
    transport = ASGITransport(app=main.app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:

        print("1. SIGNUP -- labs, and only labs, may register")
        body = dict(name="Chilenje Clinic Lab", contact_person_name="Mary Banda",
                    lab_type_id=1, position="Lab In-charge", phone_number="+260970001234",
                    province_id=1, district_id=1, email_address="Mary.Banda@Chilenje.zm",
                    physical_address="Chilenje", method_list=[{"id": 1}, {"id": 2}])
        r = await c.post("/auth/signup", json=body)
        check("signup accepted", r.status_code == 200, r.text[:300])
        signup = r.json()
        lab_id = signup["laboratory_id"]
        check("lab code generated by server", signup["code"] == "REG0001", signup)
        check("one application per selected method", signup["application_count"] == 2, signup)

        r = await c.post("/auth/signup", json=body)
        check("duplicate email rejected", r.status_code == 400, r.text[:200])

        bad = dict(body, email_address="x@y.zm", method_list=[{"id": 999}])
        r = await c.post("/auth/signup", json=bad)
        check("unknown method rejected", r.status_code == 400, r.text[:200])

        no_methods = dict(body, email_address="z@y.zm", method_list=[])
        r = await c.post("/auth/signup", json=no_methods)
        check("signup with no methods rejected", r.status_code == 422, r.text[:200])

        r = await c.post("/auth/login", data={"username": "mary.banda@chilenje.zm",
                                              "password": "12345678"})
        check("cannot sign in before approval", r.status_code in (401, 403), r.text[:200])

        print("\n2. APPLICATIONS -- the admin review queue")
        r = await c.get("/applications/list", params={"pending": True})
        check("pending applications listed", r.status_code == 200 and len(r.json()) == 2, r.text[:200])
        r = await c.get(f"/applications/list/lab/{lab_id}")
        check("applications filtered by lab", r.status_code == 200 and len(r.json()) == 2, r.text[:200])

        print("\n3. APPROVE THE LAB -- creates its account and approves its methods")
        r = await c.put(f"/laboratorys/review-update/{lab_id}",
                        json={"user_id": 1, "review_action": assist.REVIEW_ACTION_APPROVE,
                              "comments": "Looks good", "content": None, "attachment_id": None})
        check("lab approved", r.status_code == 200, r.text[:300])

        r = await c.get("/applications/list", params={"lab_id": lab_id,
                                                      "status_id": assist.STATUS_APPROVED})
        check("applications approved with the lab", r.status_code == 200 and len(r.json()) == 2, r.text[:200])

        r = await c.post("/auth/login", data={"username": "mary.banda@chilenje.zm",
                                              "password": "12345678"})
        check("lab can now sign in", r.status_code == 200, r.text[:200])
        import jose.jwt as jwt
        claims = jwt.decode(r.json()["access_token"], assist.SECRET_KEY,
                            algorithms=[assist.ALGORITHM])
        check("token carries the lab role", claims["role"] == assist.ROLE_FACILITY_SUPER_USER, claims)
        check("token carries the laboratory id", claims["lab"] == lab_id, claims)
        lab_user_id = claims["userid"]

        print("\n4. CYCLE -- admin starts one")
        cyc = dict(name="DTS Round One 2026", code="2026-A", scheme_id=1,
                   effective_date="2027-01-01", pt_cyle_status_id=assist.PT_CYCLE_UPCOMING,
                   closing_date="2027-08-31", shipping_date="2027-06-01",
                   reports_availability_date="2027-10-01", user_id=1,
                   status_id=assist.STATUS_SUBMITTED, stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                   approval_levels=1)
        r = await c.post("/pt-cycles/create", json=cyc)
        check("cycle created", r.status_code == 200, r.text[:300])
        cycle_id = r.json()["id"]

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_STARTED, "user_id": 1})
        check("unapproved cycle cannot be started", r.status_code == 400, r.text[:200])

        r = await c.put(f"/pt-cycles/review-update/{cycle_id}",
                        json={"user_id": 2, "review_action": assist.REVIEW_ACTION_APPROVE,
                              "comments": "ok", "content": None, "attachment_id": None})
        check("cycle approved", r.status_code == 200, r.text[:300])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_REPORT_AVAILABLE, "user_id": 1})
        check("cycle cannot skip a status", r.status_code == 400, r.text[:200])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_STARTED, "user_id": lab_user_id})
        check("a lab user cannot change cycle status", r.status_code == 403, r.text[:200])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_STARTED, "user_id": 1})
        check("cycle started", r.status_code == 200, r.text[:300])

        print("\n5. ENROLMENT -- the lab applies")
        r = await c.get(f"/pt-cycles/open/{lab_id}")
        check("cycle offered to the lab", r.status_code == 200 and len(r.json()) == 1, r.text[:200])

        r = await c.post("/enrollments/apply",
                         json={"pt_cycle_id": cycle_id, "lab_id": lab_id, "user_id": lab_user_id})
        check("lab enrolled", r.status_code == 200, r.text[:300])
        check("one enrolment per approved method", r.json()["enrollment_count"] == 2, r.json())

        r = await c.post("/enrollments/apply",
                         json={"pt_cycle_id": cycle_id, "lab_id": lab_id, "user_id": lab_user_id})
        check("double enrolment rejected", r.status_code == 400, r.text[:200])

        r = await c.get(f"/pt-cycles/open/{lab_id}")
        check("cycle no longer offered once enrolled", r.status_code == 200 and len(r.json()) == 0, r.text[:200])

        r = await c.get(f"/enrollments/list/lab/{lab_id}")
        enrollments = r.json()
        check("enrolments listed for the lab", len(enrollments) == 2, r.text[:200])
        enr_ultra = next(e for e in enrollments if e["method_id"] == 1)

        print("\n6. SHIPPING -- opens the result sheets")
        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_SAMPLES_SHIPPED, "user_id": 1})
        check("shipping blocked while no enrolment is accepted", r.status_code == 400, r.text[:200])

        enr_xdr = next(e for e in enrollments if e["method_id"] == 2)
        for label, enr in (("Ultra", enr_ultra), ("XDR", enr_xdr)):
            r = await c.put(f"/enrollments/review-update/{enr['id']}",
                            json={"user_id": 1, "review_action": assist.REVIEW_ACTION_APPROVE,
                                  "comments": "accepted", "content": None, "attachment_id": None})
            check(f"{label} enrolment accepted", r.status_code == 200, r.text[:300])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_SAMPLES_SHIPPED, "user_id": 1})
        check("samples shipped", r.status_code == 200, r.text[:300])
        check("a sheet per sample across both accepted enrolments",
              r.json()["result_count"] == 10, r.json())

        r = await c.get(f"/tb-xpert-xdr-results/list/{lab_id}")
        xdr_sheets = r.json()
        check("XDR sheets opened on the XDR form", len(xdr_sheets) == 5, r.text[:200])
        check("XDR sheets carry the XDR enrolment",
              all(s["enrollment_id"] == enr_xdr["id"] for s in xdr_sheets),
              [s["enrollment_id"] for s in xdr_sheets])

        r = await c.get(f"/tb-xpert-ultra-results/list/{lab_id}")
        sheets = r.json()
        check("Ultra sheets visible to the lab, XDR ones excluded",
              len(sheets) == 5, r.text[:200])
        check("sheets carry the real enrolment",
              all(s["enrollment_id"] == enr_ultra["id"] for s in sheets),
              [s["enrollment_id"] for s in sheets])

        print("\n7. RESULTS -- the lab tests and reports")
        sheet = sheets[0]
        full = dict(sheet)
        full.update(user_id=lab_user_id, status_id=assist.STATUS_DRAFT,
                    stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION, date_tested="2026-09-10")
        for k in ("stage", "status", "user", "scheme", "laboratory", "service",
                  "enrollment", "ptcycle", "method", "methodsample"):
            full.pop(k, None)

        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=full)
        check("results blocked before samples are received", r.status_code == 400, r.text[:200])

        r = await c.put(f"/enrollments/receive-samples/{enr_ultra['id']}",
                        json={"user_id": lab_user_id})
        check("samples received", r.status_code == 200, r.text[:300])

        r = await c.put(f"/enrollments/receive-samples/{enr_xdr['id']}",
                        json={"user_id": lab_user_id})
        check("XDR samples received", r.status_code == 200, r.text[:300])

        xdr = xdr_sheets[0]
        xdr_body = {k: v for k, v in xdr.items() if k not in (
            "stage", "status", "user", "scheme", "laboratory", "service",
            "enrollment", "ptcycle", "method", "methodsample")}
        xdr_body.update(user_id=lab_user_id, date_tested="2026-09-10",
                        status_id=assist.STATUS_SUBMITTED,
                        stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                        result_interpretable="Yes", tb_detection_result="DETECTED",
                        inh_result="DETECTED", flq_result="NOT DETECTED",
                        amk_result="NOT DETECTED", eth_result="DETECTED",
                        spc_ahpc=22.1, inha=22.3, katg=24.0, fabg1=23.0,
                        gyra1=23.2, gyra2=21.0, gyra3=22.0, gyrb2=22.0, rrs=21.0)
        r = await c.put(f"/tb-xpert-xdr-results/update/{xdr['id']}", json=xdr_body)
        check("XDR result submitted", r.status_code == 200, r.text[:400])

        bad_xdr = dict(xdr_body, tb_detection_result="TRACE")
        r = await c.put(f"/tb-xpert-xdr-results/update/{xdr['id']}", json=bad_xdr)
        check("Ultra grading rejected on the XDR form", r.status_code == 422, r.text[:200])

        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=full)
        check("partial draft saved", r.status_code == 200, r.text[:300])

        bad_user = dict(full, user_id=999999)
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=bad_user)
        check("unknown user rejected", r.status_code == 400, r.text[:200])

        submit = dict(full, status_id=assist.STATUS_SUBMITTED,
                      stage_id=assist.APPROVAL_STAGE_SUBMITTED)
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=submit)
        check("incomplete submission rejected", r.status_code == 422, r.text[:200])

        both = dict(full, result_interpretable="Yes", uninterpretable_result="ERROR")
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=both)
        check("interpretable + uninterpretable rejected", r.status_code == 422, r.text[:200])

        err = dict(submit, result_interpretable="No", uninterpretable_result="ERROR",
                   xpert_module_number="A3")
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=err)
        check("ERROR without a code rejected", r.status_code == 422, r.text[:200])

        err_ok = dict(err, error_code="5007")
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=err_ok)
        check("ERROR with a code accepted", r.status_code == 200, r.text[:300])

        sheet2 = sheets[1]
        good = dict(full, id=sheet2["id"], method_sample_id=sheet2["method_sample_id"],
                    name=sheet2["name"],
                    status_id=assist.STATUS_SUBMITTED, stage_id=assist.APPROVAL_STAGE_SUBMITTED,
                    result_interpretable="Yes", tb_detection_result="HIGH",
                    rif_result="NOT DETECTED", xpert_module_number="A3", ultra_spc=23.4,
                    is1081_is6110=23.2, rpob1=24.1, rpob2=23.9, rpob3=26.5, rpob4=23.1)
        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet2['id']}", json=good)
        check("complete result submitted", r.status_code == 200, r.text[:400])

        r = await c.put(f"/tb-xpert-ultra-results/review-update/{sheet2['id']}",
                        json={"user_id": 1, "review_action": assist.REVIEW_ACTION_APPROVE,
                              "comments": "graded", "content": None, "attachment_id": None})
        check("result approved by the provider", r.status_code == 200, r.text[:300])

        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet2['id']}", json=good)
        check("approved result locked", r.status_code == 400, r.text[:200])

        print("\n8. CYCLE CLOSE-OUT")
        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_REPORT_AVAILABLE, "user_id": 1})
        check("reports made available", r.status_code == 200, r.text[:300])

        r = await c.put(f"/tb-xpert-ultra-results/update/{sheet['id']}", json=err_ok)
        check("results locked once reporting starts", r.status_code == 400, r.text[:200])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_CLOSED, "user_id": 1})
        check("cycle closed", r.status_code == 200, r.text[:300])

        r = await c.put(f"/pt-cycles/status/{cycle_id}",
                        json={"pt_cyle_status_id": assist.PT_CYCLE_CLOSED, "user_id": 1})
        check("a closed cycle cannot move on", r.status_code == 400, r.text[:200])

    print("\n" + "=" * 60)
    print(f"{len(OK)} passed, {len(FAIL)} failed")
    if FAIL:
        print("FAILURES:")
        for f in FAIL:
            print("  -", f)
    return 1 if FAIL else 0


async def main_():
    """Builds a throwaway database, walks the workflow, then removes it."""
    await create_test_database()
    try:
        return await run()
    finally:
        await drop_test_database()


sys.exit(asyncio.run(main_()))
