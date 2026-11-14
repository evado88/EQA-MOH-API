from sqlalchemy import Column, Float, Integer, String, Date, DateTime, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.labtype_model import LabType
from models.province_model import Province
from models.district_model import District
from sqlalchemy.dialects.postgresql import JSONB

# ---------- SQLAlchemy Models ----------
class LaboratoryDB(Base):
    __tablename__ = "laboratorys"
    # a lab is identified by its code. The contact email is no longer unique:
    # one verified user (one email) may register the same facility for several
    # schemes, each as its own reviewable laboratory row (see migration 015).
    __table_args__ = (
        UniqueConstraint("code", name="uq_laboratorys_code"),
    )

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # properties
    contact_person_name = Column(String, nullable=False)
    code = Column(String, nullable=False)
    lab_type_id = Column(Integer, ForeignKey("lab_types.id"), nullable=False)
    position = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    province_id = Column(Integer, ForeignKey("provinces.id"), nullable=False)
    email_address = Column(String, nullable=False)
    district_id = Column(Integer, ForeignKey("districts.id"), nullable=False)
    physical_address = Column(String, nullable=False)
    # method list
    method_list = Column(JSONB, nullable=False)
    # the facility (MFL) this registration is for, and the verified user who
    # lodged it. facility_id is null for a non-Zambian facility typed free-hand.
    facility_id = Column(Integer, ForeignKey("facilities.id"), nullable=True)
    registered_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    # the controlled-document version the lab agreed to, snapshotted at
    # submission, plus the terms acceptance and (TB only) confidentiality waiver
    form_control_number = Column(String, nullable=True)
    form_version = Column(String, nullable=True)
    terms_accepted = Column(Boolean, nullable=False, default=False)
    terms_accepted_at = Column(DateTime(timezone=True), nullable=True)
    confidentiality_waiver = Column(Boolean, nullable=True)
    # approval
    # user - null until an admin approves the registration and the lab account is created
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
    user = relationship("UserDB", back_populates="laboratories", foreign_keys=[user_id], lazy='raise')
    facility = relationship("FacilityDB", foreign_keys=[facility_id], lazy='raise')
    registered_by = relationship("UserDB", foreign_keys=[registered_by_user_id], lazy='raise')
    status = relationship("StatusDB", back_populates="laboratory", lazy='raise')
    stage = relationship("StageDB", back_populates="laboratory", lazy='raise')
    labtype = relationship("LabTypeDB", back_populates="laboratory", lazy='raise')
    province = relationship("ProvinceDB", back_populates="laboratory", lazy='raise')
    district = relationship("DistrictDB", back_populates="laboratory", lazy='raise')

    #links
    enrollment = relationship("EnrollmentDB", back_populates="laboratory", lazy='raise')
    applications = relationship("ApplicationsDB", back_populates="laboratory", lazy='raise')
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="laboratory", lazy='raise')
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="laboratory", lazy='raise')
    hivvlresult = relationship("HIVVLResultDB", back_populates="laboratory", lazy='raise')
    hiveidresult = relationship("HIVEIDResultDB", back_populates="laboratory", lazy='raise')
    bacteriologyresult = relationship("BacteriologyResultDB", back_populates="laboratory", lazy='raise')

# ---------- Pydantic Schemas ----------
class Laboratory(BaseModel):
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
    contact_person_name: str = Field(
        ...,
        description="Contact Person Name must be provided",
    )
    code: Optional[str] = Field(
        default=None,
        description="Code is generated by the server on registration",
    )
    lab_type_id: int = Field(
        ...,
        description="Type of Lab must be provided",
    )
    position: str = Field(
        ...,
        description="Position must be provided",
    )
    phone_number: str = Field(
        ...,
        description="Phone Number must be provided",
    )
    province_id: int = Field(
        ...,
        description="Province must be provided",
    )
    email_address: str = Field(
        ...,
        description="Email Address must be provided",
    )
    district_id: int = Field(
        ...,
        description="District must be provided",
    )
    physical_address: str = Field(
        ...,
        description="Physical Address must be provided",
    )
    # method list
    method_list: list[dict[str, Any]]= Field(..., description="The EQA Scheme selection list must be provided")
    # facility linkage
    facility_id: Optional[int] = None
    registered_by_user_id: Optional[int] = None
    # controlled-document agreement snapshot
    form_control_number: Optional[str] = None
    form_version: Optional[str] = None
    terms_accepted: Optional[bool] = None
    terms_accepted_at: Optional[datetime] = None
    confidentiality_waiver: Optional[bool] = None
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

class LaboratoryScheme(BaseModel):
    """One scheme a laboratory applied to, as vw_laboratory_scheme sees it"""

    scheme_id: int
    scheme_name: str
    provider_name: Optional[str] = None
    method_count: int = 0
    accepted_count: int = 0
    pending_count: int = 0
    rejected_count: int = 0
    method_names: Optional[str] = None
    accepted_method_names: Optional[str] = None
    # Accepted, Pending or Rejected
    participation: Optional[str] = None

    class Config:
        orm_mode = True


class LaboratoryWithDetail(Laboratory):
    stage: Stage
    status: Status
    # a lab that registered itself has no owning user until it is approved
    user: Optional[User] = None

    labtype: LabType
    province: Province
    district: District


class LaboratoryWithSchemes(LaboratoryWithDetail):
    """A laboratory and the schemes it applied to.

    Kept apart from `LaboratoryWithDetail` so the plain laboratory listing
    stays exactly what it was - the scheme summary costs a second query and a
    good deal of payload, and only the pages that show it should pay for it.
    """

    # which schemes the lab applied to, and how each stands. Empty for a
    # registration nobody has reviewed yet.
    scheme_list: Optional[List[LaboratoryScheme]] = []
    # every scheme in scheme_list as one string. This is what a listing filters
    # and searches on, so the filter matches what the column actually shows -
    # including a scheme the lab applied to but was not accepted for.
    scheme_names: Optional[str] = None
    scheme_count: Optional[int] = 0
    # the narrower answer: the schemes the lab is actually registered in
    accepted_scheme_names: Optional[str] = None
    accepted_scheme_count: Optional[int] = 0

class ParamLaboratoryEdit(BaseModel):
    # the one-laboratory page shows its schemes, so it gets the fuller model
    laboratory: Optional[LaboratoryWithSchemes] = None
    labtypeList: Optional[List[LabType]] = []
    provinceList: Optional[List[Province]] = []
    districtList: Optional[List[District]] = []

    class Config:
        orm_mode = True

class SignupMethod(BaseModel):
    """One method a registering lab says it provides."""

    id: int = Field(..., ge=1, description="Method must be provided")


class ParamLaboratorySignup(BaseModel):
    """Posted by a laboratory registering itself for EQA.

    Deliberately narrower than `Laboratory`: a self-registering lab may not
    choose its own approval state, owning user or role. The server decides
    those, and only ever grants a laboratory role.
    """

    # name
    name: str = Field(..., min_length=2, description="Name must be provided")
    description: Optional[str] = None

    # properties
    contact_person_name: str = Field(
        ..., min_length=2, description="Contact Person Name must be provided"
    )
    lab_type_id: int = Field(..., ge=1, description="Type of Lab must be provided")
    position: str = Field(..., min_length=2, description="Position must be provided")
    phone_number: str = Field(
        ..., min_length=6, max_length=20, description="Phone Number must be provided"
    )
    province_id: int = Field(..., ge=1, description="Province must be provided")
    email_address: EmailStr
    district_id: int = Field(..., ge=1, description="District must be provided")
    physical_address: str = Field(
        ..., min_length=2, description="Physical Address must be provided"
    )

    # the methods the lab is applying to take part in
    method_list: List[SignupMethod] = Field(
        ..., min_items=1, description="At least one method must be selected"
    )


class LaboratorySignupResult(BaseModel):
    """What a lab gets back after registering."""

    succeeded: bool
    message: str
    laboratory_id: int
    code: str
    application_count: int


# ----------------------- per-scheme registration (new flow) ------------------
class ParamSchemeRegistration(BaseModel):
    """Posted by a signed-in, verified user registering their facility for one
    scheme.

    Most of the contact detail comes from the user's own profile; the form
    fills in the laboratory specifics (type, address) and the methods within
    the chosen scheme. The server derives province/district from the facility
    when they are not supplied, assigns the per-scheme registration number and
    decides the approval state.
    """

    # who is registering (their account must exist and be verified)
    user_email: EmailStr

    # the single scheme being registered for
    scheme_id: int = Field(..., ge=1, description="Scheme must be provided")

    # the laboratory being registered
    name: str = Field(..., min_length=2, description="Laboratory name must be provided")
    description: Optional[str] = None
    lab_type_id: int = Field(..., ge=1, description="Type of Lab must be provided")
    physical_address: str = Field(
        ..., min_length=2, description="Physical Address must be provided"
    )
    # optional overrides; otherwise taken from the user / facility
    contact_person_name: Optional[str] = None
    position: Optional[str] = None
    phone_number: Optional[str] = None
    province_id: Optional[int] = Field(default=None, ge=1)
    district_id: Optional[int] = Field(default=None, ge=1)

    # Zambia: the chosen facility. Elsewhere: a free-typed name.
    facility_id: Optional[int] = Field(default=None, ge=1)
    facility_name: Optional[str] = None

    # the methods within this scheme the lab is applying for
    method_list: List[SignupMethod] = Field(
        ..., min_items=1, description="At least one method must be selected"
    )

    # controlled-document agreement: the lab must accept the scheme's terms, and
    # for schemes that ask it (TB) must answer the confidentiality waiver
    terms_accepted: bool = False
    # True = waives confidentiality, False = keeps it, None = scheme does not ask
    confidentiality_waiver: Optional[bool] = None

    # the user has seen and accepted the "already registered" warning
    acknowledge_duplicate: bool = False


class SchemeRegistrationResult(BaseModel):
    succeeded: bool
    message: str
    laboratory_id: int
    code: str
    registration_number: str
    application_count: int
    # true when another user had already registered this facility for this
    # scheme; the submission still goes through for the administrator to decide
    duplicate_warning: bool = False
