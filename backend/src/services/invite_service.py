from datetime import datetime, timedelta
from fastapi import HTTPException
import secrets
import string
from typing import Optional

from ..repos.invite_repo import InviteRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.container_repo import ContainerRepository
from ..models.invite import InviteCreate, InviteResponse, Invite
from ..models.membership import MembershipCreate


class InviteService:
    """Service for invite business logic"""

    def __init__(
        self,
        invite_repo: InviteRepository,
        membership_repo: MembershipRepository,
        container_repo: ContainerRepository
    ):
        self.invite_repo = invite_repo
        self.membership_repo = membership_repo
        self.container_repo = container_repo

    def _generate_invite_code(self, length: int = 8) -> str:
        """Generate a random invite code"""
        characters = string.ascii_uppercase + string.digits
        # Exclude similar looking characters: 0, O, I, 1
        characters = characters.replace('0', '').replace('O', '').replace('I', '').replace('1', '')

        while True:
            code = ''.join(secrets.choice(characters) for _ in range(length))
            # Check if code already exists
            existing = self.invite_repo.get_by_code(code)
            if not existing:
                return code

    def _build_invite_response(self, invite: Invite, base_url: str = "http://localhost:8000") -> InviteResponse:
        """Build invite response with full link"""
        # Get container name
        container = self.container_repo.get_by_id(invite.container_id)
        container_name = container.name if container else None

        return InviteResponse(
            invite_id=invite.invite_id,
            container_id=invite.container_id,
            invite_code=invite.invite_code,
            invite_link=f"{base_url}/invites/join?code={invite.invite_code}",
            created_by=invite.created_by,
            created_at=invite.created_at,
            expires_at=invite.expires_at,
            max_uses=invite.max_uses,
            current_uses=invite.current_uses,
            is_active=invite.is_active,
            container_name=container_name
        )

    def create_invite(self, invite_data: InviteCreate, user_id: int, base_url: str = "http://localhost:8000") -> InviteResponse:
        """
        Create a new invite link
        Only container admins can create invites
        """
        # Check if user is admin of the container
        membership = self.membership_repo.get_user_membership(user_id, invite_data.container_id)
        if not membership:
            raise HTTPException(status_code=403, detail="You don't have access to this container")

        if membership.role != "admin":
            raise HTTPException(status_code=403, detail="Only admins can create invites")

        # Generate invite code
        invite_code = self._generate_invite_code()

        # Calculate expiration
        expires_at = None
        if invite_data.expires_in_hours:
            expires_at = datetime.utcnow() + timedelta(hours=invite_data.expires_in_hours)

        # Create invite
        invite = self.invite_repo.create(
            invite_data=invite_data,
            created_by=user_id,
            invite_code=invite_code,
            expires_at=expires_at
        )

        return self._build_invite_response(invite, base_url)

    def get_container_invites(self, container_id: int, user_id: int, base_url: str = "http://localhost:8000") -> list[InviteResponse]:
        """
        Get all active invites for a container
        Only admins can view invites
        """
        # Check if user is admin
        membership = self.membership_repo.get_user_membership(user_id, container_id)
        if not membership:
            raise HTTPException(status_code=403, detail="You don't have access to this container")

        if membership.role != "admin":
            raise HTTPException(status_code=403, detail="Only admins can view invites")

        # Cleanup expired invites first
        self.invite_repo.cleanup_expired()

        # Get active invites
        invites = self.invite_repo.get_active_by_container(container_id)
        return [self._build_invite_response(invite, base_url) for invite in invites]

    def join_by_code(self, invite_code: str, user_id: int) -> dict:
        """
        Join a container using an invite code
        """
        # Get invite
        invite = self.invite_repo.get_by_code(invite_code)
        if not invite:
            raise HTTPException(status_code=404, detail="Invalid invite code")

        # Check if invite is active
        if not invite.is_active:
            raise HTTPException(status_code=400, detail="This invite is no longer active")

        # Check if invite has expired
        if invite.expires_at and invite.expires_at < datetime.utcnow():
            # Auto-deactivate
            self.invite_repo.deactivate(invite.invite_id)
            raise HTTPException(status_code=400, detail="This invite has expired")

        # Check if max uses reached
        if invite.max_uses and invite.current_uses >= invite.max_uses:
            raise HTTPException(status_code=400, detail="This invite has reached its maximum usage limit")

        # Check if user is already a member
        existing_membership = self.membership_repo.get_user_membership(user_id, invite.container_id)
        if existing_membership:
            raise HTTPException(status_code=400, detail="You are already a member of this container")

        # Add user as member
        membership_data = MembershipCreate(
            user_id=user_id,
            container_id=invite.container_id,
            role="member"
        )
        membership = self.membership_repo.create(membership_data)

        # Increment invite uses
        self.invite_repo.increment_uses(invite.invite_id)

        # Get container info
        container = self.container_repo.get_by_id(invite.container_id)

        return {
            "message": "Successfully joined container",
            "container": {
                "container_id": container.container_id,
                "name": container.name
            },
            "membership": {
                "participant_id": membership.participant_id,
                "role": membership.role,
                "joined_at": membership.joined_at
            }
        }

    def deactivate_invite(self, invite_id: int, user_id: int) -> dict:
        """
        Deactivate an invite
        Only container admins or invite creator can deactivate
        """
        invite = self.invite_repo.get_by_id(invite_id)
        if not invite:
            raise HTTPException(status_code=404, detail="Invite not found")

        # Check if user is admin or creator
        membership = self.membership_repo.get_user_membership(user_id, invite.container_id)
        if not membership:
            raise HTTPException(status_code=403, detail="You don't have access to this container")

        if membership.role != "admin" and invite.created_by != user_id:
            raise HTTPException(status_code=403, detail="Only admins or invite creator can deactivate invites")

        # Deactivate
        success = self.invite_repo.deactivate(invite_id)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to deactivate invite")

        return {"message": "Invite deactivated successfully"}
