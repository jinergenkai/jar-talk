from fastapi import HTTPException
from typing import List

from ..repos.reaction_repo import ReactionRepository
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.user_repo import UserRepository
from ..models.reaction import ReactionCreate, ReactionResponse, ReactionSummary, SlipReaction


class ReactionService:
    """Service for reaction business logic"""

    def __init__(
        self,
        reaction_repo: ReactionRepository,
        slip_repo: SlipRepository,
        membership_repo: MembershipRepository,
        user_repo: UserRepository
    ):
        self.reaction_repo = reaction_repo
        self.slip_repo = slip_repo
        self.membership_repo = membership_repo
        self.user_repo = user_repo

    def _build_reaction_response(self, reaction: SlipReaction) -> ReactionResponse:
        """Build reaction response with user info"""
        user = self.user_repo.get_by_id(reaction.user_id)

        return ReactionResponse(
            slip_reaction_id=reaction.slip_reaction_id,
            slip_id=reaction.slip_id,
            user_id=reaction.user_id,
            reaction_type=reaction.reaction_type,
            created_at=reaction.created_at,
            username=user.username if user else None,
            profile_picture=user.profile_picture_url if user else None
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

    def toggle_reaction(self, reaction_data: ReactionCreate, user_id: int) -> dict:
        """
        Toggle a reaction on a slip
        If user already reacted with same type, remove it
        If user reacted with different type, update it
        If user hasn't reacted, add it
        """
        # Check access
        self._check_slip_access(reaction_data.slip_id, user_id)

        # Check if user already reacted
        existing_reaction = self.reaction_repo.get_user_reaction(reaction_data.slip_id, user_id)

        if existing_reaction:
            # Same type = remove (toggle off)
            if existing_reaction.reaction_type == reaction_data.reaction_type:
                self.reaction_repo.delete(existing_reaction.slip_reaction_id)
                return {
                    "message": "Reaction removed",
                    "action": "removed"
                }
            # Different type = update
            else:
                updated_reaction = self.reaction_repo.update(
                    existing_reaction.slip_reaction_id,
                    reaction_data.reaction_type
                )
                return {
                    "message": "Reaction updated",
                    "action": "updated",
                    "reaction": self._build_reaction_response(updated_reaction)
                }
        else:
            # No reaction = add
            new_reaction = self.reaction_repo.create(reaction_data, user_id)
            return {
                "message": "Reaction added",
                "action": "added",
                "reaction": self._build_reaction_response(new_reaction)
            }

    def get_slip_reactions(self, slip_id: int, user_id: int) -> List[ReactionResponse]:
        """
        Get all reactions for a slip
        Only container members can view
        """
        # Check access
        self._check_slip_access(slip_id, user_id)

        # Get reactions
        reactions = self.reaction_repo.get_by_slip(slip_id)

        return [self._build_reaction_response(reaction) for reaction in reactions]

    def get_reaction_summary(self, slip_id: int, user_id: int) -> List[ReactionSummary]:
        """
        Get reaction summary grouped by type
        Returns count and list of users for each reaction type
        """
        # Check access
        self._check_slip_access(slip_id, user_id)

        # Get all reactions
        reactions = self.reaction_repo.get_by_slip(slip_id)

        # Group by type
        summary_dict = {}
        for reaction in reactions:
            reaction_type = reaction.reaction_type
            if reaction_type not in summary_dict:
                summary_dict[reaction_type] = {
                    "reaction_type": reaction_type,
                    "count": 0,
                    "users": []
                }

            summary_dict[reaction_type]["count"] += 1

            # Add user info
            user = self.user_repo.get_by_id(reaction.user_id)
            if user:
                summary_dict[reaction_type]["users"].append({
                    "user_id": user.user_id,
                    "username": user.username,
                    "profile_picture": user.profile_picture_url
                })

        # Convert to list
        return [ReactionSummary(**data) for data in summary_dict.values()]

    def remove_reaction(self, slip_id: int, user_id: int) -> dict:
        """
        Remove user's reaction from a slip
        """
        # Check access
        self._check_slip_access(slip_id, user_id)

        # Delete user's reaction
        success = self.reaction_repo.delete_user_reaction(slip_id, user_id)

        if not success:
            raise HTTPException(status_code=404, detail="No reaction found to remove")

        return {"message": "Reaction removed successfully"}
