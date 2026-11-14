"""Audit logging for laboratory result submissions.

Result submission needs no approval: a lab may submit, and resubmit, until the
round's result submission due date. Every submission is recorded in
result_submissions so there is a clear, queryable trail of who submitted what
and when (see migration 021).
"""
from sqlalchemy import text


async def log_result_submission(db, result_form: str, result, submitted_by: str):
    """Record one submission of a result sheet. `result` is the ORM result row;
    the running submission number is derived from how many are already logged."""
    used = (
        await db.execute(
            text(
                "SELECT count(*) FROM result_submissions "
                "WHERE result_form = :f AND result_id = :r"
            ),
            {"f": result_form, "r": result.id},
        )
    ).scalar() or 0

    await db.execute(
        text(
            "INSERT INTO result_submissions "
            "(result_form, result_id, lab_id, pt_cycle_id, scheme_id, "
            " method_sample_id, submission_no, submitted_by) "
            "VALUES (:f, :r, :lab, :cyc, :sch, :samp, :no, :by)"
        ),
        {
            "f": result_form,
            "r": result.id,
            "lab": getattr(result, "lab_id", None),
            "cyc": getattr(result, "pt_cycle_id", None),
            "sch": getattr(result, "scheme_id", None),
            "samp": getattr(result, "method_sample_id", None),
            "no": used + 1,
            "by": submitted_by,
        },
    )
