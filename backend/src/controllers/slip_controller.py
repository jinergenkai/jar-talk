from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..models.slip import SlipCreate, SlipUpdate, SlipResponse
from ..services.slip_service import SlipService


router = APIRouter(prefix="/slips", tags=["Slips"])


@router.post("", response_model=SlipResponse, status_code=status.HTTP_201_CREATED)
async def create_slip(
    slip_data: SlipCreate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Create a new slip (journal entry)

    - User must be a member of the container
    - Slip is authored by current user
    """
    service = SlipService(session)
    return service.create_slip(slip_data, user_id)


@router.get("/{slip_id}", response_model=SlipResponse)
async def get_slip(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get slip by ID

    User must be a member of the container to view the slip
    """
    service = SlipService(session)
    return service.get_slip(slip_id, user_id)


@router.get("", response_model=List[SlipResponse])
async def get_slips(
    container_id: int = Query(..., description="Container ID to get slips from"),
    skip: int = Query(0, ge=0, description="Number of slips to skip"),
    limit: int = Query(50, ge=1, le=100, description="Max slips to return"),
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get slips from a container

    - User must be a member of the container
    - Returns slips ordered by created_at DESC (newest first)
    - Supports pagination
    """
    service = SlipService(session)
    return service.get_container_slips(container_id, user_id, skip, limit)


@router.get("/author/{author_id}", response_model=List[SlipResponse])
async def get_user_slips(
    author_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get all slips by a specific author

    - Returns only slips in containers current user has access to
    - Ordered by created_at DESC (newest first)
    """
    service = SlipService(session)
    return service.get_user_slips(author_id, user_id, skip, limit)


@router.put("/{slip_id}", response_model=SlipResponse)
async def update_slip(
    slip_id: int,
    slip_data: SlipUpdate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Update slip

    Only the author can update their slip
    """
    service = SlipService(session)
    return service.update_slip(slip_id, slip_data, user_id)


@router.delete("/{slip_id}")
async def delete_slip(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Delete slip

    - Author can delete their own slip
    - Container admin can delete any slip
    """
    service = SlipService(session)
    return service.delete_slip(slip_id, user_id)
