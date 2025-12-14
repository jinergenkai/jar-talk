from sqlmodel import Session, select
from typing import Optional, List
from ..models.membership import Membership, MembershipCreate, MembershipUpdate


class MembershipRepository:
    """Repository for Membership database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, participant_id: int) -> Optional[Membership]:
        """Get membership by ID"""
        return self.session.get(Membership, participant_id)

    def get_user_membership(self, user_id: int, container_id: int) -> Optional[Membership]:
        """Get user's membership in a specific container"""
        statement = select(Membership).where(
            Membership.user_id == user_id,
            Membership.container_id == container_id
        )
        return self.session.exec(statement).first()

    def get_container_members(self, container_id: int) -> List[Membership]:
        """Get all members of a container"""
        statement = select(Membership).where(Membership.container_id == container_id)
        return list(self.session.exec(statement).all())

    def get_user_containers(self, user_id: int) -> List[Membership]:
        """Get all containers a user is member of"""
        statement = select(Membership).where(Membership.user_id == user_id)
        return list(self.session.exec(statement).all())

    def create(self, membership_data: MembershipCreate) -> Membership:
        """Create a new membership"""
        membership = Membership(**membership_data.model_dump())
        self.session.add(membership)
        self.session.commit()
        self.session.refresh(membership)
        return membership

    def update(self, participant_id: int, membership_data: MembershipUpdate) -> Optional[Membership]:
        """Update a membership"""
        membership = self.get_by_id(participant_id)
        if not membership:
            return None

        update_data = membership_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(membership, key, value)

        self.session.add(membership)
        self.session.commit()
        self.session.refresh(membership)
        return membership

    def delete(self, participant_id: int) -> bool:
        """Delete a membership"""
        membership = self.get_by_id(participant_id)
        if not membership:
            return False

        self.session.delete(membership)
        self.session.commit()
        return True

    def is_member(self, user_id: int, container_id: int) -> bool:
        """Check if user is a member of container"""
        return self.get_user_membership(user_id, container_id) is not None

    def is_admin(self, user_id: int, container_id: int) -> bool:
        """Check if user is admin of container"""
        membership = self.get_user_membership(user_id, container_id)
        return membership is not None and membership.role == "admin"
