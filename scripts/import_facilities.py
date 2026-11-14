"""Import Zambia's Master Facility List into the facilities table.

Reads the MoH MFL export (an .xlsx) and loads every facility, resolving the
province/district names against the seeded reference tables where they match so
a lab registered off a facility can inherit the right province_id / district_id.

Usage (from the project root, with the venv active):

    python -I scripts/import_facilities.py
    python -I scripts/import_facilities.py "G:/My Drive/EQA System/mfl_facilities_export20260915112447.xlsx"

Idempotent: it truncates facilities and reloads, so re-running simply refreshes
the list. users.facility_id is ON DELETE restrict-free here only because the
wipe clears facility users first; run the wipe (or this) before users point at
facilities.
"""
import asyncio
import re
import sys
from pathlib import Path

import openpyxl
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession

DEFAULT_XLSX = r"G:/My Drive/EQA System/mfl_facilities_export20260915112447.xlsx"
DATABASE_URL = "postgresql+asyncpg://postgres:Abc123@localhost:5432/moheqa"

# column order in the MFL export (see migration 012)
COLS = [
    "mfl_code", "dhis2_uid", "hims_code", "name", "province_name",
    "district_name", "constituency", "ward", "zone", "location", "type",
    "ownership", "ownership_type", "operational_status", "mobility_status",
    "accessibility", "catchment_head", "catchment_cso", "households",
    "latitude", "longitude",
]


def _clean(value):
    if value is None:
        return None
    if isinstance(value, str):
        value = value.strip()
        return value or None
    return value


def _to_float(value):
    """Latitude/longitude cells are sometimes text in the export."""
    if value in (None, ""):
        return None
    try:
        return float(str(value).strip())
    except (TypeError, ValueError):
        return None


def _to_int(value):
    if value in (None, ""):
        return None
    try:
        return int(float(str(value).strip()))
    except (TypeError, ValueError):
        return None


def _norm(name) -> str:
    """Normalise a district/province name for matching: lower-case and strip
    everything but letters and digits, so 'Itezhi-Tezhi', 'Itezhi Tezhi' and
    'itezhitezhi' all compare equal."""
    return re.sub(r"[^a-z0-9]", "", (name or "").lower())


def read_rows(path: str):
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    ws = wb.active
    rows = ws.iter_rows(min_row=2, values_only=True)
    for raw in rows:
        record = {col: _clean(raw[i]) if i < len(raw) else None
                  for i, col in enumerate(COLS)}
        if not record.get("name"):
            continue
        yield record
    wb.close()


async def main(path: str):
    if not Path(path).exists():
        print(f"!! facility export not found: {path}")
        sys.exit(1)

    engine = create_async_engine(DATABASE_URL, echo=False)
    Session = sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)

    async with Session() as db:  # type: AsyncSession
        # reference lookups, normalised so punctuation/spacing differences in
        # the MFL names still match the seeded reference rows
        prov_rows = (await db.execute(text("SELECT id, name FROM provinces"))).all()
        province_by_name = {_norm(n): pid for pid, n in prov_rows}

        dist_rows = (await db.execute(
            text("SELECT id, province_id, name FROM districts"))).all()
        district_by_key = {(pid, _norm(n)): did for did, pid, n in dist_rows}

        records = list(read_rows(path))
        print(f"read {len(records)} facilities from {path}")

        # the seeded districts list predates some newer districts that appear in
        # the MFL (Chongwe, Itezhi-Tezhi, Chibombo, ...). Add any that are
        # missing so every facility resolves to a district and the rest of the
        # system - which keys off district_id - sees them too. Marked so they
        # can be told from the hand-seeded rows.
        missing = {}
        for r in records:
            pid = province_by_name.get(_norm(r.get("province_name")))
            dname = r.get("district_name")
            if not pid or not dname:
                continue
            key = (pid, _norm(dname))
            if key not in district_by_key and key not in missing:
                missing[key] = (pid, dname.strip())

        if missing:
            insert_district = text("""
                INSERT INTO districts (name, province_id, user_id, status_id,
                                       stage_id, approval_levels, created_by)
                VALUES (:name, :province_id, 1, :status_id, :stage_id, 1, 'mfl-import')
                RETURNING id
            """)
            for (pid, norm_name), (province_id, raw_name) in missing.items():
                row = await db.execute(insert_district, {
                    "name": raw_name,
                    "province_id": province_id,
                    "status_id": 4,   # approved
                    "stage_id": 5,    # approved
                })
                district_by_key[(pid, norm_name)] = row.scalar()
            print(f"added {len(missing)} districts missing from the reference list")

        unresolved_prov = set()
        unresolved_dist = set()
        payload = []
        for r in records:
            province_id = province_by_name.get(_norm(r.get("province_name")))
            if r.get("province_name") and province_id is None:
                unresolved_prov.add(r["province_name"])

            district_id = (
                district_by_key.get((province_id, _norm(r.get("district_name"))))
                if province_id else None
            )
            if r.get("district_name") and district_id is None:
                unresolved_dist.add((r.get("province_name"), r.get("district_name")))

            payload.append({
                "mfl_code": _to_int(r.get("mfl_code")),
                "dhis2_uid": r.get("dhis2_uid"),
                "hims_code": str(r["hims_code"]) if r.get("hims_code") is not None else None,
                "name": r["name"],
                "province_name": r.get("province_name"),
                "district_name": r.get("district_name"),
                "province_id": province_id,
                "district_id": district_id,
                "constituency": r.get("constituency"),
                "ward": r.get("ward"),
                "zone": r.get("zone"),
                "location": r.get("location"),
                "type": r.get("type"),
                "ownership": r.get("ownership"),
                "ownership_type": r.get("ownership_type"),
                "operational_status": r.get("operational_status"),
                "latitude": _to_float(r.get("latitude")),
                "longitude": _to_float(r.get("longitude")),
            })

        # DELETE, not TRUNCATE CASCADE: facilities is referenced by users and
        # laboratorys, and a CASCADE truncate would chase those FKs on into the
        # users table and, through provinces.user_id / districts.user_id, wipe
        # the whole reference catalogue. DELETE only clears facilities and fails
        # safely if any user/lab still points at one (run the reset first).
        await db.execute(text("DELETE FROM facilities"))
        await db.execute(text("ALTER SEQUENCE facilities_id_seq RESTART WITH 1"))

        # Columns are CAST explicitly so asyncpg knows each parameter's type
        # regardless of NULLs - a plain executemany infers types from the first
        # row and misbinds later rows that differ, which shifted values into the
        # wrong columns and tripped the province/district foreign keys.
        insert = text("""
            INSERT INTO facilities (
                mfl_code, dhis2_uid, hims_code, name, province_name, district_name,
                province_id, district_id, constituency, ward, zone, location,
                type, ownership, ownership_type, operational_status, latitude, longitude)
            VALUES (
                CAST(:mfl_code AS integer), :dhis2_uid, :hims_code, :name,
                :province_name, :district_name,
                CAST(:province_id AS integer), CAST(:district_id AS integer),
                :constituency, :ward, :zone, :location,
                :type, :ownership, :ownership_type, :operational_status,
                CAST(:latitude AS double precision), CAST(:longitude AS double precision))
        """)
        for row in payload:
            await db.execute(insert, row)
        await db.commit()

        total = (await db.execute(text("SELECT count(*) FROM facilities"))).scalar()
        matched_p = (await db.execute(
            text("SELECT count(*) FROM facilities WHERE province_id IS NOT NULL"))).scalar()
        matched_d = (await db.execute(
            text("SELECT count(*) FROM facilities WHERE district_id IS NOT NULL"))).scalar()

    await engine.dispose()

    print(f"loaded {total} facilities")
    print(f"  province_id resolved: {matched_p}/{total}")
    print(f"  district_id resolved: {matched_d}/{total}")
    if unresolved_prov:
        print(f"  provinces not matched: {sorted(unresolved_prov)}")
    if unresolved_dist:
        print(f"  districts not matched ({len(unresolved_dist)}): "
              f"{sorted(unresolved_dist)[:15]}{' ...' if len(unresolved_dist) > 15 else ''}")


if __name__ == "__main__":
    xlsx = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_XLSX
    asyncio.run(main(xlsx))
