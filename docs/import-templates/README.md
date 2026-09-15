# CSV import templates

Templates for migrating existing data into the system. There is one template
per form, and each comes in two files:

| File | What it is |
| --- | --- |
| `<form>-import.csv` | The header row on its own. Start here for a real migration. |
| `<form>-import-sample.csv` | The same header with three worked rows, showing what a good row looks like. |

The files are generated from the column specifications in
[`helpers/import_csv.py`](../../helpers/import_csv.py) — the same thing the
importer reads — so they cannot drift from what will actually be accepted.
After changing a form, regenerate them:

```
cd C:\Repo\Python\EQA-MOH-API
set PYTHONPATH=C:\Repo\Python\EQA-MOH-API
venv\Scripts\python.exe scripts\tools\write_import_templates.py
```

## Load them in this order

A result names the laboratory that reported it, and that laboratory has to
already be in the system for the row to match. So:

1. `laboratory-import.csv`
2. `tb_xpert_ultra-import.csv`
3. `tb_xpert_xdr-import.csv`
4. `hiv_vl-import.csv`
5. `hiv_eid-import.csv`

The four result files are independent of each other and can be loaded in any
order among themselves.

## In the app

**Administration → Data Migration** (`/admin/imports/data-migration`, provider
staff only) does all of this without a terminal: pick the form, download either
template, choose the completed file, **Check File**, then **Import File**. The
Import button stays locked until a check comes back clean for the file
currently chosen, and every fault is listed against the row it came from. The
page also shows the column guide for whichever form is selected.

The endpoints below are what that page calls, and are equally usable directly.

## Endpoints

| Method | Path | What it does |
| --- | --- | --- |
| `GET` | `/imports/forms` | The forms that can be imported, in load order |
| `GET` | `/imports/{form}/columns` | What every column means, for an in-app guide |
| `GET` | `/imports/{form}/template` | Downloads the CSV template (`?with_samples=false` for the blank one) |
| `POST` | `/imports/{form}` | Uploads a completed template |

`{form}` is one of `laboratory`, `tb_xpert_ultra`, `tb_xpert_xdr`, `hiv_vl`,
`hiv_eid`.

The upload takes the file as multipart `file`, plus two query parameters:

- `imported_by` — the email of the user running the migration. It must be an
  existing account; it becomes `created_by` on everything the file writes.
- `dry_run` — **defaults to `true`**. A dry run checks the whole file and
  reports exactly what would happen, without writing anything. Run every file
  this way first.

```
curl -F "file=@hiv_vl-import.csv" \
  "http://127.0.0.1:8000/imports/hiv_vl?imported_by=admin@cdl.moh.gov.zm&dry_run=true"
```

## A file is all or nothing

Every row is checked and every fault is reported, but **a file with one bad row
writes nothing at all**. A half-loaded round is worse than a rejected one,
because afterwards nobody can tell by looking which half landed. Fix the rows
the report lists and run the file again.

The response says what happened:

```json
{
  "succeeded": false,
  "rows": 120,
  "created": 0,
  "updated": 0,
  "failed": 2,
  "errors": [
    {"row": 14, "column": "lab_code",
     "message": "No laboratory with the code 'REG0244'. Import the laboratories first"},
    {"row": 87, "column": null,
     "message": "The cycle threshold (Ct) values must be provided for an interpretable result. Missing: rpoB3, rpoB4"}
  ],
  "message": "2 of 120 row(s) could not be imported, so nothing was written. Fix the rows listed and run the file again."
}
```

`row` is the line number in the CSV, counting the header as row 1, so it maps
straight onto what the spreadsheet shows.

## How a laboratory is matched

**On `code`** — `laboratorys.code` is unique, it is what the lab is called in
every listing and report, and it is what the result files carry.

- In `laboratory-import.csv`, `code` is the match key. Supply the legacy
  identifier so the result files can reference it. Leave it blank and the
  server issues the next `REG####`, exactly as registration does.
- In the four result files, give `lab_code`. If the migration source only has
  an email address, give `lab_email` instead — `laboratorys.email_address` is
  also unique, so either identifies a lab on its own. Give both and they must
  agree; a row that names two different laboratories is refused rather than
  guessed at.

The laboratory **name is deliberately not accepted as a match**. It has no
unique constraint, and the same hospital is spelled three ways across two
registers.

Re-running a file updates the rows it matches rather than duplicating them, so
a corrected file can simply be run again.

## Laboratories and their logins

An imported laboratory arrives as a registration awaiting review
(`status = Pending`), with one application per method listed in its `methods`
column, and **no login**. It gets its super-user account the way every other
lab does, when the registration is approved through
`PUT /laboratorys/review-update/{id}`.

Set `status = Approved` in the file only if the laboratory and its method
applications should be treated as already accepted. Note that an approved
registration can no longer be run through the review endpoint, so such a lab
will need its user account created directly.

Re-importing a laboratory adds any methods that are new to the file, but never
removes an application that has dropped off it — an application may already
have enrolments and results hanging from it. Withdraw a method through the
application endpoints, not by editing the CSV.

## How a result is matched

On the PT cycle, the laboratory and the sample together — which is the unique
constraint the result tables already carry. The columns that locate a result
are the same on all four forms:

| Column | Resolves to |
| --- | --- |
| `scheme` | `schemes.name` |
| `service` | `services.name`, within that scheme |
| `method` | `methods.name`, within that service. Its `result_form` must be the form being imported |
| `sample` | `method_samples.name`, within that method |
| `pt_cycle_code` | `pt_cycles.code`, within that scheme |
| `lab_code` / `lab_email` | `laboratorys.code` / `laboratorys.email_address` |
| `captured_by` | `users.email`. Optional — defaults to the user running the import |
| `status` | Draft, Submitted, Under Review, Approved or Rejected. Defaults to Approved |

Dates are read as `2026-03-14`, `14/03/2026`, `14-03-2026` or `14 Mar 2026`.
Blank means "not recorded".

### Enrolments are opened as needed

A result hangs off an enrolment, and a migration will rarely carry enrolments
separately. When the lab has no enrolment for that method in that cycle, one is
opened — as settled, because the round is history: approved, with the panel
recorded as received on the row's panel-received or tested date. The response
reports how many were opened.

### Historical rounds load whatever their status

Capturing a result in the browser is only allowed while the cycle is at
"Samples Shipped". The importer does not apply that gate — a migration is for
closed rounds by definition, and every round worth migrating is past it.

### What is still checked

Everything else. Each row is validated by the form's own model — the same rules
a result captured in the browser goes through — so the allowed values, the
ranges and the consistency rules all apply.

One deliberate difference: those models only enforce completeness at
*Submitted*, so a row imported as *Approved* would otherwise sail past the
checks. Anything that is not an explicit `Draft` is therefore validated as if
it were being submitted, and then written at the status the file asked for.
That is what makes a migrated round trustworthy rather than merely loaded. If a
historical row genuinely is incomplete, import it as `Draft`.

## The forms

| Form | Source | Result columns |
| --- | --- | --- |
| `laboratory` | MF006 PT Application Form | 13 |
| `tb_xpert_ultra` | CDL-PT-F-008 Xpert PT Results form | 23 |
| `tb_xpert_xdr` | CDL-PT-F-027 Xpert MTB/XDR Result Form | 28 |
| `hiv_vl` | TF-009 HIV-1 Viral Load Result Report Form | 22 |
| `hiv_eid` | TF-012 HIV-1 Early Infant Diagnosis Result Report Form | 22 |

`GET /imports/{form}/columns` returns the type, whether it is required, and the
notes for every column — that is the authoritative column reference.

## Checking the importer

```
venv\Scripts\python.exe scripts\checks\check_imports.py
```

Runs the templates against the development data as dry runs, checks that each
sample row would pass its form's real rules, checks that bad rows are refused
with a message that says why, and reads the table counts back afterwards to
prove nothing landed.
