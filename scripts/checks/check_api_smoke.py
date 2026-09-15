"""API smoke test.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_api_smoke.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import DEV_DSN

import asyncio, sys
from httpx import ASGITransport, AsyncClient
import jose.jwt as jwt
import main
from helpers import assist

async def go():
    ok = True
    async with AsyncClient(transport=ASGITransport(app=main.app),
                           base_url="http://smoke", timeout=60) as c:
        # admin
        r = await c.post("/auth/login", data={"username":"nkoleevans@gmail.com","password":"12345678"})
        print("admin login          ->", r.status_code)
        ok &= r.status_code == 200
        admin = jwt.decode(r.json()["access_token"], assist.SECRET_KEY, algorithms=[assist.ALGORITHM])
        print("   role", admin["role"], "lab", admin["lab"])

        # lab
        r = await c.post("/auth/login", data={"username":"markdoe@gmail.com","password":"12345678"})
        print("lab login            ->", r.status_code)
        ok &= r.status_code == 200
        lab = jwt.decode(r.json()["access_token"], assist.SECRET_KEY, algorithms=[assist.ALGORITHM])
        print("   role", lab["role"], "lab", lab["lab"])
        lab_id = lab["lab"]

        for label, url in [
            ("providers/list", "/providers/list"),
            ("schemes/list", "/schemes/list"),
            ("services/list", "/services/list"),
            ("methods/list", "/methods/list"),
            ("method-samples/list", "/method-samples/list"),
            ("laboratorys/list", "/laboratorys/list"),
            ("applications/list", "/applications/list"),
            ("applications pending", "/applications/list?pending=true"),
            ("pt-cycles/list", "/pt-cycles/list"),
            ("enrollments/list", "/enrollments/list"),
            ("enrollments pending", "/enrollments/list?pending=true"),
            ("results/list", "/tb-xpert-ultra-results/list"),
            ("results pending", "/tb-xpert-ultra-results/list?pending=true"),
            ("results options", "/tb-xpert-ultra-results/options"),
            ("xdr results/list", "/tb-xpert-xdr-results/list"),
            ("xdr results pending", "/tb-xpert-xdr-results/list?pending=true"),
            ("xdr results options", "/tb-xpert-xdr-results/options"),
            ("vl results/list", "/hiv-vl-results/list"),
            ("vl results pending", "/hiv-vl-results/list?pending=true"),
            ("vl results options", "/hiv-vl-results/options"),
            ("eid results/list", "/hiv-eid-results/list"),
            ("eid results pending", "/hiv-eid-results/list?pending=true"),
            ("eid results options", "/hiv-eid-results/options"),
            ("eid results/id/1", "/hiv-eid-results/id/1"),
            ("vl results/id/1", "/hiv-vl-results/id/1"),
            ("xdr results/id/1", "/tb-xpert-xdr-results/id/1"),
            (f"open cycles for lab {lab_id}", f"/pt-cycles/open/{lab_id}"),
            (f"enrolments for lab {lab_id}", f"/enrollments/list/lab/{lab_id}"),
            (f"results for lab {lab_id}", f"/tb-xpert-ultra-results/list/{lab_id}"),
            (f"xdr results for lab {lab_id}", f"/tb-xpert-xdr-results/list/{lab_id}"),
            (f"applications for lab {lab_id}", f"/applications/list/lab/{lab_id}"),
            ("laboratorys/id/0 (signup lookups)", "/laboratorys/id/0"),
            ("pt-cycles/id/1", "/pt-cycles/id/1"),
            ("results/id/1", "/tb-xpert-ultra-results/id/1"),
        ]:
            r = await c.get(url)
            n = len(r.json()) if isinstance(r.json(), list) else "-"
            status = "ok " if r.status_code == 200 else "FAIL"
            print(f"  {status} {label:38} {r.status_code}  rows={n}")
            ok &= r.status_code == 200
            if r.status_code != 200:
                print("       ", r.text[:200])
    print("\nSMOKE PASSED" if ok else "\nSMOKE FAILED")
    return 0 if ok else 1

sys.exit(asyncio.run(go()))
