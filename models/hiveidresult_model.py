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
# taken from form TF-012 'HIV-1 Early Infant Diagnosis (HIV-1 EID) Result
# Report Form'
RESULT_REPORTED_VALUES = ["Yes", "No"]

# the form is explicit: "use the exact phrase 'HIV-1 Detected' or
# 'HIV-1 Not Detected'"
HIV_RESULT_DETECTED = "HIV-1 Detected"
HIV_RESULT_NOT_DETECTED = "HIV-1 Not Detected"

HIV_RESULT_VALUES = [HIV_RESULT_DETECTED, HIV_RESULT_NOT_DETECTED]

# the panel header the lab fills in once per shipment. EID asks for fewer
# details than the viral load form - there is no kit lot or expiry date.
PANEL_FIELDS = [
    "date_panel_received",
    "date_tested",
    "detection_assay",
    "extraction_assay",
    "assay_serial_number",
]

PANEL_LABELS = {
    "date_panel_received": "Date PT Panel Received",
    "date_tested": "Date PT Panel Tested",
    "detection_assay": "Detection Assay",
    "extraction_assay": "Extraction Assay",
    "assay_serial_number": "Assay Serial Number",
}

# what a submitted, tested result has to carry before it can be graded
REQUIRED_ON_SUBMIT = [
    "date_panel_received",
    "date_tested",
    "detection_assay",
    "extraction_assay",
]

# the CT/OD and IC/QS columns are marked optional on the form
OPTIONAL_VALUE_MIN = 0.0
OPTIONAL_VALUE_MAX = 100.0


def _check_allowed(label, value, allowed):
    """Rejects a value the form does not offer as a choice"""
    if value is None or value == "":
        return None

    cleaned = " ".join(str(value).split())
    for option in allowed:
        if cleaned.upper() == option.upper():
            # the form asks for an exact phrase, so return the exact phrase
            return option

    raise ValueError(f"{label} must be one of {', '.join(allowed)}")


# ---------- SQLAlchemy Models ----------
class HIVEIDResultDB(Base):
    __tablename__ = "hiv_eid_results"
    # one result per sample, per lab, per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id",
            name="uq_hiv_eid_results_cycle_lab_sample",
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

    # panel header
    date_panel_received = Column(Date, nullable=True)
    date_tested = Column(Date, nullable=True)
    detection_assay = Column(String, nullable=True)
    extraction_assay = Column(String, nullable=True)
    assay_serial_number = Column(String, nullable=True)

    # the result itself
    result_reported = Column(String, nullable=True)
    hiv_result = Column(String, nullable=True)
    hiv_ct_od_value = Column(Float, nullable=True)
    ic_qs_value = Column(Float, nullable=True)
    not_tested_reason = Column(String, nullable=True)

    # sign off
    tested_by = Column(String, nullable=True)
    supervisor_name = Column(String, nullable=True)

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
    user = relationship("UserDB", back_populates="hiveidresult", lazy='raise')
    status = relationship("StatusDB", back_populates="hiveidresult", lazy='raise')
    stage = relationship("StageDB", back_populates="hiveidresult", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="hiveidresult", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="hiveidresult", lazy='raise')
    service = relationship("ServiceDB", back_populates="hiveidresult", lazy='raise')
    enrollment = relationship("EnrollmentDB", back_populates="hiveidresult", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="hiveidresult", lazy='raise')
    method = relationship("MethodDB", back_populates="hiveidresult", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="hiveidresult", lazy='raise')

    #links

# ---------- Pydantic Schemas ----------
class HIVEIDResult(BaseModel):
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
    scheme_id: int = Field(..., description="Scheme must be provided")
    lab_id: int = Field(..., description="Laboratory must be provided")
    service_id: int = Field(..., description="Service must be provided")
    enrollment_id: int = Field(..., description="Enrollment must be provided")
    pt_cycle_id: int = Field(..., description="Cycle must be provided")
    method_id: int = Field(..., description="Method must be provided")
    method_sample_id: int = Field(..., description="Method Sample must be provided")

    # panel header - optional on the model so a lab can save a partly captured
    # panel; the rules below are what make a result submittable
    date_panel_received: Optional[date] = Field(
        default=None, description="The date the PT panel arrived at the laboratory"
    )
    date_tested: Optional[date] = Field(
        default=None, description="The date the PT panel was tested"
    )
    detection_assay: Optional[str] = Field(
        default=None, description="The detection assay used, e.g. Cobas 4800"
    )
    extraction_assay: Optional[str] = Field(
        default=None, description="The extraction assay used, e.g. Hologic Panther"
    )
    assay_serial_number: Optional[str] = Field(
        default=None, description="The assay serial number"
    )

    # the result
    result_reported: Optional[str] = Field(
        default=None,
        description=f"Whether the sample was tested, one of {RESULT_REPORTED_VALUES}",
    )
    hiv_result: Optional[str] = Field(
        default=None,
        description=f"The result, exactly one of {HIV_RESULT_VALUES}",
    )
    hiv_ct_od_value: Optional[float] = Field(
        default=None, description="The HIV CT/OD value, optional on the form"
    )
    ic_qs_value: Optional[float] = Field(
        default=None, description="The IC/QS value, optional on the form"
    )
    not_tested_reason: Optional[str] = Field(
        default=None, description="Why the sample could not be tested"
    )

    # sign off
    tested_by: Optional[str] = Field(
        default=None, description="The person who performed the test"
    )
    supervisor_name: Optional[str] = Field(
        default=None, description="The supervisor who reviewed the panel results"
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

    @validator("result_reported")
    def check_result_reported(cls, value):
        return _check_allowed("Result Reported", value, RESULT_REPORTED_VALUES)

    @validator("hiv_result")
    def check_hiv_result(cls, value):
        return _check_allowed("Your Result", value, HIV_RESULT_VALUES)

    @validator("hiv_ct_od_value", "ic_qs_value")
    def check_optional_value(cls, value, field):
        if value is None:
            return None

        if value < OPTIONAL_VALUE_MIN or value > OPTIONAL_VALUE_MAX:
            label = (
                "HIV CT/OD Value"
                if field.name == "hiv_ct_od_value"
                else "IC/QS Value"
            )
            raise ValueError(
                f"The {label} must be between {OPTIONAL_VALUE_MIN} and "
                f"{OPTIONAL_VALUE_MAX}"
            )
        return value

    @root_validator
    def check_result_is_consistent(cls, values):
        """Applies the rules on form TF-012.

        A draft may be incomplete - the lab captures the panel over several
        sittings - but the moment it is submitted for review it has to be a
        result a reviewer can actually grade.
        """
        reported = values.get("result_reported")
        hiv_result = values.get("hiv_result")
        reason = values.get("not_tested_reason")

        # a sample was either tested or it was not - never both
        if reported == "Yes" and reason:
            raise ValueError(
                "A reason for not testing cannot be recorded when a result was reported"
            )

        if reported == "No" and hiv_result:
            raise ValueError(
                "A result cannot be recorded when the sample was not tested"
            )

        if values.get("status_id") != assist.STATUS_SUBMITTED:
            # still a draft, an incomplete panel is fine
            return values

        if not reported:
            raise ValueError(
                "Please indicate whether a result was reported for this sample"
            )

        if reported == "Yes":
            if not hiv_result:
                raise ValueError(
                    f"Your Result must be provided, exactly one of "
                    f"{' or '.join(HIV_RESULT_VALUES)}"
                )

            missing = [
                PANEL_LABELS[name]
                for name in REQUIRED_ON_SUBMIT
                if not values.get(name)
            ]
            if missing:
                raise ValueError(
                    "The panel details must be provided before the result can be "
                    f"submitted. Missing: {', '.join(missing)}"
                )
        else:
            if not reason:
                raise ValueError(
                    "Please give the reason the sample could not be tested"
                )

            if not values.get("date_panel_received"):
                raise ValueError(
                    f"The {PANEL_LABELS['date_panel_received']} must be provided"
                )

        return values

    class Config:
        orm_mode = True

class HIVEIDResultWithDetail(HIVEIDResult):
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

class ParamHIVEIDResultEdit(BaseModel):
    hiveidresult: Optional[HIVEIDResultWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    enrollmentList: Optional[List[Enrollment]] = []
    ptcycleList: Optional[List[PTCycle]] = []
    methodList: Optional[List[Method]] = []
    methodsampleList: Optional[List[MethodSample]] = []

    class Config:
        orm_mode = True
