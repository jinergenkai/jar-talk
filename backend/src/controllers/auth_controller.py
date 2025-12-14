from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlmodel import Session
from typing import Optional

from ..cores.database import get_session
from ..cores.security import get_current_user_id, security
from ..models.user import (
    UserResponse,
    AuthResponse,
    FirebaseAuthRequest
)
from ..services.auth_service import AuthService


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/firebase", response_model=AuthResponse)
async def firebase_auth(
    firebase_data: FirebaseAuthRequest,
    username: Optional[str] = None,
    session: Session = Depends(get_session)
):
    """
    Authenticate with Firebase token

    Supports all Firebase authentication methods:
    - Google OAuth
    - Email/Password (via Firebase)
    - Facebook, Twitter, etc.

    **How it works:**
    1. Client authenticates with Firebase (any method)
    2. Client gets Firebase ID token
    3. Send token to this endpoint
    4. Backend verifies token with Firebase
    5. Backend creates/updates user in database
    6. Returns JWT access token for API calls

    **Parameters:**
    - **firebase_token**: Firebase ID token from client
    - **username**: (optional) preferred username for new users

    **Response:**
    - **access_token**: JWT token for API authentication
    - **user**: User information
    """
    auth_service = AuthService(session)
    return auth_service.authenticate_with_firebase(
        firebase_data.firebase_token,
        username
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get current authenticated user information

    Requires: Authorization header with Bearer token
    """
    auth_service = AuthService(session)
    return auth_service.get_current_user(user_id)


@router.get("/check", response_model=dict)
async def check_auth(
    user_id: int = Depends(get_current_user_id)
):
    """
    Check if user is authenticated

    Requires: Authorization header with Bearer token

    Returns: {"authenticated": true, "user_id": <id>}
    """
    return {
        "authenticated": True,
        "user_id": user_id
    }


@router.get("/debug-token")
async def debug_token(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """
    Debug endpoint to check token without full validation
    REMOVE THIS IN PRODUCTION!
    """
    from jose import jwt
    from ..cores.config import settings

    token = credentials.credentials

    try:
        # Decode without verification (for debugging only!)
        unverified = jwt.get_unverified_claims(token)

        # Try to decode with verification
        try:
            verified = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            return {
                "status": "valid",
                "token_preview": token[:30] + "...",
                "unverified_payload": unverified,
                "verified_payload": verified,
                "secret_key_preview": settings.SECRET_KEY[:10] + "...",
                "algorithm": settings.ALGORITHM
            }
        except Exception as e:
            return {
                "status": "invalid",
                "error": str(e),
                "token_preview": token[:30] + "...",
                "unverified_payload": unverified,
                "secret_key_preview": settings.SECRET_KEY[:10] + "...",
                "algorithm": settings.ALGORITHM
            }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "token_preview": token[:30] + "..."
        }
