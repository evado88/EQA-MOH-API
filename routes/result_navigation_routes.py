from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

from database import get_db
from helpers import assist

router = APIRouter(prefix="/result-navigation", tags=["ResultNavigation"])

# result form -> result table. Fixed map, so the form name never reaches SQL raw.
RESULT_TABLES = {
    "tb_xpert_ultra": "tb_xpert_ultra_results",
    "tb_xpert_xdr": "tb_xpert_xdr_results",
    "hiv_vl": "hiv_vl_results",
    "hiv_eid": "hiv_eid_results",
    "bacteriology": "bacteriology_results",
}

# a sample's result counts as "entered" once it has been submitted
ENTERED_STATUSES = (assist.STATUS_SUBMITTED, assist.STATUS_APPROVED)


@router.get("")
async def result_navigation(
    result_form: str = Query(...),
    result_id: int = Query(...),
    db: AsyncSession = Depends(get_db),
):
    """Given one result sheet, returns every sample in the same panel (its
    enrolment) with entry status, plus progress and the next sample to do -
    so the lab can move A1 -> A2 -> ... and see '3 of 5 entered'."""
    table = RESULT_TABLES.get(result_form)
    if not table:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown result form. Expected one of {', '.join(RESULT_TABLES)}",
        )

    rows = (
        await db.execute(
            text(
                f"SELECT r.id, r.method_sample_id, ms.name AS sample_name, "
                f"       r.status_id, st.status_name "
                f"FROM {table} r "
                f"JOIN method_samples ms ON ms.id = r.method_sample_id "
                f"JOIN list_statuses st ON st.id = r.status_id "
                f"WHERE r.enrollment_id = "
                f"      (SELECT enrollment_id FROM {table} WHERE id = :rid) "
                f"ORDER BY ms.name"
            ),
            {"rid": result_id},
        )
    ).mappings().all()

    if not rows:
        raise HTTPException(status_code=404, detail="Result sheet not found")

    samples = []
    for r in rows:
        entered = r["status_id"] in ENTERED_STATUSES
        samples.append(
            {
                "id": r["id"],
                "method_sample_id": r["method_sample_id"],
                "sample_name": r["sample_name"],
                "status_id": r["status_id"],
                "status_name": r["status_name"],
                "entered": entered,
                "is_current": r["id"] == result_id,
            }
        )

    total = len(samples)
    entered = sum(1 for s in samples if s["entered"])
    ids = [s["id"] for s in samples]
    idx = ids.index(result_id) if result_id in ids else 0

    # the next sample in order (after the current), wrapping if needed
    next_id = ids[idx + 1] if idx + 1 < total else None
    prev_id = ids[idx - 1] if idx > 0 else None

    # the next sample still needing results (searched after current, then wraps)
    order = ids[idx + 1:] + ids[:idx]
    by_id = {s["id"]: s for s in samples}
    next_pending_id = next((i for i in order if not by_id[i]["entered"]), None)

    return {
        "total": total,
        "entered": entered,
        "pending": total - entered,
        "current_id": result_id,
        "current_index": idx,
        "next_id": next_id,
        "prev_id": prev_id,
        "next_pending_id": next_pending_id,
        "samples": samples,
    }
