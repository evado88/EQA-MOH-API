"""Request authentication and authorization helpers.

The sign-in endpoint issues a JWT; the client sends it back as
`Authorization: Bearer <token>` on every request (see the axios interceptor in
the client's main entry point). These dependencies decode that token so routes
can tell who is calling and what they are allowed to do.

`get_current_user` is deliberately optional - it returns None when no (or an
invalid) token is present - so endpoints that do not opt in keep working exactly
as before. Endpoints that must be protected depend on `require_user`,
`require_system_admin`, etc.
"""
from typing import Optional

from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError

from helpers import assist

# Registering a bearer scheme is what makes Swagger show the padlock and the
# "Authorize" button, and send the token on "Try it out". auto_error=False keeps
# it optional at the transport layer, so endpoints that only *scope* by the
# caller still work anonymously; the required guards below raise 401 themselves.
bearer_scheme = HTTPBearer(auto_error=False, description="Paste the access_token from /auth/login")


class CurrentUser:
    """The signed-in caller, as carried on the JWT (no database hit)."""

    def __init__(self, payload: dict):
        self.id = payload.get("userid")
        self.email = payload.get("sub")
        self.role_id = payload.get("role")
        self.scheme_id = payload.get("scheme_id")
        self.laboratory_id = payload.get("lab")
        self.name = payload.get("name")

    def __repr__(self):
        return f"CurrentUser(id={self.id}, role={self.role_id}, scheme={self.scheme_id})"


def _decode(token: str) -> dict:
    return jwt.decode(token, assist.SECRET_KEY, algorithms=[assist.ALGORITHM])


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
) -> Optional[CurrentUser]:
    """The caller if a valid bearer token is present, otherwise None."""
    if not credentials or not credentials.credentials:
        return None

    try:
        payload = _decode(credentials.credentials.strip())
    except JWTError:
        return None

    return CurrentUser(payload)


async def require_user(
    user: Optional[CurrentUser] = Depends(get_current_user),
) -> CurrentUser:
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication is required")
    return user


async def require_system_admin(
    user: CurrentUser = Depends(require_user),
) -> CurrentUser:
    """Only the Administrator may perform system administration."""
    if not assist.is_system_admin(user.role_id):
        raise HTTPException(
            status_code=403,
            detail="Only an Administrator may perform this action",
        )
    return user


async def require_provider(
    user: CurrentUser = Depends(require_user),
) -> CurrentUser:
    """A provider-side (non-facility) role is required."""
    if not assist.is_provider_role(user.role_id):
        raise HTTPException(
            status_code=403,
            detail="This action is restricted to scheme staff",
        )
    return user
