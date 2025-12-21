from fastapi import HTTPException
from typing import List

from ..repos.comment_repo import CommentRepository
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.user_repo import UserRepository
from ..models.comment import CommentCreate, CommentUpdate, CommentResponse, Comment


class CommentService:
    """Service for comment business logic"""

    def __init__(
        self,
        comment_repo: CommentRepository,
        slip_repo: SlipRepository,
        membership_repo: MembershipRepository,
        user_repo: UserRepository
    ):
        self.comment_repo = comment_repo
        self.slip_repo = slip_repo
        self.membership_repo = membership_repo
        self.user_repo = user_repo

    def _build_comment_response(self, comment: Comment) -> CommentResponse:
        """Build comment response with author info"""
        author = self.user_repo.get_by_id(comment.author_id)

        return CommentResponse(
            comment_id=comment.comment_id,
            slip_id=comment.slip_id,
            author_id=comment.author_id,
            text_content=comment.text_content,
            created_at=comment.created_at,
            author_username=author.username if author else None,
            author_email=author.email if author else None,
            author_profile_picture=author.profile_picture_url if author else None
        )

    def _check_slip_access(self, slip_id: int, user_id: int):
        """Check if user has access to the slip's container"""
        slip = self.slip_repo.get_by_id(slip_id)
        if not slip:
            raise HTTPException(status_code=404, detail="Slip not found")

        # Check if user is member of the container
        membership = self.membership_repo.get_user_membership(user_id, slip.container_id)
        if not membership:
            raise HTTPException(status_code=403, detail="You don't have access to this slip")

        return slip

    def create_comment(self, comment_data: CommentCreate, user_id: int) -> CommentResponse:
        """
        Create a new comment on a slip
        Only container members can comment
        """
        # Check access
        self._check_slip_access(comment_data.slip_id, user_id)

        # Create comment
        comment = self.comment_repo.create(comment_data, user_id)

        return self._build_comment_response(comment)

    def get_slip_comments(self, slip_id: int, user_id: int, skip: int = 0, limit: int = 100) -> List[CommentResponse]:
        """
        Get all comments for a slip
        Only container members can view comments
        """
        # Check access
        self._check_slip_access(slip_id, user_id)

        # Get comments
        comments = self.comment_repo.get_by_slip(slip_id, skip, limit)

        return [self._build_comment_response(comment) for comment in comments]

    def get_comment(self, comment_id: int, user_id: int) -> CommentResponse:
        """
        Get a specific comment
        Only container members can view
        """
        comment = self.comment_repo.get_by_id(comment_id)
        if not comment:
            raise HTTPException(status_code=404, detail="Comment not found")

        # Check access
        self._check_slip_access(comment.slip_id, user_id)

        return self._build_comment_response(comment)

    def update_comment(self, comment_id: int, comment_data: CommentUpdate, user_id: int) -> CommentResponse:
        """
        Update a comment
        Only comment author can update
        """
        comment = self.comment_repo.get_by_id(comment_id)
        if not comment:
            raise HTTPException(status_code=404, detail="Comment not found")

        # Check if user is the author
        if comment.author_id != user_id:
            raise HTTPException(status_code=403, detail="You can only edit your own comments")

        # Update comment
        updated_comment = self.comment_repo.update(comment_id, comment_data)
        if not updated_comment:
            raise HTTPException(status_code=500, detail="Failed to update comment")

        return self._build_comment_response(updated_comment)

    def delete_comment(self, comment_id: int, user_id: int) -> dict:
        """
        Delete a comment
        Comment author or container admin can delete
        """
        comment = self.comment_repo.get_by_id(comment_id)
        if not comment:
            raise HTTPException(status_code=404, detail="Comment not found")

        # Get slip to check container
        slip = self.slip_repo.get_by_id(comment.slip_id)
        if not slip:
            raise HTTPException(status_code=404, detail="Slip not found")

        # Check if user is author or container admin
        membership = self.membership_repo.get_user_membership(user_id, slip.container_id)
        if not membership:
            raise HTTPException(status_code=403, detail="You don't have access to this container")

        is_author = comment.author_id == user_id
        is_admin = membership.role == "admin"

        if not (is_author or is_admin):
            raise HTTPException(status_code=403, detail="Only comment author or container admin can delete comments")

        # Delete comment
        success = self.comment_repo.delete(comment_id)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to delete comment")

        return {"message": "Comment deleted successfully"}
