"""UI page endpoints.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_pages.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import DEV_DSN

import asyncio
import sys

from httpx import ASGITransport, AsyncClient
import jose.jwt as jwt

import main
from helpers import assist

OK, FAIL = [], []


def check(label, cond, detail=""):
    (OK if cond else FAIL).append(label)
    print(("  PASS  " if cond else "  FAIL  ") + label
          + (f"   <- {detail}" if detail and not cond else ""))


async def go():
    async with AsyncClient(transport=ASGITransport(app=main.app),
                           base_url="http://t", timeout=60) as c:

        # --- who the pages run as -------------------------------------
        r = await c.post("/auth/login",
                         data={"username": "musachoolwe@gmail.com",
                               "password": "12345678"})
        claims = jwt.decode(r.json()["access_token"], assist.SECRET_KEY,
                            algorithms=[assist.ALGORITHM])
        lab_id = claims["lab"]
        print(f"lab user -> lab {lab_id}\n")

        print("1. Facility > My Performance")
        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"lab_id": lab_id})
        rows = r.json()
        check("performance list loads", r.status_code == 200 and len(rows) > 0,
              f"{r.status_code} {r.text[:120]}")

        needed = ["cycle_code", "scheme_name", "method_name", "report_date",
                  "total_score", "max_score", "percent_score_display",
                  "overall_performance", "acceptable_count", "warning_count",
                  "unacceptable_count", "not_reported_count", "report_number",
                  "enrollment_id"]
        missing = [k for k in needed if k not in rows[0]]
        check("every column the grid binds is present", not missing, missing)

        check("the list is scoped to this lab",
              all(row["lab_id"] == lab_id for row in rows),
              {row["lab_id"] for row in rows})

        enrollment_id = rows[0]["enrollment_id"]

        print("\n2. Facility > Round Performance")
        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"enrollment_id": enrollment_id})
        check("header loads for one enrolment",
              r.status_code == 200 and len(r.json()) == 1,
              f"{r.status_code} {len(r.json())}")

        r = await c.get("/evaluations/report/result-evaluation",
                        params={"enrollment_id": enrollment_id})
        detail = r.json()
        check("per-sample rows load", r.status_code == 200 and len(detail) > 0,
              f"{r.status_code} {len(detail)}")

        needed = ["sample_name", "attribute_label", "reported_numeric",
                  "reported_text", "assigned_numeric", "assigned_text",
                  "participant_count", "group_mean", "robust_sd", "z_score",
                  "score", "grade", "not_evaluated_reason", "evaluation_id"]
        missing = [k for k in needed if k not in detail[0]]
        check("every column the detail grid binds is present", not missing, missing)

        print("\n3. Admin > Round Evaluation")
        # a scored round
        r = await c.get("/evaluations/performance")
        cycle_id = r.json()[0]["pt_cycle_id"]

        r = await c.get(f"/pt-cycles/id/{cycle_id}")
        check("cycle detail loads", r.status_code == 200
              and r.json()["ptcycle"] is not None, r.status_code)

        r = await c.get("/evaluations/report/sample-summary",
                        params={"pt_cycle_id": cycle_id})
        stats = r.json()
        check("sample statistics load", r.status_code == 200 and len(stats) > 0,
              f"{r.status_code} {len(stats)}")

        needed = ["sample_name", "method_name", "attribute_label",
                  "assigned_value_numeric", "assigned_value_text",
                  "assigned_value_source", "pooled_reported_count",
                  "group_mean", "group_median", "robust_sd",
                  "acceptable_count", "unacceptable_count",
                  "not_evaluated_count", "not_evaluated_reason",
                  "method_sample_id", "attribute", "frozen_at"]
        missing = [k for k in needed if k not in stats[0]]
        check("every column the statistics grid binds is present", not missing,
              missing)

        keys = [(s["method_sample_id"], s["attribute"]) for s in stats]
        check("the composite grid key is unique", len(keys) == len(set(keys)),
              f"{len(keys)} rows, {len(set(keys))} keys")

        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"pt_cycle_id": cycle_id})
        check("participants load for the round",
              r.status_code == 200 and len(r.json()) > 0, r.status_code)

        # the re-score button
        r = await c.put(f"/pt-cycles/evaluate/{cycle_id}",
                        json={"user_id": 1, "recompute": False,
                              "comments": "from the page"})
        check("scoring an already scored round is refused",
              r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.put(f"/pt-cycles/evaluate/{cycle_id}",
                        json={"user_id": 1, "recompute": True,
                              "comments": "correction applied"})
        check("re-scoring with recompute succeeds", r.status_code == 200,
              f"{r.status_code} {r.text[:200]}")
        if r.status_code == 200:
            print("          ", r.json()["message"])

        # a lab user must not be able to re-score
        lab_user = claims["userid"]
        r = await c.put(f"/pt-cycles/evaluate/{cycle_id}",
                        json={"user_id": lab_user, "recompute": True})
        check("a lab user cannot re-score a round", r.status_code == 403,
              f"{r.status_code} {r.text[:120]}")

        print("\n4. PT Performance Report page")
        r = await c.get("/evaluations/report/enrollment-performance")
        check("the participant picker loads every scored round",
              r.status_code == 200 and len(r.json()) > 0, r.status_code)

        r = await c.get(f"/reports/pt-performance/{enrollment_id}/meta")
        meta = r.json()
        check("report metadata loads", r.status_code == 200, r.status_code)
        needed = ["report_number", "lab_code", "lab_name", "scheme_name",
                  "method_name", "report_date", "total_score", "max_score",
                  "percent_score_display", "overall_performance", "renderer"]
        missing = [k for k in needed if k not in meta]
        check("every field the detail panel shows is present", not missing,
              missing)

        r = await c.get(f"/reports/pt-performance/{enrollment_id}")
        check("the PDF renders",
              r.status_code == 200
              and r.headers["content-type"] == "application/pdf"
              and r.content.startswith(b"%PDF"),
              f"{r.status_code} {r.headers.get('content-type')}")
        check("it is served inline for the viewer",
              "inline" in r.headers.get("content-disposition", ""),
              r.headers.get("content-disposition"))
        check("the filename is exposed to the browser",
              "Content-Disposition" in r.headers.get(
                  "access-control-expose-headers", ""),
              r.headers.get("access-control-expose-headers"))

        r = await c.get(f"/reports/pt-performance/{enrollment_id}",
                        params={"download": True})
        check("the download button gets an attachment",
              "attachment" in r.headers.get("content-disposition", ""),
              r.headers.get("content-disposition"))

        r = await c.get("/reports/pt-performance/999999")
        check("an unscored round reports cleanly, not a crash",
              r.status_code == 404, r.status_code)

    print("\n" + "=" * 62)
    print(f"{len(OK)} passed, {len(FAIL)} failed")
    for f in FAIL:
        print("  -", f)
    return 1 if FAIL else 0


sys.exit(asyncio.run(go()))
