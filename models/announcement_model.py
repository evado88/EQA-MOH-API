from sqlalchemy import Boolean, Column, Integer, String, Text, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel, Field, root_validator, validator
from typing import Optional, Optional, Any, List
from database import Base
from datetime import date, datetime
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User
from models.scheme_model import Scheme
from models.attachment_model import Attachment
from helpers import assist


# ---------- Allowed values ----------

# What the notice is. The category decides which of the optional fields the
# announcement has to fill in before it can go out - see the root validator.
CATEGORY_EVENT = "Event"
CATEGORY_MEETING = "Meeting"
CATEGORY_RESOURCE = "Resource"
CATEGORY_GENERAL = "General"

CATEGORY_VALUES = [
    CATEGORY_EVENT,
    CATEGORY_MEETING,
    CATEGORY_RESOURCE,
    CATEGORY_GENERAL,
]

CATEGORY_DESCRIPTIONS = {
    CATEGORY_EVENT: "Something happening on a date, such as a training day",
    CATEGORY_MEETING: "A meeting participants are expected to attend",
    CATEGORY_RESOURCE: "A document, form or link participants should have",
    CATEGORY_GENERAL: "Any other notice to participants",
}

# the categories that are an occasion, and so have to say when
DATED_CATEGORIES = [CATEGORY_EVENT, CATEGORY_MEETING]

# Who it is for. A scheme announcement reaches the laboratories registered in
# that scheme; everything else reaches every participant.
AUDIENCE_ALL = "All Participants"
AUDIENCE_SCHEME = "Scheme"

AUDIENCE_VALUES = [AUDIENCE_ALL, AUDIENCE_SCHEME]

AUDIENCE_DESCRIPTIONS = {
    AUDIENCE_ALL: "Every participating laboratory on the platform",
    AUDIENCE_SCHEME: "Only the laboratories registered in one scheme",
}

# the attachment type an announcement's files are filed under, so a Resource
# can be an uploaded document rather than a link
ATTACHMENT_TYPE = "Announcement"

# a notice is worth reading; a headline of two words is not one
TITLE_MIN_LENGTH = 4
BODY_MIN_LENGTH = 10

# what the statuses mean on this table specifically
STATUS_LABELS = {
    assist.STATUS_DRAFT: "Draft",
    assist.STATUS_SUBMITTED: "Awaiting Review",
    assist.STATUS_UNDER_REVIEW: "Under Review",
    assist.STATUS_APPROVED: "Published",
    assist.STATUS_REJECTED: "Rejected",
}

# an announcement whose approval levels are 1 is published by its own author;
# anything higher goes through the review stages instead
SELF_PUBLISH_APPROVAL_LEVELS = 1


def _check_allowed(label, value, allowed):
    """Rejects a value the form does not offer as a choice"""
    if value is None or value == "":
        return None

    cleaned = " ".join(str(value).split())
    for option in allowed:
        if cleaned.upper() == option.upper():
            # there is one spelling of each choice, so return that one
            return option

    raise ValueError(f"{label} must be one of {', '.join(allowed)}")


def _clean_text(value):
    if value is None:
        return None
    cleaned = " ".join(str(value).split())
    return cleaned or None


def is_live(announcement, today=None):
    """Whether a participant would see this announcement right now.

    Published is not the same as visible: an announcement can be published
    ahead of the window it is meant to appear in, and can fall out of the board
    again once its window closes.
    """
    if announcement.status_id != assist.STATUS_APPROVED:
        return False

    today = today or assist.get_current_date().date()

    if announcement.publish_from and announcement.publish_from > today:
        return False

    if announcement.publish_until and announcement.publish_until < today:
        return False

    return True


# ---------- SQLAlchemy Models ----------
class AnnouncementDB(Base):
    __tablename__ = "announcements"

    # id
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)

    # name
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    # the notice itself
    body = Column(Text, nullable=True)

    # properties
    category = Column(String, nullable=False)
    audience = Column(String, nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=True)
    pinned = Column(Boolean, nullable=False, default=False)

    # the window it is visible in
    publish_from = Column(Date, nullable=True)
    publish_until = Column(Date, nullable=True)

    # an occasion
    event_at = Column(DateTime(timezone=True), nullable=True)
    event_ends_at = Column(DateTime(timezone=True), nullable=True)
    location = Column(String, nullable=True)

    # a resource
    link_url = Column(String, nullable=True)

    # when it went out
    published_at = Column(DateTime(timezone=True), nullable=True)
    published_by = Column(String, nullable=True)

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
    user = relationship("UserDB", back_populates="announcement", lazy='raise')
    status = relationship("StatusDB", back_populates="announcement", lazy='raise')
    stage = relationship("StageDB", back_populates="announcement", lazy='raise')
    scheme = relationship("SchemeDB", back_populates="announcement", lazy='raise')

    #links


# ---------- Pydantic Schemas ----------
class Announcement(BaseModel):
    # id
    id: Optional[int] = None

    # name
    name: str = Field(
        ...,
        min_length=TITLE_MIN_LENGTH,
        description=f"The headline, at least {TITLE_MIN_LENGTH} characters",
    )
    description: Optional[str] = Field(
        default=None, description="A one-line summary shown under the headline"
    )

    # the notice itself - optional on the model so a notice can be parked half
    # written; the rules below are what make one publishable
    body: Optional[str] = Field(
        default=None, description="The announcement itself"
    )

    # properties
    category: str = Field(
        ...,
        description=f"What the notice is, one of {CATEGORY_VALUES}",
    )
    audience: str = Field(
        ...,
        description=f"Who it is for, one of {AUDIENCE_VALUES}",
    )
    scheme_id: Optional[int] = Field(
        default=None,
        description=f"The scheme it is for, required when the audience is "
                    f"'{AUDIENCE_SCHEME}'",
    )
    pinned: Optional[bool] = Field(
        default=False, description="Sorts this notice above the rest"
    )

    # the window it is visible in
    publish_from: Optional[date] = Field(
        default=None,
        description="The day it appears on the board; blank means immediately",
    )
    publish_until: Optional[date] = Field(
        default=None,
        description="The last day it appears; blank means it does not expire",
    )

    # an occasion
    event_at: Optional[datetime] = Field(
        default=None,
        description=f"When it happens, required for {DATED_CATEGORIES}",
    )
    event_ends_at: Optional[datetime] = Field(
        default=None, description="When it ends, if it runs to a finish time"
    )
    location: Optional[str] = Field(
        default=None, description="Where it happens, or the meeting link"
    )

    # a resource
    link_url: Optional[str] = Field(
        default=None, description="Where the resource can be found"
    )

    # when it went out
    published_at: Optional[datetime] = None
    published_by: Optional[str] = None

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
        default=SELF_PUBLISH_APPROVAL_LEVELS,
        ge=1,
        le=3,
        description="Approval levels must be between 1 and 3. At 1 the author "
                    "publishes the announcement themselves",
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

    @validator("category")
    def check_category(cls, value):
        cleaned = _check_allowed("Category", value, CATEGORY_VALUES)
        if not cleaned:
            raise ValueError(
                f"Category must be one of {', '.join(CATEGORY_VALUES)}"
            )
        return cleaned

    @validator("audience")
    def check_audience(cls, value):
        cleaned = _check_allowed("Audience", value, AUDIENCE_VALUES)
        if not cleaned:
            raise ValueError(
                f"Audience must be one of {', '.join(AUDIENCE_VALUES)}"
            )
        return cleaned

    @validator("name", "description", "location")
    def check_line(cls, value):
        return _clean_text(value)

    @validator("link_url")
    def check_link_url(cls, value):
        """Keeps a link to something a browser can actually open"""
        cleaned = _clean_text(value)
        if cleaned is None:
            return None

        if not cleaned.lower().startswith(("http://", "https://")):
            raise ValueError(
                "The link must be a web address starting with http:// or https://"
            )
        return cleaned

    @validator("body")
    def check_body(cls, value):
        if value is None:
            return None
        # a notice keeps its paragraphs, so only the ends are trimmed
        cleaned = value.strip()
        return cleaned or None

    @root_validator
    def check_announcement_is_consistent(cls, values):
        """Applies the rules a notice has to satisfy before it goes out.

        A draft may be half written - an announcement is drafted, thought
        better of, and finished later - but the moment it is published it has
        to be a notice a participant can act on: it has to say something, and
        an occasion has to say when.
        """
        audience = values.get("audience")
        scheme_id = values.get("scheme_id")
        category = values.get("category")

        # the audience and the scheme have to agree, at every status. A notice
        # addressed to nobody in particular is not a draft, it is a mistake.
        if audience == AUDIENCE_SCHEME and not scheme_id:
            raise ValueError(
                f"Please choose the scheme this announcement is for, or address "
                f"it to '{AUDIENCE_ALL}'"
            )

        if audience == AUDIENCE_ALL and scheme_id:
            raise ValueError(
                f"An announcement to '{AUDIENCE_ALL}' cannot also name a scheme"
            )

        publish_from = values.get("publish_from")
        publish_until = values.get("publish_until")
        if publish_from and publish_until and publish_until < publish_from:
            raise ValueError(
                "The announcement cannot stop being shown before it starts"
            )

        event_at = values.get("event_at")
        event_ends_at = values.get("event_ends_at")
        if event_ends_at and not event_at:
            raise ValueError(
                "Please give the time the event starts as well as the time it ends"
            )

        if event_at and event_ends_at and event_ends_at < event_at:
            raise ValueError("The event cannot end before it starts")

        # only an occasion has a time and a place
        if category and category not in DATED_CATEGORIES and event_at:
            raise ValueError(
                f"Only an {' or a '.join(DATED_CATEGORIES)} announcement carries "
                f"a date and time"
            )

        if values.get("status_id") != assist.STATUS_APPROVED:
            # not published yet, a half written notice is fine
            return values

        if not values.get("body") or len(values["body"]) < BODY_MIN_LENGTH:
            raise ValueError(
                f"Please write the announcement itself, at least "
                f"{BODY_MIN_LENGTH} characters, before publishing it"
            )

        if category in DATED_CATEGORIES and not event_at:
            raise ValueError(
                f"Please give the date and time before publishing "
                f"{'an' if category == CATEGORY_EVENT else 'a'} {category}"
            )

        return values

    class Config:
        orm_mode = True


class AnnouncementWithDetail(Announcement):
    stage: Stage
    status: Status
    user: User

    scheme: Optional[Scheme] = None

    # filled in by the router; neither is a column
    statusLabel: Optional[str] = None
    live: Optional[bool] = None
    attachmentList: Optional[List[Attachment]] = []


class ParamAnnouncementEdit(BaseModel):
    announcement: Optional[AnnouncementWithDetail] = None
    schemeList: Optional[List[Scheme]] = []
    categoryList: Optional[List[str]] = []
    audienceList: Optional[List[str]] = []

    class Config:
        orm_mode = True


class ParamAnnouncementPublish(BaseModel):
    """Who is publishing, and anything they want recorded against it"""
    user_id: int = Field(
        ..., ge=1, description="The user publishing the announcement"
    )
    comments: Optional[str] = None
