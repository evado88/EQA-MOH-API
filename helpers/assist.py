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
