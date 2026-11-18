"""CLSI zone-diameter breakpoints: the reference ranges the AST report cites.

The scheme scores AST on the interpretation a laboratory reports (S/I/SDD/R),
not on the millimetres - see helpers/evaluation._grade_ast. These breakpoints
are reference only: they let the feedback report print the expected zone
diameter range beside each antibiotic, the way the paper form TF-NHRTI-BACT-008
does, so a participant can see where their reading fell.

They are deliberately a table, not code, because CLSI M100 revises them every
year and they are organism-group specific. They carry a source and a 'verified'
flag so a seeded starting set is clearly provisional until a microbiologist has
checked it against the laboratory's current edition.
"""
from sqlalchemy import (
    Boolean, Column, Float, Integer, String, DateTime, UniqueConstraint,
)
from pydantic import BaseModel, Field
from typing import Optional, List
from database import Base
from datetime import datetime


# disk diffusion is the method the zone diameter belongs to; MIC breakpoints are
# in different units and are not modelled here
METHOD_DISK_DIFFUSION = "disk_diffusion"


class CLSIBreakpointDB(Base):
    __tablename__ = "clsi_breakpoints"
    __table_args__ = (
        UniqueConstraint(
            "organism_group", "antibiotic", "method",
            name="uq_clsi_breakpoints_group_antibiotic_method",
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # the CLSI organism group the breakpoint applies to, e.g. 'Enterobacterales'
    organism_group = Column(String, nullable=False, index=True)
    # the antibiotic, upper-cased to match the reported agent
    antibiotic = Column(String, nullable=False)
    method = Column(String, nullable=False, default=METHOD_DISK_DIFFUSION)

    # the disk potency, printed for context, e.g. '30 ug'
    disk_content = Column(String, nullable=True)

    # the zone-diameter thresholds in millimetres:
    #   susceptible  when  zone >= susceptible_min
    #   resistant    when  zone <= resistant_max
    #   intermediate is the band between them
    susceptible_min = Column(Integer, nullable=True)
    resistant_max = Column(Integer, nullable=True)
    # a few agents (cefepime against Enterobacterales) report SDD over a band of
    # their own rather than an intermediate
    sdd_min = Column(Integer, nullable=True)
    sdd_max = Column(Integer, nullable=True)

    # which edition these came from, and whether a human has checked them
    source = Column(String, nullable=True)
    verified = Column(Boolean, nullable=False, default=False)
    notes = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)


class CLSIBreakpoint(BaseModel):
    id: Optional[int] = None
    organism_group: str = Field(..., description="The CLSI organism group")
    antibiotic: str = Field(..., description="The antibiotic")
    method: str = METHOD_DISK_DIFFUSION
    disk_content: Optional[str] = None
    susceptible_min: Optional[int] = None
    resistant_max: Optional[int] = None
    sdd_min: Optional[int] = None
    sdd_max: Optional[int] = None
    source: Optional[str] = None
    verified: bool = False
    notes: Optional[str] = None

    class Config:
        orm_mode = True


class SaveBreakpoints(BaseModel):
    user_id: int = Field(..., ge=1, description="User must be provided")
    breakpoints: List[CLSIBreakpoint] = []


class SaveBreakpointsResult(BaseModel):
    succeeded: bool
    message: str
    saved: int = 0
