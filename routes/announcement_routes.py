from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from database import get_db
from models.announcement_model import (
    ATTACHMENT_TYPE,
    AUDIENCE_ALL,
    AUDIENCE_DESCRIPTIONS,
    AUDIENCE_SCHEME,
    AUDIENCE_VALUES,
    BODY_MIN_LENGTH,
    CATEGORY_DESCRIPTIONS,
    CATEGORY_RESOURCE,
    CATEGORY_VALUES,
    DATED_CATEGORIES,
    SELF_PUBLISH_APPROVAL_LEVELS,
    STATUS_LABELS,
    TITLE_MIN_LENGTH,
    Announcement,
    AnnouncementDB,
    AnnouncementWithDetail,
    ParamAnnouncementEdit,
    ParamAnnouncementPublish,
    is_live,
)
# approval
from models.stage_model import Stage
from models.status_model import Status
from models.user_model import User, UserDB
from models.review_model import Review
from helpers import assist
from sqlalchemy.orm import selectinload
# relations
from models.attachment_model import AttachmentDB
from models.scheme_model import SchemeDB

router = APIRouter(prefix="/announcements", tags=["Announcements"])


async def _get_admin_user(db: AsyncSession, user_id: int, doing: str) -> UserDB:
    """Loads the acting user and checks they may run the noticeboard.

    The board speaks for the provider, so only provider staff write to it. A
    laboratory reads it and nothing more.
    """
    result = await db.execute(select(UserDB).where(UserDB.id == user_id))
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=400,
            detail=f"The user with id '{user_id}' does not exist",
        )

    if not assist.is_admin_role(user.role_id):
        raise HTTPException(
            status_code=403,
            detail=f"You are not permitted to {doing} announcements",
        )

    return user


async def _attachments(db: AsyncSession, announcement_ids):
    """The files filed against each announcement, keyed by announcement"""
    if not announcement_ids:
        return {}

    result = await db.execute(
        select(AttachmentDB)
        .where(
            AttachmentDB.type == ATTACHMENT_TYPE,
            AttachmentDB.parent.in_(announcement_ids),
        )
        .order_by(AttachmentDB.id)
    )

    filed = {}
    for attachment in result.scalars().all():
        filed.setdefault(attachment.parent, []).append(attachment)
    return filed


async def _decorate(db: AsyncSession, announcements):
    """Adds what the board shows but the table does not store.

    Whether a notice is live is a question about today, not a column, and its
    attachments live in the shared attachments table - so both are answered
    here rather than being left for the client to work out.
    """
    items = [a for a in announcements if a is not None]
    filed = await _attachments(db, [a.id for a in items])

    decorated = []
    for announcement in items:
        item = AnnouncementWithDetail.from_orm(announcement)
        item.statusLabel = STATUS_LABELS.get(announcement.status_id)
        item.live = is_live(announcement)
        item.attachmentList = filed.get(announcement.id, [])
        decorated.append(item)

    return decorated


def _announcement_query():
    """The query every listing shares, with its detail loaded.

    Pinned first, then the newest notice - which for an occasion is the one
    happening soonest, and otherwise the one most recently published.
    """
    return (
        select(AnnouncementDB)
        .options(
            selectinload(AnnouncementDB.stage),
            selectinload(AnnouncementDB.status),
            selectinload(AnnouncementDB.user),
            selectinload(AnnouncementDB.scheme),
        )
        .order_by(
            AnnouncementDB.pinned.desc(),
            AnnouncementDB.published_at.desc().nullslast(),
            AnnouncementDB.id.desc(),
        )
    )


@router.post("/create", response_model=Announcement)
async def post_announcement(
    announcement: Announcement, db: AsyncSession = Depends(get_db)
):
    """Writes a notice. It is a draft until somebody publishes it.

    The status the caller asks for is not taken on trust: a notice reaches
    participants through /publish or /review-update, so that whoever put it in
    front of them is recorded.
    """
    user = await _get_admin_user(db, announcement.user_id, "write")

    if announcement.scheme_id is not None:
        result = await db.execute(
            select(SchemeDB).where(SchemeDB.id == announcement.scheme_id)
        )
        if not result.scalars().first():
            raise HTTPException(
                status_code=400,
                detail=f"The scheme with id '{announcement.scheme_id}' does not exist",
            )

    db_context = AnnouncementDB(
        # update
        name=announcement.name,
        description=announcement.description,
        body=announcement.body,
        # properties
        category=announcement.category,
        audience=announcement.audience,
        scheme_id=announcement.scheme_id,
        pinned=announcement.pinned,
        publish_from=announcement.publish_from,
        publish_until=announcement.publish_until,
        event_at=announcement.event_at,
        event_ends_at=announcement.event_ends_at,
        location=announcement.location,
        link_url=announcement.link_url,
        # approval - a new notice always starts as a draft
        user_id=announcement.user_id,
        status_id=assist.STATUS_DRAFT,
        stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
        approval_levels=announcement.approval_levels,
        # service
        created_by=user.email,
    )
    db.add(db_context)
    try:
        await db.commit()
        await db.refresh(db_context)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Could not create Announcement: {e}")

    return db_context


@router.post("/initialize")
async def initialize(db: AsyncSession = Depends(get_db)):

    itemList = []

    for value in itemList:
        db_item = AnnouncementDB(
            # add item
            name=value["name"],
            user_id=1,
            status_id=4,
            stage_id=5,
            approval_levels=1
        )
        db.add(db_item)

    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to initialize items for Announcement: f{e}"
        )
    return {
        "succeeded": True,
        "message": "Items for Announcement have been successfully initialized",
    }


@router.get("/options")
async def get_announcement_options():
    """The choices the noticeboard offers, so the client offers exactly these"""
    return {
        "categoryList": CATEGORY_VALUES,
        "categoryDescriptions": CATEGORY_DESCRIPTIONS,
        "datedCategoryList": DATED_CATEGORIES,
        "audienceList": AUDIENCE_VALUES,
        "audienceDescriptions": AUDIENCE_DESCRIPTIONS,
        "statusLabels": STATUS_LABELS,
        "attachmentType": ATTACHMENT_TYPE,
        "titleMinLength": TITLE_MIN_LENGTH,
        "bodyMinLength": BODY_MIN_LENGTH,
        "selfPublishApprovalLevels": SELF_PUBLISH_APPROVAL_LEVELS,
    }


@router.get("/list", response_model=List[AnnouncementWithDetail])
async def list_announcements(
    category: Optional[str] = Query(
        default=None, description="Only notices of this category"
    ),
    audience: Optional[str] = Query(
        default=None, description="Only notices addressed this way"
    ),
    scheme_id: Optional[int] = Query(
        default=None, description="Only notices for this scheme"
    ),
    status_id: Optional[int] = Query(
        default=None, description="Only notices at this status"
    ),
    published: Optional[bool] = Query(
        default=None, description="Only published notices, or only unpublished"
    ),
    db: AsyncSession = Depends(get_db),
):
    """The whole board, drafts included. This is the provider's view."""
    query = _announcement_query()

    if category is not None:
        query = query.where(AnnouncementDB.category == category)

    if audience is not None:
        query = query.where(AnnouncementDB.audience == audience)

    if scheme_id is not None:
        query = query.where(AnnouncementDB.scheme_id == scheme_id)

    if status_id is not None:
        query = query.where(AnnouncementDB.status_id == status_id)

    if published is not None:
        if published:
            query = query.where(AnnouncementDB.status_id == assist.STATUS_APPROVED)
        else:
            query = query.where(AnnouncementDB.status_id != assist.STATUS_APPROVED)

    result = await db.execute(query)
    return await _decorate(db, result.scalars().all())


@router.get("/feed", response_model=List[AnnouncementWithDetail])
async def get_announcement_feed(
    lab_id: Optional[int] = Query(
        default=None,
        description=(
            "The laboratory reading the board. Its own scheme notices are "
            "included; leave it off for the notices addressed to everyone."
        ),
    ),
    category: Optional[str] = Query(
        default=None, description="Only notices of this category"
    ),
    db: AsyncSession = Depends(get_db),
):
    """What a participant actually sees: published, in date, and addressed to them.

    A laboratory gets the notices for everyone plus the notices for the schemes
    it is registered in - registered meaning accepted for one of that scheme's
    methods, which is the definition vw_laboratory_scheme already settles.
    """
    today = assist.get_current_date().date()

    query = _announcement_query().where(
        AnnouncementDB.status_id == assist.STATUS_APPROVED,
        or_(
            AnnouncementDB.publish_from.is_(None),
            AnnouncementDB.publish_from <= today,
        ),
        or_(
            AnnouncementDB.publish_until.is_(None),
            AnnouncementDB.publish_until >= today,
        ),
    )

    if lab_id is None:
        # nobody in particular is reading, so only the board for everyone
        query = query.where(AnnouncementDB.audience == AUDIENCE_ALL)
    else:
        result = await db.execute(
            text(
                """
                SELECT scheme_id FROM vw_laboratory_scheme
                WHERE lab_id = :lab_id AND participation = 'Accepted'
                """
            ),
            {"lab_id": lab_id},
        )
        scheme_ids = [row[0] for row in result.all()]

        audience_filter = [AnnouncementDB.audience == AUDIENCE_ALL]
        if scheme_ids:
            audience_filter.append(AnnouncementDB.scheme_id.in_(scheme_ids))

        query = query.where(or_(*audience_filter))

    if category is not None:
        query = query.where(AnnouncementDB.category == category)

    result = await db.execute(query)
    return await _decorate(db, result.scalars().all())


# the board is written by its author; who published it is recorded separately
EDITABLE_ANNOUNCEMENT_FIELDS = [
    "name",
    "description",
    "body",
    "category",
    "audience",
    "scheme_id",
    "pinned",
    "publish_from",
    "publish_until",
    "event_at",
    "event_ends_at",
    "location",
    "link_url",
    "approval_levels",
]


@router.put("/update/{id}", response_model=Announcement)
async def update_announcement(
    id: int, announcement_update: Announcement, db: AsyncSession = Depends(get_db)
):
    """Edits a notice.

    A published notice can still be corrected - a wrong room number is worth
    fixing in place rather than withdrawing - but whether it is published is
    not something an edit decides. That is what /publish and /unpublish are
    for, so the record of who put it in front of participants stays true.
    """
    result = await db.execute(
        select(AnnouncementDB).where(AnnouncementDB.id == id)
    )
    announcement = result.scalars().first()

    if not announcement:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Announcement with id '{id}'",
        )

    user = await _get_admin_user(db, announcement_update.user_id, "edit")

    if announcement_update.scheme_id is not None:
        result = await db.execute(
            select(SchemeDB).where(SchemeDB.id == announcement_update.scheme_id)
        )
        if not result.scalars().first():
            raise HTTPException(
                status_code=400,
                detail=f"The scheme with id '{announcement_update.scheme_id}' "
                       "does not exist",
            )

    changes = announcement_update.dict(exclude_unset=True)
    for key in EDITABLE_ANNOUNCEMENT_FIELDS:
        if key in changes:
            setattr(announcement, key, changes[key])

    # an edit must leave a published notice still fit to be published
    if announcement.status_id == assist.STATUS_APPROVED:
        _check_publishable(announcement)

    announcement.updated_by = user.email

    try:
        await db.commit()
        await db.refresh(announcement)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Announcement {e}")
    return announcement


def _check_publishable(announcement):
    """The rules a notice has to satisfy to be in front of participants.

    The same rules the model applies at Approved, restated here because the
    model checks the payload a caller sent and this checks the row as it
    stands - a notice is published without its body being resent.
    """
    if not announcement.body or len(announcement.body.strip()) < BODY_MIN_LENGTH:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Please write the announcement itself, at least "
                f"{BODY_MIN_LENGTH} characters, before publishing it"
            ),
        )

    if announcement.category in DATED_CATEGORIES and not announcement.event_at:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Please give the date and time before publishing "
                f"{'an' if announcement.category == 'Event' else 'a'} "
                f"{announcement.category}"
            ),
        )

    if announcement.audience == AUDIENCE_SCHEME and not announcement.scheme_id:
        raise HTTPException(
            status_code=400,
            detail="Please choose the scheme this announcement is for",
        )


async def _check_resource_has_something(db, announcement):
    """A Resource that points nowhere is not a resource.

    It can be a link or an attached file, so this can only be settled once the
    files filed against the notice are known.
    """
    if announcement.category != CATEGORY_RESOURCE or announcement.link_url:
        return

    result = await db.execute(
        select(AttachmentDB.id).where(
            AttachmentDB.type == ATTACHMENT_TYPE,
            AttachmentDB.parent == announcement.id,
        )
    )

    if not result.scalars().first():
        raise HTTPException(
            status_code=400,
            detail=(
                "A Resource announcement must carry a link or an attached file. "
                "Add one, or post it as a General announcement instead."
            ),
        )


@router.put("/publish/{id}", response_model=Announcement)
async def publish_announcement(
    id: int, publish: ParamAnnouncementPublish, db: AsyncSession = Depends(get_db)
):
    """Puts a notice on the board.

    This is the ordinary way an announcement goes out, and the author may do it
    themselves: a notice that a meeting has moved to Thursday is no use on
    Friday. A scheme that wants a second pair of eyes sets the announcement's
    approval levels above one, and then this is refused in favour of the
    review stages.
    """
    result = await db.execute(
        select(AnnouncementDB).where(AnnouncementDB.id == id)
    )
    announcement = result.scalars().first()

    if not announcement:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Announcement with id '{id}'",
        )

    user = await _get_admin_user(db, publish.user_id, "publish")

    if announcement.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This announcement has already been published",
        )

    if announcement.approval_levels > SELF_PUBLISH_APPROVAL_LEVELS:
        raise HTTPException(
            status_code=400,
            detail=(
                f"This announcement is set to {announcement.approval_levels} "
                "levels of approval, so it is published by its reviewers. "
                "Submit it for review instead."
            ),
        )

    _check_publishable(announcement)
    await _check_resource_has_something(db, announcement)

    announcement.status_id = assist.STATUS_APPROVED
    announcement.stage_id = assist.APPROVAL_STAGE_APPROVED
    announcement.published_at = assist.get_current_date(False)
    announcement.published_by = user.email
    announcement.updated_by = user.email

    if publish.comments:
        announcement.review1_at = announcement.published_at
        announcement.review1_by = user.email
        announcement.review1_comments = publish.comments

    try:
        await db.commit()
        await db.refresh(announcement)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to publish Announcement: {e}")
    return announcement


@router.put("/unpublish/{id}", response_model=Announcement)
async def unpublish_announcement(
    id: int, publish: ParamAnnouncementPublish, db: AsyncSession = Depends(get_db)
):
    """Takes a notice off the board and back to draft.

    Used when something goes out that should not have. The notice is kept -
    participants may have acted on it, and the board should be able to say what
    it said - it simply stops being shown.
    """
    result = await db.execute(
        select(AnnouncementDB).where(AnnouncementDB.id == id)
    )
    announcement = result.scalars().first()

    if not announcement:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Announcement with id '{id}'",
        )

    user = await _get_admin_user(db, publish.user_id, "unpublish")

    if announcement.status_id != assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This announcement is not published, so it cannot be withdrawn",
        )

    announcement.status_id = assist.STATUS_DRAFT
    announcement.stage_id = assist.APPROVAL_STAGE_AWAIT_SUBMISSION
    announcement.published_at = None
    announcement.published_by = None
    announcement.updated_by = user.email

    if publish.comments:
        announcement.review1_comments = publish.comments

    try:
        await db.commit()
        await db.refresh(announcement)
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=400, detail=f"Unable to withdraw Announcement: {e}"
        )
    return announcement


@router.put("/submit/{id}", response_model=Announcement)
async def submit_announcement(
    id: int, publish: ParamAnnouncementPublish, db: AsyncSession = Depends(get_db)
):
    """Sends a notice for review, for a board that wants a second pair of eyes.

    Only meaningful when the announcement asks for more than one level of
    approval; at one level the author publishes it themselves.
    """
    result = await db.execute(
        select(AnnouncementDB).where(AnnouncementDB.id == id)
    )
    announcement = result.scalars().first()

    if not announcement:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Announcement with id '{id}'",
        )

    user = await _get_admin_user(db, publish.user_id, "submit")

    if announcement.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail="This announcement has already been published",
        )

    if announcement.approval_levels <= SELF_PUBLISH_APPROVAL_LEVELS:
        raise HTTPException(
            status_code=400,
            detail=(
                "This announcement needs no review, so publish it directly. "
                "Set its approval levels above one to have it reviewed."
            ),
        )

    _check_publishable(announcement)
    await _check_resource_has_something(db, announcement)

    announcement.status_id = assist.STATUS_SUBMITTED
    announcement.stage_id = assist.APPROVAL_STAGE_SUBMITTED
    announcement.updated_by = user.email

    try:
        await db.commit()
        await db.refresh(announcement)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to submit Announcement: {e}")
    return announcement


@router.get("/id/{id}", response_model=ParamAnnouncementEdit)
async def get_announcement(id: int, db: AsyncSession = Depends(get_db)):
    announcementItem = None
    # only load if not zero
    if id != 0:
        result = await db.execute(
            select(AnnouncementDB
            ).options(
                selectinload(AnnouncementDB.stage),
                selectinload(AnnouncementDB.status),
                selectinload(AnnouncementDB.user),

                selectinload(AnnouncementDB.scheme),
            )
            .filter(AnnouncementDB.id == id)
        )
        announcement = result.scalars().first()
        if not announcement:
            raise HTTPException(
                status_code=404, detail=f"Unable to find 'Announcement with id '{id}' not found"
            )
        announcementItem = (await _decorate(db, [announcement]))[0]

    # get supporting models if available

    # Scheme
    result = await db.execute(
        select(SchemeDB)
        .order_by(SchemeDB.name)
    )
    schemeItems = result.scalars().all()

    res = ParamAnnouncementEdit(
            announcement=announcementItem,
            schemeList = schemeItems,
            categoryList = CATEGORY_VALUES,
            audienceList = AUDIENCE_VALUES,
    )

    return res


@router.put("/review-update/{id}", response_model=Announcement)
async def review_posting(
    id: int, review: Review, db: AsyncSession = Depends(get_db)
):
    # check user exists
    user = await _get_admin_user(db, review.user_id, "review")

    # check if item exists
    result = await db.execute(select(AnnouncementDB).where(AnnouncementDB.id == id))
    announcement = result.scalar_one_or_none()

    if not announcement:
        raise HTTPException(
            status_code=404,
            detail=f"Unable to find Announcement with id '{id}' not found",
        )

    if announcement.status_id == assist.STATUS_APPROVED:
        raise HTTPException(
            status_code=400,
            detail=f"The Announcement with id '{id}' has already been published",
        )

    announcement.updated_by = user.email

    approveAnnouncement = False

    if announcement.stage_id == assist.APPROVAL_STAGE_SUBMITTED:
        # submitted stage

        if announcement.user_id == user.id:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the first reviewer of an Announcement you created",
        )

        announcement.review1_at = assist.get_current_date(False)
        announcement.review1_by = user.email
        announcement.review1_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            announcement.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if announcement.approval_levels == 1:
                # one level, no furthur stage approvers

                # approve announcement
                approveAnnouncement = True

            elif announcement.approval_levels == 2 or announcement.approval_levels == 3:
                # two or three levels, move to primary

                announcement.stage_id = assist.APPROVAL_STAGE_PRIMARY

    elif announcement.stage_id == assist.APPROVAL_STAGE_PRIMARY:
        # primary stage

        if announcement.review1_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the secondary reviewer since you were the primary reviewer",
        )

        announcement.review2_at = assist.get_current_date(False)
        announcement.review2_by = user.email
        announcement.review2_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            announcement.status_id = assist.STATUS_REJECTED
        else:
            # approve

            # check number of approval levels
            if announcement.approval_levels == 2:
                # two levels, no furthur stage approvers

                approveAnnouncement = True

            elif announcement.approval_levels == 3:
                # three levels, move to secondary
                announcement.stage_id = assist.APPROVAL_STAGE_SECONDARY

    elif announcement.stage_id == assist.APPROVAL_STAGE_SECONDARY:
        # secondary stage

        if announcement.review2_by == user.email:
            raise HTTPException(
                status_code=400,
                detail=f"You cannot be the final reviewer since you were the secondary reviewer",
        )

        announcement.review3_at = assist.get_current_date(False)
        announcement.review3_by = user.email
        announcement.review3_comments = review.comments

        if review.review_action == assist.REVIEW_ACTION_REJECT:
            # reject

            announcement.status_id = assist.STATUS_REJECTED
        else:
            # approve
            # three levels and on last stage
            approveAnnouncement = True

    if approveAnnouncement:
        # a reviewer approving an announcement is what publishes it
        _check_publishable(announcement)
        await _check_resource_has_something(db, announcement)

        announcement.status_id = assist.STATUS_APPROVED
        announcement.stage_id = assist.APPROVAL_STAGE_APPROVED
        announcement.published_at = assist.get_current_date(False)
        announcement.published_by = user.email

    try:
        await db.commit()
        await db.refresh(announcement)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Unable to update Announcement: {e}")
    return announcement
