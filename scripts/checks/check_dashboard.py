"""Dashboard summary audit.

Checks that the one call the dashboard makes returns every figure it shows,
that the figures agree with the tables they are drawn from, and that scoping
it to a laboratory really does narrow it.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_dashboard.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import sys

import asyncpg
from httpx import ASGITransport, AsyncClient

import main
from helpers import assist

# what dashboard.tsx binds each chart and grid to
BINDINGS = {
    "cycleList": ["cycleCode", "participants", "avgScore", "satisfactoryRate"],
    "gradeList": ["grade", "count", "percent"],
    "schemeList": ["scheme", "participants", "satisfactory", "unsatisfactory",
                   "avgScore", "satisfactoryRate"],
    "resultFormList": ["resultForm", "label", "total", "draft", "submitted",
                       "underReview", "approved", "rejected", "awaitingReview"],
    "methodList": ["method", "resultForm", "participants", "satisfactory",
                   "satisfactoryRate", "avgScore"],
    "provinceList": ["province", "laboratories", "participants", "avgScore"],
    "labTypeList": ["labType", "laboratories"],
    "openCycleList": ["ptCycleId", "cycleCode", "cycleName", "scheme", "status",
                      "enrolments", "closingDate", "reportDate"],
    "participantList": ["enrollmentId", "labCode", "labName", "cycleCode",
                        "scheme", "method", "percentScore", "totalScore",
                        "maxScore", "performance", "acceptable", "warning",
                        "unacceptable", "notReported", "reportDate",
                        "reportNumber"],
}

HEADLINE = [
    "laboratories.total", "laboratories.approved", "laboratories.pending",
    "enrolments.total", "enrolments.accepted", "enrolments.pending",
    "results.total", "results.awaitingReview",
    "rounds.scored", "rounds.participantsScored",
]

PERFORMANCE = [
    "satisfactory", "unsatisfactory", "notEvaluated", "scored",
    "satisfactoryRate", "averageScore", "gradedAttributes",
]

RESULT_TABLES = [
    "tb_xpert_ultra_results",
    "tb_xpert_xdr_results",
    "hiv_vl_results",
    "hiv_eid_results",
]


def dig(obj, path):
    for part in path.split("."):
        if not isinstance(obj, dict) or part not in obj:
            return None
        obj = obj[part]
    return obj


async def main_check():
    checks = Checks("Dashboard summary audit")

    con = await asyncpg.connect(DEV_DSN)

    async with AsyncClient(
        transport=ASGITransport(app=main.app), base_url="http://check"
    ) as client:
        response = await client.get("/dashboard/summary")
        checks.check("the summary answers", response.status_code == 200,
                     response.text[:200])
        if response.status_code != 200:
            await con.close()
            return checks.report()

        summary = response.json()

        checks.section("Every figure the page reads is present")

        missing = [p for p in HEADLINE if dig(summary["headline"], p) is None]
        checks.check("headline carries every tile", not missing, str(missing))

        missing = [p for p in PERFORMANCE if p not in summary["performance"]]
        checks.check("performance carries every figure", not missing, str(missing))

        for name, fields in BINDINGS.items():
            rows = summary.get(name)
            checks.check(f"{name} is returned", rows is not None)
            if not rows:
                continue
            missing = [f for f in fields if f not in rows[0]]
            checks.check(
                f"{name} carries every bound field", not missing, str(missing)
            )

        checks.section("The figures agree with the tables")

        labs = await con.fetchval("SELECT count(*) FROM laboratorys")
        checks.check(
            "laboratory total matches the table",
            summary["headline"]["laboratories"]["total"] == labs,
            f"summary {summary['headline']['laboratories']['total']}, table {labs}",
        )

        approved = await con.fetchval(
            "SELECT count(*) FROM laboratorys WHERE status_id = $1",
            assist.STATUS_APPROVED,
        )
        checks.check(
            "approved laboratories match",
            summary["headline"]["laboratories"]["approved"] == approved,
        )

        results = 0
        for table in RESULT_TABLES:
            results += await con.fetchval(f"SELECT count(*) FROM {table}")
        checks.check(
            "result total matches the four result tables",
            summary["headline"]["results"]["total"] == results,
            f"summary {summary['headline']['results']['total']}, tables {results}",
        )

        pending = 0
        for table in RESULT_TABLES:
            pending += await con.fetchval(
                f"SELECT count(*) FROM {table} WHERE status_id = ANY($1::int[])",
                [assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW],
            )
        checks.check(
            "results awaiting review match",
            summary["headline"]["results"]["awaitingReview"] == pending,
        )

        scored = await con.fetchval(
            "SELECT count(*) FROM vw_pt_enrollment_performance"
        )
        checks.check(
            "participants scored matches the performance view",
            summary["performance"]["scored"] == scored,
            f"summary {summary['performance']['scored']}, view {scored}",
        )

        graded = await con.fetchval("SELECT count(*) FROM vw_pt_result_evaluation")
        checks.check(
            "graded attributes match the evaluation view",
            summary["performance"]["gradedAttributes"] == graded,
        )

        satisfactory = await con.fetchval(
            "SELECT count(*) FROM vw_pt_enrollment_performance "
            "WHERE overall_performance = $1",
            assist.PERFORMANCE_SATISFACTORY,
        )
        checks.check(
            "satisfactory count matches the view",
            summary["performance"]["satisfactory"] == satisfactory,
        )

        checks.check(
            "the standings add up to what was scored",
            summary["performance"]["satisfactory"]
            + summary["performance"]["unsatisfactory"]
            + summary["performance"]["notEvaluated"]
            == summary["performance"]["scored"],
        )

        checks.check(
            "the grade counts add up to the graded attributes",
            sum(row["count"] for row in summary["gradeList"])
            == summary["performance"]["gradedAttributes"],
        )

        checks.check(
            "each form's statuses add up to its total",
            all(
                row["draft"] + row["submitted"] + row["underReview"]
                + row["approved"] + row["rejected"] == row["total"]
                for row in summary["resultFormList"]
            ),
        )

        checks.check(
            "the forms add up to the result total",
            sum(row["total"] for row in summary["resultFormList"])
            == summary["headline"]["results"]["total"],
        )

        checks.check(
            "the rounds add up to what was scored",
            sum(row["participants"] for row in summary["cycleList"])
            == summary["performance"]["scored"],
        )

        checks.check(
            "the schemes add up to what was scored",
            sum(row["participants"] for row in summary["schemeList"])
            == summary["performance"]["scored"],
        )

        checks.check(
            "no round in progress is already closed",
            all(row["status"] != "Closed" for row in summary["openCycleList"]),
        )

        checks.section("A laboratory only sees its own work")

        lab_id = await con.fetchval(
            "SELECT lab_id FROM vw_pt_enrollment_performance ORDER BY lab_id LIMIT 1"
        )

        response = await client.get(f"/dashboard/summary?lab_id={lab_id}")
        checks.check("the scoped summary answers", response.status_code == 200)
        scoped = response.json()

        checks.check("it says it is scoped", scoped["scope"] == "laboratory")
        checks.check("it reports the laboratory", scoped["labId"] == lab_id)

        checks.check(
            "the standings are only this laboratory's",
            all(
                row["labCode"] == scoped["participantList"][0]["labCode"]
                for row in scoped["participantList"]
            ),
        )

        lab_scored = await con.fetchval(
            "SELECT count(*) FROM vw_pt_enrollment_performance WHERE lab_id = $1",
            lab_id,
        )
        checks.check(
            "the scoped standing count matches the view",
            scoped["performance"]["scored"] == lab_scored,
            f"summary {scoped['performance']['scored']}, view {lab_scored}",
        )

        checks.check(
            "it is narrower than the whole scheme",
            scoped["performance"]["scored"] <= summary["performance"]["scored"],
        )

        lab_results = 0
        for table in RESULT_TABLES:
            lab_results += await con.fetchval(
                f"SELECT count(*) FROM {table} WHERE lab_id = $1", lab_id
            )
        checks.check(
            "the scoped result total is this laboratory's",
            scoped["headline"]["results"]["total"] == lab_results,
            f"summary {scoped['headline']['results']['total']}, tables {lab_results}",
        )

        lab_enrolments = await con.fetchval(
            "SELECT count(*) FROM enrollments WHERE lab_id = $1", lab_id
        )
        checks.check(
            "the scoped enrolment total is this laboratory's",
            scoped["headline"]["enrolments"]["total"] == lab_enrolments,
        )

        checks.section("A laboratory with no history still renders")

        empty = await con.fetchval(
            """
            SELECT l.id FROM laboratorys l
            WHERE NOT EXISTS (
                SELECT 1 FROM vw_pt_enrollment_performance p WHERE p.lab_id = l.id
            )
            ORDER BY l.id LIMIT 1
            """
        )

        if empty is None:
            checks.check("every laboratory has been scored, nothing to check", True)
        else:
            response = await client.get(f"/dashboard/summary?lab_id={empty}")
            checks.check("the empty summary answers", response.status_code == 200)
            blank = response.json()
            checks.check(
                "it reports nothing scored rather than failing",
                blank["performance"]["scored"] == 0
                and blank["performance"]["satisfactoryRate"] == 0.0
                and blank["cycleList"] == []
                and blank["participantList"] == [],
            )

    await con.close()
    return checks.report()


if __name__ == "__main__":
    sys.exit(asyncio.run(main_check()))
