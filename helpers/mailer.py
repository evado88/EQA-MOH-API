"""Outbound email for the EQA platform.

Currently this sends one thing - the sign-up verification link - but it is kept
general so later notices (approval, rejection, cycle reminders) can reuse it.

Configuration follows the rest of this project: sensible in-code defaults that
an environment variable can override. The defaults carry the Gmail account the
platform was set up with. Prefer setting these in the environment in any shared
or production setting:

    MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD,
    MAIL_FROM, MAIL_FROM_NAME, MAIL_USE_TLS,
    MAIL_APP_BASE_URL   - where the React client is served, for building links
    MAIL_SUPPRESS_SEND  - "1" to skip the actual SMTP send (dev/offline)

SECURITY NOTE: the default password below is a Gmail *app password*. It is a
credential; do not commit real credentials to a public repository. Move these
to the environment (or a secret store) before this leaves local development.
"""
import os
import smtplib
import ssl
from email.message import EmailMessage

from starlette.concurrency import run_in_threadpool


def _env(name: str, default: str) -> str:
    value = os.environ.get(name)
    return value if value not in (None, "") else default


# --- SMTP account -----------------------------------------------------------
MAIL_HOST = _env("MAIL_HOST", "smtp.gmail.com")
MAIL_PORT = int(_env("MAIL_PORT", "587"))
MAIL_USERNAME = _env("MAIL_USERNAME", "zebrapp2000@gmail.com")
# Gmail app password (16 chars, spaces are ignored by Gmail but we strip anyway)
MAIL_PASSWORD = _env("MAIL_PASSWORD", "utys nasu oqfw xqdg").replace(" ", "")
MAIL_FROM = _env("MAIL_FROM", MAIL_USERNAME)
MAIL_FROM_NAME = _env("MAIL_FROM_NAME", "Zambia EQA Platform")
MAIL_USE_TLS = _env("MAIL_USE_TLS", "1") == "1"

# where the client lives, so verification links point at a real page
APP_BASE_URL = _env("MAIL_APP_BASE_URL", "http://localhost:5173").rstrip("/")

# set to "1" to skip the real send - the link is still printed to the console
SUPPRESS_SEND = _env("MAIL_SUPPRESS_SEND", "0") == "1"


def verification_link(token: str) -> str:
    """The page a new user follows to prove their email and set a password."""
    return f"{APP_BASE_URL}/set-password?token={token}"


def _send_sync(to_address: str, subject: str, text_body: str, html_body: str) -> None:
    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = f"{MAIL_FROM_NAME} <{MAIL_FROM}>"
    message["To"] = to_address
    message.set_content(text_body)
    message.add_alternative(html_body, subtype="html")

    if SUPPRESS_SEND:
        print(f"[mailer] SUPPRESS_SEND set - not sending to {to_address}")
        return

    context = ssl.create_default_context()
    with smtplib.SMTP(MAIL_HOST, MAIL_PORT, timeout=30) as server:
        if MAIL_USE_TLS:
            server.starttls(context=context)
        server.login(MAIL_USERNAME, MAIL_PASSWORD)
        server.send_message(message)


async def send_email(to_address: str, subject: str, text_body: str, html_body: str) -> None:
    """Send an email without blocking the event loop.

    Raises on failure so the caller can tell the user their email could not be
    reached (which, for a verification email, is the whole point).
    """
    await run_in_threadpool(_send_sync, to_address, subject, text_body, html_body)


async def send_verification_email(to_address: str, name: str, token: str) -> None:
    link = verification_link(token)

    # always leave a trail in the server log, so a developer can verify an
    # account even when real sending is suppressed or offline
    print(f"[mailer] verification link for {to_address}: {link}")

    subject = "Verify your email - Zambia EQA Platform"
    greeting = name.strip() or "there"
    text_body = (
        f"Hello {greeting},\n\n"
        "Thank you for registering on the Zambia EQA Platform.\n\n"
        "Please confirm your email address and set your password by opening the "
        "link below:\n\n"
        f"{link}\n\n"
        "If you did not request this, you can ignore this email.\n"
    )
    html_body = f"""\
<!doctype html>
<html>
  <body style="margin:0;padding:0;background:#f4f6f8;font-family:Segoe UI,Arial,sans-serif;color:#1f2937;">
    <div style="max-width:520px;margin:24px auto;background:#ffffff;border-radius:12px;overflow:hidden;border:1px solid #e5e7eb;">
      <div style="background:#0d6e6e;padding:20px 28px;color:#ffffff;">
        <h1 style="margin:0;font-size:18px;">Zambia EQA Platform</h1>
      </div>
      <div style="padding:28px;">
        <p style="margin:0 0 14px;">Hello {greeting},</p>
        <p style="margin:0 0 14px;">Thank you for registering. Please confirm your email address and set your password to activate your account.</p>
        <p style="margin:24px 0;text-align:center;">
          <a href="{link}" style="background:#0d6e6e;color:#ffffff;text-decoration:none;padding:12px 28px;border-radius:8px;display:inline-block;font-weight:600;">Verify email &amp; set password</a>
        </p>
        <p style="margin:0 0 8px;font-size:12px;color:#6b7280;">If the button does not work, copy this link into your browser:</p>
        <p style="margin:0;font-size:12px;word-break:break-all;"><a href="{link}" style="color:#0d6e6e;">{link}</a></p>
        <p style="margin:20px 0 0;font-size:12px;color:#6b7280;">If you did not request this, you can ignore this email.</p>
      </div>
    </div>
  </body>
</html>"""

    await send_email(to_address, subject, text_body, html_body)
