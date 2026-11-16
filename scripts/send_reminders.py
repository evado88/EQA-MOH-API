"""Send any PT-cycle date reminders that fall due today (standalone one-shot).

Run once a day from a systemd timer (or cron) so reminder emails fire from a
single place. This is the counterpart to disabling the in-app scheduler with
RUN_SCHEDULER=0, which is required when the API runs with several workers
(gunicorn / multiple uvicorn workers) - otherwise the daily job runs once per
worker and participants get duplicate emails.

Idempotent: run_pt_cycle_reminders records each (cycle, date, lead) reminder in
pt_cycle_reminders and never resends it, and it also refreshes each cycle's
cached lifecycle status while it is there. Running twice in a day is safe.

Usage (from the project root, with the root on PYTHONPATH):
    python scripts/send_reminders.py                       # send the reminders
    python scripts/send_reminders.py --dry-run             # preview today, send nothing
    python scripts/send_reminders.py --date 2026-11-17     # preview a future day (implies --dry-run)

--dry-run shows exactly what a real run would send, and to which labs, without
sending any email or recording anything - so running it does not stop the next
real run from sending those same reminders. Use it to check a run before firing
the one-shot service.

--date YYYY-MM-DD evaluates the run as if that were today, to preview what a
future day's 07:00 job will send (a 0 for today does not mean tomorrow is also
empty - reminders are date-driven). It always implies --dry-run and never
sends or records anything.

It uses DATABASE_URL and the mail settings from the environment (.env) - the
same configuration as the running API, so it talks to the real database and
(unless --dry-run) sends through the real mailer.
"""
import asyncio
import os
import sys

# make the project root importable when run directly as
# `python scripts/send_reminders.py` (Python would otherwise only put the
# scripts/ directory on the path). The systemd unit also sets PYTHONPATH.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# database reads DATABASE_URL from the environment (.env in the working
# directory), exactly like the API process
from database import AsyncSessionLocal  # noqa: E402

# importing the app registers every route and therefore every ORM model, so the
# SQLAlchemy mapper registry is complete before the first query. Without this a
# relationship resolved by name at configure time (e.g. StageDB -> AnnouncementDB)
# fails with "failed to locate a name". The app is not started - only imported.
import main  # noqa: E402,F401

from routes.ptcycle_routes import run_pt_cycle_reminders  # noqa: E402


async def main_(dry_run=False, as_of=None):
    async with AsyncSessionLocal() as db:
        result = await run_pt_cycle_reminders(db, dry_run=dry_run, as_of=as_of)

    when = f" as of {as_of:%d %b %Y}" if as_of else ""
    prefix = "[DRY RUN] would send" if dry_run else "sent"
    print(
        f"pt-cycle reminders{when}: {prefix} {result.reminders_sent} reminder(s) "
        f"across {result.cycles_checked} approved cycle(s)"
    )
    for line in result.details:
        print("  -", line)
    if dry_run and result.reminders_sent:
        print("\nNothing was sent or recorded. Run without --dry-run to send.")
    return 0 if result.succeeded else 1


def _parse_args(argv):
    """--dry-run / -n for a preview; --date YYYY-MM-DD to preview a future day
    (implies dry-run)."""
    from datetime import date

    dry = any(a in ("--dry-run", "--dry", "-n") for a in argv)
    as_of = None
    for i, a in enumerate(argv):
        value = None
        if a.startswith("--date="):
            value = a.split("=", 1)[1]
        elif a == "--date" and i + 1 < len(argv):
            value = argv[i + 1]
        if value:
            try:
                as_of = date.fromisoformat(value)
            except ValueError:
                sys.exit(f"invalid --date {value!r}; expected YYYY-MM-DD")
            dry = True  # previewing another day never sends
    return dry, as_of


if __name__ == "__main__":
    _dry, _as_of = _parse_args(sys.argv[1:])
    sys.exit(asyncio.run(main_(dry_run=_dry, as_of=_as_of)))
