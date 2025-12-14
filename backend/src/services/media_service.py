from sqlmodel import Session
from fastapi import HTTPException, status
from typing import List

from ..models.media import Media, MediaCreate, MediaUpdate, MediaResponse, UploadUrlRequest, UploadUrlResponse
from ..repos.media_repo import MediaRepository
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..cores.storage import storage_service


class MediaService:
    """Service for media operations"""

    def __init__(self, session: Session):
        self.session = session
        self.media_repo = MediaRepository(session)
        self.slip_repo = SlipRepository(session)
        self.membership_repo = MembershipRepository(session)

    def request_upload_url(self, upload_request: UploadUrlRequest, user_id: int) -> UploadUrlResponse:
        """
        Generate presigned URL for file upload

        Returns URL that client can use to upload file directly to MinIO
        """
        # Validate file type
        if upload_request.file_type not in ['image', 'audio']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid file_type. Must be 'image' or 'audio'"
            )

        # Generate presigned upload URL
        result = storage_service.generate_upload_url(
            file_type=upload_request.file_type,
            content_type=upload_request.content_type
        )

        return UploadUrlResponse(**result)

    def create_media(self, media_data: MediaCreate, user_id: int) -> MediaResponse:
        """
        Create media record after upload

        - User must be member of the slip's container
        - File must exist in storage
        """
        # Get slip
        slip = self.slip_repo.get_by_id(media_data.slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Check if user has access to this slip's container
        if not self.membership_repo.is_member(user_id, slip.container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have access to this slip"
            )

        # Verify file exists in storage
        if not storage_service.file_exists(media_data.storage_url):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File not found in storage. Please upload first."
            )

        # Create media record
        media = self.media_repo.create(media_data)

        # Generate download URL
        download_url = storage_service.generate_download_url(media.storage_url)

        return MediaResponse(
            media_id=media.media_id,
            slip_id=media.slip_id,
            media_type=media.media_type,
            storage_url=media.storage_url,
            caption=media.caption,
            created_at=media.created_at,
            download_url=download_url
        )

    def get_media(self, media_id: int, user_id: int) -> MediaResponse:
        """
        Get media by ID with download URL

        - User must be member of the slip's container
        """
        media = self.media_repo.get_by_id(media_id)
        if not media:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Media not found"
            )

        # Get slip
        slip = self.slip_repo.get_by_id(media.slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Check access
        if not self.membership_repo.is_member(user_id, slip.container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have access to this media"
            )

        # Generate download URL
        download_url = storage_service.generate_download_url(media.storage_url)

        return MediaResponse(
            media_id=media.media_id,
            slip_id=media.slip_id,
            media_type=media.media_type,
            storage_url=media.storage_url,
            caption=media.caption,
            created_at=media.created_at,
            download_url=download_url
        )

    def get_slip_media(self, slip_id: int, user_id: int) -> List[MediaResponse]:
        """
        Get all media for a slip

        - User must be member of the slip's container
        """
        # Get slip
        slip = self.slip_repo.get_by_id(slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Check access
        if not self.membership_repo.is_member(user_id, slip.container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have access to this slip"
            )

        # Get all media
        media_list = self.media_repo.get_by_slip(slip_id)

        # Build responses with download URLs
        responses = []
        for media in media_list:
            download_url = storage_service.generate_download_url(media.storage_url)
            responses.append(
                MediaResponse(
                    media_id=media.media_id,
                    slip_id=media.slip_id,
                    media_type=media.media_type,
                    storage_url=media.storage_url,
                    caption=media.caption,
                    created_at=media.created_at,
                    download_url=download_url
                )
            )

        return responses

    def update_media(self, media_id: int, media_data: MediaUpdate, user_id: int) -> MediaResponse:
        """
        Update media (only caption)

        - Only author of the slip can update
        """
        media = self.media_repo.get_by_id(media_id)
        if not media:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Media not found"
            )

        # Get slip
        slip = self.slip_repo.get_by_id(media.slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Only author can update
        if slip.author_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the slip author can update media"
            )

        # Update media
        updated_media = self.media_repo.update(media_id, media_data)
        if not updated_media:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update media"
            )

        # Generate download URL
        download_url = storage_service.generate_download_url(updated_media.storage_url)

        return MediaResponse(
            media_id=updated_media.media_id,
            slip_id=updated_media.slip_id,
            media_type=updated_media.media_type,
            storage_url=updated_media.storage_url,
            caption=updated_media.caption,
            created_at=updated_media.created_at,
            download_url=download_url
        )

    def delete_media(self, media_id: int, user_id: int) -> dict:
        """
        Delete media

        - Author or container admin can delete
        - Also deletes file from storage
        """
        media = self.media_repo.get_by_id(media_id)
        if not media:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Media not found"
            )

        # Get slip
        slip = self.slip_repo.get_by_id(media.slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Author or admin can delete
        is_author = slip.author_id == user_id
        is_admin = self.membership_repo.is_admin(user_id, slip.container_id)

        if not (is_author or is_admin):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the slip author or container admin can delete media"
            )

        # Delete from storage
        storage_service.delete_file(media.storage_url)

        # Delete from database
        success = self.media_repo.delete(media_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to delete media"
            )

        return {"message": "Media deleted successfully"}
