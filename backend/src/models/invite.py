from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional


class Invite(SQLModel, table=True):
    """
    Invite - Invitation link/code for joining containers
    """
    __tablename__ = "invite"

    invite_id: Optional[int] = Field(default=None, primary_key=True)
    container_id: int = Field(foreign_key="container.container_id")
    invite_code: str = Field(index=True, unique=True, max_length=50)
    created_by: int = Field(foreign_key="user.user_id")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    expires_at: Optional[datetime] = None  # NULL = never expires
    max_uses: Optional[int] = None  # NULL = unlimited uses
    current_uses: int = Field(default=0)
    is_active: bool = Field(default=True)


class InviteCreate(SQLModel):
    """Schema for creating an invite"""
    container_id: int
    expires_in_hours: Optional[int] = None  # NULL = never expires
    max_uses: Optional[int] = None  # NULL = unlimited


class InviteResponse(SQLModel):
    """Schema for invite response"""
    invite_id: int
    container_id: int
    invite_code: str
    invite_link: str  # Full URL with code
    created_by: int
    created_at: datetime
    expires_at: Optional[datetime] = None
    max_uses: Optional[int] = None
    current_uses: int
    is_active: bool
    # Container info
    container_name: Optional[str] = None


