"""What the scheme looks like right now, in one call.

The dashboard asks a dozen questions that are all counts, so answering them
here - as aggregates, in the database - rather than shipping the rows out and
tallying them in the browser keeps the payload small and the totals honest: a
client-side count is only ever as complete as the page limit that fetched it.

Everything performance related reads the `vw_pt_*` views, the same surface the
reports bind to, so a figure on the dashboard and the same figure on a report
cannot disagree.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from database import get_db
from helpers import assist
from models.method_model import (
    RESULT_FORM_HIV_EID,
    RESULT_FORM_HIV_VL,
    RESULT_FORM_TB_XPERT_ULTRA,
    RESULT_FORM_TB_XPERT_XDR,
)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

# the result table behind each form, and what to call it on screen
RESULT_TABLES = [
    (RESULT_FORM_TB_XPERT_ULTRA, "tb_xpert_ultra_results", "TB Xpert Ultra"),
    (RESULT_FORM_TB_XPERT_XDR, "tb_xpert_xdr_results", "TB Xpert XDR"),
    (RESULT_FORM_HIV_VL, "hiv_vl_results", "HIV-1 Viral Load"),
    (RESULT_FORM_HIV_EID, "hiv_eid_results", "HIV-1 EID"),
]

STATUS_NAMES = {
    assist.STATUS_DRAFT: "Draft",
    assist.STATUS_SUBMITTED: "Submitted",
    assist.STATUS_UNDER_REVIEW: "Under Review",
    assist.STATUS_APPROVED: "Approved",
    assist.STATUS_REJECTED: "Rejected",
}

# the grades a sample can be given, in the order they belong on a chart
GRADE_ORDER = [
    assist.GRADE_ACCEPTABLE,
    assist.GRADE_WARNING,
    assist.GRADE_UNACCEPTABLE,
    assist.GRADE_NOT_EVALUATED,
]


async def _rows(db, sql, params=None):
    result = await db.execute(text(sql), params or {})
    return [dict(row) for row in result.mappings().all()]


def _percent(part, whole):
    if not whole:
        return 0.0
    return round((part / whole) * 100, 1)


def _score(value):
    """A stored score is a proportion; the dashboard shows it as a percentage"""
    if value is None:
        return None
    return round(float(value) * 100, 1)


@router.get("/summary")
async def get_dashboard_summary(
    lab_id: Optional[int] = Query(
        default=None,
        description=(
            "Scopes the whole dashboard to one laboratory. A lab user passes "
            "its own id; provider staff leave it off to see the whole scheme."
        ),
    ),
    db: AsyncSession = Depends(get_db),
):
    """Every headline figure, distribution and trend the dashboard shows."""
    scoped = lab_id is not None
    params = {"lab_id": lab_id}

    # the filter every performance query shares. A laboratory sees its own
    # standing; provider staff see the scheme.
    only_lab = "WHERE lab_id = :lab_id" if scoped else ""
    and_lab = "AND lab_id = :lab_id" if scoped else ""

    # ---------------------------------------------------------- participation
    laboratories = await _rows(
        db, "SELECT status_id, count(*) AS n FROM laboratorys GROUP BY 1"
    )
    lab_counts = {row["status_id"]: row["n"] for row in laboratories}

    cycles = await _rows(
        db,
        """
        SELECT cs.id, cs.name, count(c.id) AS n
        FROM pt_cycle_statuses cs
        LEFT JOIN pt_cycles c ON c.pt_cyle_status_id = cs.id
        GROUP BY 1, 2
        ORDER BY 1
        """,
    )

    enrollments = await _rows(
        db,
        f"""
        SELECT status_id, count(*) AS n
        FROM enrollments
        {'WHERE lab_id = :lab_id' if scoped else ''}
        GROUP BY 1
        """,
        params,
    )
    enrollment_counts = {row["status_id"]: row["n"] for row in enrollments}

    # ---------------------------------------------------------------- results
    # one row per form per status, across the four result tables
    union = " UNION ALL ".join(
        f"""SELECT '{form}' AS result_form, status_id, count(*) AS n
            FROM {table}
            {'WHERE lab_id = :lab_id' if scoped else ''}
            GROUP BY 1, 2"""
        for form, table, _ in RESULT_TABLES
    )
    result_rows = await _rows(db, union, params)

    by_form = {form: {} for form, _, _ in RESULT_TABLES}
    for row in result_rows:
        by_form[row["result_form"]][row["status_id"]] = row["n"]

    result_form_list = []
    results_total = 0
    awaiting_review = 0

    for form, _, label in RESULT_TABLES:
        counts = by_form[form]
        total = sum(counts.values())
        pending = counts.get(assist.STATUS_SUBMITTED, 0) + counts.get(
            assist.STATUS_UNDER_REVIEW, 0
        )
        results_total += total
        awaiting_review += pending

        result_form_list.append(
            {
                "resultForm": form,
                "label": label,
                "total": total,
                "draft": counts.get(assist.STATUS_DRAFT, 0),
                "submitted": counts.get(assist.STATUS_SUBMITTED, 0),
                "underReview": counts.get(assist.STATUS_UNDER_REVIEW, 0),
                "approved": counts.get(assist.STATUS_APPROVED, 0),
                "rejected": counts.get(assist.STATUS_REJECTED, 0),
                "awaitingReview": pending,
            }
        )

    # ------------------------------------------------------------ performance
    standing = await _rows(
        db,
        f"""
        SELECT overall_performance, count(*) AS n, avg(percent_score) AS avg_score
        FROM vw_pt_enrollment_performance
        {only_lab}
        GROUP BY 1
        """,
        params,
    )

    satisfactory = 0
    unsatisfactory = 0
    not_evaluated = 0
    for row in standing:
        if row["overall_performance"] == assist.PERFORMANCE_SATISFACTORY:
            satisfactory = row["n"]
        elif row["overall_performance"] == assist.PERFORMANCE_UNSATISFACTORY:
            unsatisfactory = row["n"]
        else:
            not_evaluated += row["n"]

    scored_total = satisfactory + unsatisfactory + not_evaluated

    overall = await _rows(
        db,
        f"""
        SELECT avg(percent_score) AS avg_score,
               count(DISTINCT pt_cycle_id) AS rounds,
               count(DISTINCT lab_id) AS labs
        FROM vw_pt_enrollment_performance
        {only_lab}
        """,
        params,
    )
    overall = overall[0] if overall else {}

    # ------------------------------------------------------------- the grades
    grades = await _rows(
        db,
        f"""
        SELECT grade, count(*) AS n
        FROM vw_pt_result_evaluation
        {only_lab}
        GROUP BY 1
        """,
        params,
    )
    grade_counts = {row["grade"]: row["n"] for row in grades}
    graded_total = sum(grade_counts.values())

    grade_list = [
        {
            "grade": grade,
            "count": grade_counts.get(grade, 0),
            "percent": _percent(grade_counts.get(grade, 0), graded_total),
        }
        for grade in GRADE_ORDER
    ]

    # --------------------------------------------------------- by scheme
    scheme_list = await _rows(
        db,
        f"""
        SELECT scheme_name,
               count(*) AS participants,
               count(*) FILTER (WHERE overall_performance = 'Satisfactory')
                   AS satisfactory,
               count(*) FILTER (WHERE overall_performance = 'Unsatisfactory')
                   AS unsatisfactory,
               avg(percent_score) AS avg_score
        FROM vw_pt_enrollment_performance
        {only_lab}
        GROUP BY 1
        ORDER BY 1
        """,
        params,
    )
    for row in scheme_list:
        row["avgScore"] = _score(row.pop("avg_score"))
        row["satisfactoryRate"] = _percent(row["satisfactory"], row["participants"])
        row["scheme"] = row.pop("scheme_name")

    # -------------------------------------------------- by round, over time
    cycle_list = await _rows(
        db,
        f"""
        SELECT pt_cycle_id, cycle_code, cycle_name, scheme_name, report_date,
               count(*) AS participants,
               count(*) FILTER (WHERE overall_performance = 'Satisfactory')
                   AS satisfactory,
               count(*) FILTER (WHERE overall_performance = 'Unsatisfactory')
                   AS unsatisfactory,
               avg(percent_score) AS avg_score
        FROM vw_pt_enrollment_performance
        {only_lab}
        GROUP BY 1, 2, 3, 4, 5
        ORDER BY report_date, cycle_code
        """,
        params,
    )
    for row in cycle_list:
        row["avgScore"] = _score(row.pop("avg_score"))
        row["satisfactoryRate"] = _percent(row["satisfactory"], row["participants"])
        row["ptCycleId"] = row.pop("pt_cycle_id")
        row["cycleCode"] = row.pop("cycle_code")
        row["cycleName"] = row.pop("cycle_name")
        row["scheme"] = row.pop("scheme_name")
        row["reportDate"] = row.pop("report_date")

    # ------------------------------------------------------------- by method
    method_list = await _rows(
        db,
        f"""
        SELECT method_name, result_form,
               count(*) AS participants,
               count(*) FILTER (WHERE overall_performance = 'Satisfactory')
                   AS satisfactory,
               avg(percent_score) AS avg_score
        FROM vw_pt_enrollment_performance
        {only_lab}
        GROUP BY 1, 2
        ORDER BY participants DESC, 1
        """,
        params,
    )
    for row in method_list:
        row["avgScore"] = _score(row.pop("avg_score"))
        row["satisfactoryRate"] = _percent(row["satisfactory"], row["participants"])
        row["method"] = row.pop("method_name")
        row["resultForm"] = row.pop("result_form")

    # ------------------------------------------------- where the labs are
    # geography is about the network, so it is not scoped to one laboratory
    province_list = await _rows(
        db,
        """
        SELECT p.name AS province, count(l.id) AS laboratories
        FROM provinces p
        JOIN laboratorys l ON l.province_id = p.id
        WHERE l.status_id = :approved
        GROUP BY 1
        ORDER BY 2 DESC, 1
        """,
        {"approved": assist.STATUS_APPROVED},
    )

    province_scores = await _rows(
        db,
        """
        SELECT province_name AS province,
               count(*) AS participants,
               avg(percent_score) AS avg_score
        FROM vw_pt_enrollment_performance
        GROUP BY 1
        """,
    )
    scores_by_province = {
        row["province"]: (row["participants"], _score(row["avg_score"]))
        for row in province_scores
    }

    for row in province_list:
        participants, avg_score = scores_by_province.get(row["province"], (0, None))
        row["participants"] = participants
        row["avgScore"] = avg_score

    # an unquoted alias comes back lower cased, so the names the client reads
    # are set here rather than in the SELECT
    lab_type_list = await _rows(
        db,
        """
        SELECT t.name AS lab_type, count(l.id) AS laboratories
        FROM lab_types t
        JOIN laboratorys l ON l.lab_type_id = t.id
        WHERE l.status_id = :approved
        GROUP BY 1
        ORDER BY 2 DESC, 1
        """,
        {"approved": assist.STATUS_APPROVED},
    )
    for row in lab_type_list:
        row["labType"] = row.pop("lab_type")

    # ------------------------------------------- how each participant stood
    participant_list = await _rows(
        db,
        f"""
        SELECT enrollment_id, lab_code, lab_name, cycle_code, scheme_name,
               method_name, report_date, percent_score_display,
               total_score, max_score, overall_performance,
               acceptable_count, warning_count, unacceptable_count,
               not_reported_count, report_number
        FROM vw_pt_enrollment_performance
        {only_lab}
        ORDER BY report_date DESC, percent_score, lab_code
        LIMIT 100
        """,
        params,
    )
    for row in participant_list:
        row["enrollmentId"] = row.pop("enrollment_id")
        row["labCode"] = row.pop("lab_code")
        row["labName"] = row.pop("lab_name")
        row["cycleCode"] = row.pop("cycle_code")
        row["scheme"] = row.pop("scheme_name")
        row["method"] = row.pop("method_name")
        row["reportDate"] = row.pop("report_date")
        row["percentScore"] = (
            float(row.pop("percent_score_display"))
            if row["percent_score_display"] is not None
            else None
        )
        row["totalScore"] = row.pop("total_score")
        row["maxScore"] = row.pop("max_score")
        row["performance"] = row.pop("overall_performance")
        row["acceptable"] = row.pop("acceptable_count")
        row["warning"] = row.pop("warning_count")
        row["unacceptable"] = row.pop("unacceptable_count")
        row["notReported"] = row.pop("not_reported_count")
        row["reportNumber"] = row.pop("report_number")

    # --------------------------------------------- rounds still to be scored
    open_cycles = await _rows(
        db,
        f"""
        SELECT c.id AS pt_cycle_id, c.code AS cycle_code, c.name AS cycle_name,
               s.name AS scheme, cs.name AS status,
               c.closing_date, c.reports_availability_date,
               count(DISTINCT e.id) AS enrolments
        FROM pt_cycles c
        JOIN schemes s ON s.id = c.scheme_id
        JOIN pt_cycle_statuses cs ON cs.id = c.pt_cyle_status_id
        LEFT JOIN enrollments e ON e.pt_cycle_id = c.id {and_lab}
        WHERE c.pt_cyle_status_id < :closed
        GROUP BY 1, 2, 3, 4, 5, 6, 7
        ORDER BY c.reports_availability_date
        """,
        {**params, "closed": assist.PT_CYCLE_CLOSED},
    )
    for row in open_cycles:
        row["ptCycleId"] = row.pop("pt_cycle_id")
        row["cycleCode"] = row.pop("cycle_code")
        row["cycleName"] = row.pop("cycle_name")
        row["closingDate"] = row.pop("closing_date")
        row["reportDate"] = row.pop("reports_availability_date")

    return {
        "scope": "laboratory" if scoped else "provider",
        "labId": lab_id,
        "headline": {
            "laboratories": {
                "total": sum(lab_counts.values()),
                "approved": lab_counts.get(assist.STATUS_APPROVED, 0),
                "pending": lab_counts.get(assist.STATUS_SUBMITTED, 0)
                + lab_counts.get(assist.STATUS_UNDER_REVIEW, 0),
                "rejected": lab_counts.get(assist.STATUS_REJECTED, 0),
            },
            "ptCycles": {
                "total": sum(row["n"] for row in cycles),
                "statusList": [
                    {"status": row["name"], "count": row["n"]} for row in cycles
                ],
            },
            "enrolments": {
                "total": sum(enrollment_counts.values()),
                "accepted": enrollment_counts.get(assist.STATUS_APPROVED, 0),
                "pending": enrollment_counts.get(assist.STATUS_SUBMITTED, 0)
                + enrollment_counts.get(assist.STATUS_UNDER_REVIEW, 0),
            },
            "results": {
                "total": results_total,
                "awaitingReview": awaiting_review,
            },
            "rounds": {
                "scored": overall.get("rounds") or 0,
                "participantsScored": scored_total,
                "laboratoriesScored": overall.get("labs") or 0,
            },
        },
        "performance": {
            "satisfactory": satisfactory,
            "unsatisfactory": unsatisfactory,
            "notEvaluated": not_evaluated,
            "scored": scored_total,
            "satisfactoryRate": _percent(satisfactory, scored_total),
            "averageScore": _score(overall.get("avg_score")),
            "gradedAttributes": graded_total,
        },
        "gradeList": grade_list,
        "resultFormList": result_form_list,
        "schemeList": scheme_list,
        "cycleList": cycle_list,
        "methodList": method_list,
        "provinceList": province_list,
        "labTypeList": lab_type_list,
        "participantList": participant_list,
        "openCycleList": open_cycles,
    }
