"""Shared setup for the check scripts.

Importing this puts the API on the import path, so the checks can be run
directly from anywhere without setting PYTHONPATH:

    venv\\Scripts\\python.exe scripts\\checks\\check_integrity.py

It also reads the database URL from database.py rather than repeating it, so
there is one place to change when the connection details move.
"""
import os
import sys

# the API lives two directories up from scripts/checks
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))))

if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

import database  # noqa: E402  (needs the path set first)

# SQLAlchemy speaks postgresql+asyncpg; asyncpg itself wants plain postgresql
DEV_URL = database.DATABASE_URL
DEV_DSN = DEV_URL.replace("postgresql+asyncpg://", "postgresql://")

# the workflow check builds and drops its own database so it never touches
# the development data
TEST_DB_NAME = "moheqa_check_workflow"
TEST_URL = DEV_URL.rsplit("/", 1)[0] + "/" + TEST_DB_NAME
TEST_DSN = DEV_DSN.rsplit("/", 1)[0] + "/" + TEST_DB_NAME
ADMIN_DSN = DEV_DSN.rsplit("/", 1)[0] + "/postgres"


class Checks:
    """Collects pass/fail results and prints them as they happen."""

    def __init__(self, title):
        self.title = title
        self.passed = []
        self.failed = []
        print(f"\n{title}\n{'=' * len(title)}")

    def section(self, name):
        print(f"\n{name}")

    def check(self, label, condition, detail=""):
        if condition:
            self.passed.append(label)
            print(f"  PASS  {label}")
        else:
            self.failed.append(label)
            suffix = f"   <- {detail}" if detail else ""
            print(f"  FAIL  {label}{suffix}")
        return bool(condition)

    def report(self):
        total = len(self.passed) + len(self.failed)
        print("\n" + "-" * 62)
        print(f"{self.title}: {len(self.passed)} of {total} passed")
        for label in self.failed:
            print("  failed:", label)
        return 1 if self.failed else 0


async def create_test_database():
    """Drops and recreates the throwaway database used by the workflow check."""
    import asyncpg

    con = await asyncpg.connect(ADMIN_DSN)
    await con.execute(f"DROP DATABASE IF EXISTS {TEST_DB_NAME} WITH (FORCE)")
    await con.execute(f"CREATE DATABASE {TEST_DB_NAME}")
    await con.close()


async def drop_test_database():
    import asyncpg

    con = await asyncpg.connect(ADMIN_DSN)
    await con.execute(f"DROP DATABASE IF EXISTS {TEST_DB_NAME} WITH (FORCE)")
    await con.close()


def use_test_database():
    """Points the app at the throwaway database.

    Must be called before `import main`, because the routes bind to the
    session factory at import time.
    """
    from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
    from sqlalchemy.orm import sessionmaker

    database.engine = create_async_engine(TEST_URL, echo=False)
    database.AsyncSessionLocal = sessionmaker(
        bind=database.engine, class_=AsyncSession, expire_on_commit=False
    )
