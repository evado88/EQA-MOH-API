from sqlalchemy import Column, Float, Integer, String, Date, DateTime, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field, root_validator
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.scheme_model import Scheme
from models.ptcyclestatus_model import PTCycleStatus


# ---------- SQLAlchemy Models ----------
class PTCycleDB(Base):
    __tablename__ = "pt_cycles"
    # a cycle code is only unique within its scheme
    __table_args__ = (UniqueConstraint("scheme_id", "code", name="uq_pt_cycles_scheme_code"),)

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # properties
    code = Column(String, nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)
    effective_date = Column(Date, nullable=False)
    pt_cyle_status_id = Column(Integer, ForeignKey("pt_cycle_statuses.id"), nullable=False)
    closing_date = Column(Date, nullable=False)
    # planned sample shipping date; shipping itself is a manual action
    shipping_date = Column(Date, nullable=True)
    # test event window and result submission deadline
    test_event_start_date = Column(Date, nullable=True)
    test_event_stop_date = Column(Date, nullable=True)
    result_submission_due_date = Column(Date, nullable=True)
    reports_availability_date = Column(Date, nullable=False)
    # free-text notes for the round
    notes = Column(String, nullable=True)
    # the two manual gates whose status transitions carry side effects
    samples_shipped = Column(Boolean, nullable=False, default=False)
    samples_shipped_at = Column(DateTime(timezone=True), nullable=True)
    reports_published = Column(Boolean, nullable=False, default=False)
    reports_published_at = Column(DateTime(timezone=True), nullable=True)
    # approval
    # user
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    # status
    status_id = Column(Integer, ForeignKey("list_statuses.id"), nullable=False)
    # stage
    stage_id = Column(Integer, ForeignKey("list_stages.id"), nullable=False)

    approval_levels = Column(Integer, nullable=False)

    review1_at = Column(DateTime(timezone=True), nullable=True)
    review1_by = Column(String, nullable=True)
    review1_comments = Column(String, nullable=True)

    review2_at = Column(DateTime(timezone=True), nullable=True)
    review2_by = Column(String, nullable=True)
    review2_comments = Column(String, nullable=True)

    review3_at = Column(DateTime(timezone=True), nullable=True)
    review3_by = Column(String, nullable=True)
    review3_comments = Column(String, nullable=True)

    # service columns
    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)
    
    #relationships
    user = relationship("UserDB", back_populates="ptcycle", lazy='raise')
    status = relationship("StatusDB", back_populates="ptcycle", lazy='raise')
    stage = relationship("StageDB", back_populates="ptcycle", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="ptcycle", lazy='raise')
    ptcyclestatus = relationship("PTCycleStatusDB", back_populates="ptcycle", lazy='raise')

    #links
    enrollment = relationship("EnrollmentDB", back_populates="ptcycle", lazy='raise')
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="ptcycle", lazy='raise')
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="ptcycle", lazy='raise')
    hivvlresult = relationship("HIVVLResultDB", back_populates="ptcycle", lazy='raise')
    hiveidresult = relationship("HIVEIDResultDB", back_populates="ptcycle", lazy='raise')
    bacteriologyresult = relationship("BacteriologyResultDB", back_populates="ptcycle", lazy='raise')

# ---------- Pydantic Schemas ----------
class PTCycle(BaseModel):
    # id
    id: Optional[int] = None

    # name
    name: str = Field(
        ...,
        min_length=2,
        description="Name must be between at least 2 characters",
    )
    description: Optional[str] = None

    # properties
    code: str = Field(
        ...,
        description="Code must be provided",
    )
    scheme_id: int = Field(
        ...,
        description="Scheme must be provided",
    )
    effective_date: date = Field(
        ...,
        description="Effective Date must be provided",
    )
    # Not chosen by the caller: the lifecycle status is derived from the
    # schedule dates and the two manual gates (samples shipped / reports
    # published). A new cycle is always Upcoming; an edit never moves it.
    pt_cyle_status_id: Optional[int] = Field(
        default=None,
        description="Set by the server. A new PT Cycle always starts as Upcoming",
    )
    closing_date: date = Field(
        ...,
        description="Enrollment closing date must be provided",
    )
    shipping_date: Optional[date] = Field(
        default=None,
        description="Planned sample shipping date",
    )
    test_event_start_date: Optional[date] = None
    test_event_stop_date: Optional[date] = None
    result_submission_due_date: Optional[date] = None
    reports_availability_date: date = Field(
        ...,
        description="Report availability date must be provided",
    )
    notes: Optional[str] = None
    samples_shipped: Optional[bool] = None
    samples_shipped_at: Optional[datetime] = None
    reports_published: Optional[bool] = None
    reports_published_at: Optional[datetime] = None
    # approval
    # user
    user_id: int

    # stage
    stage_id: int = Field(..., ge=1, le=8, description="Stage must be between 1 and 8")

    # status
    status_id: int = Field(
        ..., ge=1, description="Status must be greater than or equal to 1"
    )


    approval_levels: int = Field(
        ..., ge=1, le=3, description="Approval levels must be between 1 and 3"
    )

    review1_at: Optional[datetime] = None
    review1_by: Optional[str] = None
    review1_comments: Optional[str] = None

    review2_at: Optional[datetime] = None
    review2_by: Optional[str] = None
    review2_comments: Optional[str] = None

    review3_at: Optional[datetime] = None
    review3_by: Optional[str] = None
    review3_comments: Optional[str] = None

    # linkage
    created_at: Optional[datetime] = None
    created_by: Optional[str]  = None
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] = None

    class Config:
        orm_mode = True     

class PTCycleWithDetail(PTCycle):
    stage: Stage
    status: Status
    user: User
    
    scheme: Scheme
    ptcyclestatus: PTCycleStatus

class ParamPTCycleEdit(BaseModel):
    ptcycle: Optional[PTCycleWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    ptcyclestatusList: Optional[List[PTCycleStatus]] = []

    class Config:
        orm_mode = True

class ParamPTCycleSave(BaseModel):
    """Posted by an administrator to create or edit a round.

    Captures the full schedule of dates; the lifecycle status is derived from
    them. Optionally copies all accepted participants from an earlier round of
    the same scheme (they are enrolled automatically and emailed).
    """

    scheme_id: int = Field(..., ge=1, description="Scheme must be provided")
    code: str = Field(..., min_length=1, description="Code must be provided")

    effective_date: date = Field(..., description="Enrollment opening date")
    closing_date: date = Field(..., description="Enrollment closing date")
    shipping_date: date = Field(..., description="Sample shipping date")
    test_event_start_date: date = Field(..., description="Test event start date")
    test_event_stop_date: date = Field(..., description="Test event stop date")
    result_submission_due_date: date = Field(..., description="Result submission due date")
    reports_availability_date: date = Field(..., description="Report availability date")

    notes: Optional[str] = None
    user_id: int = Field(..., ge=1, description="User must be provided")

    # copy all accepted participants from this earlier round of the same scheme
    reuse_from_pt_cycle_id: Optional[int] = Field(default=None, ge=1)

    @root_validator
    def check_date_order(cls, values):
        order = [
            ("enrollment opening", values.get("effective_date")),
            ("enrollment closing", values.get("closing_date")),
            ("sample shipping", values.get("shipping_date")),
            ("test event start", values.get("test_event_start_date")),
            ("test event stop", values.get("test_event_stop_date")),
            ("result submission due", values.get("result_submission_due_date")),
            ("report availability", values.get("reports_availability_date")),
        ]
        present = [(name, d) for name, d in order if d is not None]
        for (prev_name, prev), (name, cur) in zip(present, present[1:]):
            if cur < prev:
                raise ValueError(
                    f"The {name} date cannot be before the {prev_name} date"
                )
        return values


class ParamPTCycleAction(BaseModel):
    """Posted for a manual step - marking samples shipped, or publishing
    reports."""

    user_id: int = Field(..., ge=1, description="User must be provided")
    comments: Optional[str] = None


# the dates an administrator may extend, with their labels
EXTENDABLE_DATE_FIELDS = {
    "closing_date": "Enrollment closing date",
    "result_submission_due_date": "Result submission due date",
}


class ParamPTCycleExtend(BaseModel):
    """Posted to extend a round's enrollment closing or result submission due
    date. Moving the date forward re-opens the window (gating is live)."""

    user_id: int = Field(..., ge=1, description="User must be provided")
    field: str = Field(..., description="closing_date or result_submission_due_date")
    new_date: date = Field(..., description="The new (later) date")
    reason: Optional[str] = None


class PTCycleExtensionDB(Base):
    """Audit trail of date extensions on a round."""

    __tablename__ = "pt_cycle_extensions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    field = Column(String, nullable=False)
    field_label = Column(String, nullable=True)
    old_value = Column(Date, nullable=True)
    new_value = Column(Date, nullable=False)
    reason = Column(String, nullable=True)
    recipients_notified = Column(Integer, nullable=True, default=0)
    extended_by = Column(String, nullable=True)
    extended_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)


class PTCycleExtension(BaseModel):
    id: int
    pt_cycle_id: int
    field: str
    field_label: Optional[str] = None
    old_value: Optional[date] = None
    new_value: date
    reason: Optional[str] = None
    recipients_notified: Optional[int] = 0
    extended_by: Optional[str] = None
    extended_at: Optional[datetime] = None

    class Config:
        orm_mode = True


class PTCycleExtendResult(BaseModel):
    succeeded: bool
    message: str
    pt_cycle_id: int
    field: str
    new_date: date
    recipients_notified: int


class PTCycleReminderResult(BaseModel):
    succeeded: bool
    cycles_checked: int
    reminders_sent: int
    details: List[str] = []


class ParamPTCycleStatusChange(BaseModel):
    """Posted by an administrator moving a cycle to its next status."""

    pt_cyle_status_id: int = Field(
        ..., ge=1, description="The status to move the cycle to must be provided"
    )
    user_id: int = Field(..., ge=1, description="User must be provided")
    comments: Optional[str] = None


class PTCycleStatusChangeResult(BaseModel):
    """What changing a cycle status produced."""

    succeeded: bool
    message: str
    pt_cycle_id: int
    pt_cyle_status_id: int
    enrollment_count: int = 0
    result_count: int = 0
