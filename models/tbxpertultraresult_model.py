from sqlalchemy import Column, Float, Integer, String, Date, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field, root_validator, validator
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.scheme_model import Scheme
from models.laboratory_model import Laboratory
from models.service_model import Service
from models.enrollment_model import Enrollment
from models.ptcycle_model import PTCycle
from models.method_model import Method
from models.methodsample_model import MethodSample
from helpers import assist


# ---------- Allowed values ----------
# taken from form CDL-PT-F-008 'Xpert PT Results form'
RESULT_INTERPRETABLE_VALUES = ["Yes", "No"]

TB_DETECTION_RESULT_VALUES = [
    "NOT DETECTED",
    "TRACE",
    "VERY LOW",
    "LOW",
    "MEDIUM",
    "HIGH",
]

RIF_RESULT_VALUES = ["N/A", "NOT DETECTED", "DETECTED"]

UNINTERPRETABLE_RESULT_VALUES = [
    "INVALID",
    "NO RESULT",
    "ERROR",
    "INDETERMINATE",
]

# the cycle threshold (Ct) probes reported by an Xpert MTB/RIF Ultra run
CT_VALUE_FIELDS = [
    "ultra_spc",
    "is1081_IS6110",
    "rpoB1",
    "rpoB2",
    "rpoB3",
    "rpoB4",
]

# an ERROR must be accompanied by the code the instrument displayed
UNINTERPRETABLE_RESULT_REQUIRING_CODE = "ERROR"


def _check_allowed(label, value, allowed):
    """Rejects a result the Xpert form does not offer as a choice"""
    if value is None or value == "":
        return None

    # the form prints some of these values with trailing spaces
    cleaned = value.strip()
    if cleaned not in allowed:
        raise ValueError(f"{label} must be one of {', '.join(allowed)}")

    return cleaned


# ---------- SQLAlchemy Models ----------
class TBXpertUltraResultDB(Base):
    __tablename__ = "tb_xpert_ultra_results"
    # one result per sample, per lab, per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id",
            name="uq_tb_xpert_ultra_results_cycle_lab_sample",
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
    enrollment_id = Column(Integer, ForeignKey("enrollments.id"), nullable=False)
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    method_sample_id = Column(Integer, ForeignKey("method_samples.id"), nullable=False)
    date_tested = Column(Date, nullable=True)
    result_nterpretable = Column(String, nullable=True)
    tb_detection_result = Column(String, nullable=True)
    rif_result = Column(String, nullable=True)
    uninterpretable_result = Column(String, nullable=True)
    error_code = Column(String, nullable=True)
    ultra_spc = Column(Float, nullable=True)
    is1081_IS6110 = Column(Float, nullable=True)
    rpoB1 = Column(Float, nullable=True)
    rpoB2 = Column(Float, nullable=True)
    rpoB3 = Column(Float, nullable=True)
    rpoB4 = Column(Float, nullable=True)
    xpert_module_number = Column(String, nullable=True)
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
    user = relationship("UserDB", back_populates="tbxpertultraresult", lazy='raise')
    status = relationship("StatusDB", back_populates="tbxpertultraresult", lazy='raise')
    stage = relationship("StageDB", back_populates="tbxpertultraresult", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="tbxpertultraresult", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="tbxpertultraresult", lazy='raise')
    service = relationship("ServiceDB", back_populates="tbxpertultraresult", lazy='raise')
    enrollment = relationship("EnrollmentDB", back_populates="tbxpertultraresult", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="tbxpertultraresult", lazy='raise')
    method = relationship("MethodDB", back_populates="tbxpertultraresult", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="tbxpertultraresult", lazy='raise')

    #links

# ---------- Pydantic Schemas ----------
class TBXpertUltraResult(BaseModel):
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
    enrollment_id: int = Field(
        ...,
        description="Enrollment must be provided",
    )
    pt_cycle_id: int = Field(
        ...,
        description="Cycle must be provided",
    )
    method_id: int = Field(
        ...,
        description="Method must be provided",
    )
    method_sample_id: int = Field(
        ...,
        description="Method Sample must be provided",
    )
    # results - all optional on the model so a lab can save a partially
    # captured panel; the rules below are what make a result submittable
    date_tested: Optional[date] = Field(
        default=None, description="The date the sample was tested"
    )
    result_nterpretable: Optional[str] = Field(
        default=None,
        description=f"Result Interpretable must be one of {RESULT_INTERPRETABLE_VALUES}",
    )
    tb_detection_result: Optional[str] = Field(
        default=None,
        description=f"TB Detection Result must be one of {TB_DETECTION_RESULT_VALUES}",
    )
    rif_result: Optional[str] = Field(
        default=None, description=f"Rif Result must be one of {RIF_RESULT_VALUES}"
    )
    uninterpretable_result: Optional[str] = Field(
        default=None,
        description=f"Uninterpretable Result must be one of {UNINTERPRETABLE_RESULT_VALUES}",
    )
    error_code: Optional[str] = Field(
        default=None,
        description="The instrument error code, required for an ERROR result",
    )
    ultra_spc: Optional[float] = Field(
        default=None, description="The Ultra SPC cycle threshold value"
    )
    is1081_IS6110: Optional[float] = Field(
        default=None, description="The IS1081-IS6110 cycle threshold value"
    )
    rpoB1: Optional[float] = Field(
        default=None, description="The rpoB1 cycle threshold value"
    )
    rpoB2: Optional[float] = Field(
        default=None, description="The rpoB2 cycle threshold value"
    )
    rpoB3: Optional[float] = Field(
        default=None, description="The rpoB3 cycle threshold value"
    )
    rpoB4: Optional[float] = Field(
        default=None, description="The rpoB4 cycle threshold value"
    )
    xpert_module_number: Optional[str] = Field(
        default=None, description="The Xpert module the sample was run on"
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

    @validator("result_nterpretable")
    def check_result_nterpretable(cls, value):
        return _check_allowed(
            "Result Interpretable", value, RESULT_INTERPRETABLE_VALUES
        )

    @validator("tb_detection_result")
    def check_tb_detection_result(cls, value):
        return _check_allowed(
            "TB Detection Result", value, TB_DETECTION_RESULT_VALUES
        )

    @validator("rif_result")
    def check_rif_result(cls, value):
        return _check_allowed("Rif Result", value, RIF_RESULT_VALUES)

    @validator("uninterpretable_result")
    def check_uninterpretable_result(cls, value):
        return _check_allowed(
            "Uninterpretable Result", value, UNINTERPRETABLE_RESULT_VALUES
        )

    @validator(*CT_VALUE_FIELDS)
    def check_ct_value(cls, value, field):
        # a cycle threshold is a positive number of amplification cycles
        if value is not None and (value < 0 or value > 100):
            raise ValueError(
                f"The {field.name} cycle threshold must be between 0 and 100"
            )
        return value

    @root_validator
    def check_result_is_consistent(cls, values):
        """Applies the rules on form CDL-PT-F-008.

        A draft may be incomplete - the lab captures the panel over several
        sittings - but the moment it is submitted for review it has to be a
        result a reviewer can actually grade.
        """
        interpretable = values.get("result_nterpretable")
        detection = values.get("tb_detection_result")
        rif = values.get("rif_result")
        uninterpretable = values.get("uninterpretable_result")
        error_code = values.get("error_code")

        # a sample is either interpretable or it is not - never both
        if interpretable == "Yes" and uninterpretable:
            raise ValueError(
                "An Uninterpretable Result cannot be recorded when the result is interpretable"
            )

        if interpretable == "No" and (detection or rif):
            raise ValueError(
                "A TB Detection Result or Rif Result cannot be recorded when the result is not interpretable"
            )

        # an error code only belongs to an ERROR
        if error_code and uninterpretable != UNINTERPRETABLE_RESULT_REQUIRING_CODE:
            raise ValueError(
                "An Error Code can only be recorded for an ERROR result"
            )

        if values.get("status_id") != assist.STATUS_SUBMITTED:
            # still a draft, an incomplete panel is fine
            return values

        if not interpretable:
            raise ValueError("Result Interpretable must be provided")

        if interpretable == "Yes":
            if not detection:
                raise ValueError(
                    "TB Detection Result must be provided for an interpretable result"
                )
            if not rif:
                raise ValueError(
                    "Rif Result must be provided for an interpretable result"
                )
        else:
            if not uninterpretable:
                raise ValueError(
                    "Uninterpretable Result must be provided when the result is not interpretable"
                )
            if uninterpretable == UNINTERPRETABLE_RESULT_REQUIRING_CODE and not error_code:
                raise ValueError("An Error Code must be provided for an ERROR result")

        if not values.get("date_tested"):
            raise ValueError("The Date Tested must be provided")

        if not values.get("xpert_module_number"):
            raise ValueError("The Xpert Module Number must be provided")

        # the Ct values are read off the instrument print out for every
        # successful test, so they are only expected for an interpretable result
        if interpretable == "Yes":
            missing = [
                name for name in CT_VALUE_FIELDS if values.get(name) is None
            ]
            if missing:
                raise ValueError(
                    "The cycle threshold (Ct) values must be provided for an "
                    f"interpretable result. Missing: {', '.join(missing)}"
                )

        return values

    class Config:
        orm_mode = True

class TBXpertUltraResultWithDetail(TBXpertUltraResult):
    stage: Stage
    status: Status
    user: User
    
    scheme: Scheme
    laboratory: Laboratory
    service: Service
    enrollment: Enrollment
    ptcycle: PTCycle
    method: Method
    methodsample: MethodSample

class ParamTBXpertUltraResultEdit(BaseModel):
    tbxpertultraresult: Optional[TBXpertUltraResultWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    enrollmentList: Optional[List[Enrollment]] = []
    ptcycleList: Optional[List[PTCycle]] = []
    methodList: Optional[List[Method]] = []
    methodsampleList: Optional[List[MethodSample]] = []

    class Config:
        orm_mode = True