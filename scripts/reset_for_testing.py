"""Clear entered/transactional data so the platform can be tested fresh.

Keeps the reference catalogue (provinces, districts, lab types, providers,
schemes, services, methods, roles/statuses/stages) and the provider/admin staff
accounts, so administrators can still sign in and review. Clears everything a
participant has entered: laboratories, applications, enrolments, results,
cycles, announcements, and the facility-role user accounts.

Facilities (the MFL) are reference data and are NOT touched here - load them
with scripts/import_facilities.py.

Usage (project root, venv active):
    python scripts/reset_for_testing.py
"""
import asyncio
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from helpers import assist

DATABASE_URL = "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"

# transactional tables, cleared in full (CASCADE handles dependents)
TRUNCATE_TABLES = [
    "pt_result_evaluations",
    "pt_enrollment_performance",
    "pt_sample_statistics",
    "tb_xpert_ultra_results",
    "tb_xpert_xdr_results",
    "hiv_vl_results",
    "hiv_eid_results",
    "bacteriology_ast_results",
    "bacteriology_results",
    "announcements",
    "enrollments",
    "applications",
    "pt_cycles",
    "laboratorys",
]


async def main():
    engine = create_async_engine(DATABASE_URL, echo=False)
    Session = sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)

    async with Session() as db:  # type: AsyncSession
        before = (await db.execute(text("SELECT count(*) FROM users"))).scalar()

        for table in TRUNCATE_TABLES:
            # skip tables that may not exist in a given environment
            exists = (await db.execute(
                text("SELECT to_regclass(:t)"), {"t": table})).scalar()
            if exists is None:
                print(f"  (skipped missing table {table})")
                continue
            await db.execute(text(f"TRUNCATE {table} RESTART IDENTITY CASCADE"))

        # facility accounts go with their labs; provider/admin staff are kept
        await db.execute(
            text("DELETE FROM users WHERE role_id = ANY(:roles)"),
            {"roles": list(assist.LABORATORY_ROLES)},
        )
        await db.commit()

        after = (await db.execute(text("SELECT count(*) FROM users"))).scalar()
        kept = (await db.execute(text(
            "SELECT email FROM users ORDER BY id"))).scalars().all()

    await engine.dispose()

    print("Entered data cleared (catalogue, facilities and provider/admin staff kept).")
    print(f"  users: {before} -> {after}")
    print(f"  remaining accounts: {kept}")


if __name__ == "__main__":
    asyncio.run(main())
