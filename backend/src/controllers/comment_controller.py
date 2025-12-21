from fastapi import APIRouter, Depends
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..repos.comment_repo import CommentRepository
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.user_repo import UserRepository
from ..services.comment_service import CommentService
from ..models.comment import CommentCreate, CommentUpdate, CommentResponse


router = APIRouter(prefix="/comments", tags=["Comments"])


def get_comment_service(session: Session = Depends(get_session)) -> CommentService:
    """Dependency injection for comment service"""
    comment_repo = CommentRepository(session)
    slip_repo = SlipRepository(session)
    membership_repo = MembershipRepository(session)
    user_repo = UserRepository(session)
    return CommentService(comment_repo, slip_repo, membership_repo, user_repo)


@router.post("", response_model=CommentResponse)
def create_comment(
    comment_data: CommentCreate,
    user_id: int = Depends(get_current_user_id),
    comment_service: CommentService = Depends(get_comment_service)
):
    """
    Create a new comment on a slip

    Only container members can comment
    """
    return comment_service.create_comment(comment_data, user_id)


@router.get("/slip/{slip_id}", response_model=List[CommentResponse])
def get_slip_comments(
    slip_id: int,
    skip: int = 0,
    limit: int = 100,
    user_id: int = Depends(get_current_user_id),
    comment_service: CommentService = Depends(get_comment_service)
):
    """
    Get all comments for a slip

    Only container members can view comments

    **Query Parameters:**
    - skip: Pagination offset (default: 0)
    - limit: Number of comments to return (default: 100)
    """
    return comment_service.get_slip_comments(slip_id, user_id, skip, limit)


@router.get("/{comment_id}", response_model=CommentResponse)
def get_comment(
    comment_id: int,
    user_id: int = Depends(get_current_user_id),
    comment_service: CommentService = Depends(get_comment_service)
):
    """
    Get a specific comment

    Only container members can view
    """
    return comment_service.get_comment(comment_id, user_id)


@router.put("/{comment_id}", response_model=CommentResponse)
def update_comment(
    comment_id: int,
    comment_data: CommentUpdate,
    user_id: int = Depends(get_current_user_id),
    comment_service: CommentService = Depends(get_comment_service)
):
    """
    Update a comment

    Only comment author can update
    """
    return comment_service.update_comment(comment_id, comment_data, user_id)


@router.delete("/{comment_id}")
def delete_comment(
    comment_id: int,
    user_id: int = Depends(get_current_user_id),
    comment_service: CommentService = Depends(get_comment_service)
):
    """
    Delete a comment

    Comment author or container admin can delete
    """
    return comment_service.delete_comment(comment_id, user_id)
