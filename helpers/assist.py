import hashlib
from typing import Tuple
from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
import calendar
from helpers.env import env

# WhatsApp (Infobip) - the token is a live credential, so it comes from the
# environment; the URL and sender default to the configured account
INFOBIP_API_URL = env(
    "INFOBIP_API_URL",
    "https://xk85nl.api.infobip.com/whatsapp/1/message/template",
)
INFOBIP_API_TOKEN = env("INFOBIP_API_TOKEN", "")
INFOBIP_PHONE_NUMBER = env("INFOBIP_PHONE_NUMBER", "12098869548")

USER_MEMBER = 1
USER_ADMIN = 2

UPLOAD_DIR = "uploads"

# roles - must match the order of the list seeded by /roles/initialize
ROLE_ADMINISTRATOR = 1
ROLE_SCHEME_HEAD = 2
ROLE_SCHEME_COORDINATOR = 3
ROLE_SCHEME_QUALITY_OFFICER = 4
ROLE_FINANCE_OFFICER = 5
ROLE_PROVINCIAL_BIOMEDICAL_SCIENTIST = 6
ROLE_EQA_FOCAL_POINT = 7
ROLE_DISTRICT_LAB_COORDINATOR = 8
ROLE_FACILITY_SUPER_USER = 9
ROLE_FACILITY_STAFF = 10
# the Ministry of Health: works across every scheme, like a provider role, but
# may not perform system administration (managing users, the catalogue, ...)
ROLE_MINISTRY_OF_HEALTH = 11

# roles that belong to a participating laboratory rather than to the provider
LABORATORY_ROLES = (ROLE_FACILITY_SUPER_USER, ROLE_FACILITY_STAFF)
# a facility super user may enter and edit their facility's data; facility staff
# (management / supervisors) may only view it
FACILITY_WRITE_ROLES = (ROLE_FACILITY_SUPER_USER,)
FACILITY_READONLY_ROLES = (ROLE_FACILITY_STAFF,)

# issued to a lab super user when its registration is approved; the lab is
# expected to change it on first sign in
DEFAULT_LAB_PASSWORD = "12345678"

# system administration (managing users, roles, the whole catalogue, imports)
# is reserved to the Administrator alone
SYSTEM_ADMIN_ROLES = (ROLE_ADMINISTRATOR,)

# the scheme team: every one of these is tied to a single scheme and only ever
# sees and acts on that scheme's data
SCHEME_TEAM_ROLES = (
    ROLE_SCHEME_HEAD,
    ROLE_SCHEME_COORDINATOR,
    ROLE_SCHEME_QUALITY_OFFICER,
    ROLE_FINANCE_OFFICER,
    ROLE_PROVINCIAL_BIOMEDICAL_SCIENTIST,
    ROLE_EQA_FOCAL_POINT,
    ROLE_DISTRICT_LAB_COORDINATOR,
)

# provider-side roles that work across every scheme without being tied to one
CROSS_SCHEME_ROLES = (ROLE_ADMINISTRATOR, ROLE_MINISTRY_OF_HEALTH)

# every provider-side (non-facility) role
PROVIDER_ROLES = SCHEME_TEAM_ROLES + CROSS_SCHEME_ROLES

# roles that may administer the scheme's operations (start cycles, review
# applications, post announcements, grade results). This is the scheme
# management trio plus the cross-scheme roles; the wider scheme team
# (finance, PBs, FPPs, district coordinators) take part but do not administer.
ADMIN_ROLES = (
    ROLE_ADMINISTRATOR,
    ROLE_SCHEME_HEAD,
    ROLE_SCHEME_COORDINATOR,
    ROLE_SCHEME_QUALITY_OFFICER,
    ROLE_MINISTRY_OF_HEALTH,
)

# pt cycle statuses - must match the order seeded in pt_cycle_statuses
# (migration 019). The status is DERIVED from the cycle's dates and its two
# manual gates (samples_shipped, reports_published); see compute_pt_cycle_status.
PT_CYCLE_UPCOMING = 1
PT_CYCLE_ENROLMENT_OPEN = 2
PT_CYCLE_ENROLMENT_CLOSED = 3
PT_CYCLE_SAMPLES_SHIPPED = 4
PT_CYCLE_TESTING = 5
PT_CYCLE_RESULTS_DUE = 6
PT_CYCLE_REPORT_AVAILABLE = 7

# kept so older references resolve; "Started" is now "Enrolment Open"
PT_CYCLE_STARTED = PT_CYCLE_ENROLMENT_OPEN

PT_CYCLE_STATUS_NAMES = {
    PT_CYCLE_UPCOMING: "Upcoming",
    PT_CYCLE_ENROLMENT_OPEN: "Enrolment Open",
    PT_CYCLE_ENROLMENT_CLOSED: "Enrolment Closed",
    PT_CYCLE_SAMPLES_SHIPPED: "Samples Shipped",
    PT_CYCLE_TESTING: "Testing In Progress",
    PT_CYCLE_RESULTS_DUE: "Results Due",
    PT_CYCLE_REPORT_AVAILABLE: "Report Available",
}


def compute_pt_cycle_status(cycle, today=None):
    """The cycle's lifecycle status, derived from its dates and manual gates.

    Precedence: a published report or shipped samples take over from the date-
    driven enrolment phases, because those two steps are manual and carry side
    effects. `cycle` is any object exposing the date fields and the two flags.
    """
    if today is None:
        today = get_current_date().date()

    if getattr(cycle, "reports_published", False):
        return PT_CYCLE_REPORT_AVAILABLE

    if getattr(cycle, "samples_shipped", False):
        start = getattr(cycle, "test_event_start_date", None)
        stop = getattr(cycle, "test_event_stop_date", None)
        if start and today < start:
            return PT_CYCLE_SAMPLES_SHIPPED
        if stop and today <= stop:
            return PT_CYCLE_TESTING
        return PT_CYCLE_RESULTS_DUE

    opening = getattr(cycle, "effective_date", None)
    closing = getattr(cycle, "closing_date", None)
    if opening and today < opening:
        return PT_CYCLE_UPCOMING
    if closing and today <= closing:
        return PT_CYCLE_ENROLMENT_OPEN
    return PT_CYCLE_ENROLMENT_CLOSED


def pt_enrollment_open(cycle, today=None):
    """Enrolment is open only during the enrolment window (before shipping)."""
    return compute_pt_cycle_status(cycle, today) == PT_CYCLE_ENROLMENT_OPEN


def pt_result_capture_open(cycle, today=None):
    """Results may be captured from when samples ship until the submission due
    date passes, and never after reports are published."""
    if today is None:
        today = get_current_date().date()
    if not getattr(cycle, "samples_shipped", False):
        return False
    if getattr(cycle, "reports_published", False):
        return False
    due = getattr(cycle, "result_submission_due_date", None)
    if due and today > due:
        return False
    return True


# kept for any remaining membership-style checks
PT_CYCLE_ENROLLMENT_OPEN = (PT_CYCLE_ENROLMENT_OPEN,)
PT_CYCLE_RESULT_CAPTURE_OPEN = (PT_CYCLE_SAMPLES_SHIPPED, PT_CYCLE_TESTING, PT_CYCLE_RESULTS_DUE)

# reminder emails: how many days before each date to remind, and which date
# fields carry reminders (recipients decided in the reminder job)
PT_CYCLE_REMINDER_LEAD_DAYS = (7, 1)
PT_CYCLE_REMINDER_FIELDS = (
    "effective_date",            # enrolment opening  -> all approved scheme labs
    "closing_date",              # enrolment closing  -> enrolled labs
    "shipping_date",             # sample shipping    -> enrolled labs
    "test_event_start_date",     # test event start   -> enrolled labs
    "result_submission_due_date",# result due         -> enrolled labs
    "reports_availability_date", # report availability-> enrolled labs
)


# ---------------------------------------------------------------- evaluation
# How a reported result is turned into a score and a grade.

# a sample is graded either against a number (a viral load) or against a
# category (TB detected / not detected)
EVALUATION_QUANTITATIVE = "quantitative"
EVALUATION_QUALITATIVE = "qualitative"

# where the value a result is graded against comes from
ASSIGNED_VALUE_PREDEFINED = "predefined"   # the panel manufacturer states it
ASSIGNED_VALUE_CONSENSUS = "consensus"     # derived from the participants

GRADE_ACCEPTABLE = "Acceptable"
GRADE_WARNING = "Warning"
GRADE_UNACCEPTABLE = "Unacceptable"
GRADE_NOT_EVALUATED = "Not Evaluated"

# z-score bands, from form TF-007:
#   z <= +/-2.0          Acceptable     no action required
#   +/-2.0 < z < +/-3.0  Warning        closely monitor performance
#   z >= +/-3.0          Unacceptable   perform corrective action
Z_SCORE_ACCEPTABLE = 2.0
Z_SCORE_WARNING = 3.0

PERFORMANCE_SATISFACTORY = "Satisfactory"
PERFORMANCE_UNSATISFACTORY = "Unsatisfactory"
PERFORMANCE_NOT_EVALUATED = "Not Evaluated"


class ScoringPolicy:
    """How one scheme turns a grade into marks, and marks into a standing.

    Schemes do not agree on this. The EID scheme awards 20 marks a sample and
    demands all of them; the others are scored out of 2 with a lower bar. So
    the policy belongs to the form, not to the system.

    Nor do all schemes weight every question the same. Bacteriology is worth
    3 marks for the Gram stain reaction but 10 for naming the organism, so a
    policy may carry a mark per attribute; one that does not weights them all
    alike, as before.
    """

    def __init__(self, acceptable, warning, unacceptable, threshold, source,
                 attribute_scores=None):
        self.acceptable = acceptable
        self.warning = warning
        self.unacceptable = unacceptable
        self.max_per_attribute = max(acceptable, warning, unacceptable)
        # marks per graded field, where the scheme weights them differently.
        # An attribute this does not mention falls back to `acceptable`, so a
        # field the scheme never put a mark against scores nothing and is left
        # out of the total rather than being invented a weight.
        self.attribute_scores = attribute_scores or {}
        # the proportion of the available marks a lab must reach
        self.threshold = threshold
        # where these numbers come from, so they can be checked
        self.source = source

    def max_for(self, attribute=None):
        """The marks a correct answer to this field is worth"""
        return self.attribute_scores.get(attribute, self.acceptable)

    def score_for(self, grade, attribute=None):
        if grade == GRADE_ACCEPTABLE:
            return self.max_for(attribute)
        if grade == GRADE_WARNING:
            return self.warning
        return self.unacceptable


# ASSUMPTION: the weights and threshold for the TB and viral load schemes are
# not stated on their forms - confirm against scheme protocol LMUTHL-ID-002.
DEFAULT_SCORING_POLICY = ScoringPolicy(
    acceptable=2, warning=1, unacceptable=0, threshold=0.80,
    source="assumed - confirm against LMUTHL-ID-002",
)

# Stated on form TF-006: a correct result scores 20, anything else scores 0,
# and only a full 100 marks is satisfactory.
EID_SCORING_POLICY = ScoringPolicy(
    acceptable=20, warning=0, unacceptable=0, threshold=1.00,
    source="TF-006 performance criteria",
)

# Stated in scheme protocol TP-NHRTI-BACT-001 section 17.1. Bacteriology is
# the one scheme that pays different marks for different questions, and the
# marks fall out of a survey of five samples:
#
#     Gram stain reaction       3 x 5 =  15
#     Bacterial morphology      3 x 5 =  15
#     Bacterial identification 10 x 5 =  50
#     AST (tested discs)       20 x 1 =  20
#                                       ---
#                                       100
#
# Section 17.2 puts the bar at the full 100%.
BACTERIOLOGY_SCORING_POLICY = ScoringPolicy(
    acceptable=0, warning=0, unacceptable=0, threshold=1.00,
    source="TP-NHRTI-BACT-001 section 17.1",
    attribute_scores={
        "gram_stain_reaction": 3,
        "gram_morphology": 3,
        "organism_identified": 10,
        "ast_result": 20,
    },
)

# keyed by the result form; anything not listed uses the default
SCORING_POLICIES = {
    "hiv_eid": EID_SCORING_POLICY,
    "bacteriology": BACTERIOLOGY_SCORING_POLICY,
}


def scoring_policy(result_form):
    return SCORING_POLICIES.get(result_form, DEFAULT_SCORING_POLICY)


# kept for callers that predate the per-scheme policies
SCORE_ACCEPTABLE = DEFAULT_SCORING_POLICY.acceptable
SCORE_WARNING = DEFAULT_SCORING_POLICY.warning
SCORE_UNACCEPTABLE = DEFAULT_SCORING_POLICY.unacceptable
SCORE_MAX_PER_ATTRIBUTE = DEFAULT_SCORING_POLICY.max_per_attribute
PERFORMANCE_SATISFACTORY_THRESHOLD = DEFAULT_SCORING_POLICY.threshold

# ISO 13528 derives a robust standard deviation from the interquartile range
NIQR_FACTOR = 0.7413

# consensus needs enough participants to be meaningful; below this the sample
# is reported but not graded
MIN_PARTICIPANTS_FOR_CONSENSUS = 3


def grade_for_z_score(z_score, policy=None, attribute=None):
    """Turns a z-score into the grade and marks on form TF-007"""
    policy = policy or DEFAULT_SCORING_POLICY

    if z_score is None:
        return GRADE_NOT_EVALUATED, policy.unacceptable

    magnitude = abs(z_score)

    if magnitude <= Z_SCORE_ACCEPTABLE:
        grade = GRADE_ACCEPTABLE
    elif magnitude < Z_SCORE_WARNING:
        grade = GRADE_WARNING
    else:
        grade = GRADE_UNACCEPTABLE

    return grade, policy.score_for(grade, attribute)


def grade_for_agreement(reported, assigned, policy=None, attribute=None):
    """Grades a categorical result by whether it matches the assigned value"""
    policy = policy or DEFAULT_SCORING_POLICY

    if reported is None or assigned is None:
        return GRADE_NOT_EVALUATED, policy.unacceptable

    if reported.strip().upper() == assigned.strip().upper():
        return GRADE_ACCEPTABLE, policy.max_for(attribute)

    return GRADE_UNACCEPTABLE, policy.unacceptable


def is_laboratory_role(role_id: int) -> bool:
    """Returns true when the specified role belongs to a participating laboratory"""
    return role_id in LABORATORY_ROLES


def is_admin_role(role_id: int) -> bool:
    """Returns true when the specified role may administer the scheme's operations"""
    return role_id in ADMIN_ROLES


def is_system_admin(role_id: int) -> bool:
    """Only the Administrator may perform system administration (manage users,
    roles and the catalogue)."""
    return role_id in SYSTEM_ADMIN_ROLES


def is_cross_scheme(role_id: int) -> bool:
    """Returns true for roles that work across every scheme (Administrator, MOH)"""
    return role_id in CROSS_SCHEME_ROLES


def is_scheme_team(role_id: int) -> bool:
    """Returns true for a scheme-team role, each tied to a single scheme"""
    return role_id in SCHEME_TEAM_ROLES


def is_provider_role(role_id: int) -> bool:
    """Returns true for any provider-side (non-facility) role"""
    return role_id in PROVIDER_ROLES


def can_write_facility(role_id: int) -> bool:
    """A facility super user may enter/edit data; facility staff may only view"""
    return role_id in FACILITY_WRITE_ROLES


def requires_scheme(role_id: int) -> bool:
    """Scheme-team roles must be tied to exactly one scheme"""
    return role_id in SCHEME_TEAM_ROLES


def scheme_scope_for(user) -> "int | None":
    """The scheme a user is confined to, or None for anyone who sees them all.

    Cross-scheme and system-admin roles (Administrator, MOH) see every scheme;
    a scheme-team member sees only their own; anyone else (facility) is not
    scoped this way and is handled by laboratory ownership instead.
    """
    role_id = getattr(user, "role_id", None)
    if role_id in CROSS_SCHEME_ROLES:
        return None
    if role_id in SCHEME_TEAM_ROLES:
        return getattr(user, "scheme_id", None)
    return None

# JWT signing - the secret is a live credential and must come from the
# environment in any shared or production setting
SECRET_KEY = env("SECRET_KEY", "your-secret-key")
ALGORITHM = env("ALGORITHM", "HS256")
CURRENT_TIME_ZONE = env("CURRENT_TIME_ZONE", "Africa/Lusaka")

STATUS_DRAFT = 1
STATUS_SUBMITTED = 2
STATUS_UNDER_REVIEW = 3
STATUS_APPROVED = 4
STATUS_REJECTED = 5

STATE_OPEN = 1
STATE_CLOSED = 2

REVIEW_ACTION_REJECT = 1
REVIEW_ACTION_APPROVE = 2

APPROVAL_STAGE_AWAIT_SUBMISSION = 1
APPROVAL_STAGE_SUBMITTED = 2
APPROVAL_STAGE_PRIMARY = 3
APPROVAL_STAGE_SECONDARY = 4
APPROVAL_STAGE_APPROVED = 5
# payment step (optional): set when an approver marks payment required at the
# first approval. The registration waits with the applicant for proof, then
# returns for a final approval the Finance role may also give.
APPROVAL_STAGE_AWAITING_PAYMENT = 6
APPROVAL_STAGE_PAYMENT_REVIEW = 7

# who may approve at the payment-review stage: the usual scheme administrators
# plus the Finance Officer
PAYMENT_APPROVER_ROLES = ADMIN_ROLES + (ROLE_FINANCE_OFFICER,)


def is_payment_approver(role_id: int) -> bool:
    """Returns true for a role allowed to approve a registration once proof of
    payment has been attached (scheme administrators and Finance)."""
    return role_id in PAYMENT_APPROVER_ROLES

RESPONSE_NO = 1
RESPONSE_YES = 2

def extract_names(full_name: str) -> Tuple[str, str]:
    parts = full_name.strip().split()

    if not parts:
        return "", ""

    if len(parts) == 1:
        return parts[0], ""

    first_name = parts[0]
    last_name = " ".join(parts[1:])

    return first_name, last_name

def get_safe_name(input: str):
    return input.replace(" ", "")


def get_current_date(date=True):
    # Set your timezon
    tz = ZoneInfo(CURRENT_TIME_ZONE)

    # Get current date with timezone
    now = datetime.now(tz)

    if date:
        now = datetime(now.year, now.month, now.day)

    return now


def get_current_period():
    # Set your timezon
    date = get_current_date()
    return get_date_period(date)

def get_date_period(date):
    return date.strftime("%Y%m")

def get_first_month_day(inputDate=None):
    # Set your timezon
    tz = ZoneInfo(CURRENT_TIME_ZONE)

    # Get current date with timezone
    now = datetime.now(tz) if inputDate == None else inputDate

    # Get first day of current month
    first_day = datetime(now.year, now.month, 1, tzinfo=tz)

    return first_day


def get_last_month_day(inputDate=None):
    # Set your timezon
    tz = ZoneInfo(CURRENT_TIME_ZONE)

    # Get current date with timezone
    now = datetime.now(tz) if inputDate == None else inputDate

    # Get last day of current month
    last_day_num = calendar.monthrange(now.year, now.month)[1]
    last_day = datetime(now.year, now.month, last_day_num, tzinfo=tz)

    return last_day


def encode_sha256(input):
    """
    Encodes the specified input to SHA-256

    Args:
        input (string): The input to encode.


    Returns:
        string: The encode string in SHA-256 format.
    """
    # Create a SHA-256 hash object
    hasher = hashlib.sha256()
    # Update the hash object with the byte-encoded message
    hasher.update(input.encode("utf-8"))
    # Get the hexadecimal representation of the hash
    sha256_result = hasher.hexdigest()
    return sha256_result


# Create a password context using bcrypt
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a plain password using bcrypt

    Args:
        passwrd (string): The password to hash.

    Returns:
        string: The hashed password string.
    """
    hashed = pwd_context.hash(password)
    return hashed


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against a hash

    Args:
        plain_password (string): The plain password to verify.
        hashed_password (string): The password hash to verify against.
    Returns:
        bool: Returns true if the password matches the hash, false otherwise
    """
    return pwd_context.verify(plain_password, hashed_password)
