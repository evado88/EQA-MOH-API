from sqlalchemy import Column, Float, Integer, String, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel,  Field
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.laboratory_model import Laboratory
from models.scheme_model import Scheme
from models.service_model import Service
from models.method_model import Method


# ---------- SQLAlchemy Models ----------
class ApplicationsDB(Base):
    __tablename__ = "applications"
    # a lab applies for a given method once
    __table_args__ = (UniqueConstraint("lab_id", "method_id", name="uq_applications_lab_method"),)

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # properties
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    # approval
    # user - null for an application raised by a lab registering itself
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
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
    user = relationship("UserDB", back_populates="applications", lazy='raise')
    status = relationship("StatusDB", back_populates="applications", lazy='raise')
    stage = relationship("StageDB", back_populates="applications", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="applications", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="applications", lazy='raise')
    service = relationship("ServiceDB", back_populates="applications", lazy='raise')
    method = relationship("MethodDB", back_populates="applications", lazy='raise')

    #links

# ---------- Pydantic Schemas ----------
class Applications(BaseModel):
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
    lab_id: int = Field(
        ...,
        description="Laboratory must be provided",
    )
    scheme_id: int = Field(
        ...,
        description="Scheme must be provided",
    )
    service_id: int = Field(
        ...,
        description="Service must be provided",
    )
    method_id: int = Field(
        ...,
        description="Method must be provided",
    )
    # approval
    # user
    user_id: Optional[int] = None

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

class ApplicationsWithDetail(Applications):
    stage: Stage
    status: Status
    # an application raised at registration has no user behind it yet
    user: Optional[User] = None
    laboratory: Laboratory
    scheme: Scheme
    service: Service
    method: Method

class ParamApplicationsEdit(BaseModel):
    applications: Optional[ApplicationsWithDetail] = None
    laboratoryList: Optional[List[Laboratory]] = []
    schemeList: Optional[List[Scheme]] = []
    serviceList: Optional[List[Service]] = []
    methodList: Optional[List[Method]] = []

    class Config:
        orm_mode = True