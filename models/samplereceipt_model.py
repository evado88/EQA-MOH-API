from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey, UniqueConstraint
from pydantic import BaseModel, Field, root_validator
from typing import Optional
from datetime import date, datetime
from database import Base

CONDITION_SUITABLE = "Suitable"
CONDITION_NOT_SUITABLE = "Not suitable"
CONDITIONS = (CONDITION_SUITABLE, CONDITION_NOT_SUITABLE)


# ---------- SQLAlchemy Models ----------
class SampleReceiptDB(Base):
    """A lab's receipt details for one sample (A1, A2, ...) in one cycle.

    Shared across result forms; a result sheet and its receipt share the
    (pt_cycle_id, lab_id, method_sample_id) identity.
    """

    __tablename__ = "sample_receipts"
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id", name="uq_sample_receipts_sample"
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)
    method_sample_id = Column(Integer, ForeignKey("method_samples.id"), nullable=False)
    enrollment_id = Column(Integer, ForeignKey("enrollments.id"), nullable=True)

    date_received = Column(Date, nullable=True)
    condition = Column(String, nullable=True)
    temperature_c = Column(Float, nullable=True)
    comments = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


# ---------- Pydantic Schemas ----------
class SampleReceipt(BaseModel):
    id: Optional[int] = None
    pt_cycle_id: int
    lab_id: int
    method_sample_id: int
    enrollment_id: Optional[int] = None
    date_received: Optional[date] = None
    condition: Optional[str] = None
    temperature_c: Optional[float] = None
    comments: Optional[str] = None
    created_by: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True


class ParamSampleReceipt(BaseModel):
    """Posted by a lab to record (or correct) a sample's receipt details before
    entering results for that sample."""

    user_id: int = Field(..., ge=1)
    pt_cycle_id: int = Field(..., ge=1)
    lab_id: int = Field(..., ge=1)
    method_sample_id: int = Field(..., ge=1)

    date_received: date = Field(..., description="Date the sample was received")
    condition: str = Field(..., description=f"One of {CONDITIONS}")
    temperature_c: float = Field(..., description="Temperature on receipt (°C)")
    comments: Optional[str] = None

    @root_validator
    def check(cls, values):
        condition = values.get("condition")
        if condition not in CONDITIONS:
            raise ValueError(f"Condition must be one of {', '.join(CONDITIONS)}")
        if condition == CONDITION_NOT_SUITABLE and not (values.get("comments") or "").strip():
            raise ValueError("Please comment on why the sample is not suitable")
        return values
