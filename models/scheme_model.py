from sqlalchemy import Column, Float, Integer, String, Date, DateTime, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel,  Field
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.provider_model import Provider


# ---------- SQLAlchemy Models ----------
class SchemeDB(Base):
    __tablename__ = "schemes"
    # a name is only unique within its parent
    __table_args__ = (UniqueConstraint("provider_id", "name", name="uq_schemes_provider_name"),)

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    # short code used to build a lab's per-scheme registration number, e.g. TB
    code = Column(String, nullable=True)

    # controlled-document metadata for this scheme's application form
    form_control_number = Column(String, nullable=True)
    form_version = Column(String, nullable=True)
    # authority named in the terms agreement ("...as provided by <X>")
    form_terms_authority = Column(String, nullable=True)
    requires_confidentiality_waiver = Column(Boolean, nullable=False, default=False)

    # registration payment configuration (set by administrators). Local
    # (Zambian) applicants are charged in ZMW and may use mobile money;
    # international applicants are charged in USD.
    registration_fee_usd = Column(Float, nullable=True)
    registration_fee_zmw = Column(Float, nullable=True)
    bank_account_details = Column(String, nullable=True)
    mobile_money_details = Column(String, nullable=True)
    payment_instructions = Column(String, nullable=True)

    # properties
    provider_id = Column(Integer, ForeignKey("providers.id"), nullable=False)
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
    # the user who created this scheme (schemes.user_id). users.scheme_id now
    # also links the two tables, so this join is spelled out to stay unambiguous.
    user = relationship(
        "UserDB", back_populates="scheme", foreign_keys=[user_id], lazy='raise'
    )
    status = relationship("StatusDB", back_populates="scheme", lazy='raise')
    stage = relationship("StageDB", back_populates="scheme", lazy='raise')
    provider = relationship("ProviderDB", back_populates="scheme", lazy='raise')

    #links
    enrollment = relationship("EnrollmentDB", back_populates="scheme", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="scheme", lazy='raise')
    method = relationship("MethodDB", back_populates="scheme", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="scheme", lazy='raise')
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="scheme", lazy='raise')
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="scheme", lazy='raise')
    hivvlresult = relationship("HIVVLResultDB", back_populates="scheme", lazy='raise')
    hiveidresult = relationship("HIVEIDResultDB", back_populates="scheme", lazy='raise')
    bacteriologyresult = relationship("BacteriologyResultDB", back_populates="scheme", lazy='raise')
    announcement = relationship("AnnouncementDB", back_populates="scheme", lazy='raise')
    applications = relationship("ApplicationsDB", back_populates="scheme", lazy='raise')
    service = relationship("ServiceDB", back_populates="scheme", lazy='raise')

# ---------- Pydantic Schemas ----------
class Scheme(BaseModel):
    # id
    id: Optional[int] = None

    # name
    name: str = Field(
        ...,
        min_length=2,
        description="Name must be between at least 2 characters",
    )
    description: Optional[str] = None
    code: Optional[str] = None
    form_control_number: Optional[str] = None
    form_version: Optional[str] = None
    form_terms_authority: Optional[str] = None
    requires_confidentiality_waiver: Optional[bool] = False

    # registration payment configuration
    registration_fee_usd: Optional[float] = None
    registration_fee_zmw: Optional[float] = None
    bank_account_details: Optional[str] = None
    mobile_money_details: Optional[str] = None
    payment_instructions: Optional[str] = None

    # properties
    provider_id: int = Field(
        ...,
        description="Provider must be provided",
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

class SchemeWithDetail(Scheme):
    stage: Stage
    status: Status
    user: User
    
    provider: Provider

class ParamSchemeEdit(BaseModel):
    scheme: Optional[SchemeWithDetail] = None
    providerList: Optional[List[Provider]] = []

    class Config:
        orm_mode = True


# ------------------------ scheme catalogue (tiles page) ----------------------
class CatalogueMethod(BaseModel):
    id: int
    name: str
    service_id: int

    class Config:
        orm_mode = True


class CatalogueService(BaseModel):
    id: int
    name: str
    methods: List[CatalogueMethod] = []

    class Config:
        orm_mode = True


class SchemeTile(BaseModel):
    """One scheme as the selection page shows it: enough to draw a tile and,
    on selection, drive the per-scheme registration form's method picker."""

    id: int
    name: str
    code: Optional[str] = None
    description: Optional[str] = None
    provider_name: Optional[str] = None
    method_count: int = 0
    services: List[CatalogueService] = []
    # controlled-document metadata for the application form
    form_control_number: Optional[str] = None
    form_version: Optional[str] = None
    form_terms_authority: Optional[str] = None
    requires_confidentiality_waiver: bool = False

    class Config:
        orm_mode = True