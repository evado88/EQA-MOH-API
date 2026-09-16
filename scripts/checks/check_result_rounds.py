"""Result round picker audit.

The result listings no longer show everything at once: a round has to be chosen
first. This checks what the picker is offered and that choosing a round really
does narrow the listing to it - for the provider's view of every form, and for
a laboratory's view of its own.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_result_rounds.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import sys

import asyncpg
from httpx import ASGITransport, AsyncClient

import main

# the endpoint prefix and result table behind each form
FORMS = [
    ("tb-xpert-ultra-results", "tb_xpert_ultra_results"),
    ("tb-xpert-xdr-results", "tb_xpert_xdr_results"),
    ("hiv-vl-results", "hiv_vl_results"),
    ("hiv-eid-results", "hiv_eid_results"),
]

# what the round picker binds to
CYCLE_FIELDS = [
    "pt_cycle_id",
    "cycle_code",
    "cycle_name",
    "cycle_status",
    "label",
    "result_count",
    "draft_count",
    "pending_count",
    "approved_count",
]


async def main_check():
    checks = Checks("Result round picker audit")

    con = await asyncpg.connect(DEV_DSN)

    async with AsyncClient(
        transport=ASGITransport(app=main.app), base_url="http://check"
    ) as client:
        for prefix, table in FORMS:
            checks.section(prefix)

            response = await client.get(f"/{prefix}/cycles")
            checks.check("the rounds answer", response.status_code == 200,
                         response.text[:160])
            if response.status_code != 200:
                continue

            cycles = response.json()

            expected = await con.fetchval(
                f"SELECT count(DISTINCT pt_cycle_id) FROM {table}"
            )
            checks.check(
                "it offers every round that has sheets",
                len(cycles) == expected,
                f"offered {len(cycles)}, table {expected}",
            )

            if not cycles:
                continue

            missing = [f for f in CYCLE_FIELDS if f not in cycles[0]]
            checks.check("every field the picker binds to is there", not missing,
                         str(missing))

            checks.check(
                "no round is offered with nothing on it",
                all(row["result_count"] > 0 for row in cycles),
            )

            checks.check(
                "the newest round comes first",
                [c["effective_date"] for c in cycles]
                == sorted((c["effective_date"] for c in cycles), reverse=True),
            )

            total = await con.fetchval(f"SELECT count(*) FROM {table}")
            checks.check(
                "the rounds account for every result",
                sum(row["result_count"] for row in cycles) == total,
                f"rounds {sum(r['result_count'] for r in cycles)}, table {total}",
            )

            checks.check(
                "each round's statuses add up to its total",
                all(
                    row["draft_count"] + row["pending_count"] + row["approved_count"]
                    <= row["result_count"]
                    for row in cycles
                ),
            )

            # choosing a round narrows the listing to it
            chosen = cycles[0]
            response = await client.get(
                f"/{prefix}/list?pt_cycle_id={chosen['pt_cycle_id']}"
            )
            checks.check("the round lists", response.status_code == 200,
                         response.text[:160])
            rows = response.json()

            checks.check(
                "it returns only that round",
                all(r["pt_cycle_id"] == chosen["pt_cycle_id"] for r in rows),
            )
            checks.check(
                "it returns the number the picker promised",
                len(rows) == chosen["result_count"],
                f"listed {len(rows)}, picker said {chosen['result_count']}",
            )

            everything = await client.get(f"/{prefix}/list")
            checks.check(
                "and it is narrower than the whole form",
                len(rows) <= len(everything.json()),
            )

        checks.section("A laboratory only sees its own rounds")

        lab_id = await con.fetchval(
            "SELECT lab_id FROM hiv_eid_results ORDER BY lab_id LIMIT 1"
        )

        for prefix, table in FORMS:
            response = await client.get(f"/{prefix}/cycles?lab_id={lab_id}")
            checks.check(f"{prefix}: the scoped rounds answer",
                         response.status_code == 200, response.text[:160])
            cycles = response.json()

            expected = await con.fetchval(
                f"SELECT count(DISTINCT pt_cycle_id) FROM {table} WHERE lab_id = $1",
                lab_id,
            )
            checks.check(
                f"{prefix}: it offers only rounds this lab has sheets for",
                len(cycles) == expected,
                f"offered {len(cycles)}, table {expected}",
            )

            if not cycles:
                continue

            chosen = cycles[0]
            response = await client.get(
                f"/{prefix}/list?lab_id={lab_id}&pt_cycle_id={chosen['pt_cycle_id']}"
            )
            rows = response.json()
            checks.check(
                f"{prefix}: the listing is this lab and this round only",
                all(
                    r["lab_id"] == lab_id
                    and r["pt_cycle_id"] == chosen["pt_cycle_id"]
                    for r in rows
                ),
            )
            checks.check(
                f"{prefix}: and it matches the count the picker promised",
                len(rows) == chosen["result_count"],
                f"listed {len(rows)}, picker said {chosen['result_count']}",
            )

        checks.section("A round nobody has results for is not offered")

        empty = await con.fetchval(
            """
            SELECT c.id FROM pt_cycles c
            WHERE NOT EXISTS (SELECT 1 FROM hiv_eid_results r WHERE r.pt_cycle_id = c.id)
            ORDER BY c.id LIMIT 1
            """
        )
        if empty is None:
            checks.check("every round has EID results, nothing to check", True)
        else:
            response = await client.get("/hiv-eid-results/cycles")
            checks.check(
                "it is left out of the picker",
                all(row["pt_cycle_id"] != empty for row in response.json()),
            )

    await con.close()
    return checks.report()


if __name__ == "__main__":
    sys.exit(asyncio.run(main_check()))
