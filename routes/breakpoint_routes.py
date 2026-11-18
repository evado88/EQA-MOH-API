"""CLSI breakpoints: read and maintain the reference zone-diameter ranges.

These feed the expected-range column on the AST feedback report. They change
with each CLSI M100 edition, so they are maintained here rather than in code.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from database import get_db
from helpers import assist
from models.user_model import UserDB
from models.clsi_breakpoint_model import (
    METHOD_DISK_DIFFUSION,
    CLSIBreakpoint,
    CLSIBreakpointDB,
    SaveBreakpoints,
    SaveBreakpointsResult,
)

router = APIRouter(prefix="/clsi-breakpoints", tags=["CLSIBreakpoints"])


async def _get_admin_user(db: AsyncSession, user_id: int) -> UserDB:
    result = await db.execute(select(UserDB).where(UserDB.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=400, detail=f"The user with id '{user_id}' does not exist"
        )
    if not assist.is_admin_role(user.role_id):
        raise HTTPException(
            status_code=403,
            detail="You are not permitted to change the CLSI breakpoints",
        )
    return user


@router.get("/list", response_model=List[CLSIBreakpoint])
async def list_breakpoints(
    organism_group: Optional[str] = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    """The breakpoints, optionally for one organism group."""
    query = select(CLSIBreakpointDB).order_by(
        CLSIBreakpointDB.organism_group, CLSIBreakpointDB.antibiotic
    )
    if organism_group is not None:
        query = query.where(CLSIBreakpointDB.organism_group == organism_group)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/groups", response_model=List[str])
async def list_groups(db: AsyncSession = Depends(get_db)):
    """The organism groups that have breakpoints, for a filter."""
    result = await db.execute(
        select(CLSIBreakpointDB.organism_group)
        .distinct()
        .order_by(CLSIBreakpointDB.organism_group)
    )
    return [g for (g,) in result.all()]


@router.put("/save", response_model=SaveBreakpointsResult)
async def save_breakpoints(
    payload: SaveBreakpoints, db: AsyncSession = Depends(get_db)
):
    """Adds or updates breakpoints.

    Keyed on (organism group, antibiotic, method): an existing one is updated in
    place, a new combination is inserted. Saving through here marks the row
    verified, since a person has chosen its values.
    """
    user = await _get_admin_user(db, payload.user_id)

    saved = 0
    for bp in payload.breakpoints:
        method = bp.method or METHOD_DISK_DIFFUSION
        antibiotic = " ".join((bp.antibiotic or "").split()).upper()
        group = " ".join((bp.organism_group or "").split())
        if not antibiotic or not group:
            continue

        result = await db.execute(
            select(CLSIBreakpointDB).where(
                CLSIBreakpointDB.organism_group == group,
                CLSIBreakpointDB.antibiotic == antibiotic,
                CLSIBreakpointDB.method == method,
            )
        )
        row = result.scalars().first()
        if row is None:
            row = CLSIBreakpointDB(
                organism_group=group, antibiotic=antibiotic, method=method,
                created_by=user.email,
            )
            db.add(row)

        row.disk_content = bp.disk_content
        row.susceptible_min = bp.susceptible_min
        row.resistant_max = bp.resistant_max
        row.sdd_min = bp.sdd_min
        row.sdd_max = bp.sdd_max
        row.source = bp.source
        row.notes = bp.notes
        # saving by hand is the verification
        row.verified = True
        row.updated_by = user.email
        saved += 1

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to save the CLSI breakpoints: {e}"
        )

    return SaveBreakpointsResult(
        succeeded=True, message=f"{saved} breakpoint(s) saved.", saved=saved
    )
