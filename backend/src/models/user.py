from sqlmodel import Field, SQLModel, Relationship
from datetime import datetime
from typing import Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from .container import Container
    from .slip import Slip
    from .membership import Membership
    from .slip_reaction import SlipReaction
    from .streak import Streak
    from .comment import Comment


class User(SQLModel, table=True):
    """
    User model - All authentication is handled by Firebase
    Backend only stores user data for the application
    """
    __tablename__ = "user"

    user_id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(index=True, unique=True, max_length=255)
    email: str = Field(index=True, unique=True, max_length=255)
    firebase_uid: str = Field(index=True, unique=True, max_length=255)  # Required - from Firebase
    profile_picture_url: Optional[str] = Field(default=None, max_length=500)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class UserCreate(SQLModel):
    """Schema for creating a new user (internal use)"""
    username: str
    email: str
    firebase_uid: str
    profile_picture_url: Optional[str] = None


class UserResponse(SQLModel):
    """Schema for user response"""
    user_id: int
    username: str
    email: str
    profile_picture_url: Optional[str] = None
    created_at: datetime


class FirebaseAuthRequest(SQLModel):
    """
    Schema for Firebase authentication request

    Client should authenticate with Firebase first, then send the token here.
    Supports all Firebase auth methods: Google, Email/Password, Facebook, etc.
    """
    firebase_token: str


class AuthResponse(SQLModel):
    """Schema for authentication response"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
