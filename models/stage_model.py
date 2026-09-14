from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from database import Base
from datetime import datetime

# ---------- SQLAlchemy Models ----------
class StageDB(Base):
    __tablename__ = "list_stages"

    #id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    stage_name = Column(String,  nullable=False)
    description = Column(String, nullable=True)
    
    #service columns
    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True, default='System')
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)
    
    #relationships
    provider = relationship("ProviderDB", back_populates="stage")
    ptcycle = relationship("PTCycleDB", back_populates="stage")
    user = relationship("UserDB", back_populates="stage")
    province = relationship("ProvinceDB", back_populates="stage")
    district = relationship("DistrictDB", back_populates="stage")
    ptcyclestatus = relationship("PTCycleStatusDB", back_populates="stage")
    scheme = relationship("SchemeDB", back_populates="stage")
    labtype = relationship("LabTypeDB", back_populates="stage")
    laboratory = relationship("LaboratoryDB", back_populates="stage")
    service = relationship("ServiceDB", back_populates="stage")
    method = relationship("MethodDB", back_populates="stage")
    methodsample = relationship("MethodSampleDB", back_populates="stage")
    tbxpertultraresult = relationship("TBXpertUltraResultDB", back_populates="stage")
    tbxpertxdrresult = relationship("TBXpertXDRResultDB", back_populates="stage")
    hivvlresult = relationship("HIVVLResultDB", back_populates="stage")
    hiveidresult = relationship("HIVEIDResultDB", back_populates="stage")
    enrollment = relationship("EnrollmentDB", back_populates="stage")
    applications = relationship("ApplicationsDB", back_populates="stage")
    role = relationship("RoleDB", back_populates="stage")


# ---------- Pydantic Schemas ----------
class Stage(BaseModel):
    #id
    id: int = Field(..., ge=1, description="ID must be greater than or equal to 1")
    stage_name: str = Field(..., min_length=2, max_length=50, description="Name must be between 2 and 50 characters")
    description: Optional[str] = None
    #service columns
    created_at: Optional[datetime] = None
    created_by: Optional[str] 
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] 
    
    class Config:
        orm_mode = True
