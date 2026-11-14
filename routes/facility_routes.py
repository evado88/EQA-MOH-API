from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional

from database import get_db
from models.facility_model import Facility, FacilityDB

router = APIRouter(prefix="/facilities", tags=["Facilities"])


@router.get("/search", response_model=List[Facility])
async def search_facilities(
    province_id: Optional[int] = Query(default=None),
    q: Optional[str] = Query(default=None, description="name contains"),
    limit: int = Query(default=50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    """Facilities for the sign-up picker.

    The MFL is large (thousands of rows), so the picker narrows by province and
    a name search rather than shipping the whole list. With neither filter it
    still returns the first `limit` facilities by name, so the control has
    something to show before the user types.
    """
    query = select(FacilityDB)

    if province_id is not None:
        query = query.where(FacilityDB.province_id == province_id)

    if q:
        like = f"%{q.strip().lower()}%"
        query = query.where(FacilityDB.name.ilike(like))

    query = query.order_by(FacilityDB.name).limit(limit)

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/id/{facility_id}", response_model=Facility)
async def get_facility(facility_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(FacilityDB).where(FacilityDB.id == facility_id))
    return result.scalars().first()
