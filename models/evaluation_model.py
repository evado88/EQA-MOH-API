"""The evaluation layer: what a PT round concluded about each participant.

These tables are written once, when a cycle moves to 'Report Available', and
are not recomputed afterwards. A PT report has to be reproducible: if the
group mean were recalculated at render time, a late or amended submission
would silently rewrite every report already issued for that round.

They carry plain typed columns and no ORM relationships, because their main
consumer is XtraReports through the reporting views, not the API.
"""
from sqlalchemy import (
    Boolean, Column, Float, Integer, String, Date, DateTime, ForeignKey,
    UniqueConstraint,
)
from pydantic import BaseModel, Field
from typing import Optional, List
from database import Base
from datetime import date, datetime


# ---------- SQLAlchemy Models ----------
class PTSampleStatisticsDB(Base):
    """What all the participants together reported for one sample in one round."""

    __tablename__ = "pt_sample_statistics"
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "method_sample_id", "attribute",
            name="uq_pt_sample_statistics_cycle_sample_attribute",
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # what this row describes
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    method_sample_id = Column(Integer, ForeignKey("method_samples.id"), nullable=False)
    # the panel material these participants share, pooled across platforms
    sample_group = Column(String, nullable=True)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)

    # the form the results came from, and the field on it being graded
    result_form = Column(String, nullable=False)
    attribute = Column(String, nullable=False)
    attribute_label = Column(String, nullable=True)
    evaluation_kind = Column(String, nullable=False)

    # the value results are graded against
    assigned_value_numeric = Column(Float, nullable=True)
    assigned_value_text = Column(String, nullable=True)
    assigned_value_source = Column(String, nullable=True)

    # the participant distribution
    participant_count = Column(Integer, nullable=False, default=0)
    reported_count = Column(Integer, nullable=False, default=0)

    # quantitative
    group_mean = Column(Float, nullable=True)
    group_median = Column(Float, nullable=True)
    robust_sd = Column(Float, nullable=True)
    standard_sd = Column(Float, nullable=True)
    minimum_value = Column(Float, nullable=True)
    maximum_value = Column(Float, nullable=True)

    # qualitative
    concordant_count = Column(Integer, nullable=True)

    # why a sample could not be graded at all
    evaluated = Column(Boolean, nullable=False, default=False)
    not_evaluated_reason = Column(String, nullable=True)

    # the freeze
    frozen_at = Column(DateTime(timezone=True), nullable=True)
    frozen_by = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


class PTResultEvaluationDB(Base):
    """What one laboratory scored on one sample."""

    __tablename__ = "pt_result_evaluations"
    __table_args__ = (
        UniqueConstraint(
            "result_form", "result_id", "attribute",
            name="uq_pt_result_evaluations_result_attribute",
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # what this row describes
    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)
    enrollment_id = Column(Integer, ForeignKey("enrollments.id"), nullable=False)
    method_sample_id = Column(Integer, ForeignKey("method_samples.id"), nullable=False)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)

    # the row in whichever result table this came from
    result_form = Column(String, nullable=False)
    result_id = Column(Integer, nullable=False)
    attribute = Column(String, nullable=False)
    attribute_label = Column(String, nullable=True)

    # what the lab said
    reported_numeric = Column(Float, nullable=True)
    reported_text = Column(String, nullable=True)

    # what it was graded against, copied here so the report never has to
    # recompute it
    assigned_numeric = Column(Float, nullable=True)
    assigned_text = Column(String, nullable=True)
    group_mean = Column(Float, nullable=True)
    robust_sd = Column(Float, nullable=True)

    # the outcome
    deviation = Column(Float, nullable=True)
    z_score = Column(Float, nullable=True)
    score = Column(Integer, nullable=False, default=0)
    max_score = Column(Integer, nullable=False, default=0)
    grade = Column(String, nullable=False)

    evaluated = Column(Boolean, nullable=False, default=False)
    not_evaluated_reason = Column(String, nullable=True)

    frozen_at = Column(DateTime(timezone=True), nullable=True)
    frozen_by = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


class PTEnrollmentPerformanceDB(Base):
    """One laboratory's overall standing for one enrolment."""

    __tablename__ = "pt_enrollment_performance"
    __table_args__ = (
        UniqueConstraint(
            "enrollment_id", name="uq_pt_enrollment_performance_enrollment"
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    pt_cycle_id = Column(Integer, ForeignKey("pt_cycles.id"), nullable=False)
    lab_id = Column(Integer, ForeignKey("laboratorys.id"), nullable=False)
    enrollment_id = Column(Integer, ForeignKey("enrollments.id"), nullable=False)
    method_id = Column(Integer, ForeignKey("methods.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)

    result_form = Column(String, nullable=False)

    # the report identifier a participant quotes back at the provider
    report_number = Column(String, nullable=True)

    attributes_total = Column(Integer, nullable=False, default=0)
    attributes_evaluated = Column(Integer, nullable=False, default=0)
    acceptable_count = Column(Integer, nullable=False, default=0)
    warning_count = Column(Integer, nullable=False, default=0)
    unacceptable_count = Column(Integer, nullable=False, default=0)
    not_reported_count = Column(Integer, nullable=False, default=0)

    total_score = Column(Integer, nullable=False, default=0)
    max_score = Column(Integer, nullable=False, default=0)
    percent_score = Column(Float, nullable=True)

    overall_performance = Column(String, nullable=False)
    reason_for_no_evaluation = Column(String, nullable=True)

    frozen_at = Column(DateTime(timezone=True), nullable=True)
    frozen_by = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


# ---------- Pydantic Schemas ----------
class PTSampleStatistics(BaseModel):
    id: Optional[int] = None
    pt_cycle_id: int
    method_sample_id: int
    sample_group: Optional[str] = None
    method_id: int
    service_id: int
    scheme_id: int

    result_form: str
    attribute: str
    attribute_label: Optional[str] = None
    evaluation_kind: str

    assigned_value_numeric: Optional[float] = None
    assigned_value_text: Optional[str] = None
    assigned_value_source: Optional[str] = None

    participant_count: int = 0
    reported_count: int = 0

    group_mean: Optional[float] = None
    group_median: Optional[float] = None
    robust_sd: Optional[float] = None
    standard_sd: Optional[float] = None
    minimum_value: Optional[float] = None
    maximum_value: Optional[float] = None

    concordant_count: Optional[int] = None

    evaluated: bool = False
    not_evaluated_reason: Optional[str] = None

    frozen_at: Optional[datetime] = None
    frozen_by: Optional[str] = None

    class Config:
        orm_mode = True


class PTResultEvaluation(BaseModel):
    id: Optional[int] = None
    pt_cycle_id: int
    lab_id: int
    enrollment_id: int
    method_sample_id: int
    method_id: int
    service_id: int
    scheme_id: int

    result_form: str
    result_id: int
    attribute: str
    attribute_label: Optional[str] = None

    reported_numeric: Optional[float] = None
    reported_text: Optional[str] = None

    assigned_numeric: Optional[float] = None
    assigned_text: Optional[str] = None
    group_mean: Optional[float] = None
    robust_sd: Optional[float] = None

    deviation: Optional[float] = None
    z_score: Optional[float] = None
    score: int = 0
    max_score: int = 0
    grade: str

    evaluated: bool = False
    not_evaluated_reason: Optional[str] = None

    frozen_at: Optional[datetime] = None
    frozen_by: Optional[str] = None

    class Config:
        orm_mode = True


class PTEnrollmentPerformance(BaseModel):
    id: Optional[int] = None
    pt_cycle_id: int
    lab_id: int
    enrollment_id: int
    method_id: int
    service_id: int
    scheme_id: int

    result_form: str
    report_number: Optional[str] = None

    attributes_total: int = 0
    attributes_evaluated: int = 0
    acceptable_count: int = 0
    warning_count: int = 0
    unacceptable_count: int = 0
    not_reported_count: int = 0

    total_score: int = 0
    max_score: int = 0
    percent_score: Optional[float] = None

    overall_performance: str
    reason_for_no_evaluation: Optional[str] = None

    frozen_at: Optional[datetime] = None
    frozen_by: Optional[str] = None

    class Config:
        orm_mode = True


class ParamEvaluateCycle(BaseModel):
    """Posted by an administrator to freeze, or re-freeze, a round."""

    user_id: int = Field(..., ge=1, description="User must be provided")
    recompute: bool = Field(
        default=False,
        description=(
            "Re-evaluate a round that has already been frozen. This changes "
            "reports that have already been issued, so it is deliberate."
        ),
    )
    comments: Optional[str] = None


class EvaluateCycleResult(BaseModel):
    succeeded: bool
    message: str
    pt_cycle_id: int
    sample_statistics: int = 0
    result_evaluations: int = 0
    enrollment_performances: int = 0


class MethodSampleExpectedValueDB(Base):
    """The stated correct answer for one field of one manufactured sample.

    A sample is graded on more than one field - an Ultra sample on both TB
    Detection and Rif - so the value belongs here rather than on the sample.
    """

    __tablename__ = "method_sample_expected_values"
    __table_args__ = (
        UniqueConstraint(
            "method_sample_id", "attribute",
            name="uq_method_sample_expected_values_sample_attribute",
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    method_sample_id = Column(
        Integer, ForeignKey("method_samples.id", ondelete="CASCADE"), nullable=False
    )
    attribute = Column(String, nullable=False)
    expected_value_numeric = Column(Float, nullable=True)
    expected_value_text = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


class MethodSampleExpectedValue(BaseModel):
    id: Optional[int] = None
    method_sample_id: int
    attribute: str
    expected_value_numeric: Optional[float] = None
    expected_value_text: Optional[str] = None

    class Config:
        orm_mode = True
