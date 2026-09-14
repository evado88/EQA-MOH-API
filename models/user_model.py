from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from typing import Optional, List
from datetime import date, datetime
from database import Base
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
    role = relationship("RoleDB", back_populates="user")




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