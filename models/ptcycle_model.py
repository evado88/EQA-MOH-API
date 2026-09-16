from sqlalchemy import Column, Float, Integer, String, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel,  Field
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
    shipping_date = Column(Date, nullable=False)
    reports_availability_date = Column(Date, nullable=False)
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
    # Not asked for when a cycle is created - a new cycle is always Upcoming -
    # and not changed by an edit either. It moves one step at a time through
    # /pt-cycles/status/{id}, which is where the side effects of each step live.
    pt_cyle_status_id: Optional[int] = Field(
        default=None,
        description="Set by the server. A new PT Cycle always starts as Upcoming",
    )
    closing_date: date = Field(
        ...,
        description="Closing Date must be provided",
    )
    shipping_date: date = Field(
        ...,
        description="Shipping Date must be provided",
    )
    reports_availability_date: date = Field(
        ...,
        description="Reports Availability Date must be provided",
    )
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
