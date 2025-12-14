from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..models.container import ContainerCreate, ContainerUpdate, ContainerResponse, ContainerDetailResponse
from ..services.container_service import ContainerService


router = APIRouter(prefix="/containers", tags=["Containers"])


@router.post("", response_model=ContainerResponse, status_code=status.HTTP_201_CREATED)
async def create_container(
    container_data: ContainerCreate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Create a new container (jar)

    - Creates a container owned by current user
    - Automatically adds creator as admin
    """
    service = ContainerService(session)
    return service.create_container(container_data, user_id)


@router.get("", response_model=List[ContainerResponse])
async def get_user_containers(
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get all containers user is member of

    Returns all containers where user is either owner, admin, or member
    """
    service = ContainerService(session)
    return service.get_user_containers(user_id)


@router.get("/{container_id}", response_model=ContainerDetailResponse)
async def get_container(
    container_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get container by ID

    User must be a member of the container to view it
    """
    service = ContainerService(session)
    return service.get_container(container_id, user_id)


@router.put("/{container_id}", response_model=ContainerResponse)
async def update_container(
    container_id: int,
    container_data: ContainerUpdate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Update container

    Only admins can update container settings
    """
    service = ContainerService(session)
    return service.update_container(container_id, container_data, user_id)


@router.delete("/{container_id}")
async def delete_container(
    container_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Delete container

    Only the owner can delete the container
    This will also delete all slips and memberships
    """
    service = ContainerService(session)
    return service.delete_container(container_id, user_id)


@router.post("/{container_id}/members")
async def add_member(
    container_id: int,
    member_user_id: int = Query(..., description="User ID to add as member"),
    role: str = Query("member", description="Role: 'admin' or 'member'"),
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Add member to container

    Only admins can add members
    """
    service = ContainerService(session)
    return service.add_member(container_id, member_user_id, user_id, role)


@router.delete("/{container_id}/members/{member_user_id}")
async def remove_member(
    container_id: int,
    member_user_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Remove member from container

    - Admins can remove any member
    - Users can remove themselves (leave container)
    """
    service = ContainerService(session)
    return service.remove_member(container_id, member_user_id, user_id)
