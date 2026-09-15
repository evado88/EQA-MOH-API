from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, ConfigDict, EmailStr, Field, root_validator
from typing import Optional, List
from datetime import date, datetime
from database import Base
from helpers import assist
from models.stage_model import Stage
from models.status_model import Status


# ---------- SQLAlchemy Models ----------
class UserDB(Base):
    __tablename__ = "users"

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    code = Column(String, nullable=True)
    type = Column(Integer, nullable=True)

    # personal details
    fname = Column(String, nullable=False)
    lname = Column(String, nullable=False)
    position = Column(String, nullable=True)
    
    #contact, address 
    email = Column(String, unique=True, index=True, nullable=False)
    mobile_code = Column(String, nullable=False)
    mobile = Column(String, nullable=False)
    address_physical = Column(String, nullable=True)
    address_postal = Column(String, nullable=True)

    # account
    role_id = Column(Integer, nullable=False)
    password = Column(String, nullable=False)

    # approval
    status_id = Column(Integer, ForeignKey("list_statuses.id"), nullable=False)
    stage_id = Column(Integer, ForeignKey("list_stages.id"), nullable=False)

    # laboratory
    laboratory_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=True)

    # province, district
    province_id = Column(Integer, ForeignKey("provinces.id"), nullable=True)
    district_id = Column(Integer, ForeignKey("districts.id"), nullable=True)

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

    # relationships
    stage = relationship("StageDB", back_populates="user", lazy="selectin")
    status = relationship("StatusDB", back_populates="user", lazy="selectin")
    provider = relationship("ProviderDB", back_populates="user")
    ptcycle = relationship("PTCycleDB", back_populates="user")
    provinces = relationship("ProvinceDB", back_populates="user", foreign_keys="ProvinceDB.user_id")
    province = relationship("ProvinceDB", foreign_keys=[province_id])
    districts = relationship("DistrictDB", back_populates="user", foreign_keys="DistrictDB.user_id")
    district = relationship("DistrictDB", foreign_keys=[district_id])
    ptcyclestatus = relationship("PTCycleStatusDB", back_populates="user")
    scheme = relationship("SchemeDB", back_populates="user")
    labtype = relationship("LabTypeDB", back_populates="user")
    laboratories = relationship("LaboratoryDB", back_populates="user", foreign_keys="LaboratoryDB.user_id")
    laboratory = relationship("LaboratoryDB", foreign_keys=[laboratory_id])
    service = relationship("ServiceDB", back_populates="user")
    method = relationship("MethodDB", back_populates="user")
    methodsample = relationship("MethodSampleDB", back_populates="user")
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="user")
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="user")
    hivvlresult = relationship("HIVVLResultDB", back_populates="user")
    hiveidresult = relationship("HIVEIDResultDB", back_populates="user")
    enrollment = relationship("EnrollmentDB", back_populates="user")
    applications = relationship("ApplicationsDB", back_populates="user")
    # the roles this user created, following the same naming as laboratories /
    # provinces / districts above: plural is what the user made, singular is
    # what the user belongs to
    roles = relationship(
        "RoleDB", back_populates="user", foreign_keys="RoleDB.user_id"
    )
    # the role this user holds. role_id carries no foreign key of its own - the
    # list is seeded in a fixed order that helpers/assist.py mirrors - so the
    # join has to be spelled out
    role = relationship(
        "RoleDB",
        primaryjoin="foreign(UserDB.role_id) == RoleDB.id",
        viewonly=True,
    )




# ---------- Pydantic Schemas ----------
class User(BaseModel):
    # id
    id: Optional[int] = None
    
    user_id: Optional[int] = None
    
    code: Optional[str] = None
    type: Optional[int] = None
    
    # personal details
    fname: str = Field(
        ...,
        min_length=2,
        max_length=50,
        description="First name must be between 2 and 50 characters",
    )
    lname: str = Field(
        ...,
        min_length=2,
        max_length=50,
        description="Last name must be between 2 and 50 characters",
    )
    position: Optional[str] = None
    
    #contact, address 
    email: EmailStr
    mobile_code: str = Field(
        ...,
        min_length=2,
        max_length=5,
        description="Mobile code must be between 3 and 15 characters",
    )
    mobile: str = Field(
        ...,
        min_length=3,
        max_length=15,
        description="Mobile must be between 3 and 15 characters",
    )
    address_physical: Optional[str] = None
    address_postal: Optional[str] = None
    
    # account
    role_id: int = Field(
        ..., ge=1, le=100, description="Role must be greater than or equal to 1"
    )
    password: str = Field(
        ...,
        min_length=8,
        max_length=255,
        description="Password must be between 8 and 80 characters",
    )
    
    # approval
    status_id: int = Field(
        ..., ge=1, description="Status must be greater than or equal to 1"
    )
    stage_id: int = Field(..., ge=1, le=8, description="Stage must be between 1 and 8")

    # laboratory
    laboratory_id: Optional[int] = Field(
        default=None, ge=1, description="Laboratory must be greater than or equal to 1"
    )

    # province, district
    province_id: Optional[int] = Field(
        default=None, ge=1, description="Province must be greater than or equal to 1"
    )
    district_id: Optional[int] = Field(
        default=None, ge=1, description="District must be greater than or equal to 1"
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

    # service columns
    created_at: Optional[datetime] = None
    created_by: Optional[str] = None
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] = None

    class Config:
        orm_mode = True


# Spelled out here rather than imported from role_model, laboratory_model,
# province_model and district_model, every one of which imports this module.
# They are also deliberately narrow: a listing needs what a laboratory is
# called, not its method list.
class UserRole(BaseModel):
    id: Optional[int] = None
    name: Optional[str] = None

    class Config:
        orm_mode = True


class UserLaboratory(BaseModel):
    id: Optional[int] = None
    code: Optional[str] = None
    name: Optional[str] = None

    class Config:
        orm_mode = True


class UserProvince(BaseModel):
    id: Optional[int] = None
    name: Optional[str] = None

    class Config:
        orm_mode = True


class UserDistrict(BaseModel):
    id: Optional[int] = None
    name: Optional[str] = None
    # carried so the form can narrow the districts to the chosen province
    province_id: Optional[int] = None

    class Config:
        orm_mode = True


class UserWithDetail(BaseModel):
    """A user as a listing shows them: the role they hold and where they work.

    Deliberately not built on `User`. That model carries the password, which a
    listing has no business sending to a browser, and it makes fields required
    that only matter when an account is being created.
    """

    # id
    id: Optional[int] = None
    code: Optional[str] = None
    type: Optional[int] = None

    # personal details
    fname: Optional[str] = None
    lname: Optional[str] = None
    position: Optional[str] = None

    # contact, address
    email: Optional[str] = None
    mobile_code: Optional[str] = None
    mobile: Optional[str] = None
    address_physical: Optional[str] = None
    address_postal: Optional[str] = None

    # account
    role_id: Optional[int] = None
    role: Optional[UserRole] = None

    # where they work; provider staff belong to no laboratory
    laboratory_id: Optional[int] = None
    laboratory: Optional[UserLaboratory] = None

    province_id: Optional[int] = None
    district_id: Optional[int] = None

    # approval
    status_id: Optional[int] = None
    stage_id: Optional[int] = None
    status: Optional[Status] = None
    stage: Optional[Stage] = None
    approval_levels: Optional[int] = None

    # service columns
    created_at: Optional[datetime] = None
    created_by: Optional[str] = None
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] = None

    class Config:
        orm_mode = True

class UserSave(BaseModel):
    """What the add and edit form posts.

    Separate from `User` because the two have different rules. `User` makes a
    password mandatory, which is right when an account is being created and
    wrong every other time - an admin correcting a phone number should not have
    to retype, or reset, somebody's password.
    """

    # personal details
    fname: str = Field(
        ...,
        min_length=2,
        max_length=50,
        description="First name must be between 2 and 50 characters",
    )
    lname: str = Field(
        ...,
        min_length=2,
        max_length=50,
        description="Last name must be between 2 and 50 characters",
    )
    position: Optional[str] = None
    code: Optional[str] = None
    type: Optional[int] = None

    # contact, address
    email: EmailStr
    mobile_code: str = Field(..., min_length=2, max_length=5)
    mobile: str = Field(..., min_length=3, max_length=15)
    address_physical: Optional[str] = None
    address_postal: Optional[str] = None

    # account
    role_id: int = Field(..., ge=1, le=100, description="Role must be provided")
    # a laboratory role reports for one laboratory; provider staff for none
    laboratory_id: Optional[int] = Field(default=None, ge=1)
    province_id: Optional[int] = Field(default=None, ge=1)
    district_id: Optional[int] = Field(default=None, ge=1)

    # left unset on an edit, which leaves the existing password alone
    password: Optional[str] = Field(
        default=None,
        min_length=8,
        max_length=255,
        description="Password must be at least 8 characters",
    )

    # service
    created_by: Optional[str] = None
    updated_by: Optional[str] = None

    @root_validator
    def check_laboratory_matches_role(cls, values):
        """A laboratory account has to say which laboratory it belongs to.

        The result and dashboard routes decide what an account may see from
        `laboratory_id`, so a facility account without one can sign in and then
        find nothing it is allowed to touch.
        """
        role_id = values.get("role_id")
        laboratory_id = values.get("laboratory_id")

        if role_id is None:
            return values

        if assist.is_laboratory_role(role_id):
            if not laboratory_id:
                raise ValueError(
                    "A facility role must be linked to a laboratory"
                )
        elif laboratory_id:
            raise ValueError(
                "Only a facility role can be linked to a laboratory"
            )

        return values

    class Config:
        orm_mode = True


class ParamUserEdit(BaseModel):
    """The user being edited, and everything its form has to offer as a choice"""

    user: Optional[UserWithDetail] = None
    roleList: Optional[List[UserRole]] = []
    laboratoryList: Optional[List[UserLaboratory]] = []
    provinceList: Optional[List[UserProvince]] = []
    districtList: Optional[List[UserDistrict]] = []

    class Config:
        orm_mode = True
