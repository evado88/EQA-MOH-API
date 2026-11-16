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
    python scripts/send_reminders.py              # send the reminders
    python scripts/send_reminders.py --dry-run    # preview only, send nothing

--dry-run shows exactly what a real run would send, and to which labs, without
sending any email or recording anything - so running it does not stop the next
real run from sending those same reminders. Use it to check a run before firing
the one-shot service.

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
from routes.ptcycle_routes import run_pt_cycle_reminders  # noqa: E402


async def main_(dry_run=False):
    async with AsyncSessionLocal() as db:
        result = await run_pt_cycle_reminders(db, dry_run=dry_run)

    prefix = "[DRY RUN] would send" if dry_run else "sent"
    print(
        f"pt-cycle reminders: {prefix} {result.reminders_sent} reminder(s) across "
        f"{result.cycles_checked} approved cycle(s)"
    )
    for line in result.details:
        print("  -", line)
    if dry_run and result.reminders_sent:
        print("\nNothing was sent or recorded. Run without --dry-run to send.")
    return 0 if result.succeeded else 1


if __name__ == "__main__":
    _dry = any(a in ("--dry-run", "--dry", "-n") for a in sys.argv[1:])
    sys.exit(asyncio.run(main_(dry_run=_dry)))
