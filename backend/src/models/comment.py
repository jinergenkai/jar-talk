from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional


class Comment(SQLModel, table=True):
    """
    Comment - A comment on a slip
    """
    __tablename__ = "comment"

    comment_id: Optional[int] = Field(default=None, primary_key=True)
    slip_id: int = Field(foreign_key="slip.slip_id")
    author_id: int = Field(foreign_key="user.user_id")
    text_content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


class CommentCreate(SQLModel):
    """Schema for creating a comment"""
    slip_id: int
    text_content: str


class CommentUpdate(SQLModel):
    """Schema for updating a comment"""
    text_content: str


class CommentResponse(SQLModel):
    """Schema for comment response with author info"""
    comment_id: int
    slip_id: int
    author_id: int
    text_content: str
    created_at: datetime
    # Author info
    author_username: Optional[str] = None
    author_email: Optional[str] = None
    author_profile_picture: Optional[str] = None
