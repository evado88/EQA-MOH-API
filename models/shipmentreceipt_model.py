from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey, UniqueConstraint
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import date, datetime
from database import Base

# swabs travel at 2-8 degrees; a reading far outside that is a typing slip
# rather than a cold chain excursion, so the field is bounded but generously
RECEIPT_TEMPERATURE_MIN = -30.0
RECEIPT_TEMPERATURE_MAX = 50.0


# ---------- SQLAlchemy Models ----------
class ShipmentReceiptDB(Base):
    """A lab's receipt details for one shipment in one cycle.

    Samples A-E arrive together in a single package, so the arrival details are
    recorded once per (pt_cycle_id, lab_id). The per-sample suitability
    judgement lives on sample_receipts instead.
    """

    __tablename__ = "shipment_receipts"
    __table_args__ = (
        UniqueConstraint("pt_cycle_id", "lab_id", name="uq_shipment_receipts_cycle_lab"),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)

    date_received = Column(Date, nullable=True)
    temperature_c = Column(Float, nullable=True)
    comments = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


# ---------- Pydantic Schemas ----------
class ShipmentReceipt(BaseModel):
    id: Optional[int] = None
    pt_cycle_id: int
    lab_id: int
    date_received: Optional[date] = None
    temperature_c: Optional[float] = None
    comments: Optional[str] = None
    created_by: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True


class ParamShipmentReceipt(BaseModel):
    """Posted by a lab to record (or correct) how a shipment arrived, before
    entering results for any of its samples."""

    user_id: int = Field(..., ge=1)
    pt_cycle_id: int = Field(..., ge=1)
    lab_id: int = Field(..., ge=1)

    date_received: date = Field(..., description="Date the shipment was received")
    temperature_c: float = Field(..., description="Temperature on receipt (°C)")
    comments: Optional[str] = None

    @validator("temperature_c")
    def check_temperature(cls, value):
        if value is not None and not (
            RECEIPT_TEMPERATURE_MIN <= value <= RECEIPT_TEMPERATURE_MAX
        ):
            raise ValueError(
                f"The temperature on receipt must be between "
                f"{RECEIPT_TEMPERATURE_MIN} and {RECEIPT_TEMPERATURE_MAX} °C"
            )
        return value
