"""CSV import audit.

Checks the templates against the live development data, without writing to it:
every import runs as a dry run, and the counts are read back afterwards to
prove nothing landed.

Run directly:  venv\\Scripts\\python.exe scripts\\checks\\check_imports.py
"""
import _bootstrap  # noqa: F401  puts the API on the import path, must be first
from _bootstrap import Checks, DEV_DSN

import asyncio
import csv
import io
import sys

import asyncpg

import database
import main  # noqa: F401  registers every model, so the mappers resolve
from helpers import assist, import_csv


RESULT_TABLES = {
    "tb_xpert_ultra": "tb_xpert_ultra_results",
    "tb_xpert_xdr": "tb_xpert_xdr_results",
    "hiv_vl": "hiv_vl_results",
    "hiv_eid": "hiv_eid_results",
}


async def _counts(con):
    """What the tables an import can touch hold right now"""
    tables = list(RESULT_TABLES.values()) + ["laboratorys", "enrollments", "applications"]
    return {
        table: await con.fetchval(f"select count(*) from {table}") for table in tables
    }


def _importer_email():
    """An admin who exists in the development data"""
    return "nkoleevans@hotmail.com"


async def main():
    checks = Checks("CSV import audit")

    con = await asyncpg.connect(DEV_DSN)
    before = await _counts(con)

    importer = await con.fetchval(
        "select email from users where email = $1", _importer_email()
    )
    if not importer:
        importer = await con.fetchval(
            "select email from users where role_id = any($1::int[]) order by id limit 1",
            list(assist.ADMIN_ROLES),
        )

    checks.section("Templates")

    for key in import_csv.IMPORT_ORDER:
        spec = import_csv.get_spec(key)
        text = import_csv.template_csv(key)
        rows = list(csv.DictReader(io.StringIO(text)))

        checks.check(
            f"{key}: template has every column the importer reads",
            [c.name for c in spec.columns] == list(rows[0].keys()) if rows else False,
        )
        checks.check(f"{key}: template carries sample rows", len(rows) >= 1)

        blank = import_csv.template_csv(key, with_samples=False)
        checks.check(
            f"{key}: blank template is the header alone",
            blank.strip().count("\n") == 0,
        )

    checks.section("Sample data validates against the form's own rules")

    for key, table in RESULT_TABLES.items():
        spec = import_csv.get_spec(key)
        failures = []

        for number, raw in enumerate(
            csv.DictReader(io.StringIO(import_csv.template_csv(key))), start=2
        ):
            values = {c.name: c.parse(raw.get(c.name)) for c in spec.columns}
            payload = dict(
                name="sample - laboratory", scheme_id=1, lab_id=1, service_id=1,
                enrollment_id=1, pt_cycle_id=1, method_id=1, method_sample_id=1,
                user_id=1, status_id=assist.STATUS_SUBMITTED,
                stage_id=assist.APPROVAL_STAGE_APPROVED, approval_levels=1,
            )
            for column in spec.value_columns:
                payload[column.field] = values.get(column.name)

            try:
                spec.schema(**payload)
            except Exception as error:
                failures.append(f"row {number}: {error}")

        checks.check(
            f"{key}: every sample row would submit for review",
            not failures,
            "; ".join(failures)[:200],
        )

    checks.section("Dry run against the development data")

    async with database.AsyncSessionLocal() as db:
        for key in RESULT_TABLES:
            report = await import_csv.import_csv(
                db, key, import_csv.template_csv(key),
                imported_by=importer, dry_run=True,
            )
            checks.check(
                f"{key}: the sample file imports cleanly",
                report["failed"] == 0,
                "; ".join(
                    f"row {e['row']} {e['column']}: {e['message']}"
                    for e in report["errors"]
                )[:300],
            )
            checks.check(
                f"{key}: a dry run writes nothing", not report["committed"]
            )

    async with database.AsyncSessionLocal() as db:
        report = await import_csv.import_csv(
            db, import_csv.LAB_IMPORT,
            import_csv.template_csv(import_csv.LAB_IMPORT),
            imported_by=importer, dry_run=True,
        )
        checks.check(
            "laboratory: the sample file imports cleanly",
            report["failed"] == 0,
            "; ".join(
                f"row {e['row']} {e['column']}: {e['message']}"
                for e in report["errors"]
            )[:300],
        )
        checks.check(
            "laboratory: the three sample labs are new",
            report["created"] == 3,
            f"created {report['created']}",
        )

    checks.section("A bad file is refused, and says why")

    spec = import_csv.get_spec("tb_xpert_ultra")
    header = ",".join(spec.headers)

    async def run_one(label, row, expect):
        async with database.AsyncSessionLocal() as db:
            report = await import_csv.import_csv(
                db, "tb_xpert_ultra", header + "\n" + row,
                imported_by=importer, dry_run=True,
            )
            said = " ".join(e["message"] for e in report["errors"])
            checks.check(
                label,
                report["failed"] == 1 and expect.lower() in said.lower(),
                said[:200] or "no error was raised",
            )

    good = {name: "" for name in spec.headers}
    good.update({
        "scheme": "Tuberculosis (TB)", "service": "TB Xpert", "method": "Ultra",
        "sample": "ultra-CDL-2026-A-1", "pt_cycle_code": "2026-A",
        "lab_code": "REG0001", "status": "Approved",
        "date_tested": "2026-03-04", "result_interpretable": "Yes",
        "tb_detection_result": "MEDIUM", "rif_result": "NOT DETECTED",
        "ultra_spc": "24.6", "is1081_is6110": "18.2", "rpob1": "19.4",
        "rpob2": "19.8", "rpob3": "20.1", "rpob4": "20.4",
        "xpert_module_number": "A1-0431",
    })

    def line(**changes):
        row = dict(good, **changes)
        buffer = io.StringIO()
        csv.DictWriter(buffer, fieldnames=spec.headers, lineterminator="").writerow(row)
        return buffer.getvalue()

    await run_one(
        "a laboratory that is not in the system is refused",
        line(lab_code="REG9999"), "No laboratory with the code",
    )
    await run_one(
        "a row naming two different laboratories is refused",
        line(lab_code="REG0001", lab_email="naomi.sakala@livingstone.health.zm"),
        "two different laboratories",
    )
    await run_one(
        "a method captured on another form is refused",
        line(method="XDR", sample="xdr-CDL-2026-A-1"), "cannot be imported",
    )
    await run_one(
        "a sample that belongs to another method is refused",
        line(sample="xdr-CDL-2026-A-1"), "No method sample",
    )
    await run_one(
        "an unknown PT cycle is refused",
        line(pt_cycle_code="1999-Z"), "No PT cycle",
    )
    await run_one(
        "an incomplete approved result is refused",
        line(ultra_spc="", rpob1=""), "cycle threshold",
    )
    await run_one(
        "a value the form does not offer is refused",
        line(tb_detection_result="MASSIVE"), "must be one of",
    )
    await run_one(
        "a Ct value that is not a number is refused",
        line(rpob2="twenty"), "must be a number",
    )
    await run_one(
        "an unreadable date is refused",
        line(date_tested="14th of March"), "must be a date",
    )
    await run_one(
        "an unknown capturing user is refused",
        line(captured_by="nobody@example.com"), "No user account",
    )

    async with database.AsyncSessionLocal() as db:
        report = await import_csv.import_csv(
            db, "tb_xpert_ultra",
            header + "\n" + line() + "\n" + line(lab_code="REG9999"),
            imported_by=importer, dry_run=False,
        )
        checks.check(
            "one bad row stops the whole file being written",
            report["failed"] == 1 and not report["committed"],
        )

    async with database.AsyncSessionLocal() as db:
        report = await import_csv.import_csv(
            db, "tb_xpert_ultra", header, imported_by=importer, dry_run=True,
        )
        checks.check("a file with no rows is accepted, and does nothing",
                     report["rows"] == 0 and report["failed"] == 0)

    async with database.AsyncSessionLocal() as db:
        try:
            await import_csv.import_csv(
                db, "tb_xpert_ultra", "scheme,service\nx,y",
                imported_by=importer, dry_run=True,
            )
            checks.check("a file missing columns is refused", False, "it was accepted")
        except import_csv.RowError as error:
            checks.check(
                "a file missing columns is refused",
                "missing the column" in error.message,
            )

    checks.section("Nothing was written")

    after = await _counts(con)
    for table, count in before.items():
        checks.check(
            f"{table}: unchanged at {count}", after[table] == count,
            f"now {after[table]}",
        )

    await con.close()
    # hand the pool back before the loop closes, or it complains on the way out
    await database.engine.dispose()

    return checks.report()


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
