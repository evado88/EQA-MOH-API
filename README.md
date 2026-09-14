# Trails Data Calibration Backend - FastAPI Project

A lightweight and high-performance API built with FastAPI. This project
includes a simple structure for rapid development, local testing, and
production-readiness.

## Project Structure (Example)

    project/
        models/
        routes/
        .gitignore
        database.py
        main.py
        requirements.txt
        README.md

## Prerequisites

-   Python 3.9+
-   pip
-   Git (optional)
-   Virtual environment tool: venv (recommended)

## 1. Create and Activate Virtual Environment

### UNIX (macOS / Linux)

    python3 -m venv venv
    source venv/bin/activate

### Windows (PowerShell)

    python -m venv venv
    .env\Scripts\Activate

## 2. Install Dependencies

After activating your virtual environment:

### UNIX & Windows

    pip install --upgrade pip
    pip install -r requirements.txt

## 3. Running the FastAPI Project

### UNIX

    uvicorn app.main:app --reload

### Windows

    uvicorn app.main:app --reload

API will be available at: http://127.0.0.1:8000

Interactive docs: http://127.0.0.1:8000/docs\
http://127.0.0.1:8000/redoc

## 4. Running Tests (optional)

### UNIX & Windows

    pytest

## 5. Exporting Updated Dependencies

    pip freeze > requirements.txt

## Notes

-   Activate your virtual environment before running commands.
-   Ensure the database settings are specified correctly in database.py and that databse is accessible before running project
-   Use uvicorn for development; consider gunicorn + uvicorn workers or Docker for production.
-   Keep requirements.txt updated for consistent deployments.
