from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from database import Base


# ---------- SQLAlchemy Models ----------
class FacilityDB(Base):
    """A health facility from Zambia's Master Facility List (MFL).

    Reference data, imported from the MoH export - see scripts/import_facilities.py
    and migration 012. A Zambian user picks their facility from this list at
    sign up; the lab they later register inherits the facility's province and
    district.
    """

    __tablename__ = "facilities"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # identifiers from the MFL
    mfl_code = Column(Integer, nullable=True, index=True)
    dhis2_uid = Column(String, nullable=True)
    hims_code = Column(String, nullable=True)

    name = Column(String, nullable=False)

    # location: the MFL text, plus resolved reference keys where the name matched
    province_name = Column(String, nullable=True)
    district_name = Column(String, nullable=True)
    province_id = Column(Integer, ForeignKey("provinces.id"), nullable=True)
    district_id = Column(Integer, ForeignKey("districts.id"), nullable=True)
    constituency = Column(String, nullable=True)
    ward = Column(String, nullable=True)
    zone = Column(String, nullable=True)
    location = Column(String, nullable=True)

    # classification
    type = Column(String, nullable=True)
    ownership = Column(String, nullable=True)
    ownership_type = Column(String, nullable=True)
    operational_status = Column(String, nullable=True)

    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)

    # resolved reference rows, loaded only when asked
    province = relationship("ProvinceDB", lazy="raise")
    district = relationship("DistrictDB", lazy="raise")


# ---------- Pydantic Schemas ----------
class Facility(BaseModel):
    """A facility as the sign-up picker shows it."""

    id: int
    mfl_code: Optional[int] = None
    name: str
    province_name: Optional[str] = None
    district_name: Optional[str] = None
    province_id: Optional[int] = None
    district_id: Optional[int] = None
    type: Optional[str] = None
    ownership: Optional[str] = None
    location: Optional[str] = None

    class Config:
        orm_mode = True
