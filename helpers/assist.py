import hashlib
from typing import Tuple
from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
import calendar

INFOBIP_API_URL = "https://xk85nl.api.infobip.com/whatsapp/1/message/template"
INFOBIP_API_TOKEN = (
    "05704a467eaab51ea1bd2aabaa652517-c006af8e-55e6-4254-aa46-440344a6e040"
)
INFOBIP_PHONE_NUMBER = "12098869548"

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

# roles that belong to a participating laboratory rather than to the provider
LABORATORY_ROLES = (ROLE_FACILITY_SUPER_USER, ROLE_FACILITY_STAFF)

# issued to a lab super user when its registration is approved; the lab is
# expected to change it on first sign in
DEFAULT_LAB_PASSWORD = "12345678"

# roles that may administer the scheme (start cycles, review applications, ...)
ADMIN_ROLES = (
    ROLE_ADMINISTRATOR,
    ROLE_SCHEME_HEAD,
    ROLE_SCHEME_COORDINATOR,
    ROLE_SCHEME_QUALITY_OFFICER,
)

# pt cycle statuses - must match the order of the list seeded by
# /pt-cycle-statuses/initialize
PT_CYCLE_UPCOMING = 1
PT_CYCLE_STARTED = 2
PT_CYCLE_SAMPLES_SHIPPED = 3
PT_CYCLE_REPORT_AVAILABLE = 4
PT_CYCLE_CLOSED = 5

PT_CYCLE_STATUS_NAMES = {
    PT_CYCLE_UPCOMING: "Upcoming",
    PT_CYCLE_STARTED: "Started",
    PT_CYCLE_SAMPLES_SHIPPED: "Samples Shipped",
    PT_CYCLE_REPORT_AVAILABLE: "Report Available",
    PT_CYCLE_CLOSED: "Closed",
}

# the cycle life cycle only ever moves forward, one step at a time
PT_CYCLE_TRANSITIONS = {
    PT_CYCLE_UPCOMING: (PT_CYCLE_STARTED,),
    PT_CYCLE_STARTED: (PT_CYCLE_SAMPLES_SHIPPED,),
    PT_CYCLE_SAMPLES_SHIPPED: (PT_CYCLE_REPORT_AVAILABLE,),
    PT_CYCLE_REPORT_AVAILABLE: (PT_CYCLE_CLOSED,),
    PT_CYCLE_CLOSED: (),
}

# labs may only enrol while the cycle is accepting applications
PT_CYCLE_ENROLLMENT_OPEN = (PT_CYCLE_STARTED,)

# labs may only capture results once the samples are on their way
PT_CYCLE_RESULT_CAPTURE_OPEN = (PT_CYCLE_SAMPLES_SHIPPED,)


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
    """

    def __init__(self, acceptable, warning, unacceptable, threshold, source):
        self.acceptable = acceptable
        self.warning = warning
        self.unacceptable = unacceptable
        self.max_per_attribute = max(acceptable, warning, unacceptable)
        # the proportion of the available marks a lab must reach
        self.threshold = threshold
        # where these numbers come from, so they can be checked
        self.source = source

    def score_for(self, grade):
        if grade == GRADE_ACCEPTABLE:
            return self.acceptable
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

# keyed by the result form; anything not listed uses the default
SCORING_POLICIES = {
    "hiv_eid": EID_SCORING_POLICY,
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


def grade_for_z_score(z_score, policy=None):
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

    return grade, policy.score_for(grade)


def grade_for_agreement(reported, assigned, policy=None):
    """Grades a categorical result by whether it matches the assigned value"""
    policy = policy or DEFAULT_SCORING_POLICY

    if reported is None or assigned is None:
        return GRADE_NOT_EVALUATED, policy.unacceptable

    if reported.strip().upper() == assigned.strip().upper():
        return GRADE_ACCEPTABLE, policy.acceptable

    return GRADE_UNACCEPTABLE, policy.unacceptable


def is_laboratory_role(role_id: int) -> bool:
    """Returns true when the specified role belongs to a participating laboratory"""
    return role_id in LABORATORY_ROLES


def is_admin_role(role_id: int) -> bool:
    """Returns true when the specified role may administer the scheme"""
    return role_id in ADMIN_ROLES

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
CURRENT_TIME_ZONE = "Africa/Lusaka"

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
