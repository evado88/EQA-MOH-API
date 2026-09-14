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
# taken from form TF-009 'HIV-1 Viral Load (HIV-1 VL) Result Report Form'
RESULT_REPORTED_VALUES = ["Yes", "No"]

# a viral load is reported as log10 copies/ml. Undetectable is reported as 0;
# the upper bound is well above any assay's linear range, so it only catches a
# value entered in copies/ml by mistake.
VIRAL_LOAD_MIN = 0.0
VIRAL_LOAD_MAX = 10.0

# the panel header the lab fills in once per shipment. It is held on every
# result row so each row stays independently reviewable, the way the Ultra and
# XDR sheets are.
PANEL_FIELDS = [
    "date_panel_received",
    "date_tested",
    "detection_assay",
    "extraction_assay",
    "assay_kit_lot_number",
    "assay_kit_expiry_date",
    "assay_serial_number",
]

PANEL_LABELS = {
    "date_panel_received": "Date PT Panel Received",
    "date_tested": "Date PT Panel Tested",
    "detection_assay": "Detection Assay",
    "extraction_assay": "Extraction Assay",
    "assay_kit_lot_number": "Assay Kit Lot Number",
    "assay_kit_expiry_date": "Assay Kit Expiration Date",
    "assay_serial_number": "Assay Serial Number",
}

# what a submitted, tested result has to carry before a reviewer can grade it
REQUIRED_ON_SUBMIT = [
    "date_panel_received",
    "date_tested",
    "detection_assay",
    "extraction_assay",
]


def _check_allowed(label, value, allowed):
    """Rejects a value the form does not offer as a choice"""
    if value is None or value == "":
        return None

    cleaned = value.strip()
    for option in allowed:
        if cleaned.upper() == option.upper():
            return option

    raise ValueError(f"{label} must be one of {', '.join(allowed)}")


# ---------- SQLAlchemy Models ----------
class HIVVLResultDB(Base):
    __tablename__ = "hiv_vl_results"
    # one result per sample, per lab, per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id",
            name="uq_hiv_vl_results_cycle_lab_sample",
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
    assay_kit_lot_number = Column(String, nullable=True)
    assay_kit_expiry_date = Column(Date, nullable=True)
    assay_serial_number = Column(String, nullable=True)

    # the result itself
    result_reported = Column(String, nullable=True)
    viral_load_log10 = Column(Float, nullable=True)
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
    user = relationship("UserDB", back_populates="hivvlresult", lazy='raise')
    status = relationship("StatusDB", back_populates="hivvlresult", lazy='raise')
    stage = relationship("StageDB", back_populates="hivvlresult", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="hivvlresult", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="hivvlresult", lazy='raise')
    service = relationship("ServiceDB", back_populates="hivvlresult", lazy='raise')
    enrollment = relationship("EnrollmentDB", back_populates="hivvlresult", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="hivvlresult", lazy='raise')
    method = relationship("MethodDB", back_populates="hivvlresult", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="hivvlresult", lazy='raise')

    #links

# ---------- Pydantic Schemas ----------
class HIVVLResult(BaseModel):
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

    # panel header - optional on the model so a lab can save a partly captured
    # panel; the rules below are what make a result submittable
    date_panel_received: Optional[date] = Field(
        default=None, description="The date the PT panel arrived at the laboratory"
    )
    date_tested: Optional[date] = Field(
        default=None, description="The date the PT panel was tested"
    )
    detection_assay: Optional[str] = Field(
        default=None, description="The detection assay used, e.g. GeneXpert"
    )
    extraction_assay: Optional[str] = Field(
        default=None, description="The extraction assay used, e.g. Cobas 4800"
    )
    assay_kit_lot_number: Optional[str] = Field(
        default=None, description="The assay kit lot number"
    )
    assay_kit_expiry_date: Optional[date] = Field(
        default=None, description="The assay kit expiration date"
    )
    assay_serial_number: Optional[str] = Field(
        default=None, description="The assay serial number"
    )

    # the result
    result_reported: Optional[str] = Field(
        default=None,
        description=f"Whether the sample was tested, one of {RESULT_REPORTED_VALUES}",
    )
    viral_load_log10: Optional[float] = Field(
        default=None, description="The viral load result in log10 copies/ml"
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

    @validator("viral_load_log10")
    def check_viral_load(cls, value):
        if value is None:
            return None

        if value < VIRAL_LOAD_MIN or value > VIRAL_LOAD_MAX:
            raise ValueError(
                "The Viral Load Result must be between "
                f"{VIRAL_LOAD_MIN} and {VIRAL_LOAD_MAX} log10 copies/ml. A value "
                "outside that range is usually copies/ml entered by mistake"
            )
        return value

    @root_validator
    def check_result_is_consistent(cls, values):
        """Applies the rules on form TF-009.

        A draft may be incomplete - the lab captures the panel over several
        sittings - but the moment it is submitted for review it has to be a
        result a reviewer can actually grade.
        """
        reported = values.get("result_reported")
        viral_load = values.get("viral_load_log10")
        reason = values.get("not_tested_reason")

        # a sample was either tested or it was not - never both
        if reported == "Yes" and reason:
            raise ValueError(
                "A reason for not testing cannot be recorded when a result was reported"
            )

        if reported == "No" and viral_load is not None:
            raise ValueError(
                "A Viral Load Result cannot be recorded when the sample was not tested"
            )

        if values.get("status_id") != assist.STATUS_SUBMITTED:
            # still a draft, an incomplete panel is fine
            return values

        if not reported:
            raise ValueError(
                "Please indicate whether a result was reported for this sample"
            )

        if reported == "Yes":
            if viral_load is None:
                raise ValueError(
                    "The Viral Load Result must be provided in log10 copies/ml"
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

class HIVVLResultWithDetail(HIVVLResult):
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

class ParamHIVVLResultEdit(BaseModel):
    hivvlresult: Optional[HIVVLResultWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    enrollmentList: Optional[List[Enrollment]] = []
    ptcycleList: Optional[List[PTCycle]] = []
    methodList: Optional[List[Method]] = []
    methodsampleList: Optional[List[MethodSample]] = []

    class Config:
        orm_mode = True
