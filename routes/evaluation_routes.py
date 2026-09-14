from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import text
from typing import List, Optional

from database import get_db
from helpers import assist
from models.evaluation_model import (
    PTEnrollmentPerformance,
    PTEnrollmentPerformanceDB,
    PTResultEvaluation,
    PTResultEvaluationDB,
    PTSampleStatistics,
    PTSampleStatisticsDB,
)

router = APIRouter(prefix="/evaluations", tags=["Evaluations"])


@router.get("/results", response_model=List[PTResultEvaluation])
async def list_result_evaluations(
    pt_cycle_id: Optional[int] = Query(default=None),
    lab_id: Optional[int] = Query(default=None),
    enrollment_id: Optional[int] = Query(default=None),
    grade: Optional[str] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """What each laboratory scored, sample by sample."""
    query = select(PTResultEvaluationDB).order_by(
        PTResultEvaluationDB.lab_id,
        PTResultEvaluationDB.method_sample_id,
        PTResultEvaluationDB.attribute,
    )

    if pt_cycle_id is not None:
        query = query.where(PTResultEvaluationDB.pt_cycle_id == pt_cycle_id)
    if lab_id is not None:
        query = query.where(PTResultEvaluationDB.lab_id == lab_id)
    if enrollment_id is not None:
        query = query.where(PTResultEvaluationDB.enrollment_id == enrollment_id)
    if grade is not None:
        query = query.where(PTResultEvaluationDB.grade == grade)

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/statistics", response_model=List[PTSampleStatistics])
async def list_sample_statistics(
    pt_cycle_id: Optional[int] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """The participant distribution behind each assigned value."""
    query = select(PTSampleStatisticsDB).order_by(
        PTSampleStatisticsDB.sample_group, PTSampleStatisticsDB.attribute
    )

    if pt_cycle_id is not None:
        query = query.where(PTSampleStatisticsDB.pt_cycle_id == pt_cycle_id)

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/performance", response_model=List[PTEnrollmentPerformance])
async def list_enrollment_performance(
    pt_cycle_id: Optional[int] = Query(default=None),
    lab_id: Optional[int] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """Each participant's overall standing for a round."""
    query = select(PTEnrollmentPerformanceDB).order_by(
        PTEnrollmentPerformanceDB.lab_id
    )

    if pt_cycle_id is not None:
        query = query.where(PTEnrollmentPerformanceDB.pt_cycle_id == pt_cycle_id)
    if lab_id is not None:
        query = query.where(PTEnrollmentPerformanceDB.lab_id == lab_id)

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/performance/lab/{lab_id}", response_model=List[PTEnrollmentPerformance])
async def list_lab_performance(lab_id: int, db: AsyncSession = Depends(get_db)):
    """One laboratory's history across every round it took part in."""
    result = await db.execute(
        select(PTEnrollmentPerformanceDB)
        .where(PTEnrollmentPerformanceDB.lab_id == lab_id)
        .order_by(PTEnrollmentPerformanceDB.pt_cycle_id.desc())
    )
    return result.scalars().all()


# the flat, typed views the reports bind to
REPORT_VIEWS = {
    "result-evaluation": "vw_pt_result_evaluation",
    "enrollment-performance": "vw_pt_enrollment_performance",
    "sample-summary": "vw_pt_sample_summary",
}


@router.get("/report/{view}")
async def read_report_view(
    view: str,
    provider_id: Optional[int] = Query(default=None),
    scheme_id: Optional[int] = Query(default=None),
    pt_cycle_id: Optional[int] = Query(default=None),
    lab_id: Optional[int] = Query(default=None),
    enrollment_id: Optional[int] = Query(default=None),
    limit: int = Query(default=500, le=5000),
    db: AsyncSession = Depends(get_db),
):
    """Reads one of the reporting views.

    These are the same views XtraReports binds to directly through its own
    connection; this endpoint exists so the web client can show the report
    data without a second data path.
    """
    table = REPORT_VIEWS.get(view)
    if not table:
        raise HTTPException(
            status_code=404,
            detail=(
                f"Unknown report view '{view}'. Available: "
                f"{', '.join(sorted(REPORT_VIEWS))}"
            ),
        )

    clauses = []
    params = {"limit": limit}

    if pt_cycle_id is not None:
        clauses.append("pt_cycle_id = :pt_cycle_id")
        params["pt_cycle_id"] = pt_cycle_id

    if scheme_id is not None:
        clauses.append("scheme_id = :scheme_id")
        params["scheme_id"] = scheme_id

    # the sample summary is per scheme, so it carries no provider column
    if provider_id is not None and view != "sample-summary":
        clauses.append("provider_id = :provider_id")
        params["provider_id"] = provider_id

    # the sample summary is an aggregate across labs, so it has neither a lab
    # nor an enrolment column
    if view != "sample-summary":
        if lab_id is not None:
            clauses.append("lab_id = :lab_id")
            params["lab_id"] = lab_id
        if enrollment_id is not None:
            clauses.append("enrollment_id = :enrollment_id")
            params["enrollment_id"] = enrollment_id

    where = (" WHERE " + " AND ".join(clauses)) if clauses else ""

    # the view name comes from the fixed map above, never from the caller
    result = await db.execute(
        text(f"SELECT * FROM {table}{where} LIMIT :limit"), params
    )
    return [dict(row) for row in result.mappings().all()]
