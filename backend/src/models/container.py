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


class MemberInfo(SQLModel):
    """Member info for container response"""
    user_id: int
    username: str
    email: str
    profile_picture_url: Optional[str] = None
    role: str  # 'admin' or 'member'
    joined_at: datetime


class ContainerResponse(SQLModel):
    """Schema for container response"""
    container_id: int
    name: str
    owner_id: int
    jar_style_settings: Optional[str] = None
    created_at: datetime
    # Current user's role in this container
    user_role: Optional[str] = None
    # Member count
    member_count: Optional[int] = None


class ContainerDetailResponse(ContainerResponse):
    """Schema for container detail with members"""
    members: List[MemberInfo] = []  # List of members with their details
