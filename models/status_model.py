from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from database import Base
from datetime import datetime

# ---------- SQLAlchemy Models ----------
class StatusDB(Base):
    __tablename__ = "list_statuses"

    #id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    status_name = Column(String,  nullable=False)
    description = Column(String, nullable=True)
    
    #service columns
    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True, default='System')
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)
    
    #relationships
    provider = relationship("ProviderDB", back_populates="status")
    ptcycle = relationship("PTCycleDB", back_populates="status")
    user = relationship("UserDB", back_populates="status")
    province = relationship("ProvinceDB", back_populates="status")
    district = relationship("DistrictDB", back_populates="status")
    ptcyclestatus = relationship("PTCycleStatusDB", back_populates="status")
    scheme = relationship("SchemeDB", back_populates="status")
    labtype = relationship("LabTypeDB", back_populates="status")
    laboratory = relationship("LaboratoryDB", back_populates="status")
    service = relationship("ServiceDB", back_populates="status")
    method = relationship("MethodDB", back_populates="status")
    methodsample = relationship("MethodSampleDB", back_populates="status")
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="status")
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="status")
    hivvlresult = relationship("HIVVLResultDB", back_populates="status")
    hiveidresult = relationship("HIVEIDResultDB", back_populates="status")
    enrollment = relationship("EnrollmentDB", back_populates="status")
    applications = relationship("ApplicationsDB", back_populates="status")
    role = relationship("RoleDB", back_populates="status")

# ---------- Pydantic Schemas ----------
class Status(BaseModel):
    #id
    id: int = Field(..., ge=1, description="ID must be greater than or equal to 1")
    status_name: str = Field(..., min_length=2, max_length=50, description="Name must be between 2 and 50 characters")
    description: Optional[str] = None
    #service columns
    created_at: Optional[datetime] = None
    created_by: Optional[str] 
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] 
    
    class Config:
        orm_mode = True
