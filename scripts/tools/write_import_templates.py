"""Writes the CSV import templates out to docs/import-templates.

The templates are generated from the column specifications in
`helpers/import_csv.py`, which is the same thing the importer reads. Run this
after changing a form so the files on disk cannot drift from what the importer
will actually accept.

    cd C:\\Repo\\Python\\EQA-MOH-API
    set PYTHONPATH=C:\\Repo\\Python\\EQA-MOH-API
    venv\\Scripts\\python.exe scripts\\tools\\write_import_templates.py
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from helpers import import_csv  # noqa: E402

OUTPUT_DIR = os.path.join(ROOT, "docs", "import-templates")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    written = []

    for key in import_csv.IMPORT_ORDER:
        spec = import_csv.get_spec(key)

        for suffix, with_samples in (("-sample", True), ("", False)):
            name = f"{key}-import{suffix}.csv"
            path = os.path.join(OUTPUT_DIR, name)

            with open(path, "w", encoding="utf-8", newline="") as handle:
                handle.write(import_csv.template_csv(key, with_samples=with_samples))

            written.append((name, len(spec.columns), len(spec.samples) if with_samples else 0))

    print(f"Wrote {len(written)} template(s) to {OUTPUT_DIR}\n")
    for name, columns, rows in written:
        print(f"   {name:44} {columns:>3} columns  {rows} sample row(s)")


if __name__ == "__main__":
    main()
