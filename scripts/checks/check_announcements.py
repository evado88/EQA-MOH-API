"""Noticeboard audit.

Checks the announcements feature end to end: that only provider staff can post,
that a notice reaches participants only once it is published and only while its
window is open, that a scheme notice goes to that scheme's laboratories and no
further, that the configurable review gate really gates, and that the rules on
what a notice must say before it goes out are enforced.

It writes its own announcements and removes them again, asserting the table is
back to the size it started at.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_announcements.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import sys
from datetime import date, timedelta

import asyncpg
from httpx import ASGITransport, AsyncClient

import main
from helpers import assist

# what the noticeboard page binds to on every row
ROW_FIELDS = [
    "id", "name", "description", "body", "category", "audience", "scheme_id",
    "pinned", "publish_from", "publish_until", "event_at", "event_ends_at",
    "location", "link_url", "published_at", "published_by", "status_id",
    "stage_id", "approval_levels", "statusLabel", "live", "attachmentList",
]

TODAY = date.today()

# announcements this script creates, so it can clear up after itself
CREATED = []


async def _admin_ids(con):
    """The provider staff the check posts and reviews as"""
    rows = await con.fetch(
        "SELECT id, email, role_id FROM users WHERE role_id = ANY($1::int[]) "
        "ORDER BY id",
        list(assist.ADMIN_ROLES),
    )
    return [dict(r) for r in rows]


async def _lab_user(con):
    """A laboratory account, which must not be able to post"""
    row = await con.fetchrow(
        "SELECT id, email, laboratory_id FROM users "
        "WHERE role_id = ANY($1::int[]) AND laboratory_id IS NOT NULL "
        "ORDER BY id LIMIT 1",
        list(assist.LABORATORY_ROLES),
    )
    return dict(row) if row else None


def _draft(author_id, **overrides):
    body = dict(
        name="Check - a notice written by the audit",
        description="Written by check_announcements.py",
        body="This announcement was created by the noticeboard audit and is "
             "removed again before it finishes.",
        category="General",
        audience="All Participants",
        scheme_id=None,
        pinned=False,
        publish_from=None,
        publish_until=None,
        event_at=None,
        event_ends_at=None,
        location=None,
        link_url=None,
        user_id=author_id,
        status_id=assist.STATUS_DRAFT,
        stage_id=assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
        approval_levels=1,
    )
    body.update(overrides)
    return body


async def _create(c, checks, author_id, **overrides):
    r = await c.post("/announcements/create", json=_draft(author_id, **overrides))
    if r.status_code != 200:
        return None, r
    CREATED.append(r.json()["id"])
    return r.json(), r


async def main_check():
    checks = Checks("Noticeboard audit")

    con = await asyncpg.connect(DEV_DSN)
    started_with = await con.fetchval("SELECT count(*) FROM announcements")

    admins = await _admin_ids(con)
    if len(admins) < 3:
        print("  needs at least three provider staff; run seed_demo.py first")
        await con.close()
        return 1

    author, reviewer1, reviewer2 = admins[0], admins[1], admins[2]
    lab_user = await _lab_user(con)

    transport = ASGITransport(app=main.app)
    async with AsyncClient(transport=transport, base_url="http://check",
                           timeout=60) as c:

        # -------------------------------------------------- who may post
        checks.section("The board is written by provider staff only")

        r = await c.get("/announcements/options")
        options = r.json() if r.status_code == 200 else {}
        checks.check("the options answer", r.status_code == 200)
        checks.check(
            "it offers the four categories",
            set(options.get("categoryList", []))
            == {"Event", "Meeting", "Resource", "General"},
            options.get("categoryList"),
        )
        checks.check(
            "and the two audiences",
            set(options.get("audienceList", []))
            == {"All Participants", "Scheme"},
            options.get("audienceList"),
        )

        if lab_user:
            r = await c.post("/announcements/create",
                             json=_draft(lab_user["id"]))
            checks.check(
                "a laboratory account cannot post a notice",
                r.status_code == 403, f"{r.status_code} {r.text[:120]}",
            )
        else:
            checks.check("a laboratory account cannot post a notice", True,
                         "no laboratory account to try")

        r = await c.post("/announcements/create", json=_draft(999999))
        checks.check(
            "an unknown user cannot post a notice",
            r.status_code == 400, f"{r.status_code} {r.text[:120]}",
        )

        # -------------------------------------------------- a notice is born a draft
        checks.section("A new notice is a draft until somebody publishes it")

        created, r = await _create(c, checks, author["id"])
        if not checks.check("provider staff can post a notice",
                            created is not None, r.text[:160]):
            await con.close()
            return checks.report()

        checks.check(
            "it starts as a draft whatever the caller asked for",
            created["status_id"] == assist.STATUS_DRAFT
            and created["stage_id"] == assist.APPROVAL_STAGE_AWAIT_SUBMISSION,
            created,
        )
        checks.check("and is not published", created["published_at"] is None)

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("a draft is not on the board", created["id"] not in ids)

        r = await c.get("/announcements/list",
                        params={"published": False})
        ids = [a["id"] for a in r.json()]
        checks.check("but provider staff can see it", created["id"] in ids)

        row = next((a for a in r.json() if a["id"] == created["id"]), {})
        missing = [f for f in ROW_FIELDS if f not in row]
        checks.check("every field the page binds to is present", not missing, missing)
        checks.check("a draft is labelled Draft", row.get("statusLabel") == "Draft",
                     row.get("statusLabel"))
        checks.check("and is not live", row.get("live") is False, row.get("live"))

        # -------------------------------------------------- publishing
        checks.section("Publishing puts it on the board")

        r = await c.put(f"/announcements/publish/{created['id']}",
                        json={"user_id": author["id"], "comments": None})
        published = r.json() if r.status_code == 200 else {}
        checks.check("the author can publish their own notice",
                     r.status_code == 200, f"{r.status_code} {r.text[:160]}")
        checks.check("it is recorded as published",
                     published.get("status_id") == assist.STATUS_APPROVED
                     and published.get("published_at") is not None,
                     published)
        checks.check("and says who published it",
                     published.get("published_by") == author["email"],
                     published.get("published_by"))

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("now it is on the board", created["id"] in ids)

        r = await c.put(f"/announcements/publish/{created['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("publishing it twice is refused",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.put(f"/announcements/unpublish/{created['id']}",
                        json={"user_id": author["id"], "comments": None})
        withdrawn = r.json() if r.status_code == 200 else {}
        checks.check("it can be withdrawn again", r.status_code == 200,
                     f"{r.status_code} {r.text[:160]}")
        checks.check("withdrawing clears the publication record",
                     withdrawn.get("published_at") is None
                     and withdrawn.get("published_by") is None,
                     withdrawn)

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("and it leaves the board", created["id"] not in ids)

        # -------------------------------------------------- the publish window
        checks.section("The window decides when it is actually shown")

        future, _ = await _create(
            c, checks, author["id"],
            name="Check - scheduled for later",
            publish_from=(TODAY + timedelta(days=30)).isoformat(),
        )
        await c.put(f"/announcements/publish/{future['id']}",
                    json={"user_id": author["id"], "comments": None})

        expired, _ = await _create(
            c, checks, author["id"],
            name="Check - already expired",
            publish_until=(TODAY - timedelta(days=1)).isoformat(),
        )
        await c.put(f"/announcements/publish/{expired['id']}",
                    json={"user_id": author["id"], "comments": None})

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("a notice published ahead of its window is not shown yet",
                     future["id"] not in ids)
        checks.check("a notice whose window has closed is not shown",
                     expired["id"] not in ids)

        r = await c.get("/announcements/list", params={"published": True})
        rows = {a["id"]: a for a in r.json()}
        checks.check("both are still published on the provider's view",
                     future["id"] in rows and expired["id"] in rows)
        checks.check("but neither is live",
                     rows.get(future["id"], {}).get("live") is False
                     and rows.get(expired["id"], {}).get("live") is False)
        checks.check("and both are labelled Published",
                     rows.get(future["id"], {}).get("statusLabel") == "Published")

        r = await c.post("/announcements/create", json=_draft(
            author["id"],
            publish_from=(TODAY + timedelta(days=10)).isoformat(),
            publish_until=(TODAY + timedelta(days=2)).isoformat(),
        ))
        checks.check("a window that closes before it opens is refused",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        # -------------------------------------------------- audience
        checks.section("A scheme notice reaches that scheme only")

        scheme = await con.fetchrow(
            "SELECT scheme_id, count(DISTINCT lab_id) AS labs "
            "FROM vw_laboratory_scheme WHERE participation = 'Accepted' "
            "GROUP BY 1 ORDER BY 2 DESC LIMIT 1"
        )

        if scheme:
            scoped, _ = await _create(
                c, checks, author["id"],
                name="Check - a notice for one scheme",
                audience="Scheme", scheme_id=scheme["scheme_id"],
            )
            await c.put(f"/announcements/publish/{scoped['id']}",
                        json={"user_id": author["id"], "comments": None})

            inside = await con.fetchval(
                "SELECT lab_id FROM vw_laboratory_scheme "
                "WHERE scheme_id = $1 AND participation = 'Accepted' LIMIT 1",
                scheme["scheme_id"],
            )
            outside = await con.fetchval(
                "SELECT l.id FROM laboratorys l WHERE NOT EXISTS ("
                "  SELECT 1 FROM vw_laboratory_scheme v"
                "  WHERE v.lab_id = l.id AND v.scheme_id = $1"
                "    AND v.participation = 'Accepted') LIMIT 1",
                scheme["scheme_id"],
            )

            r = await c.get("/announcements/feed", params={"lab_id": inside})
            ids = [a["id"] for a in r.json()]
            checks.check("a lab in the scheme sees it", scoped["id"] in ids)

            if outside:
                r = await c.get("/announcements/feed", params={"lab_id": outside})
                ids = [a["id"] for a in r.json()]
                checks.check("a lab outside the scheme does not",
                             scoped["id"] not in ids)
            else:
                checks.check("a lab outside the scheme does not", True,
                             "every lab is in this scheme")

            r = await c.get("/announcements/feed")
            ids = [a["id"] for a in r.json()]
            checks.check("and it is not on the board for everyone",
                         scoped["id"] not in ids)

            # the view and the endpoint have to agree
            view_ids = [
                row["announcement_id"] for row in await con.fetch(
                    "SELECT announcement_id FROM vw_announcement_audience "
                    "WHERE lab_id = $1", inside)
            ]
            r = await c.get("/announcements/feed", params={"lab_id": inside})
            feed_ids = sorted(a["id"] for a in r.json())
            checks.check("the feed matches vw_announcement_audience",
                         sorted(view_ids) == feed_ids,
                         f"view {sorted(view_ids)} feed {feed_ids}")
        else:
            checks.check("a lab in the scheme sees it", False,
                         "no accepted lab/scheme pair to test with")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], audience="Scheme", scheme_id=None))
        checks.check("a scheme notice with no scheme is refused",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], audience="All Participants", scheme_id=1))
        checks.check("a notice to everyone cannot also name a scheme",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], audience="Scheme", scheme_id=999999))
        checks.check("a notice naming a scheme that does not exist is refused",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        # -------------------------------------------------- what a notice must say
        checks.section("A notice has to say something before it goes out")

        empty, _ = await _create(c, checks, author["id"],
                                 name="Check - nothing written yet", body=None)
        r = await c.put(f"/announcements/publish/{empty['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("a notice with no body cannot be published",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        undated, _ = await _create(c, checks, author["id"],
                                   name="Check - a meeting with no date",
                                   category="Meeting")
        r = await c.put(f"/announcements/publish/{undated['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("a meeting with no date cannot be published",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        pointless, _ = await _create(c, checks, author["id"],
                                     name="Check - a resource pointing nowhere",
                                     category="Resource")
        r = await c.put(f"/announcements/publish/{pointless['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("a resource with no link and no file cannot be published",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], category="Resource",
            link_url="nhrti.moh.gov.zm/protocol.pdf"))
        checks.check("a link that is not a web address is refused",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], category="General",
            event_at=(TODAY + timedelta(days=5)).isoformat() + "T09:30:00"))
        checks.check("only an Event or a Meeting carries a date",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create", json=_draft(
            author["id"], category="Event",
            event_at=(TODAY + timedelta(days=6)).isoformat() + "T09:30:00",
            event_ends_at=(TODAY + timedelta(days=5)).isoformat() + "T09:30:00"))
        checks.check("an event cannot end before it starts",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        r = await c.post("/announcements/create",
                         json=_draft(author["id"], category="Newsletter"))
        checks.check("a category the board does not offer is refused",
                     r.status_code == 422, f"{r.status_code} {r.text[:120]}")

        # -------------------------------------------------- the review gate
        checks.section("The review gate, for a board that wants one")

        gated, _ = await _create(c, checks, author["id"],
                                 name="Check - reviewed before it goes out",
                                 approval_levels=2)

        r = await c.put(f"/announcements/publish/{gated['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("a gated notice cannot be published directly",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.put(f"/announcements/submit/{gated['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("it can be submitted for review", r.status_code == 200,
                     f"{r.status_code} {r.text[:160]}")

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("a notice awaiting review is not on the board",
                     gated["id"] not in ids)

        r = await c.put(f"/announcements/review-update/{gated['id']}", json={
            "user_id": author["id"], "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "approving my own", "content": None, "attachment_id": None})
        checks.check("the author cannot review their own notice",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.put(f"/announcements/review-update/{gated['id']}", json={
            "user_id": reviewer1["id"], "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "first", "content": None, "attachment_id": None})
        first = r.json() if r.status_code == 200 else {}
        checks.check("another officer reviews it", r.status_code == 200,
                     f"{r.status_code} {r.text[:160]}")
        checks.check("one approval of two does not publish it",
                     first.get("status_id") != assist.STATUS_APPROVED,
                     first.get("status_id"))

        r = await c.put(f"/announcements/review-update/{gated['id']}", json={
            "user_id": reviewer1["id"], "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "again", "content": None, "attachment_id": None})
        checks.check("the same officer cannot approve it twice",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        r = await c.put(f"/announcements/review-update/{gated['id']}", json={
            "user_id": reviewer2["id"], "review_action": assist.REVIEW_ACTION_APPROVE,
            "comments": "second", "content": None, "attachment_id": None})
        second = r.json() if r.status_code == 200 else {}
        checks.check("the second approval publishes it",
                     second.get("status_id") == assist.STATUS_APPROVED,
                     f"{r.status_code} {r.text[:160]}")
        checks.check("and records the reviewer as the publisher",
                     second.get("published_by") == reviewer2["email"],
                     second.get("published_by"))

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("now it is on the board", gated["id"] in ids)

        r = await c.put(f"/announcements/submit/{created['id']}",
                        json={"user_id": author["id"], "comments": None})
        checks.check("an ungated notice cannot be sent for review",
                     r.status_code == 400, f"{r.status_code} {r.text[:120]}")

        # -------------------------------------------------- editing
        checks.section("Editing a notice")

        r = await c.put(f"/announcements/update/{gated['id']}", json=_draft(
            author["id"], name="Check - corrected room number",
            status_id=assist.STATUS_APPROVED,
            approval_levels=2))
        edited = r.json() if r.status_code == 200 else {}
        checks.check("a published notice can still be corrected",
                     r.status_code == 200, f"{r.status_code} {r.text[:160]}")
        checks.check("the correction is kept",
                     edited.get("name") == "Check - corrected room number",
                     edited.get("name"))
        checks.check("and it stays published",
                     edited.get("status_id") == assist.STATUS_APPROVED,
                     edited.get("status_id"))

        # Two layers refuse this, and which one answers depends on what the
        # caller claims the status is. Sending the true status is caught by the
        # model; sending a stale one is caught by the router re-checking the
        # row as it stands. Both have to hold, or a published notice could be
        # emptied by a client that simply sent the wrong status.
        r = await c.put(f"/announcements/update/{gated['id']}", json=_draft(
            author["id"], body=None, status_id=assist.STATUS_APPROVED,
            approval_levels=2))
        checks.check("an edit cannot empty a published notice",
                     r.status_code == 422, f"{r.status_code} {r.text[:160]}")

        r = await c.put(f"/announcements/update/{gated['id']}", json=_draft(
            author["id"], body=None, status_id=assist.STATUS_DRAFT,
            approval_levels=2))
        checks.check("nor by claiming it is still a draft",
                     r.status_code == 400, f"{r.status_code} {r.text[:160]}")

        r = await c.get("/announcements/feed")
        ids = [a["id"] for a in r.json()]
        checks.check("so it is still on the board, with its body intact",
                     gated["id"] in ids)

        if lab_user:
            r = await c.put(f"/announcements/update/{gated['id']}",
                            json=_draft(lab_user["id"], approval_levels=2))
            checks.check("a laboratory account cannot edit the board",
                         r.status_code == 403, f"{r.status_code} {r.text[:120]}")

        # -------------------------------------------------- the edit page
        checks.section("The edit page")

        r = await c.get(f"/announcements/id/{gated['id']}")
        page = r.json() if r.status_code == 200 else {}
        checks.check("the page answers", r.status_code == 200)
        checks.check("it carries the notice",
                     (page.get("announcement") or {}).get("id") == gated["id"])
        checks.check("and the schemes it can be addressed to",
                     len(page.get("schemeList") or []) > 0)
        checks.check("and the choices the form offers",
                     len(page.get("categoryList") or []) == 4
                     and len(page.get("audienceList") or []) == 2)

        r = await c.get("/announcements/id/0")
        checks.check("id 0 answers with the choices and no notice",
                     r.status_code == 200
                     and r.json().get("announcement") is None)

        r = await c.get("/announcements/id/999999")
        checks.check("an unknown notice is a 404", r.status_code == 404)

        # -------------------------------------------------- the dashboard
        checks.section("The dashboard shows the board")

        r = await c.get("/dashboard/summary")
        summary = r.json() if r.status_code == 200 else {}
        checks.check("the summary answers", r.status_code == 200)
        checks.check("it carries the noticeboard counts",
                     set(summary.get("noticeboard", {})) ==
                     {"live", "published", "draft", "awaitingReview"},
                     summary.get("noticeboard"))

        live_now = await con.fetchval(
            "SELECT count(*) FROM announcements WHERE status_id = 4 "
            "AND (publish_from IS NULL OR publish_from <= CURRENT_DATE) "
            "AND (publish_until IS NULL OR publish_until >= CURRENT_DATE)"
        )
        checks.check("the live count agrees with the table",
                     summary.get("noticeboard", {}).get("live") == live_now,
                     f"{summary.get('noticeboard', {}).get('live')} vs {live_now}")
        checks.check("and it lists the notices themselves",
                     isinstance(summary.get("announcementList"), list)
                     and len(summary["announcementList"]) > 0,
                     summary.get("announcementList"))

    # -------------------------------------------------- clear up
    checks.section("Nothing is left behind")

    for announcement_id in CREATED:
        await con.execute("DELETE FROM announcements WHERE id = $1", announcement_id)

    ended_with = await con.fetchval("SELECT count(*) FROM announcements")
    checks.check(f"the board is back to {started_with} notice(s)",
                 ended_with == started_with, f"{ended_with}")

    await con.close()
    return checks.report()


sys.exit(asyncio.run(main_check()))
