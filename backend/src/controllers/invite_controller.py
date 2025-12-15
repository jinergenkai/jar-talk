from fastapi import APIRouter, Depends, Request
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..repos.invite_repo import InviteRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.container_repo import ContainerRepository
from ..services.invite_service import InviteService
from ..models.invite import InviteCreate, InviteResponse


router = APIRouter(prefix="/invites", tags=["Invites"])


def get_invite_service(session: Session = Depends(get_session)) -> InviteService:
    """Dependency injection for invite service"""
    invite_repo = InviteRepository(session)
    membership_repo = MembershipRepository(session)
    container_repo = ContainerRepository(session)
    return InviteService(invite_repo, membership_repo, container_repo)


@router.post("", response_model=InviteResponse)
def create_invite(
    invite_data: InviteCreate,
    request: Request,
    user_id: int = Depends(get_current_user_id),
    invite_service: InviteService = Depends(get_invite_service)
):
    """
    Create a new invite link for a container

    Only container admins can create invites

    **Parameters:**
    - container_id: ID of the container
    - expires_in_hours: Hours until invite expires (null = never expires)
    - max_uses: Maximum number of uses (null = unlimited)

    **Returns:**
    - Invite with code and full link
    """
    base_url = str(request.base_url).rstrip('/')
    return invite_service.create_invite(invite_data, user_id, base_url)


@router.get("/container/{container_id}", response_model=List[InviteResponse])
def get_container_invites(
    container_id: int,
    request: Request,
    user_id: int = Depends(get_current_user_id),
    invite_service: InviteService = Depends(get_invite_service)
):
    """
    Get all active invites for a container

    Only container admins can view invites
    """
    base_url = str(request.base_url).rstrip('/')
    return invite_service.get_container_invites(container_id, user_id, base_url)


@router.post("/join")
def join_by_invite(
    code: str,
    user_id: int = Depends(get_current_user_id),
    invite_service: InviteService = Depends(get_invite_service)
):
    """
    Join a container using an invite code

    **Query Parameters:**
    - code: The invite code (from link or manually entered)

    **Example:**
    - Click link: POST /invites/join?code=ABC123XY
    - Manual entry: POST /invites/join?code=ABC123XY

    **Returns:**
    - Success message with container and membership info
    """
    return invite_service.join_by_code(code, user_id)


@router.delete("/{invite_id}")
def deactivate_invite(
    invite_id: int,
    user_id: int = Depends(get_current_user_id),
    invite_service: InviteService = Depends(get_invite_service)
):
    """
    Deactivate an invite

    Only container admins or invite creator can deactivate
    """
    return invite_service.deactivate_invite(invite_id, user_id)
