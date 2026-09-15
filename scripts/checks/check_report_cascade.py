"""Report cascade.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_report_cascade.py
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


def unique(rows, id_field, name_field):
    seen = {}
    for r in rows:
        if r[id_field] is not None and r[id_field] not in seen:
            seen[r[id_field]] = r[name_field]
    return seen


async def go():
    async with AsyncClient(transport=ASGITransport(app=main.app),
                           base_url="http://t", timeout=60) as c:

        print("Provider staff")
        r = await c.get("/evaluations/report/enrollment-performance")
        rows = r.json()
        check("the scope loads", r.status_code == 200 and len(rows) > 0,
              r.status_code)

        needed = ["provider_id", "provider_name", "scheme_id", "scheme_name",
                  "pt_cycle_id", "cycle_code", "cycle_name", "method_id",
                  "method_name", "lab_code", "lab_name", "enrollment_id",
                  "report_date"]
        missing = [k for k in needed if k not in rows[0]]
        check("every field the cascade needs is present", not missing, missing)

        providers = unique(rows, "provider_id", "provider_name")
        print("          providers:", list(providers.values()))
        check("more than one provider to choose from", len(providers) > 1,
              providers)

        # narrowing to one provider must narrow the schemes
        virology = [p for p, n in providers.items() if n == "Virology PT"][0]
        vrows = [r for r in rows if r["provider_id"] == virology]
        vschemes = unique(vrows, "scheme_id", "scheme_name")
        allschemes = unique(rows, "scheme_id", "scheme_name")
        check("choosing a provider narrows the schemes",
              len(vschemes) < len(allschemes) and len(vschemes) == 2,
              f"{list(vschemes.values())} of {list(allschemes.values())}")

        check("a CDL scheme is not offered under Virology PT",
              not any("Tuberculosis" in n for n in vschemes.values()),
              vschemes)

        # and a scheme must narrow the rounds
        eid = [s for s, n in vschemes.items() if n.startswith("HIV EID")][0]
        erows = [r for r in vrows if r["scheme_id"] == eid]
        ecycles = unique(erows, "pt_cycle_id", "cycle_code")
        check("choosing a scheme narrows the rounds",
              len(ecycles) == 1 and list(ecycles.values())[0] == "EID-2026-A",
              ecycles)

        # and a round must narrow the participants
        cycle = list(ecycles)[0]
        participants = [r for r in erows if r["pt_cycle_id"] == cycle]
        check("choosing a round narrows the participants",
              len(participants) == 4, len(participants))
        print("          participants:",
              [f"{p['lab_code']} ({p['method_name']})" for p in participants])

        # the same narrowing done server side must agree
        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"provider_id": virology, "scheme_id": eid})
        check("the server filters the same way the page does",
              r.status_code == 200 and len(r.json()) == len(participants),
              f"{r.status_code} {len(r.json())} vs {len(participants)}")

        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"scheme_id": eid, "pt_cycle_id": cycle})
        check("filtering by scheme and round works together",
              r.status_code == 200 and len(r.json()) == 4, len(r.json()))

        print("\nLaboratory user")
        r = await c.post("/auth/login",
                         data={"username": "musachoolwe@gmail.com",
                               "password": "12345678"})
        claims = jwt.decode(r.json()["access_token"], assist.SECRET_KEY,
                            algorithms=[assist.ALGORITHM])
        lab_id = claims["lab"]

        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"lab_id": lab_id})
        lab_rows = r.json()
        check("a lab sees only its own enrolments",
              all(row["lab_id"] == lab_id for row in lab_rows),
              {row["lab_id"] for row in lab_rows})

        lab_providers = unique(lab_rows, "provider_id", "provider_name")
        lab_schemes = unique(lab_rows, "scheme_id", "scheme_name")
        print(f"          this lab works across {len(lab_providers)} "
              f"provider(s), {len(lab_schemes)} scheme(s)")
        check("a lab across several schemes still needs the cascade",
              len(lab_schemes) > 1, lab_schemes)

        # within one round a lab may hold more than one enrolment
        counts = {}
        for row in lab_rows:
            counts[row["pt_cycle_id"]] = counts.get(row["pt_cycle_id"], 0) + 1
        multi = [k for k, v in counts.items() if v > 1]
        check("a lab with two methods in a round picks between them",
              len(multi) > 0, counts)

        print("\nDeep link")
        target = lab_rows[0]
        r = await c.get("/evaluations/report/enrollment-performance",
                        params={"enrollment_id": target["enrollment_id"]})
        row = r.json()[0]
        check("a linked enrolment carries its whole cascade",
              row["provider_id"] is not None
              and row["scheme_id"] is not None
              and row["pt_cycle_id"] is not None,
              row)

        r = await c.get(f"/reports/pt-performance/{target['enrollment_id']}")
        check("and its report still renders",
              r.status_code == 200 and r.content.startswith(b"%PDF"),
              r.status_code)

    print("\n" + "=" * 62)
    print(f"{len(OK)} passed, {len(FAIL)} failed")
    for f in FAIL:
        print("  -", f)
    return 1 if FAIL else 0


sys.exit(asyncio.run(go()))
