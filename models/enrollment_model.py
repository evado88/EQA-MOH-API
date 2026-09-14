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
from models.laboratory_model import Laboratory
from models.service_model import Service
from models.method_model import Method
from models.ptcycle_model import PTCycle


# ---------- SQLAlchemy Models ----------
class EnrollmentDB(Base):
    __tablename__ = "enrollments"
    # a lab enrols for a given method once per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_id", name="uq_enrollments_cycle_lab_method"
        ),
    )

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # properties
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    # sample receipt - set by the lab once the shipped panel arrives
    samples_received_at = Column(DateTime(timezone=True), nullable=True)
    samples_received_by = Column(String, nullable=True)
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
    user = relationship("UserDB", back_populates="enrollment", lazy='raise')
    status = relationship("StatusDB", back_populates="enrollment", lazy='raise')
    stage = relationship("StageDB", back_populates="enrollment", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="enrollment", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="enrollment", lazy='raise')
    service = relationship("ServiceDB", back_populates="enrollment", lazy='raise')
    method = relationship("MethodDB", back_populates="enrollment", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="enrollment", lazy='raise')

    #links
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="enrollment", lazy='raise')

# ---------- Pydantic Schemas ----------
class Enrollment(BaseModel):
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
    scheme_id: int = Field(
        ...,
        description="Scheme must be provided",
    )
    lab_id: int = Field(
        ...,
        description="Laboratory must be provided",
    )
    service_id: int = Field(
        ...,
        description="Service must be provided",
    )
    method_id: int = Field(
        ...,
        description="Method must be provided",
    )
    pt_cycle_id: int = Field(
        ...,
        description="Cycle must be provided",
    )
    # sample receipt
    samples_received_at: Optional[datetime] = None
    samples_received_by: Optional[str] = None
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

class EnrollmentWithDetail(Enrollment):
    stage: Stage
    status: Status
    user: User
    
    scheme: Scheme
    laboratory: Laboratory
    service: Service
    method: Method
    ptcycle: PTCycle

class ParamEnrollmentEdit(BaseModel):
    enrollment: Optional[EnrollmentWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    methodList: Optional[List[Method]] = []
    ptcycleList: Optional[List[PTCycle]] = []

    class Config:
        orm_mode = True

class ParamEnrollmentApply(BaseModel):
    """Posted by a laboratory that wants to take part in an open PT cycle.

    The methods enrolled for are not chosen here - they are derived from the
    approved applications the lab already holds for the cycle's scheme.
    """

    pt_cycle_id: int = Field(..., ge=1, description="Cycle must be provided")
    lab_id: int = Field(..., ge=1, description="Laboratory must be provided")
    user_id: int = Field(..., ge=1, description="User must be provided")
    comments: Optional[str] = None


class ParamEnrollmentReceiveSamples(BaseModel):
    """Posted by a laboratory to confirm the shipped panel has arrived."""

    user_id: int = Field(..., ge=1, description="User must be provided")
    samples_received_at: Optional[datetime] = None
    comments: Optional[str] = None


class EnrollmentApplyResult(BaseModel):
    """What enrolling in a cycle produced."""

    succeeded: bool
    message: str
    pt_cycle_id: int
    lab_id: int
    enrollment_count: int
