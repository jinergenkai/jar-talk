from sqlmodel import Session, select
from typing import Optional, List
from datetime import datetime
from ..models.invite import Invite, InviteCreate


class InviteRepository:
    """Repository for Invite database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, invite_id: int) -> Optional[Invite]:
        """Get invite by ID"""
        return self.session.get(Invite, invite_id)

    def get_by_code(self, invite_code: str) -> Optional[Invite]:
        """Get invite by code"""
        statement = select(Invite).where(Invite.invite_code == invite_code)
        return self.session.exec(statement).first()

    def get_active_by_container(self, container_id: int) -> List[Invite]:
        """Get all active invites for a container"""
        statement = (
            select(Invite)
            .where(Invite.container_id == container_id)
            .where(Invite.is_active == True)
            .order_by(Invite.created_at.desc())
        )
        return list(self.session.exec(statement).all())

    def create(self, invite_data: InviteCreate, created_by: int, invite_code: str, expires_at: Optional[datetime] = None) -> Invite:
        """Create a new invite"""
        invite = Invite(
            container_id=invite_data.container_id,
            invite_code=invite_code,
            created_by=created_by,
            expires_at=expires_at,
            max_uses=invite_data.max_uses,
            current_uses=0,
            is_active=True
        )
        self.session.add(invite)
        self.session.commit()
        self.session.refresh(invite)
        return invite

    def increment_uses(self, invite_id: int) -> Optional[Invite]:
        """Increment the current_uses counter"""
        invite = self.get_by_id(invite_id)
        if not invite:
            return None

        invite.current_uses += 1

        # Auto-deactivate if max uses reached
        if invite.max_uses and invite.current_uses >= invite.max_uses:
            invite.is_active = False

        self.session.add(invite)
        self.session.commit()
        self.session.refresh(invite)
        return invite

    def deactivate(self, invite_id: int) -> bool:
        """Deactivate an invite"""
        invite = self.get_by_id(invite_id)
        if not invite:
            return False

        invite.is_active = False
        self.session.add(invite)
        self.session.commit()
        return True

    def delete(self, invite_id: int) -> bool:
        """Delete an invite"""
        invite = self.get_by_id(invite_id)
        if not invite:
            return False

        self.session.delete(invite)
        self.session.commit()
        return True

    def cleanup_expired(self):
        """Deactivate all expired invites"""
        now = datetime.utcnow()
        statement = (
            select(Invite)
            .where(Invite.is_active == True)
            .where(Invite.expires_at != None)
            .where(Invite.expires_at < now)
        )
        expired_invites = self.session.exec(statement).all()

        for invite in expired_invites:
            invite.is_active = False
            self.session.add(invite)

        self.session.commit()
        return len(list(expired_invites))
