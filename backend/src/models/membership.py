from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional
from enum import Enum


class MemberRole(str, Enum):
    """Member roles in a container"""
    ADMIN = "admin"
    MEMBER = "member"


class Membership(SQLModel, table=True):
    """
    Membership - User's participation in a container
    """
    __tablename__ = "membership"

    participant_id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.user_id")
    container_id: int = Field(foreign_key="container.container_id")
    role: str = Field(default=MemberRole.MEMBER.value, max_length=50)
    joined_at: datetime = Field(default_factory=datetime.utcnow)


class MembershipCreate(SQLModel):
    """Schema for adding a member to container"""
    user_id: int
    container_id: int
    role: str = MemberRole.MEMBER.value


class MembershipUpdate(SQLModel):
    """Schema for updating membership"""
    role: str


class MembershipResponse(SQLModel):
    """Schema for membership response"""
    participant_id: int
    user_id: int
    container_id: int
    role: str
    joined_at: datetime
    # Optional: Include user info
    username: Optional[str] = None
    email: Optional[str] = None
