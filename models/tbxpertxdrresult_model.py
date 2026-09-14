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
# taken from form CDL-PT-F-027 'DRIED TUBE SPECIMENS (DTS) Xpert MTB/XDR Result Form'
RESULT_INTERPRETABLE_VALUES = ["Yes", "No"]

# the XDR assay only reports presence or absence, unlike the Ultra assay which
# grades the bacterial load
TB_DETECTION_RESULT_VALUES = ["NOT DETECTED", "DETECTED"]

# the four drug resistance results, all reported on the same scale
DRUG_RESULT_VALUES = ["N/A", "NOT DETECTED", "DETECTED"]

# isoniazid, fluoroquinolone, amikacin and ethionamide
DRUG_RESULT_FIELDS = [
    "inh_result",
    "flq_result",
    "amk_result",
    "eth_result",
]

DRUG_RESULT_LABELS = {
    "inh_result": "INH Result",
    "flq_result": "FLQ Result",
    "amk_result": "AMK Result",
    "eth_result": "ETH Result",
}

UNINTERPRETABLE_RESULT_VALUES = [
    "INVALID",
    "NO RESULT",
    "ERROR",
    "INDETERMINATE",
]

# the cycle threshold (Ct) probes reported by an Xpert MTB/XDR run. The columns
# are lower case so raw SQL never has to quote them; the form spells them
# SPC-ahpC, inhA, KatG, fabG1, gyrA1, gyrA2, gyrA3, gyrB2 and rrs.
CT_VALUE_FIELDS = [
    "spc_ahpc",
    "inha",
    "katg",
    "fabg1",
    "gyra1",
    "gyra2",
    "gyra3",
    "gyrb2",
    "rrs",
]

CT_VALUE_LABELS = {
    "spc_ahpc": "SPC-ahpC",
    "inha": "inhA",
    "katg": "KatG",
    "fabg1": "fabG1",
    "gyra1": "gyrA1",
    "gyra2": "gyrA2",
    "gyra3": "gyrA3",
    "gyrb2": "gyrB2",
    "rrs": "rrs",
}

# an ERROR must be accompanied by the code the instrument displayed
UNINTERPRETABLE_RESULT_REQUIRING_CODE = "ERROR"


def _check_allowed(label, value, allowed):
    """Rejects a result the Xpert form does not offer as a choice"""
    if value is None or value == "":
        return None

    # the form prints some of these values with trailing spaces, and spells
    # 'Detected' in mixed case in the TB detection column
    cleaned = value.strip()
    for option in allowed:
        if cleaned.upper() == option.upper():
            return option

    raise ValueError(f"{label} must be one of {', '.join(allowed)}")


# ---------- SQLAlchemy Models ----------
class TBXpertXDRResultDB(Base):
    __tablename__ = "tb_xpert_xdr_results"
    # one result per sample, per lab, per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id",
            name="uq_tb_xpert_xdr_results_cycle_lab_sample",
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
    result_interpretable = Column(String, nullable=True)
    tb_detection_result = Column(String, nullable=True)
    # drug resistance
    inh_result = Column(String, nullable=True)
    flq_result = Column(String, nullable=True)
    amk_result = Column(String, nullable=True)
    eth_result = Column(String, nullable=True)
    uninterpretable_result = Column(String, nullable=True)
    error_code = Column(String, nullable=True)
    # cycle thresholds
    spc_ahpc = Column(Float, nullable=True)
    inha = Column(Float, nullable=True)
    katg = Column(Float, nullable=True)
    fabg1 = Column(Float, nullable=True)
    gyra1 = Column(Float, nullable=True)
    gyra2 = Column(Float, nullable=True)
    gyra3 = Column(Float, nullable=True)
    gyrb2 = Column(Float, nullable=True)
    rrs = Column(Float, nullable=True)
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
    user = relationship("UserDB", back_populates="tbxpertxdrresult", lazy='raise')
    status = relationship("StatusDB", back_populates="tbxpertxdrresult", lazy='raise')
    stage = relationship("StageDB", back_populates="tbxpertxdrresult", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="tbxpertxdrresult", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="tbxpertxdrresult", lazy='raise')
    service = relationship("ServiceDB", back_populates="tbxpertxdrresult", lazy='raise')
    enrollment = relationship("EnrollmentDB", back_populates="tbxpertxdrresult", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="tbxpertxdrresult", lazy='raise')
    method = relationship("MethodDB", back_populates="tbxpertxdrresult", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="tbxpertxdrresult", lazy='raise')

    #links

# ---------- Pydantic Schemas ----------
class TBXpertXDRResult(BaseModel):
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
    result_interpretable: Optional[str] = Field(
        default=None,
        description=f"Result Interpretable must be one of {RESULT_INTERPRETABLE_VALUES}",
    )
    tb_detection_result: Optional[str] = Field(
        default=None,
        description=f"TB Detection Result must be one of {TB_DETECTION_RESULT_VALUES}",
    )
    inh_result: Optional[str] = Field(
        default=None, description=f"INH Result must be one of {DRUG_RESULT_VALUES}"
    )
    flq_result: Optional[str] = Field(
        default=None, description=f"FLQ Result must be one of {DRUG_RESULT_VALUES}"
    )
    amk_result: Optional[str] = Field(
        default=None, description=f"AMK Result must be one of {DRUG_RESULT_VALUES}"
    )
    eth_result: Optional[str] = Field(
        default=None, description=f"ETH Result must be one of {DRUG_RESULT_VALUES}"
    )
    uninterpretable_result: Optional[str] = Field(
        default=None,
        description=f"Uninterpretable Result must be one of {UNINTERPRETABLE_RESULT_VALUES}",
    )
    error_code: Optional[str] = Field(
        default=None,
        description="The instrument error code, required for an ERROR result",
    )
    spc_ahpc: Optional[float] = Field(
        default=None, description="The SPC-ahpC cycle threshold value"
    )
    inha: Optional[float] = Field(
        default=None, description="The inhA cycle threshold value"
    )
    katg: Optional[float] = Field(
        default=None, description="The KatG cycle threshold value"
    )
    fabg1: Optional[float] = Field(
        default=None, description="The fabG1 cycle threshold value"
    )
    gyra1: Optional[float] = Field(
        default=None, description="The gyrA1 cycle threshold value"
    )
    gyra2: Optional[float] = Field(
        default=None, description="The gyrA2 cycle threshold value"
    )
    gyra3: Optional[float] = Field(
        default=None, description="The gyrA3 cycle threshold value"
    )
    gyrb2: Optional[float] = Field(
        default=None, description="The gyrB2 cycle threshold value"
    )
    rrs: Optional[float] = Field(
        default=None, description="The rrs cycle threshold value"
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

    @validator("result_interpretable")
    def check_result_interpretable(cls, value):
        return _check_allowed(
            "Result Interpretable", value, RESULT_INTERPRETABLE_VALUES
        )

    @validator("tb_detection_result")
    def check_tb_detection_result(cls, value):
        return _check_allowed(
            "TB Detection Result", value, TB_DETECTION_RESULT_VALUES
        )

    @validator(*DRUG_RESULT_FIELDS)
    def check_drug_result(cls, value, field):
        return _check_allowed(
            DRUG_RESULT_LABELS[field.name], value, DRUG_RESULT_VALUES
        )

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
                f"The {CT_VALUE_LABELS[field.name]} cycle threshold must be "
                "between 0 and 100"
            )
        return value

    @root_validator
    def check_result_is_consistent(cls, values):
        """Applies the rules on form CDL-PT-F-027.

        A draft may be incomplete - the lab captures the panel over several
        sittings - but the moment it is submitted for review it has to be a
        result a reviewer can actually grade.
        """
        interpretable = values.get("result_interpretable")
        detection = values.get("tb_detection_result")
        uninterpretable = values.get("uninterpretable_result")
        error_code = values.get("error_code")

        drugs = {name: values.get(name) for name in DRUG_RESULT_FIELDS}
        any_drug = any(value for value in drugs.values())

        # a sample is either interpretable or it is not - never both
        if interpretable == "Yes" and uninterpretable:
            raise ValueError(
                "An Uninterpretable Result cannot be recorded when the result is interpretable"
            )

        if interpretable == "No" and (detection or any_drug):
            raise ValueError(
                "A TB Detection Result or drug resistance result cannot be "
                "recorded when the result is not interpretable"
            )

        # an error code only belongs to an ERROR
        if error_code and uninterpretable != UNINTERPRETABLE_RESULT_REQUIRING_CODE:
            raise ValueError(
                "An Error Code can only be recorded for an ERROR result"
            )

        # the drug resistance probes only report against a detected complex
        if detection == "NOT DETECTED":
            reported = [
                DRUG_RESULT_LABELS[name]
                for name, value in drugs.items()
                if value and value != "N/A"
            ]
            if reported:
                raise ValueError(
                    "A drug resistance result cannot be DETECTED or NOT DETECTED "
                    "when the TB Detection Result is NOT DETECTED. Use N/A for "
                    f"{', '.join(reported)}"
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

            missing = [
                DRUG_RESULT_LABELS[name]
                for name, value in drugs.items()
                if not value
            ]
            if missing:
                raise ValueError(
                    "Every drug resistance result must be provided for an "
                    f"interpretable result. Missing: {', '.join(missing)}"
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

        # the Ct values are read off the instrument print out for every
        # successful test, so they are only expected for an interpretable result
        if interpretable == "Yes":
            missing = [
                CT_VALUE_LABELS[name]
                for name in CT_VALUE_FIELDS
                if values.get(name) is None
            ]
            if missing:
                raise ValueError(
                    "The cycle threshold (Ct) values must be provided for an "
                    f"interpretable result. Missing: {', '.join(missing)}"
                )

        return values

    class Config:
        orm_mode = True

class TBXpertXDRResultWithDetail(TBXpertXDRResult):
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

class ParamTBXpertXDRResultEdit(BaseModel):
    tbxpertxdrresult: Optional[TBXpertXDRResultWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    enrollmentList: Optional[List[Enrollment]] = []
    ptcycleList: Optional[List[PTCycle]] = []
    methodList: Optional[List[Method]] = []
    methodsampleList: Optional[List[MethodSample]] = []

    class Config:
        orm_mode = True
