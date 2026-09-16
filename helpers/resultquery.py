"""Queries the four result forms share.

The result routers are deliberate near-duplicates - one table per form, with
real typed columns - so anything that would otherwise be copied four times and
drift is written here once instead, parameterised by the form's model.
"""
from sqlalchemy import func
from sqlalchemy.future import select

from helpers import assist
from models.ptcycle_model import PTCycleDB

# a result counts as needing a decision from the moment the lab submits it
PENDING_STATUSES = (assist.STATUS_SUBMITTED, assist.STATUS_UNDER_REVIEW)


async def cycles_with_results(db, model, lab_id=None):
    """The rounds that have result sheets on this form, newest first.

    This is what the round picker on a result listing offers. It deliberately
    lists only rounds that actually have sheets: a round with nothing on it is
    not a round anybody wants to open, and offering it would make an empty
    listing look like a fault.
    """
    query = (
        select(
            PTCycleDB.id.label("pt_cycle_id"),
            PTCycleDB.code.label("cycle_code"),
            PTCycleDB.name.label("cycle_name"),
            PTCycleDB.effective_date,
            PTCycleDB.pt_cyle_status_id,
            func.count(model.id).label("result_count"),
            func.count(model.id)
            .filter(model.status_id.in_(PENDING_STATUSES))
            .label("pending_count"),
            func.count(model.id)
            .filter(model.status_id == assist.STATUS_APPROVED)
            .label("approved_count"),
            func.count(model.id)
            .filter(model.status_id == assist.STATUS_DRAFT)
            .label("draft_count"),
        )
        .join(model, model.pt_cycle_id == PTCycleDB.id)
        .group_by(
            PTCycleDB.id,
            PTCycleDB.code,
            PTCycleDB.name,
            PTCycleDB.effective_date,
            PTCycleDB.pt_cyle_status_id,
        )
        .order_by(PTCycleDB.effective_date.desc(), PTCycleDB.code.desc())
    )

    if lab_id is not None:
        query = query.where(model.lab_id == lab_id)

    result = await db.execute(query)

    cycles = []
    for row in result.mappings().all():
        cycle = dict(row)
        cycle["cycle_status"] = assist.PT_CYCLE_STATUS_NAMES.get(
            cycle.pop("pt_cyle_status_id")
        )
        # what the picker shows, built here so all four forms read alike
        cycle["label"] = f"{cycle['cycle_code']} - {cycle['cycle_name']}"
        cycles.append(cycle)

    return cycles
