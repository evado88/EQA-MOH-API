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
from models.service_model import Service


# ---------- SQLAlchemy Models ----------
class MethodDB(Base):
    __tablename__ = "methods"
    # a name is only unique within its parent
    __table_args__ = (UniqueConstraint("service_id", "name", name="uq_methods_service_name"),)

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # properties
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
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
    user = relationship("UserDB", back_populates="method", lazy='raise')
    status = relationship("StatusDB", back_populates="method", lazy='raise')
    stage = relationship("StageDB", back_populates="method", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="method", lazy='raise')
    service = relationship("ServiceDB", back_populates="method", lazy='raise')

    #links
    enrollment = relationship("EnrollmentDB", back_populates="method", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="method", lazy='raise')
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="method", lazy='raise')
    applications = relationship("ApplicationsDB", back_populates="method", lazy='raise')

# ---------- Pydantic Schemas ----------
class Method(BaseModel):
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
    service_id: int = Field(
        ...,
        description="Service must be provided",
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

class MethodWithDetail(Method):
    stage: Stage
    status: Status
    user: User
    
    scheme: Scheme
    service: Service

class ParamMethodEdit(BaseModel):
    method: Optional[MethodWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    serviceList: Optional[List[Service]] = []

    class Config:
        orm_mode = True