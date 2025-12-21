from sqlmodel import Session, select
from typing import Optional, List
from ..models.comment import Comment, CommentCreate, CommentUpdate


class CommentRepository:
    """Repository for Comment database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, comment_id: int) -> Optional[Comment]:
        """Get comment by ID"""
        return self.session.get(Comment, comment_id)

    def get_by_slip(self, slip_id: int, skip: int = 0, limit: int = 100) -> List[Comment]:
        """Get all comments for a slip"""
        statement = (
            select(Comment)
            .where(Comment.slip_id == slip_id)
            .order_by(Comment.created_at.asc())  # Oldest first
            .offset(skip)
            .limit(limit)
        )
        return list(self.session.exec(statement).all())

    def get_by_author(self, author_id: int, skip: int = 0, limit: int = 100) -> List[Comment]:
        """Get all comments by an author"""
        statement = (
            select(Comment)
            .where(Comment.author_id == author_id)
            .order_by(Comment.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(self.session.exec(statement).all())

    def create(self, comment_data: CommentCreate, author_id: int) -> Comment:
        """Create a new comment"""
        comment = Comment(
            **comment_data.model_dump(),
            author_id=author_id
        )
        self.session.add(comment)
        self.session.commit()
        self.session.refresh(comment)
        return comment

    def update(self, comment_id: int, comment_data: CommentUpdate) -> Optional[Comment]:
        """Update a comment"""
        comment = self.get_by_id(comment_id)
        if not comment:
            return None

        comment.text_content = comment_data.text_content
        self.session.add(comment)
        self.session.commit()
        self.session.refresh(comment)
        return comment

    def delete(self, comment_id: int) -> bool:
        """Delete a comment"""
        comment = self.get_by_id(comment_id)
        if not comment:
            return False

        self.session.delete(comment)
        self.session.commit()
        return True

    def count_by_slip(self, slip_id: int) -> int:
        """Count comments on a slip"""
        statement = select(Comment).where(Comment.slip_id == slip_id)
        return len(list(self.session.exec(statement).all()))
