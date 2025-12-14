from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from typing import List

from ..cores.database import get_session
from ..cores.security import get_current_user_id
from ..models.media import (
    MediaCreate,
    MediaUpdate,
    MediaResponse,
    UploadUrlRequest,
    UploadUrlResponse
)
from ..services.media_service import MediaService


router = APIRouter(prefix="/media", tags=["Media"])


@router.post("/upload-url", response_model=UploadUrlResponse)
async def request_upload_url(
    upload_request: UploadUrlRequest,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Request presigned URL for file upload

    **Flow:**
    1. Client calls this endpoint with file type and content type
    2. Backend generates presigned URL from MinIO
    3. Client uploads file directly to MinIO using the URL
    4. Client creates media record with the file_key

    **Parameters:**
    - **file_type**: 'image' or 'audio'
    - **content_type**: MIME type (e.g., 'image/jpeg', 'audio/mp3')

    **Returns:**
    - **upload_url**: Presigned URL to upload file (valid for 1 hour)
    - **file_key**: Storage path (save this for creating media record)

    **Example:**
    ```
    1. POST /media/upload-url
       { "file_type": "image", "content_type": "image/jpeg" }

    2. Receive: { "upload_url": "http://...", "file_key": "image/uuid.jpg" }

    3. PUT to upload_url with file data

    4. POST /media
       { "slip_id": 1, "media_type": "image", "storage_url": "image/uuid.jpg" }
    ```
    """
    service = MediaService(session)
    return service.request_upload_url(upload_request, user_id)


@router.post("", response_model=MediaResponse, status_code=status.HTTP_201_CREATED)
async def create_media(
    media_data: MediaCreate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Create media record after file upload

    Call this after uploading file to the presigned URL

    **Parameters:**
    - **slip_id**: Slip to attach media to
    - **media_type**: 'image' or 'audio'
    - **storage_url**: File key from upload-url response
    - **caption**: Optional caption/description

    **Requirements:**
    - File must exist in storage (uploaded via presigned URL)
    - User must be member of the slip's container
    """
    service = MediaService(session)
    return service.create_media(media_data, user_id)


@router.get("/{media_id}", response_model=MediaResponse)
async def get_media(
    media_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get media by ID with download URL

    Returns media info with presigned download URL (valid for 1 hour)
    """
    service = MediaService(session)
    return service.get_media(media_id, user_id)


@router.get("/slip/{slip_id}", response_model=List[MediaResponse])
async def get_slip_media(
    slip_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Get all media for a slip

    Returns list of media with presigned download URLs
    User must be member of the slip's container
    """
    service = MediaService(session)
    return service.get_slip_media(slip_id, user_id)


@router.put("/{media_id}", response_model=MediaResponse)
async def update_media(
    media_id: int,
    media_data: MediaUpdate,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Update media caption

    Only the slip author can update media
    """
    service = MediaService(session)
    return service.update_media(media_id, media_data, user_id)


@router.delete("/{media_id}")
async def delete_media(
    media_id: int,
    user_id: int = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """
    Delete media

    - Deletes file from storage (MinIO)
    - Deletes database record
    - Only slip author or container admin can delete
    """
    service = MediaService(session)
    return service.delete_media(media_id, user_id)
