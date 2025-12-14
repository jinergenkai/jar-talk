from sqlmodel import Field, SQLModel, Relationship
from datetime import datetime
from typing import Optional, List, TYPE_CHECKING

if TYPE_CHECKING:
    from .user import User
    from .slip import Slip
    from .membership import Membership


class Container(SQLModel, table=True):
    """
    Container (Jar) - A shared journal space
    """
    __tablename__ = "container"

    container_id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(max_length=255)
    owner_id: int = Field(foreign_key="user.user_id")
    jar_style_settings: Optional[str] = Field(default=None)  # JSON string for customization
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ContainerCreate(SQLModel):
    """Schema for creating a new container"""
    name: str
    jar_style_settings: Optional[str] = None


class ContainerUpdate(SQLModel):
    """Schema for updating a container"""
    name: Optional[str] = None
    jar_style_settings: Optional[str] = None


class ContainerResponse(SQLModel):
    """Schema for container response"""
    container_id: int
    name: str
    owner_id: int
    jar_style_settings: Optional[str] = None
    created_at: datetime
    # Optional: Include membership info
    user_role: Optional[str] = None  # Role of current user in this container
    member_count: Optional[int] = None


class ContainerWithMembers(ContainerResponse):
    """Schema for container with member details"""
    members: List[dict] = []  # List of members with their roles
