from sqlalchemy import Boolean, Column, Float, Integer, String, Date, DateTime, ForeignKey, UniqueConstraint
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
# taken from worksheet TF-NHRTI-BACT-001 'Bacteriology Participant's Worksheet'

SAMPLE_CONDITION_SUITABLE = "Suitable"
SAMPLE_CONDITION_UNSUITABLE = "Unsuitable"
SAMPLE_CONDITION_VALUES = [SAMPLE_CONDITION_SUITABLE, SAMPLE_CONDITION_UNSUITABLE]

# the STAIN REACTION column
GRAM_STAIN_REACTION_VALUES = [
    "Gram positive",
    "Gram negative",
    "Gram variable",
]

# the MORPHOLOGY column. 'Other' is the worksheet's 'Others:' box, and is the
# one choice that carries free text alongside it
GRAM_MORPHOLOGY_OTHER = "Other"
GRAM_MORPHOLOGY_VALUES = [
    "Cocci",
    "Diplococci",
    "Bacilli",
    "Yeast",
    "Cocco-bacilli",
    GRAM_MORPHOLOGY_OTHER,
]

# 'insert applicable guidelines: CLSI or EUCAST'
AST_GUIDELINE_VALUES = ["CLSI", "EUCAST"]

# the MIC METHOD choices, manual first then the automated systems
AST_MIC_METHOD_OTHER = "Other"
AST_MIC_METHOD_VALUES = [
    "Broth Microdilution in house",
    "Etest",
    "Vitek 2",
    "MicroScan",
    "AutoMic",
    "Maldi Tof",
    AST_MIC_METHOD_OTHER,
]

# the two AST tables on the worksheet
AST_METHOD_DISK_DIFFUSION = "disk_diffusion"
AST_METHOD_MIC = "mic"
AST_METHOD_VALUES = [AST_METHOD_DISK_DIFFUSION, AST_METHOD_MIC]

AST_METHOD_LABELS = {
    AST_METHOD_DISK_DIFFUSION: "Disk Diffusion Method (Kirby Bauer)",
    AST_METHOD_MIC: "MIC Method",
}

# the S / I / SDD / R columns
AST_INTERPRETATION_VALUES = ["S", "I", "SDD", "R"]

AST_INTERPRETATION_LABELS = {
    "S": "Susceptible",
    "I": "Intermediate",
    "SDD": "Susceptible-Dose Dependent",
    "R": "Resistant",
}

# each AST table on the worksheet is numbered 1 to 15
AST_MAX_ROWS = 15

# The bacterial identification menu, from the NHRTI Master Organism Catalogue.
# Offered as the Bacterial Identification dropdown; values are kept consistent
# with the scheme report/reference list.
ORGANISM_CATALOGUE = [
    'Escherichia coli',
    'Escherichia coli O157:H7',
    'Escherichia albertii',
    'Escherichia fergusonii',
    'Escherichia spp',
    'Klebsiella pneumoniae',
    'Klebsiella oxytoca',
    'Klebsiella variicola',
    'Klebsiella aerogenes',
    'Klebsiella quasipneumoniae',
    'Klebsiella spp',
    'Enterobacter cloacae complex',
    'Enterobacter spp',
    'Citrobacter freundii complex',
    'Citrobacter koseri',
    'Citrobacter spp',
    'Serratia marcescens',
    'Serratia liquefaciens',
    'Serratia fonticola',
    'Serratia spp',
    'Proteus mirabilis',
    'Proteus vulgaris',
    'Proteus penneri',
    'Proteus spp',
    'Morganella morganii',
    'Morganella spp',
    'Providencia stuartii',
    'Providencia rettgeri',
    'Providencia alcalifaciens',
    'Providencia spp',
    'Salmonella enterica serovar Typhi',
    'Salmonella enterica serovar Paratyphi A',
    'Salmonella enterica serovar Paratyphi B',
    'Salmonella enterica serovar Paratyphi C',
    'Other Salmonella spp.',
    'Shigella flexneri',
    'Shigella sonnei',
    'Shigella dysenteriae',
    'Shigella boydii',
    'Shigella spp',
    'Yersinia enterocolitica',
    'Yersinia pseudotuberculosis',
    'Yersinia spp',
    'Edwardsiella tarda',
    'Edwardsiella spp',
    'Cronobacter sakazakii',
    'Pantoea(Enterobacter) agglomerans',
    'Raoultella ornithinolytica',
    'Raoultella planticola',
    'Raoultella spp',
    'Pseudomonas aeruginosa',
    'Pseudomonas putida',
    'Pseudomonas spp',
    'Stenotrophomonas maltophilia',
    'Burkholderia cepacia complex',
    'Burkholderia pseudomallei',
    'Acinetobacter baumannii',
    'Acinetobacter nosocomialis',
    'Acinetobacter pittii',
    'Achromobacter xylosoxidans',
    'Elizabethkingia meningoseptica',
    'Chryseobacterium spp.',
    'Vibrio cholerae O1',
    'Vibrio cholerae non-O1/non-O139',
    'Vibrio parahaemolyticus',
    'Vibrio vulnificus',
    'Vibro spp',
    'Aeromonas hydrophila',
    'Aeromonas caviae',
    'Aeromonas veronii',
    'Plesiomonas shigelloides',
    'Campylobacter jejuni',
    'Campylobacter coli',
    'Campylobacter spp',
    'Staphylococcus aureus',
    'Staphylococcus epidermidis',
    'Staphylococcus saprophyticus',
    'Staphylococcus haemolyticus',
    'Staphylococcus hominis',
    'Staphylococcus lugdunensis',
    'Staphylococcus capitis',
    'Staphylococcus warneri',
    'Staphylococcus simulans',
    'Staphylococcus schleiferi',
    'Staphylococcus cohnii',
    'Staphylococcus xylosus',
    'Staphylococcus sciuri',
    'Staphylococcus spp',
    'Other coagulase-negative Staphylococcus spp.',
    'Streptococcus pneumoniae',
    'Streptococcus pyogenes',
    'Streptococcus agalactiae',
    'Streptococcus dysgalactiae',
    'Streptococcus anginosus',
    'Streptococcus constellatus',
    'Streptococcus intermedius',
    'Viridans group streptococci',
    'Streptococcus gallolyticus',
    'Streptococcus spp',
    'Enterococcus faecalis',
    'Enterococcus faecium',
    'Enterococcus gallinarum',
    'Enterococcus casseliflavus',
    'Enterococcus spp',
    'Neisseria gonorrhoeae',
    'Neisseria meningitidis',
    'Neisseria lactamica',
    'Neisseria sicca',
    'Neisseria subflava',
    'Neisseria spp',
    'Moraxella catarrhalis',
    'Haemophilus influenzae',
    'Haemophilus parainfluenzae',
    'Haemophilus haemolyticus',
    'Haemophilus parahaemolyticus',
    'Haemophilus spp',
    'Corynebacterium diphtheriae',
    'Corynebacterium ulcerans',
    'Corynebacterium jeikeium',
    'Corynebacterium striatum',
    'Corynebacterium amycolatum',
    'Corynebacterium spp',
    'Listeria monocytogenes',
    'Listeria spp',
    'Bacillus cereus',
    'Bacillus anthracis',
    'Bacillus spp',
    'Clostridium perfringens',
    'Clostridioides difficile',
    'Clostridium tetani',
    'Clostridium botulinum',
    'Clostridium spp',
    'Bacteroides fragilis group',
    'Prevotella spp.',
    'Fusobacterium spp.',
    'Peptostreptococcus spp.',
    'Clostridium septicum',
    'No growth',
]


# What the antibiotic dropdown offers. The worksheet leaves the list to the
# testing guideline rather than fixing it, and a laboratory may report an agent
# this list has not caught up with, so this is offered as a suggestion and a
# value outside it is still accepted - see check_antibiotic.
ANTIBIOTIC_SUGGESTIONS = [
    "AMIKACIN",
    "AMOXICILLIN-CLAVULANATE",
    "AMPICILLIN",
    "AZITHROMYCIN",
    "AZTREONAM",
    "CEFAZOLIN",
    "CEFEPIME",
    "CEFOTAXIME",
    "CEFOXITIN",
    "CEFTAZIDIME",
    "CEFTRIAXONE",
    "CEFUROXIME",
    "CHLORAMPHENICOL",
    "CIPROFLOXACIN",
    "CLINDAMYCIN",
    "COLISTIN",
    "DOXYCYCLINE",
    "ERTAPENEM",
    "ERYTHROMYCIN",
    "GENTAMICIN",
    "IMIPENEM",
    "LEVOFLOXACIN",
    "LINEZOLID",
    "MEROPENEM",
    "NALIDIXIC ACID",
    "NITROFURANTOIN",
    "NORFLOXACIN",
    "OXACILLIN",
    "PENICILLIN",
    "PIPERACILLIN-TAZOBACTAM",
    "RIFAMPICIN",
    "TETRACYCLINE",
    "TIGECYCLINE",
    "TOBRAMYCIN",
    "TRIMETHOPRIM-SULFAMETHOXAZOLE",
    "VANCOMYCIN",
]

# the header the participant fills in on receipt of the panel
RECEIPT_FIELDS = [
    "date_samples_received",
    "receipt_temperature",
    "sample_condition",
    "sample_condition_reason",
]

RECEIPT_LABELS = {
    "date_samples_received": "Receipt Date of PT Samples",
    "receipt_temperature": "Receipt Temperature",
    "sample_condition": "Sample Condition",
    "sample_condition_reason": "Reason the Sample was Unsuitable",
}

# Sample receipt details (date received, condition, temperature) are now
# captured once per sample in the shared sample_receipts table and enforced at
# the route by receipt_exists(), so they are no longer required on the worksheet
# row itself. Kept as a list for any future worksheet-level submit requirement.
REQUIRED_ON_SUBMIT = []

# swabs travel at 2-8 degrees; a reading far outside that is a typing slip
# rather than a cold chain excursion, so the field is bounded but generously
RECEIPT_TEMPERATURE_MIN = -30.0
RECEIPT_TEMPERATURE_MAX = 50.0

# a zone of inhibition is read off a ruler in millimetres
ZONE_DIAMETER_MIN = 0.0
ZONE_DIAMETER_MAX = 100.0


def _check_allowed(label, value, allowed):
    """Rejects a value the worksheet does not offer as a choice"""
    if value is None or value == "":
        return None

    cleaned = " ".join(str(value).split())
    for option in allowed:
        if cleaned.upper() == option.upper():
            # the worksheet has one spelling for each choice, so return it
            return option

    raise ValueError(f"{label} must be one of {', '.join(allowed)}")


def _clean_text(value):
    if value is None:
        return None
    cleaned = " ".join(str(value).split())
    return cleaned or None


# ---------- The AST section as one graded answer ----------
# Protocol TP-NHRTI-BACT-001 scores the AST section as a single 20 mark
# question - 'Tested AST discs' - not as one question per antibiotic. So the
# table is reduced to one canonical answer, 'AGENT:INTERPRETATION' per agent in
# alphabetical order, which is what the assigned value for the sample is
# written in and what the participant's table is compared against.
AST_SUMMARY_PAIR_SEPARATOR = "|"
AST_SUMMARY_VALUE_SEPARATOR = ":"


def ast_summary(rows):
    """The canonical answer for an AST table, or None when nothing was typed.

    An agent reported on both the disk diffusion and the MIC table counts once;
    the two methods are two ways of reaching the same interpretation, and the
    protocol scores the interpretation.
    """
    interpretations = {}
    for row in rows or []:
        agent = _clean_text(getattr(row, "antibiotic", None))
        interpretation = _clean_text(getattr(row, "interpretation", None))
        if agent and interpretation:
            interpretations[agent.upper()] = interpretation.upper()

    if not interpretations:
        return None

    return AST_SUMMARY_PAIR_SEPARATOR.join(
        f"{agent}{AST_SUMMARY_VALUE_SEPARATOR}{interpretations[agent]}"
        for agent in sorted(interpretations)
    )


def ast_interpretations(summary):
    """Reads a canonical AST answer back into {agent: interpretation}"""
    if not summary:
        return {}

    pairs = {}
    for part in str(summary).split(AST_SUMMARY_PAIR_SEPARATOR):
        agent, _, interpretation = part.partition(AST_SUMMARY_VALUE_SEPARATOR)
        agent = _clean_text(agent)
        interpretation = _clean_text(interpretation)
        if agent and interpretation:
            pairs[agent.upper()] = interpretation.upper()

    return pairs


# ---------- SQLAlchemy Models ----------
class BacteriologyResultDB(Base):
    __tablename__ = "bacteriology_results"
    # one worksheet per sample, per lab, per cycle
    __table_args__ = (
        UniqueConstraint(
            "pt_cycle_id", "lab_id", "method_sample_id",
            name="uq_bacteriology_results_cycle_lab_sample",
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

    # worksheet header
    date_samples_received = Column(Date, nullable=True)
    receipt_temperature = Column(Float, nullable=True)
    sample_condition = Column(String, nullable=True)
    sample_condition_reason = Column(String, nullable=True)
    date_tested = Column(Date, nullable=True)

    # 'Testing not done on this specimen/isolate'
    testing_not_done = Column(Boolean, nullable=False, default=False)
    testing_not_done_reason = Column(String, nullable=True)

    # microscopy (Gram stain)
    gram_stain_reaction = Column(String, nullable=True)
    gram_morphology = Column(String, nullable=True)
    gram_morphology_other = Column(String, nullable=True)
    microscopy_comment = Column(String, nullable=True)

    # final organism identification
    organism_identified = Column(String, nullable=True)
    identification_comment = Column(String, nullable=True)

    # antimicrobial susceptibility testing
    ast_performed = Column(Boolean, nullable=False, default=False)
    ast_guideline = Column(String, nullable=True)
    ast_disk_diffusion = Column(Boolean, nullable=False, default=False)
    ast_mic_method = Column(String, nullable=True)
    ast_mic_method_other = Column(String, nullable=True)

    comments = Column(String, nullable=True)

    # sign off
    reported_by = Column(String, nullable=True)
    reported_on = Column(Date, nullable=True)
    reviewed_by = Column(String, nullable=True)
    reviewed_on = Column(Date, nullable=True)

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
    user = relationship("UserDB", back_populates="bacteriologyresult", lazy='raise')
    status = relationship("StatusDB", back_populates="bacteriologyresult", lazy='raise')
    stage = relationship("StageDB", back_populates="bacteriologyresult", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="bacteriologyresult", lazy='raise')
    laboratory = relationship("LaboratoryDB", back_populates="bacteriologyresult", lazy='raise')
    service = relationship("ServiceDB", back_populates="bacteriologyresult", lazy='raise')
    enrollment = relationship("EnrollmentDB", back_populates="bacteriologyresult", lazy='raise')
    ptcycle = relationship("PTCycleDB", back_populates="bacteriologyresult", lazy='raise')
    method = relationship("MethodDB", back_populates="bacteriologyresult", lazy='raise')
    methodsample = relationship("MethodSampleDB", back_populates="bacteriologyresult", lazy='raise')

    #links
    # the AST table on the worksheet, ordered as it is printed
    astresult = relationship(
        "BacteriologyASTResultDB",
        back_populates="bacteriologyresult",
        lazy='raise',
        cascade="all, delete-orphan",
        order_by="(BacteriologyASTResultDB.ast_method, BacteriologyASTResultDB.row_no)",
    )

    @property
    def ast_result(self):
        """The AST table as the one answer the protocol grades.

        The evaluation layer reads every graded field off the result with
        getattr, and the AST section is a table rather than a column, so it is
        presented as one here. `astresult` has to have been loaded.
        """
        return ast_summary(self.astresult)


class BacteriologyASTResultDB(Base):
    """One antibiotic on the worksheet's AST table.

    Kept apart from the worksheet because the section is a list - up to fifteen
    agents for disk diffusion and fifteen for MIC - and a list does not fit in
    columns without inventing thirty of them.
    """
    __tablename__ = "bacteriology_ast_results"
    # Both are deferred to commit. Saving a worksheet replaces its AST table
    # rather than editing it row by row, so the new rows are written before the
    # old ones have gone; checked per statement, re-numbering an antibiotic
    # would collide with the row that is about to be deleted.
    __table_args__ = (
        UniqueConstraint(
            "bacteriology_result_id", "ast_method", "row_no",
            name="uq_bacteriology_ast_results_result_method_row",
            deferrable=True, initially="DEFERRED",
        ),
        UniqueConstraint(
            "bacteriology_result_id", "ast_method", "antibiotic",
            name="uq_bacteriology_ast_results_result_method_antibiotic",
            deferrable=True, initially="DEFERRED",
        ),
    )

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # properties
    bacteriology_result_id = Column(
        Integer,
        ForeignKey("bacteriology_results.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    ast_method = Column(String, nullable=False)
    row_no = Column(Integer, nullable=False)

    antibiotic = Column(String, nullable=False)
    zone_diameter = Column(Float, nullable=True)
    mic_reading = Column(String, nullable=True)
    interpretation = Column(String, nullable=True)

    # service columns
    created_at = Column(DateTime(timezone=True), default=datetime.now, nullable=True)
    created_by = Column(String, nullable=True)
    updated_at = Column(DateTime(timezone=True), onupdate=datetime.now, nullable=True)
    updated_by = Column(String, nullable=True)

    #relationships
    bacteriologyresult = relationship(
        "BacteriologyResultDB", back_populates="astresult", lazy='raise'
    )


# ---------- Pydantic Schemas ----------
class BacteriologyASTResult(BaseModel):
    # id
    id: Optional[int] = None

    # properties - set by the router from the worksheet being captured
    bacteriology_result_id: Optional[int] = None

    ast_method: str = Field(
        ...,
        description=f"Which AST table the row was read off, one of {AST_METHOD_VALUES}",
    )
    row_no: int = Field(
        ...,
        ge=1,
        le=AST_MAX_ROWS,
        description=f"The row on the worksheet, 1 to {AST_MAX_ROWS}",
    )

    antibiotic: str = Field(
        ...,
        min_length=2,
        description="The antibiotic tested",
    )
    zone_diameter: Optional[float] = Field(
        default=None,
        description="The zone of inhibition in mm, for disk diffusion",
    )
    mic_reading: Optional[str] = Field(
        default=None,
        description="The MIC reading, e.g. '<=0.5' or '>2', for the MIC method",
    )
    interpretation: Optional[str] = Field(
        default=None,
        description=f"The interpretation, one of {AST_INTERPRETATION_VALUES}",
    )

    # linkage
    created_at: Optional[datetime] = None
    created_by: Optional[str] = None
    updated_at: Optional[datetime] = None
    updated_by: Optional[str] = None

    @validator("ast_method")
    def check_ast_method(cls, value):
        cleaned = _check_allowed("AST Method", value, AST_METHOD_VALUES)
        if not cleaned:
            raise ValueError(
                f"AST Method must be one of {', '.join(AST_METHOD_VALUES)}"
            )
        return cleaned

    @validator("antibiotic")
    def check_antibiotic(cls, value):
        """Normalises the agent's name without confining it to the list.

        The dropdown on the worksheet is filled from the testing guideline, and
        a guideline gains agents faster than this list does, so an agent that
        is not among the suggestions is still accepted - upper cased, so the
        same agent from two laboratories groups as one at evaluation.
        """
        cleaned = _clean_text(value)
        if not cleaned:
            raise ValueError("The antibiotic must be provided")
        return cleaned.upper()

    @validator("interpretation")
    def check_interpretation(cls, value):
        return _check_allowed(
            "Interpretation", value, AST_INTERPRETATION_VALUES
        )

    @validator("mic_reading")
    def check_mic_reading(cls, value):
        return _clean_text(value)

    @validator("zone_diameter")
    def check_zone_diameter(cls, value):
        if value is None:
            return None

        if value < ZONE_DIAMETER_MIN or value > ZONE_DIAMETER_MAX:
            raise ValueError(
                f"The Zone Diameter must be between {ZONE_DIAMETER_MIN} and "
                f"{ZONE_DIAMETER_MAX} mm"
            )
        return value

    @root_validator
    def check_reading_matches_the_method(cls, values):
        """A row carries the reading its own table asks for"""
        method = values.get("ast_method")

        if method == AST_METHOD_DISK_DIFFUSION and values.get("mic_reading"):
            raise ValueError(
                "A MIC reading cannot be recorded on the disk diffusion table; "
                "record a zone diameter instead"
            )

        if method == AST_METHOD_MIC and values.get("zone_diameter") is not None:
            raise ValueError(
                "A zone diameter cannot be recorded on the MIC table; record a "
                "MIC reading instead"
            )

        return values

    class Config:
        orm_mode = True


class BacteriologyResult(BaseModel):
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

    # worksheet header - optional on the model so a laboratory can park a
    # partly worked specimen; the rules below are what make one submittable
    date_samples_received: Optional[date] = Field(
        default=None, description="The date the PT samples arrived at the laboratory"
    )
    receipt_temperature: Optional[float] = Field(
        default=None, description="The temperature the panel was received at, in C"
    )
    sample_condition: Optional[str] = Field(
        default=None,
        description=f"The condition of the sample, one of {SAMPLE_CONDITION_VALUES}",
    )
    sample_condition_reason: Optional[str] = Field(
        default=None, description="Why the sample was unsuitable"
    )
    date_tested: Optional[date] = Field(
        default=None, description="The date the sample was tested"
    )

    # 'Testing not done on this specimen/isolate'
    testing_not_done: Optional[bool] = Field(
        default=False,
        description="The specimen or isolate could not be worked at all",
    )
    testing_not_done_reason: Optional[str] = Field(
        default=None, description="Why the specimen could not be worked"
    )

    # microscopy (Gram stain)
    gram_stain_reaction: Optional[str] = Field(
        default=None,
        description=f"The stain reaction, one of {GRAM_STAIN_REACTION_VALUES}",
    )
    gram_morphology: Optional[str] = Field(
        default=None,
        description=f"The morphology seen, one of {GRAM_MORPHOLOGY_VALUES}",
    )
    gram_morphology_other: Optional[str] = Field(
        default=None,
        description=f"The morphology seen, when it is '{GRAM_MORPHOLOGY_OTHER}'",
    )
    microscopy_comment: Optional[str] = Field(
        default=None, description="The comment under the microscopy section"
    )

    # final organism identification
    organism_identified: Optional[str] = Field(
        default=None, description="The organism identified, to genus or species"
    )
    identification_comment: Optional[str] = Field(
        default=None, description="The comment under the identification section"
    )

    # antimicrobial susceptibility testing
    ast_performed: Optional[bool] = Field(
        default=False,
        description="Whether antimicrobial susceptibility testing was carried out",
    )
    ast_guideline: Optional[str] = Field(
        default=None,
        description=f"The guideline applied, one of {AST_GUIDELINE_VALUES}",
    )
    ast_disk_diffusion: Optional[bool] = Field(
        default=False,
        description="Whether the disk diffusion (Kirby Bauer) method was used",
    )
    ast_mic_method: Optional[str] = Field(
        default=None,
        description=f"The MIC method used, one of {AST_MIC_METHOD_VALUES}",
    )
    ast_mic_method_other: Optional[str] = Field(
        default=None,
        description=f"The MIC method used, when it is '{AST_MIC_METHOD_OTHER}'",
    )

    comments: Optional[str] = Field(
        default=None, description="The comments at the foot of the worksheet"
    )

    # sign off
    reported_by: Optional[str] = Field(
        default=None, description="The person who reported the worksheet"
    )
    reported_on: Optional[date] = Field(
        default=None, description="The date the worksheet was reported"
    )
    reviewed_by: Optional[str] = Field(
        default=None, description="The person who reviewed the worksheet"
    )
    reviewed_on: Optional[date] = Field(
        default=None, description="The date the worksheet was reviewed"
    )

    # the AST table; sent with the worksheet rather than row by row, because
    # that is how the participant fills it in
    astresult: Optional[List[BacteriologyASTResult]] = None

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

    @validator("sample_condition")
    def check_sample_condition(cls, value):
        return _check_allowed("Sample Condition", value, SAMPLE_CONDITION_VALUES)

    @validator("gram_stain_reaction")
    def check_gram_stain_reaction(cls, value):
        return _check_allowed("Stain Reaction", value, GRAM_STAIN_REACTION_VALUES)

    @validator("gram_morphology")
    def check_gram_morphology(cls, value):
        return _check_allowed("Morphology", value, GRAM_MORPHOLOGY_VALUES)

    @validator("ast_guideline")
    def check_ast_guideline(cls, value):
        return _check_allowed("AST Guideline", value, AST_GUIDELINE_VALUES)

    @validator("ast_mic_method")
    def check_ast_mic_method(cls, value):
        return _check_allowed("MIC Method", value, AST_MIC_METHOD_VALUES)

    @validator("organism_identified")
    def check_organism_identified(cls, value):
        return _clean_text(value)

    @validator("receipt_temperature")
    def check_receipt_temperature(cls, value):
        if value is None:
            return None

        if value < RECEIPT_TEMPERATURE_MIN or value > RECEIPT_TEMPERATURE_MAX:
            raise ValueError(
                f"The {RECEIPT_LABELS['receipt_temperature']} must be between "
                f"{RECEIPT_TEMPERATURE_MIN} and {RECEIPT_TEMPERATURE_MAX} C"
            )
        return value

    @root_validator
    def check_worksheet_is_consistent(cls, values):
        """Applies the rules on worksheet TF-NHRTI-BACT-001.

        A draft may be incomplete - a specimen is worked over several days, and
        AST only after the isolate has grown - but the moment it is submitted
        for review it has to be a worksheet a reviewer can actually grade.
        """
        not_done = values.get("testing_not_done")
        condition = values.get("sample_condition")
        rows = values.get("astresult") or []

        # 'Others:' and the free text that goes beside it travel together
        if (
            values.get("gram_morphology_other")
            and values.get("gram_morphology") != GRAM_MORPHOLOGY_OTHER
        ):
            raise ValueError(
                f"A morphology can only be written in when the Morphology is "
                f"'{GRAM_MORPHOLOGY_OTHER}'"
            )

        if (
            values.get("ast_mic_method_other")
            and values.get("ast_mic_method") != AST_MIC_METHOD_OTHER
        ):
            raise ValueError(
                f"A MIC method can only be written in when the MIC Method is "
                f"'{AST_MIC_METHOD_OTHER}'"
            )

        if condition == SAMPLE_CONDITION_SUITABLE and values.get(
            "sample_condition_reason"
        ):
            raise ValueError(
                "A reason cannot be recorded when the sample was suitable"
            )

        # the specimen was either worked or it was not - never both
        if not_done:
            if (
                values.get("gram_stain_reaction")
                or values.get("gram_morphology")
                or values.get("organism_identified")
            ):
                raise ValueError(
                    "A result cannot be recorded when testing was not done on "
                    "this specimen or isolate"
                )

            if values.get("ast_performed") or rows:
                raise ValueError(
                    "Antimicrobial susceptibility testing cannot be recorded "
                    "when testing was not done on this specimen or isolate"
                )

        if rows and not values.get("ast_performed"):
            raise ValueError(
                "Please indicate that the AST procedure was carried out before "
                "recording antibiotics"
            )

        # a row belongs to the table whose method was selected
        if rows:
            disk = [r for r in rows if r.ast_method == AST_METHOD_DISK_DIFFUSION]
            mic = [r for r in rows if r.ast_method == AST_METHOD_MIC]

            if disk and not values.get("ast_disk_diffusion"):
                raise ValueError(
                    "Please select the disk diffusion (Kirby Bauer) method "
                    "before recording zone diameters"
                )

            if mic and not values.get("ast_mic_method"):
                raise ValueError(
                    "Please choose the MIC method used before recording MIC "
                    "readings"
                )

        if values.get("status_id") != assist.STATUS_SUBMITTED:
            # still a draft, a part worked specimen is fine
            return values

        missing = [
            RECEIPT_LABELS[name]
            for name in REQUIRED_ON_SUBMIT
            if not values.get(name)
        ]
        if missing:
            raise ValueError(
                "The receipt details must be provided before the worksheet can "
                f"be submitted. Missing: {', '.join(missing)}"
            )

        if not_done:
            if not values.get("testing_not_done_reason"):
                raise ValueError(
                    "Please give the reason testing was not done on this "
                    "specimen or isolate"
                )
            return values

        if not values.get("date_tested"):
            raise ValueError(
                "Please provide the Date Tested before submitting the worksheet"
            )

        if not values.get("gram_stain_reaction"):
            raise ValueError(
                f"The Stain Reaction must be provided, one of "
                f"{', '.join(GRAM_STAIN_REACTION_VALUES)}"
            )

        if not values.get("gram_morphology"):
            raise ValueError(
                f"The Morphology must be provided, one of "
                f"{', '.join(GRAM_MORPHOLOGY_VALUES)}"
            )

        if (
            values.get("gram_morphology") == GRAM_MORPHOLOGY_OTHER
            and not values.get("gram_morphology_other")
        ):
            raise ValueError(
                f"Please write in the morphology seen when the Morphology is "
                f"'{GRAM_MORPHOLOGY_OTHER}'"
            )

        if not values.get("organism_identified"):
            raise ValueError(
                "Please indicate the organism identified"
            )

        if values.get("ast_performed"):
            if not values.get("ast_guideline"):
                raise ValueError(
                    f"Please insert the applicable guideline, one of "
                    f"{', '.join(AST_GUIDELINE_VALUES)}"
                )

            if not rows:
                raise ValueError(
                    "Please record the antibiotics tested before submitting the "
                    "worksheet"
                )

            untyped = [r.antibiotic for r in rows if not r.interpretation]
            if untyped:
                raise ValueError(
                    "Every antibiotic must be interpreted as S, I, SDD or R. "
                    f"Missing: {', '.join(untyped)}"
                )

            unread = [
                r.antibiotic for r in rows
                if r.ast_method == AST_METHOD_DISK_DIFFUSION
                and r.zone_diameter is None
            ]
            if unread:
                raise ValueError(
                    "Every disk diffusion antibiotic must carry a zone "
                    f"diameter. Missing: {', '.join(unread)}"
                )

            unread = [
                r.antibiotic for r in rows
                if r.ast_method == AST_METHOD_MIC and not r.mic_reading
            ]
            if unread:
                raise ValueError(
                    "Every MIC antibiotic must carry a MIC reading. Missing: "
                    f"{', '.join(unread)}"
                )

            if (
                values.get("ast_mic_method") == AST_MIC_METHOD_OTHER
                and not values.get("ast_mic_method_other")
            ):
                raise ValueError(
                    f"Please specify the MIC method used when it is "
                    f"'{AST_MIC_METHOD_OTHER}'"
                )

        return values

    class Config:
        orm_mode = True

class BacteriologyResultWithDetail(BacteriologyResult):
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

class ParamBacteriologyResultEdit(BaseModel):
    bacteriologyresult: Optional[BacteriologyResultWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    laboratoryList: Optional[List[Laboratory]] = []
    serviceList: Optional[List[Service]] = []
    enrollmentList: Optional[List[Enrollment]] = []
    ptcycleList: Optional[List[PTCycle]] = []
    methodList: Optional[List[Method]] = []
    methodsampleList: Optional[List[MethodSample]] = []

    class Config:
        orm_mode = True
