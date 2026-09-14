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

Re-runnable. It does not touch the audit trail.

Everyone it creates signs in with the password `12345678`.
