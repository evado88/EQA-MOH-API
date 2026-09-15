"""Prints the row count of every table in the database."""
import os
import sys

sys.path.insert(0, os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "checks"))
from _bootstrap import DEV_DSN  # noqa: E402

import asyncio, asyncpg

TABLES = ["list_statuses","list_stages","roles","lab_types","provinces","districts",
          "users","providers","schemes","services","methods","method_samples",
          "pt_cycle_statuses","pt_cycles","laboratorys","applications","enrollments",
          "tb_xpert_ultra_results","audits","attachments"]

async def go():
    con = await asyncpg.connect(DEV_DSN)
    existing = {r["tablename"] for r in await con.fetch(
        "select tablename from pg_tables where schemaname='public'")}
    print("tables present:", len(existing))
    missing = [t for t in TABLES if t not in existing]
    print("missing from schema:", missing or "none")
    print()
    for t in TABLES:
        if t not in existing:
            continue
        n = await con.fetchval(f"select count(*) from {t}")
        print(f"  {t:26} {n}")
    extra = sorted(existing - set(TABLES))
    if extra:
        print("\nother tables:", extra)
    await con.close()
asyncio.run(go())
