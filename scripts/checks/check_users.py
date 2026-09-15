"""User account audit.

Covers the endpoints behind the user list, add, edit and view pages: the detail
a listing carries, the rules an account has to satisfy, and what an edit leaves
alone.

It opens two accounts of its own and removes them again, asserting at the end
that the table is back to the size it started at.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_users.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import sys

import asyncpg
from httpx import ASGITransport, AsyncClient

import main
from helpers import assist

# a domain the email validator accepts and the development data never uses
PROVIDER_EMAIL = "check.provider@audit-check.example.com"
FACILITY_EMAIL = "check.facility@audit-check.example.com"
PASSWORD = "check-password-1"


def provider_payload(**changes):
    payload = dict(
        fname="Audit",
        lname="Provider",
        position="Focal Point",
        email=PROVIDER_EMAIL,
        mobile_code="+260",
        mobile="260977000001",
        role_id=assist.ROLE_EQA_FOCAL_POINT,
        password=PASSWORD,
        created_by="check_users",
    )
    payload.update(changes)
    return payload


async def main_check():
    checks = Checks("User account audit")

    con = await asyncpg.connect(DEV_DSN)

    # leave nothing behind from an interrupted run
    await con.execute(
        "DELETE FROM users WHERE email = ANY($1::text[])",
        [PROVIDER_EMAIL, FACILITY_EMAIL],
    )
    before = await con.fetchval("SELECT count(*) FROM users")

    created = []

    async with AsyncClient(
        transport=ASGITransport(app=main.app), base_url="http://check"
    ) as client:
        checks.section("The listing carries role and facility")

        response = await client.get("/users/list")
        checks.check("the listing answers", response.status_code == 200)
        rows = response.json()

        checks.check("it returns every account", len(rows) == before,
                     f"listing {len(rows)}, table {before}")
        checks.check(
            "no account carries a password",
            all("password" not in row for row in rows),
        )
        checks.check(
            "every account resolves its role",
            all(row.get("role") for row in rows),
            str([r["email"] for r in rows if not r.get("role")])[:120],
        )

        lab_rows = [
            row for row in rows if assist.is_laboratory_role(row["role_id"])
        ]
        checks.check(
            "every facility account names its facility",
            lab_rows and all(row.get("laboratory") for row in lab_rows),
            str([r["email"] for r in lab_rows if not r.get("laboratory")])[:120],
        )
        checks.check(
            "no provider account names a facility",
            all(
                not row.get("laboratory")
                for row in rows
                if not assist.is_laboratory_role(row["role_id"])
            ),
        )

        checks.section("The form gets the choices it needs")

        response = await client.get("/users/id/0")
        checks.check("a new account answers", response.status_code == 200)
        blank = response.json()

        checks.check("it carries no account", blank["user"] is None)
        checks.check("it offers the roles", len(blank["roleList"]) > 0)
        checks.check("it offers the provinces", len(blank["provinceList"]) > 0)
        checks.check(
            "every district says which province it is in",
            all(d.get("province_id") for d in blank["districtList"]),
        )

        approved_labs = await con.fetchval(
            "SELECT count(*) FROM laboratorys WHERE status_id = $1",
            assist.STATUS_APPROVED,
        )
        checks.check(
            "it offers only laboratories that are taking part",
            len(blank["laboratoryList"]) == approved_labs,
            f"offered {len(blank['laboratoryList'])}, approved {approved_labs}",
        )

        response = await client.get("/users/id/999999")
        checks.check("an account that is not there is a 404",
                     response.status_code == 404)

        checks.section("Opening an account")

        response = await client.post("/users/create", json=provider_payload())
        checks.check("a provider account is opened", response.status_code == 200,
                     response.text[:160])
        if response.status_code == 200:
            body = response.json()
            created.append(body["id"])
            checks.check("it comes back with its role", body.get("role") is not None)
            checks.check("it comes back with no password",
                         "password" not in body)
            checks.check(
                "it is opened as settled, not awaiting review",
                body["status_id"] == assist.STATUS_APPROVED
                and body["stage_id"] == assist.APPROVAL_STAGE_APPROVED,
            )

        response = await client.post("/users/create", json=provider_payload())
        checks.check(
            "the same email cannot be used twice",
            response.status_code == 400
            and "already exists" in response.json()["detail"],
            response.text[:160],
        )

        response = await client.post(
            "/users/create",
            json=provider_payload(email=FACILITY_EMAIL, password=None),
        )
        checks.check(
            "an account cannot be opened without a password",
            response.status_code == 400,
            response.text[:160],
        )

        checks.section("A role and a facility have to agree")

        response = await client.post(
            "/users/create",
            json=provider_payload(
                email=FACILITY_EMAIL, role_id=assist.ROLE_FACILITY_STAFF
            ),
        )
        checks.check(
            "a facility role without a facility is refused",
            response.status_code == 422,
            response.text[:160],
        )

        response = await client.post(
            "/users/create",
            json=provider_payload(email=FACILITY_EMAIL, laboratory_id=1),
        )
        checks.check(
            "a provider role with a facility is refused",
            response.status_code == 422,
            response.text[:160],
        )

        lab_id = await con.fetchval(
            "SELECT id FROM laboratorys WHERE status_id = $1 ORDER BY id LIMIT 1",
            assist.STATUS_APPROVED,
        )
        response = await client.post(
            "/users/create",
            json=provider_payload(
                email=FACILITY_EMAIL,
                role_id=assist.ROLE_FACILITY_STAFF,
                laboratory_id=lab_id,
            ),
        )
        checks.check(
            "a facility role with a facility is opened",
            response.status_code == 200,
            response.text[:160],
        )
        if response.status_code == 200:
            body = response.json()
            created.append(body["id"])
            checks.check(
                "it names the facility it reports for",
                (body.get("laboratory") or {}).get("id") == lab_id,
            )

        checks.section("Editing an account")

        if created:
            user_id = created[0]

            edit = provider_payload(position="Senior Focal Point")
            edit.pop("password")
            edit["updated_by"] = "check_users"

            response = await client.put(f"/users/update/{user_id}", json=edit)
            checks.check("the change is saved", response.status_code == 200,
                         response.text[:160])
            checks.check(
                "the change took",
                response.status_code == 200
                and response.json()["position"] == "Senior Focal Point",
            )

            response = await client.post(
                "/auth/login",
                data={"username": PROVIDER_EMAIL, "password": PASSWORD},
            )
            checks.check(
                "an edit with no password leaves the password alone",
                response.status_code == 200,
                response.text[:160],
            )

            edit["password"] = "a-different-password"
            response = await client.put(f"/users/update/{user_id}", json=edit)
            checks.check("a new password is saved", response.status_code == 200)

            response = await client.post(
                "/auth/login",
                data={"username": PROVIDER_EMAIL, "password": "a-different-password"},
            )
            checks.check("the new password signs in", response.status_code == 200)

            response = await client.post(
                "/auth/login",
                data={"username": PROVIDER_EMAIL, "password": PASSWORD},
            )
            checks.check("the old password no longer signs in",
                         response.status_code == 401)

            if len(created) > 1:
                edit = provider_payload(email=FACILITY_EMAIL)
                edit.pop("password")
                response = await client.put(f"/users/update/{user_id}", json=edit)
                checks.check(
                    "an account cannot take another's email",
                    response.status_code == 400
                    and "already uses" in response.json()["detail"],
                    response.text[:160],
                )

            response = await client.get(f"/users/id/{user_id}")
            checks.check("the account can be viewed", response.status_code == 200)
            checks.check(
                "the view carries no password",
                response.status_code == 200
                and "password" not in response.json()["user"],
            )

        checks.section("The public email check gives nothing away")

        response = await client.get(f"/users/email/{PROVIDER_EMAIL}")
        checks.check("a taken email is reported", response.status_code == 200
                     and len(response.json()) == 1)
        checks.check(
            "it does not hand back the password",
            response.status_code == 200
            and all("password" not in row for row in response.json()),
        )

        response = await client.get("/users/email/nobody@audit-check.example.com")
        checks.check("a free email comes back empty",
                     response.status_code == 200 and response.json() == [])

    checks.section("Nothing is left behind")

    await con.execute(
        "DELETE FROM users WHERE email = ANY($1::text[])",
        [PROVIDER_EMAIL, FACILITY_EMAIL],
    )
    after = await con.fetchval("SELECT count(*) FROM users")
    checks.check(f"the table is back to {before} account(s)", after == before,
                 f"now {after}")

    await con.close()
    return checks.report()


if __name__ == "__main__":
    sys.exit(asyncio.run(main_check()))
