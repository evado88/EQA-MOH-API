# Scripts

## seed_demo.py

Rebuilds the development database with a coherent demo dataset.

```
cd C:\Repo\Python\EQA-MOH-API
set PYTHONPATH=C:\Repo\Python\EQA-MOH-API
venv\Scripts\python.exe scripts\seed_demo.py
```

It clears the transactional tables (laboratories, applications, PT cycles,
enrolments, results) and every laboratory user account, keeps the provider
staff, rebuilds the scheme catalogue, and then drives the whole workflow
through the API - registration, review, cycle status, enrolment, shipping,
sample receipt and result capture. Because every step goes through the real
endpoints, the data it produces is exactly what the running system allows.

The catalogue it builds is three providers: CDL's TB scheme, Virology PT's
viral load and early infant diagnosis schemes, and NHRTI's bacteriology
scheme. It finishes by writing the noticeboard - events, meetings, resources
and general notices, including one still in draft, one scheduled for a future
date, one already expired and one taken through the review gate.

Re-runnable. It does not touch the audit trail.

Everyone it creates signs in with the password `12345678`.

## tools/write_import_templates.py

Regenerates the CSV import templates in `docs/import-templates` from the column
specifications in `helpers/import_csv.py`. Run it after changing a form, so the
files on disk cannot drift from what the importer will accept.

```
cd C:\Repo\Python\EQA-MOH-API
set PYTHONPATH=C:\Repo\Python\EQA-MOH-API
venv\Scripts\python.exe scripts\tools\write_import_templates.py
```

## checks/check_imports.py

Audits the CSV import against the development data, without writing to it.
Every import runs as a dry run and the table counts are read back afterwards to
prove nothing landed.

```
venv\Scripts\python.exe scripts\checks\check_imports.py
```

See `docs/import-templates/README.md` for the templates themselves.

## checks/check_dashboard.py

Audits `/dashboard/summary`, the single call the dashboard page makes: that it
returns every figure the page binds to, that those figures agree with the
tables and views they are drawn from, and that scoping it to a laboratory
really does narrow it.

```
venv\Scripts\python.exe scripts\checks\check_dashboard.py
```

## checks/check_users.py

Audits the endpoints behind the user list, add, edit and view pages: the role
and facility a listing carries, the choices the form is offered, the rule that
a facility role must name a facility, and what an edit leaves alone (a blank
password keeps the existing one).

It opens two accounts of its own and removes them again, asserting the table is
back to the size it started at.

```
venv\Scripts\python.exe scripts\checks\check_users.py
```

## checks/check_laboratories.py

Audits the Laboratory Scheme List: that `vw_laboratory_scheme`
says the same thing as the applications it is derived from, that the plain
Laboratory List stays free of it, that the scheme listing and the laboratory
page agree, and that a lab nobody has accepted yet is not shown as registered.

```
venv\Scripts\python.exe scripts\checks\check_laboratories.py
```

## checks/check_announcements.py

Audits the noticeboard: that only provider staff can post, that a notice
reaches participants only once it is published and only while its publish
window is open, that a scheme notice goes to that scheme's laboratories and no
further, that the configurable review gate really gates, and that the rules on
what a notice must say before it goes out hold.

It writes its own announcements and removes them again, asserting the table is
back to the size it started at.

```
venv\Scripts\python.exe scripts\checks\check_announcements.py
```

## checks/check_result_rounds.py

Audits the round picker on the result listings. A listing no longer shows every
result at once: a round has to be chosen first. This checks what the picker is
offered (only rounds that actually have sheets, newest first, counts that add
up) and that choosing one narrows the listing to it - for the provider's view
of all five forms, and for a laboratory's view of its own.

```
venv\Scripts\python.exe scripts\checks\check_result_rounds.py
```
