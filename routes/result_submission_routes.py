from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from typing import Optional

from database import get_db

router = APIRouter(prefix="/result-submissions", tags=["ResultSubmissions"])


@router.get("")
async def list_result_submissions(
    result_form: Optional[str] = Query(default=None),
    result_id: Optional[int] = Query(default=None),
    pt_cycle_id: Optional[int] = Query(default=None),
    lab_id: Optional[int] = Query(default=None),
    limit: int = Query(default=500, ge=1, le=5000),
    db: AsyncSession = Depends(get_db),
):
    """The result-submission audit trail, newest first, optionally filtered by
    result sheet, cycle or lab."""
    clauses = []
    params = {"limit": limit}
    if result_form is not None:
        clauses.append("result_form = :result_form")
        params["result_form"] = result_form
    if result_id is not None:
        clauses.append("result_id = :result_id")
        params["result_id"] = result_id
    if pt_cycle_id is not None:
        clauses.append("pt_cycle_id = :pt_cycle_id")
        params["pt_cycle_id"] = pt_cycle_id
    if lab_id is not None:
        clauses.append("lab_id = :lab_id")
        params["lab_id"] = lab_id

    where = (" WHERE " + " AND ".join(clauses)) if clauses else ""
    result = await db.execute(
        text(
            "SELECT id, result_form, result_id, lab_id, pt_cycle_id, scheme_id, "
            "method_sample_id, submission_no, submitted_by, submitted_at "
            f"FROM result_submissions{where} ORDER BY submitted_at DESC, id DESC LIMIT :limit"
        ),
        params,
    )
    return [dict(row) for row in result.mappings().all()]
