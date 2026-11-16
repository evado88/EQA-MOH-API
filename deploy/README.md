# Deployment — Ubuntu 24 (nginx + certbot)

Public deployment of the EQA platform: **FastAPI + PostgreSQL + static React build**,
behind **nginx** with **certbot/Let's Encrypt** TLS. (XtraReports/.NET is deferred and
not part of this deploy.) A Caddy alternative is in [`Caddyfile`](Caddyfile) to try later.

**Public URL:** `https://eqa.ims-zm.online/`
**Single domain:** the SPA is served at `/` and the API is proxied under `/api/` on the
same host — one certificate, one DNS record, and no CORS (same origin).

Before you start: add a DNS **A record** for `eqa.ims-zm.online` → the server's public IP.
Certbot needs it resolving. (The domain currently serves a placeholder app for testing;
point it here when the build is ready.)

---

## 1. Server packages

```bash
sudo apt update
sudo apt install -y python3-venv python3-pip postgresql nginx git \
                    certbot python3-certbot-nginx
# Node is only needed if you build the frontend ON the server (step 4);
# otherwise build locally and upload dist/.
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## 2. PostgreSQL database

```bash
sudo -u postgres psql <<'SQL'
CREATE USER eqa WITH PASSWORD 'CHANGE-ME';
CREATE DATABASE moheqa OWNER eqa;
SQL
```

## 3. Backend

```bash
sudo mkdir -p /opt/eqa && sudo chown $USER /opt/eqa
cd /opt/eqa
git clone <your-repo-url> EQA-MOH-API
cd EQA-MOH-API
python3 -m venv venv
./venv/bin/pip install -r requirements.txt
cp .env.example .env         # then edit .env — see below
```

Edit `.env` (loaded automatically from the working directory):

```
DATABASE_URL=postgresql+asyncpg://eqa:CHANGE-ME@localhost:5432/moheqa
DB_ECHO=false
SECRET_KEY=<python -c "import secrets; print(secrets.token_urlsafe(48))">
CORS_ORIGINS=https://eqa.ims-zm.online
MAIL_USERNAME=...            # rotated Gmail account
MAIL_PASSWORD=...            # rotated Gmail app password
MAIL_APP_BASE_URL=https://eqa.ims-zm.online
INFOBIP_API_TOKEN=...        # rotated, or leave blank
ENABLE_DEV_TOOLS=1           # 1 for the validation workshop; 0 for real production
# RUN_SCHEDULER defaults to 1; only change it if you run multiple uvicorn workers
```

Tables are created automatically on first start (no migration step). Optionally load
the demo dataset for the workshop:

```bash
./venv/bin/python scripts/seed_demo.py            # rebuild the full demo dataset
```

`seed_demo.py` always targets the local dev database (never production). Re-running it
is safe and idempotent: it truncates the transactional tables (labs, enrolments, PT
cycles, all result tables, applications, announcements) and rebuilds the catalogue,
provider staff and the whole workflow. Two modes:

```bash
./venv/bin/python scripts/seed_demo.py            # reset → full demo dataset
./venv/bin/python scripts/seed_demo.py --clear    # wipe demo data only, no reseeding
```

`--clear` (alias `--clear-only`) leaves an empty transactional layer on top of the
catalogue and provider staff — a clean slate for manual end-to-end testing.

Create the Linux user and install the service:

```bash
sudo useradd --system --home /opt/eqa/EQA-MOH-API --shell /usr/sbin/nologin eqa || true
sudo chown -R eqa:eqa /opt/eqa/EQA-MOH-API
sudo cp deploy/eqa-api.service /etc/systemd/system/eqa-api.service
sudo systemctl daemon-reload
sudo systemctl enable --now eqa-api
systemctl status eqa-api        # should be active (running)
```

## 4. Frontend build

In the **EQA-MOH-UI** repo, create `.env.production.local` (git-ignored):

```
VITE_API_URL=https://eqa.ims-zm.online/api/
VITE_REPORT_URL=https://eqa.ims-zm.online/api/
VITE_ENABLE_DEV_TOOLS=true        # shows the phase-jump card for the workshop; false otherwise
```

Build (locally or on the server) and publish the static files:

```bash
npm ci
npm run build                     # outputs dist/
sudo mkdir -p /var/www/eqa
sudo rsync -a --delete dist/ /var/www/eqa/dist/
```

## 5. nginx + HTTPS

```bash
sudo cp deploy/nginx/eqa.conf /etc/nginx/sites-available/eqa
sudo ln -s /etc/nginx/sites-available/eqa /etc/nginx/sites-enabled/eqa
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# issue the certificate and auto-configure HTTPS + redirect:
sudo certbot --nginx -d eqa.ims-zm.online
```

Certbot installs a renewal timer automatically. Verify: `sudo certbot renew --dry-run`.

## 6. Verify

- `https://eqa.ims-zm.online` loads the app (replacing the placeholder).
- Sign-in works; requests go to `https://eqa.ims-zm.online/api/...` (same origin, no CORS).
- Email verification links point at `https://eqa.ims-zm.online/set-password?...`.

---

## Updating later

```bash
cd /opt/eqa/EQA-MOH-API && git pull && ./venv/bin/pip install -r requirements.txt
sudo systemctl restart eqa-api
# frontend: rebuild and rsync dist/ again
```

## Going to production (after the workshop)

- Set `ENABLE_DEV_TOOLS=0` (backend) and rebuild the frontend with
  `VITE_ENABLE_DEV_TOOLS=false` to remove the phase-jump tooling.
- Rotate `SECRET_KEY`, the Gmail app password and the Infobip token.
- Add database backups (e.g. a nightly `pg_dump` cron) and off-site copies.
- To scale the API to multiple workers, set `--workers N` in the service AND
  `RUN_SCHEDULER=0`, then run one extra single process with `RUN_SCHEDULER=1`
  so reminder emails fire once.
