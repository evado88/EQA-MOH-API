-- The noticeboard: what the provider tells its participants.
--
-- Events, meetings, resources and general notices all sit in one table. They
-- differ in which fields they fill in, not in shape: an Event or a Meeting
-- carries a date and a place, a Resource carries a link or an attachment, and
-- a General notice carries neither.
--
-- Two things make an announcement visible to a participant:
--
--   1. it is published - status_id = 4 (Approved), the same column every
--      other table uses for the same idea; and
--   2. today falls inside its publish window, which is open at either end.
--
-- Publishing is normally the author's own doing: an announcement created with
-- approval_levels = 1 is published by whoever wrote it, because a notice that
-- a meeting has moved to Thursday is no use on Friday. A scheme that wants a
-- second pair of eyes sets approval_levels to 2 or 3 and the announcement goes
-- through the same review stages as everything else instead.
--
-- Attachments are the existing attachments table, with type = 'Announcement'
-- and parent = the announcement id, so a Resource can be a file rather than a
-- link without a table of its own.
--
--   psql -U postgres -d moheqa -f migrations/011_announcements.sql

BEGIN;

CREATE TABLE IF NOT EXISTS announcements (
    id                      SERIAL PRIMARY KEY,

    -- the headline, and a one-line standfirst under it
    name                    VARCHAR NOT NULL,
    description             VARCHAR,

    -- the notice itself
    body                    TEXT,

    -- Event, Meeting, Resource or General
    category                VARCHAR NOT NULL,

    -- who it is for: 'All Participants', or the labs registered in one scheme
    audience                VARCHAR NOT NULL,
    scheme_id               INTEGER REFERENCES schemes(id),

    -- a pinned notice sorts above the rest, whatever its date
    pinned                  BOOLEAN NOT NULL DEFAULT FALSE,

    -- the window it is visible in; open at either end
    publish_from            DATE,
    publish_until           DATE,

    -- an Event or a Meeting happens somewhere, at a time
    event_at                TIMESTAMPTZ,
    event_ends_at           TIMESTAMPTZ,
    location                VARCHAR,

    -- a Resource points somewhere, unless it is an attached file
    link_url                VARCHAR,

    -- when it actually went out, and who sent it
    published_at            TIMESTAMPTZ,
    published_by            VARCHAR,

    user_id                 INTEGER NOT NULL REFERENCES users(id),
    status_id               INTEGER NOT NULL REFERENCES list_statuses(id),
    stage_id                INTEGER NOT NULL REFERENCES list_stages(id),
    approval_levels         INTEGER NOT NULL,

    review1_at              TIMESTAMPTZ,
    review1_by              VARCHAR,
    review1_comments        VARCHAR,
    review2_at              TIMESTAMPTZ,
    review2_by              VARCHAR,
    review2_comments        VARCHAR,
    review3_at              TIMESTAMPTZ,
    review3_by              VARCHAR,
    review3_comments        VARCHAR,

    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

CREATE INDEX IF NOT EXISTS ix_announcements_id ON announcements (id);

-- the feed reads by audience and window, in that order
CREATE INDEX IF NOT EXISTS ix_announcements_audience
    ON announcements (audience, scheme_id);
CREATE INDEX IF NOT EXISTS ix_announcements_window
    ON announcements (status_id, publish_from, publish_until);

-- A scheme announcement names its scheme; an announcement to everyone does
-- not. Without this the two could disagree - a row claiming to be for all
-- participants while pointing at one scheme has no defined audience.
DO $$ BEGIN
    ALTER TABLE announcements
        ADD CONSTRAINT ck_announcements_audience_scheme
        CHECK (
            (audience = 'Scheme' AND scheme_id IS NOT NULL)
            OR (audience <> 'Scheme' AND scheme_id IS NULL)
        );
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- a window that closes before it opens would never be visible at all
DO $$ BEGIN
    ALTER TABLE announcements
        ADD CONSTRAINT ck_announcements_window
        CHECK (
            publish_from IS NULL
            OR publish_until IS NULL
            OR publish_until >= publish_from
        );
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- likewise an event that ends before it starts
DO $$ BEGIN
    ALTER TABLE announcements
        ADD CONSTRAINT ck_announcements_event_window
        CHECK (
            event_at IS NULL
            OR event_ends_at IS NULL
            OR event_ends_at >= event_at
        );
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;


-- What each participant sees, resolved once here rather than in every caller.
--
-- A laboratory is in a scheme when it has been accepted for one of that
-- scheme's methods - the definition vw_laboratory_scheme already settles, and
-- deliberately the same one, so 'registered' cannot come to mean two things.
--
-- An announcement to all participants appears against every laboratory; a
-- scheme announcement only against the laboratories in that scheme. Provider
-- staff are not laboratories and are not listed here: they read the board
-- through /announcements/list, which shows drafts too.
DROP VIEW IF EXISTS vw_announcement_audience;
CREATE VIEW vw_announcement_audience AS
SELECT
    a.id                                AS announcement_id,
    a.name,
    a.description,
    a.category,
    a.audience,
    a.scheme_id,
    s.name                              AS scheme_name,
    a.pinned,
    a.publish_from,
    a.publish_until,
    a.event_at,
    a.event_ends_at,
    a.location,
    a.link_url,
    a.published_at,
    a.published_by,
    l.id                                AS lab_id,
    l.code                              AS lab_code,
    l.name                              AS lab_name
FROM announcements a
JOIN laboratorys l
  ON a.audience = 'All Participants'
 OR EXISTS (
        SELECT 1 FROM vw_laboratory_scheme v
        WHERE v.lab_id = l.id
          AND v.scheme_id = a.scheme_id
          AND v.participation = 'Accepted'
    )
LEFT JOIN schemes s ON s.id = a.scheme_id
WHERE a.status_id = 4
  AND (a.publish_from IS NULL OR a.publish_from <= CURRENT_DATE)
  AND (a.publish_until IS NULL OR a.publish_until >= CURRENT_DATE);

COMMIT;
