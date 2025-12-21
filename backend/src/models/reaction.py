from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional, List


class SlipReaction(SQLModel, table=True):
    """
    SlipReaction - A reaction to a slip
    """
    __tablename__ = "slipreaction"

    slip_reaction_id: Optional[int] = Field(default=None, primary_key=True)
    slip_id: int = Field(foreign_key="slip.slip_id")
    user_id: int = Field(foreign_key="user.user_id")
    reaction_type: str = Field(max_length=50)  # 'Heart', 'Fire', 'Resonate', etc.
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ReactionCreate(SQLModel):
    """Schema for creating a reaction"""
    slip_id: int
    reaction_type: str


class ReactionResponse(SQLModel):
    """Schema for reaction response with user info"""
    slip_reaction_id: int
    slip_id: int
    user_id: int
    reaction_type: str
    created_at: datetime
    # User info
    username: Optional[str] = None
    profile_picture: Optional[str] = None


class ReactionSummary(SQLModel):
    """Schema for reaction summary by type"""
    reaction_type: str
    count: int
    # List of users who reacted with this type
    users: List[dict] = []  # [{"user_id": 1, "username": "john"}]
