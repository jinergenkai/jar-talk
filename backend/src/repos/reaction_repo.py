from sqlmodel import Session, select
from typing import Optional, List, Dict
from ..models.reaction import SlipReaction, ReactionCreate


class ReactionRepository:
    """Repository for SlipReaction database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, slip_reaction_id: int) -> Optional[SlipReaction]:
        """Get reaction by ID"""
        return self.session.get(SlipReaction, slip_reaction_id)

    def get_by_slip(self, slip_id: int) -> List[SlipReaction]:
        """Get all reactions for a slip"""
        statement = (
            select(SlipReaction)
            .where(SlipReaction.slip_id == slip_id)
            .order_by(SlipReaction.created_at.desc())
        )
        return list(self.session.exec(statement).all())

    def get_user_reaction(self, slip_id: int, user_id: int) -> Optional[SlipReaction]:
        """Get a specific user's reaction on a slip"""
        statement = select(SlipReaction).where(
            SlipReaction.slip_id == slip_id,
            SlipReaction.user_id == user_id
        )
        return self.session.exec(statement).first()

    def get_by_type(self, slip_id: int, reaction_type: str) -> List[SlipReaction]:
        """Get all reactions of a specific type for a slip"""
        statement = select(SlipReaction).where(
            SlipReaction.slip_id == slip_id,
            SlipReaction.reaction_type == reaction_type
        )
        return list(self.session.exec(statement).all())

    def create(self, reaction_data: ReactionCreate, user_id: int) -> SlipReaction:
        """Create a new reaction"""
        reaction = SlipReaction(
            **reaction_data.model_dump(),
            user_id=user_id
        )
        self.session.add(reaction)
        self.session.commit()
        self.session.refresh(reaction)
        return reaction

    def update(self, slip_reaction_id: int, reaction_type: str) -> Optional[SlipReaction]:
        """Update a reaction type"""
        reaction = self.get_by_id(slip_reaction_id)
        if not reaction:
            return None

        reaction.reaction_type = reaction_type
        self.session.add(reaction)
        self.session.commit()
        self.session.refresh(reaction)
        return reaction

    def delete(self, slip_reaction_id: int) -> bool:
        """Delete a reaction"""
        reaction = self.get_by_id(slip_reaction_id)
        if not reaction:
            return False

        self.session.delete(reaction)
        self.session.commit()
        return True

    def delete_user_reaction(self, slip_id: int, user_id: int) -> bool:
        """Delete user's reaction on a slip"""
        reaction = self.get_user_reaction(slip_id, user_id)
        if not reaction:
            return False

        self.session.delete(reaction)
        self.session.commit()
        return True

    def count_by_slip(self, slip_id: int) -> int:
        """Count total reactions on a slip"""
        statement = select(SlipReaction).where(SlipReaction.slip_id == slip_id)
        return len(list(self.session.exec(statement).all()))

    def get_reaction_summary(self, slip_id: int) -> Dict[str, int]:
        """Get reaction count grouped by type"""
        reactions = self.get_by_slip(slip_id)
        summary = {}
        for reaction in reactions:
            summary[reaction.reaction_type] = summary.get(reaction.reaction_type, 0) + 1
        return summary
