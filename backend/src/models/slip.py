from sqlmodel import Field, SQLModel, Relationship
from datetime import datetime
from typing import Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from .user import User
    from .container import Container


class Slip(SQLModel, table=True):
    """
    Slip - A journal entry in a container
    """
    __tablename__ = "slip"

    slip_id: Optional[int] = Field(default=None, primary_key=True)
    container_id: int = Field(foreign_key="container.container_id")
    author_id: int = Field(foreign_key="user.user_id")
    text_content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    location_data: Optional[str] = Field(default=None, max_length=500)  # coordinates, city


class SlipCreate(SQLModel):
    """Schema for creating a new slip"""
    container_id: int
    text_content: str
    location_data: Optional[str] = None


class SlipUpdate(SQLModel):
    """Schema for updating a slip"""
    text_content: Optional[str] = None
    location_data: Optional[str] = None


class SlipResponse(SQLModel):
    """Schema for slip response"""
    slip_id: int
    container_id: int
    author_id: int
    text_content: str
    created_at: datetime
    location_data: Optional[str] = None
    # Optional: Include author info
    author_username: Optional[str] = None
    author_email: Optional[str] = None
