from fastapi import APIRouter, Depends
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..repos.reaction_repo import ReactionRepository
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.user_repo import UserRepository
from ..services.reaction_service import ReactionService
from ..models.reaction import ReactionCreate, ReactionResponse, ReactionSummary


router = APIRouter(prefix="/reactions", tags=["Reactions"])


def get_reaction_service(session: Session = Depends(get_session)) -> ReactionService:
    """Dependency injection for reaction service"""
    reaction_repo = ReactionRepository(session)
    slip_repo = SlipRepository(session)
    membership_repo = MembershipRepository(session)
    user_repo = UserRepository(session)
    return ReactionService(reaction_repo, slip_repo, membership_repo, user_repo)


@router.post("/toggle")
def toggle_reaction(
    reaction_data: ReactionCreate,
    user_id: int = Depends(get_current_user_id),
    reaction_service: ReactionService = Depends(get_reaction_service)
):
    """
    Toggle a reaction on a slip

    **Behavior:**
    - If user hasn't reacted: Add reaction
    - If user reacted with same type: Remove reaction
    - If user reacted with different type: Update to new type

    **Request:**
    ```json
    {
      "slip_id": 1,
      "reaction_type": "Heart"
    }
    ```

    **Reaction Types:** Heart, Fire, Resonate, etc.
    """
    return reaction_service.toggle_reaction(reaction_data, user_id)


@router.get("/slip/{slip_id}", response_model=List[ReactionResponse])
def get_slip_reactions(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    reaction_service: ReactionService = Depends(get_reaction_service)
):
    """
    Get all reactions for a slip

    Returns detailed list of all reactions with user info
    """
    return reaction_service.get_slip_reactions(slip_id, user_id)


@router.get("/slip/{slip_id}/summary", response_model=List[ReactionSummary])
def get_reaction_summary(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    reaction_service: ReactionService = Depends(get_reaction_service)
):
    """
    Get reaction summary for a slip

    Returns count and user list grouped by reaction type

    **Example Response:**
    ```json
    [
      {
        "reaction_type": "Heart",
        "count": 5,
        "users": [
          {"user_id": 1, "username": "john"},
          {"user_id": 2, "username": "jane"}
        ]
      },
      {
        "reaction_type": "Fire",
        "count": 3,
        "users": [...]
      }
    ]
    ```
    """
    return reaction_service.get_reaction_summary(slip_id, user_id)


@router.delete("/slip/{slip_id}")
def remove_reaction(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    reaction_service: ReactionService = Depends(get_reaction_service)
):
    """
    Remove your reaction from a slip

    Removes the current user's reaction regardless of type
    """
    return reaction_service.remove_reaction(slip_id, user_id)
