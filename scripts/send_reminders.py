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
    python scripts/send_reminders.py

It uses DATABASE_URL and the mail settings from the environment (.env) - the
same configuration as the running API, so it talks to the real database and
sends through the real mailer.
"""
import asyncio
import sys

# imported after nothing special: database reads DATABASE_URL from the
# environment (.env in the working directory), exactly like the API process
from database import AsyncSessionLocal
from routes.ptcycle_routes import run_pt_cycle_reminders


async def main_():
    async with AsyncSessionLocal() as db:
        result = await run_pt_cycle_reminders(db)

    print(
        f"pt-cycle reminders: {result.reminders_sent} sent across "
        f"{result.cycles_checked} approved cycle(s)"
    )
    for line in result.details:
        print("  -", line)
    return 0 if result.succeeded else 1


if __name__ == "__main__":
    sys.exit(asyncio.run(main_()))
