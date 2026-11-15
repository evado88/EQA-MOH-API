# Zambia EQA Platform — API

Backend for the External Quality Assessment (EQA) proficiency-testing platform
operated by the National Health Research and Training Institute (NHRTI) and the
Zambia Ministry of Health. It runs the full proficiency-testing (PT) lifecycle
for laboratory schemes — **TB (Xpert Ultra / XDR), HIV Viral Load, HIV EID, and
Bacteriology** — from laboratory registration through result scoring and reports.

Built with **FastAPI**, **SQLAlchemy (async)** on **PostgreSQL** (asyncpg), and
**Pydantic**. The React/DevExtreme web client lives in a separate repository
(`EQA-MOH-UI`).

---

## What it does

The platform drives each step of a PT round as a real workflow:

1. **Self-registration** — a user signs up against a facility (from the Zambia
   Master Facility List), verifies their email, and sets a password.
2. **Scheme registration** — they register their laboratory for a scheme
   (e.g. Bacteriology), accepting the scheme's terms; an administrator reviews it.
3. **PT rounds** — coordinators schedule rounds on a date calendar; the lifecycle
   status (Upcoming → Enrolment Open → Samples Shipped → Testing → Results Due →
   Report Available) is **derived from those dates**. Shipping and publishing are
   the two manual gates.
4. **Enrolment** — approved labs enrol in an open round for their scheme.
5. **Sample receipt** — each panel sample's receipt (date, condition, temperature)
   is recorded before any results can be entered.
6. **Result entry** — scheme-specific worksheets (microscopy, organism ID, AST,
   Ct values, viral loads, …) with drafts, resubmission until the due date, and
   optional file attachments.
7. **Scoring & reports** — publishing a round scores it and makes participant
   performance reports available.

## Tech stack

- **FastAPI** (ASGI, `uvicorn`) — 37 routers mounted in `main.py`
- **SQLAlchemy 1.4 async** + **asyncpg** on **PostgreSQL**
- **Pydantic** request/response models
- **APScheduler** — daily in-app job for reminder emails / status refresh
- **python-jose** (JWT auth), **passlib** (password hashing)
- SMTP email (`helpers/mailer.py`) and optional WhatsApp (Infobip)

## Project structure

```
EQA-MOH-API/
  main.py              FastAPI app: lifespan, CORS, router mounting, scheduler
  database.py          async engine + session (reads DATABASE_URL from env)
  models/              SQLAlchemy models + Pydantic schemas (one per domain)
  routes/              API routers (auth, registration, pt-cycles, results, …)
  helpers/             env loader, auth, mailer, evaluation/scoring, queries
  migrations/          ordered SQL migrations (views, lookup data, schema changes)
  scripts/             seed_demo.py, import_facilities.py, reset_for_testing.py, checks/
  deploy/              nginx / Caddy / systemd configs + deployment runbook
  uploads/             attachment storage (served at /static)
  .env.example         configuration template
```

Configuration and secrets are read from a `.env` file by `helpers/env.py`
(standard-library loader; real environment variables always win). Nothing
sensitive is hard-coded — see `.env.example`.

---

## Getting started

### Prerequisites

- Python 3.10+
- PostgreSQL 14+
- A virtual environment tool (`venv`)

### 1. Clone and create a virtual environment

```bash
python -m venv venv
# Linux/macOS:
source venv/bin/activate
# Windows (PowerShell):
.\venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Configure

```bash
cp .env.example .env
```

Edit `.env` — at minimum set `DATABASE_URL` and a `SECRET_KEY`:

```
DATABASE_URL=postgresql+asyncpg://postgres:PASSWORD@localhost:5432/moheqa
SECRET_KEY=<python -c "import secrets; print(secrets.token_urlsafe(48))">
```

Email and WhatsApp are optional: with `MAIL_PASSWORD` unset, email sending is
skipped and verification links are printed to the console (dev-friendly).
See [Configuration](#configuration) for the full list.

### 4. Database

Create the database, then apply the ordered SQL migrations (they add the
`vw_pt_*` reporting views, reference/lookup data, and schema changes):

```bash
createdb moheqa      # or: CREATE DATABASE moheqa;
# apply migrations in numeric order, e.g.:
for f in $(ls migrations/*.sql | sort); do psql -d moheqa -f "$f"; done
```

The ORM-declared tables are also created automatically on first startup
(`Base.metadata.create_all`).

### 5. Run

```bash
uvicorn main:app --reload --port 8800
```

- API: http://127.0.0.1:8800
- Interactive docs: http://127.0.0.1:8800/docs and `/redoc`

Port **8800** matches the web client's default dev configuration.

### 6. Seed demo data (optional)

For a fully populated, coherent demo dataset (labs, rounds in every phase,
results, scoring) — useful for development and demos:

```bash
python scripts/seed_demo.py
```

> ⚠️ `seed_demo.py` **truncates the transactional tables** before reseeding.
> Run it only against a development database.

---

## The web client

The React + TypeScript + DevExtreme front end is a separate repository
(`EQA-MOH-UI`). It builds with Vite and, in development, expects this API at
`http://127.0.0.1:8800`. Its API base URL is configured through `VITE_API_URL`.

---

## Configuration

All settings come from the environment (`.env` in development). Key variables:

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL async connection string |
| `DB_ECHO` | log SQL statements (`true`/`false`) |
| `SECRET_KEY`, `ALGORITHM` | JWT signing |
| `CURRENT_TIME_ZONE` | timezone for schedules/reminders (default `Africa/Lusaka`) |
| `CORS_ORIGINS` | comma-separated allowed browser origins |
| `MAIL_*` | SMTP account and `MAIL_APP_BASE_URL` for verification links |
| `INFOBIP_*` | optional WhatsApp messaging |
| `ENABLE_DEV_TOOLS` | enables the PT-cycle phase-jump testing endpoint (`0` in production) |
| `RUN_SCHEDULER` | run the daily reminder job in this process (set `0` on extra uvicorn workers) |

Full list and defaults: [`.env.example`](.env.example).

## Workflow checks

`scripts/checks/` holds end-to-end workflow checks that drive the API in-process
(via httpx ASGI transport) against a database. `scripts/reset_for_testing.py`
resets transactional data for a clean run.

## Deployment

A complete production runbook (Ubuntu 24, nginx + certbot, systemd) plus ready
nginx / Caddy configs are in [`deploy/`](deploy/). See
[`deploy/README.md`](deploy/README.md).

The PT reports are rendered by a separate ASP.NET **XtraReports** service over
the `vw_pt_*` views; it is deployed separately and is not required to run the API.
