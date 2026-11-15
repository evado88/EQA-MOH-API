"""Tiny, dependency-free environment loader.

Importing this module reads a `.env` file from the project root (if present)
into the process environment, then exposes small typed accessors. Values that
are already set in the real environment always win over the `.env` file, so a
deployment can override anything without editing files.

This is deliberately standalone (standard library only) and imported first by
the modules that read configuration - database.py, helpers/assist.py and
helpers/mailer.py - so the `.env` file is loaded before any of them read a
value at import time.
"""
import os
from pathlib import Path

# the project root is the parent of this helpers/ package
_ROOT = Path(__file__).resolve().parent.parent
_ENV_FILE = _ROOT / ".env"


def _load_env_file(path: Path) -> None:
    """Load KEY=VALUE lines from `path` into os.environ without overriding
    variables already set in the real environment."""
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return  # no .env file - in-code defaults are used

    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip()
        # strip matching surrounding quotes, if any
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        if key and key not in os.environ:
            os.environ[key] = value


_load_env_file(_ENV_FILE)


def env(name: str, default: str = "") -> str:
    """The environment value, or `default` when unset or empty."""
    value = os.environ.get(name)
    return value if value not in (None, "") else default


def env_bool(name: str, default: bool = False) -> bool:
    """A truthy environment flag: 1/true/yes/on (case-insensitive)."""
    value = os.environ.get(name)
    if value in (None, ""):
        return default
    return value.strip().lower() in ("1", "true", "yes", "on")


def env_int(name: str, default: int) -> int:
    """An integer environment value, falling back to `default` when unset or
    not a valid integer."""
    value = os.environ.get(name)
    if value in (None, ""):
        return default
    try:
        return int(value)
    except ValueError:
        return default
