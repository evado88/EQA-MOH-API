"""Laboratory scheme audit.

Checks the Laboratory Scheme List: that its scheme summary says the same thing
as the applications it is derived from, that the plain Laboratory List stays
free of it, that the scheme listing and the laboratory page agree, and that a
lab nobody has accepted yet is not shown as registered in anything.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_laboratories.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import sys

import asyncpg
from httpx import ASGITransport, AsyncClient

import main
from helpers import assist

# what laboratory_scheme_list.tsx binds the Schemes column to
GRID_FIELDS = [
    "scheme_names",
    "scheme_count",
    "scheme_list",
    "accepted_scheme_names",
    "accepted_scheme_count",
]
CHIP_FIELDS = [
    "scheme_id",
    "scheme_name",
    "provider_name",
    "participation",
    "method_count",
    "accepted_count",
    "pending_count",
    "rejected_count",
    "method_names",
    "accepted_method_names",
]

PARTICIPATION = {"Accepted", "Pending", "Rejected"}


async def main_check():
    checks = Checks("Laboratory scheme audit")

    con = await asyncpg.connect(DEV_DSN)

    checks.section("The view exists and is derived from the applications")

    view_rows = await con.fetch("SELECT * FROM vw_laboratory_scheme")
    checks.check("vw_laboratory_scheme answers", view_rows is not None)

    pairs = await con.fetchval(
        "SELECT count(*) FROM (SELECT DISTINCT lab_id, scheme_id FROM applications) x"
    )
    checks.check(
        "one row per laboratory per scheme applied for",
        len(view_rows) == pairs,
        f"view {len(view_rows)}, applications {pairs}",
    )

    checks.check(
        "the method counts add up",
        all(
            row["method_count"]
            == row["accepted_count"] + row["pending_count"] + row["rejected_count"]
            for row in view_rows
        ),
    )

    checks.check(
        "participation is one of the three words",
        all(row["participation"] in PARTICIPATION for row in view_rows),
        str(sorted({r["participation"] for r in view_rows})),
    )

    checks.check(
        "a row is Accepted exactly when a method was accepted",
        all(
            (row["participation"] == "Accepted") == (row["accepted_count"] > 0)
            for row in view_rows
        ),
    )

    checks.check(
        "only an accepted row names accepted methods",
        all(
            (row["accepted_method_names"] is not None) == (row["accepted_count"] > 0)
            for row in view_rows
        ),
    )

    total_applications = await con.fetchval("SELECT count(*) FROM applications")
    checks.check(
        "every application is counted once",
        sum(row["method_count"] for row in view_rows) == total_applications,
        f"view {sum(r['method_count'] for r in view_rows)}, table {total_applications}",
    )

    async with AsyncClient(
        transport=ASGITransport(app=main.app), base_url="http://check"
    ) as client:
        checks.section("The flat listing stays flat")

        response = await client.get("/laboratorys/list")
        checks.check("the laboratory list answers", response.status_code == 200,
                     response.text[:160])
        flat = response.json()

        labs = await con.fetchval("SELECT count(*) FROM laboratorys")
        checks.check("it returns every laboratory", len(flat) == labs)
        checks.check(
            "it carries no scheme summary",
            all(
                field not in flat[0]
                for field in GRID_FIELDS
            ),
            str([f for f in GRID_FIELDS if f in flat[0]]),
        )

        checks.section("The scheme listing carries it")

        response = await client.get("/laboratorys/scheme-list")
        checks.check("the scheme list answers", response.status_code == 200,
                     response.text[:160])
        rows = response.json()

        checks.check("it returns every laboratory", len(rows) == labs)
        checks.check(
            "it is the same laboratories as the flat listing",
            sorted(r["id"] for r in rows) == sorted(r["id"] for r in flat),
        )

        missing = [f for f in GRID_FIELDS if f not in rows[0]]
        checks.check("every field the column binds to is there", not missing,
                     str(missing))

        chips = [chip for row in rows for chip in row["scheme_list"]]
        checks.check("the scheme rows come through", len(chips) == len(view_rows),
                     f"listing {len(chips)}, view {len(view_rows)}")

        missing = [f for f in CHIP_FIELDS if f not in chips[0]]
        checks.check("every field a chip needs is there", not missing, str(missing))

        checks.check(
            "the count matches the schemes listed",
            all(row["scheme_count"] == len(row["scheme_list"]) for row in rows),
        )

        checks.check(
            "the searchable text names every scheme the column shows",
            all(
                row["scheme_names"]
                == ", ".join(s["scheme_name"] for s in row["scheme_list"])
                for row in rows
            ),
        )

        checks.check(
            "the registered text names only the accepted schemes",
            all(
                row["accepted_scheme_names"]
                == ", ".join(
                    s["scheme_name"]
                    for s in row["scheme_list"]
                    if s["participation"] == "Accepted"
                )
                for row in rows
            ),
        )

        checks.check(
            "the registered count matches the registered names",
            all(
                row["accepted_scheme_count"]
                == len(
                    [
                        s
                        for s in row["scheme_list"]
                        if s["participation"] == "Accepted"
                    ]
                )
                for row in rows
            ),
        )

        checks.section("It matches the applications, laboratory by laboratory")

        accepted = await con.fetch(
            """
            SELECT a.lab_id, count(DISTINCT a.scheme_id) AS n
            FROM applications a
            WHERE a.status_id = $1
            GROUP BY a.lab_id
            """,
            assist.STATUS_APPROVED,
        )
        accepted_by_lab = {row["lab_id"]: row["n"] for row in accepted}

        mismatched = [
            row["code"]
            for row in rows
            if len(
                [s for s in row["scheme_list"] if s["participation"] == "Accepted"]
            )
            != accepted_by_lab.get(row["id"], 0)
        ]
        checks.check(
            "every laboratory shows the schemes it was accepted into",
            not mismatched,
            str(mismatched)[:160],
        )

        checks.section("A laboratory nobody has accepted shows nothing")

        rejected_only = [
            row
            for row in rows
            if row["scheme_list"]
            and all(s["participation"] != "Accepted" for s in row["scheme_list"])
        ]
        if rejected_only:
            checks.check(
                "it is registered in no scheme",
                all(row["accepted_scheme_names"] == "" for row in rejected_only),
                str([r["code"] for r in rejected_only]),
            )
            checks.check(
                "but its application is still shown",
                all(row["scheme_count"] > 0 for row in rejected_only),
            )
        else:
            checks.check(
                "every laboratory has been accepted somewhere, nothing to check",
                True,
            )

        checks.section("The laboratory page says the same thing")

        lab_id = rows[0]["id"]
        response = await client.get(f"/laboratorys/id/{lab_id}")
        checks.check("the laboratory page answers", response.status_code == 200)

        page = response.json()["laboratory"]
        checks.check(
            "its scheme list matches the listing",
            page["scheme_list"] == rows[0]["scheme_list"],
        )
        checks.check(
            "its scheme names match the listing",
            page["scheme_names"] == rows[0]["scheme_names"]
            and page["accepted_scheme_names"] == rows[0]["accepted_scheme_names"],
        )

    await con.close()
    return checks.report()


if __name__ == "__main__":
    sys.exit(asyncio.run(main_check()))
