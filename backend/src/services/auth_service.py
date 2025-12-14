from sqlmodel import Session
from fastapi import HTTPException, status
from typing import Optional
from ..models.user import User, UserCreate, UserResponse, AuthResponse
from ..repos.user_repo import UserRepository
from ..cores.security import create_access_token
from ..cores.firebase_config import verify_firebase_token, get_firebase_user


class AuthService:
    """
    Authentication service - All auth is handled by Firebase
    This service only verifies Firebase tokens and manages user data
    """

    def __init__(self, session: Session):
        self.session = session
        self.user_repo = UserRepository(session)

    def authenticate_with_firebase(self, firebase_token: str, username: Optional[str] = None) -> AuthResponse:
        """
        Authenticate user with Firebase token

        Supports all Firebase authentication methods:
        - Google OAuth
        - Email/Password (via Firebase)
        - Facebook, Twitter, etc.

        Flow:
        1. Verify Firebase token with Firebase Admin SDK
        2. Extract user info (uid, email) from token
        3. Check if user exists in our database
        4. Create new user if first time login
        5. Return JWT token for API access
        """

        try:
            # 1. Verify Firebase token
            decoded_token = verify_firebase_token(firebase_token)
            firebase_uid = decoded_token.get("uid")
            email = decoded_token.get("email")

            if not firebase_uid or not email:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid Firebase token: missing uid or email"
                )

            # 2. Check if user exists with this Firebase UID
            user = self.user_repo.get_by_firebase_uid(firebase_uid)

            if not user:
                # 3. First time login - create new user
                # Get additional info from Firebase
                try:
                    firebase_user = get_firebase_user(firebase_uid)
                    display_name = firebase_user.display_name if hasattr(firebase_user, 'display_name') else None
                    photo_url = firebase_user.photo_url if hasattr(firebase_user, 'photo_url') else None
                except:
                    display_name = None
                    photo_url = None

                # Generate username from email or provided username
                if not username:
                    username = email.split("@")[0]
                    # Ensure username is unique
                    base_username = username
                    counter = 1
                    while self.user_repo.username_exists(username):
                        username = f"{base_username}{counter}"
                        counter += 1

                # Create user
                user_data = UserCreate(
                    username=username,
                    email=email,
                    firebase_uid=firebase_uid,
                    profile_picture_url=photo_url
                )
                user = self.user_repo.create(user_data)

            # 4. Create JWT access token for API
            access_token = create_access_token(data={"sub": str(user.user_id)})

            # 5. Return response
            return AuthResponse(
                access_token=access_token,
                user=UserResponse.model_validate(user)
            )

        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e)
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Authentication failed: {str(e)}"
            )

    def get_current_user(self, user_id: int) -> UserResponse:
        """Get current user by ID"""
        user = self.user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        return UserResponse.model_validate(user)
