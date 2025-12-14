from sqlmodel import Session
from fastapi import HTTPException, status
from typing import List

from ..models.slip import Slip, SlipCreate, SlipUpdate, SlipResponse
from ..repos.slip_repo import SlipRepository
from ..repos.membership_repo import MembershipRepository
from ..repos.user_repo import UserRepository


class SlipService:
    """Service for slip (journal entry) business logic"""

    def __init__(self, session: Session):
        self.session = session
        self.slip_repo = SlipRepository(session)
        self.membership_repo = MembershipRepository(session)
        self.user_repo = UserRepository(session)

    def create_slip(self, slip_data: SlipCreate, author_id: int) -> SlipResponse:
        """
        Create a new slip
        - User must be member of the container
        """
        # Check if user is member of container
        if not self.membership_repo.is_member(author_id, slip_data.container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You must be a member of this container to create slips"
            )

        # Create slip
        slip = self.slip_repo.create(slip_data, author_id)

        # Get author info
        author = self.user_repo.get_by_id(author_id)

        return SlipResponse(
            slip_id=slip.slip_id,
            container_id=slip.container_id,
            author_id=slip.author_id,
            text_content=slip.text_content,
            created_at=slip.created_at,
            location_data=slip.location_data,
            author_username=author.username if author else None,
            author_email=author.email if author else None
        )

    def get_slip(self, slip_id: int, user_id: int) -> SlipResponse:
        """
        Get slip by ID
        - User must be member of the container
        """
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

        # Get author info
        author = self.user_repo.get_by_id(slip.author_id)

        return SlipResponse(
            slip_id=slip.slip_id,
            container_id=slip.container_id,
            author_id=slip.author_id,
            text_content=slip.text_content,
            created_at=slip.created_at,
            location_data=slip.location_data,
            author_username=author.username if author else None,
            author_email=author.email if author else None
        )

    def get_container_slips(
        self,
        container_id: int,
        user_id: int,
        skip: int = 0,
        limit: int = 50
    ) -> List[SlipResponse]:
        """
        Get all slips in a container
        - User must be member of the container
        """
        # Check access
        if not self.membership_repo.is_member(user_id, container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have access to this container"
            )

        # Get slips
        slips = self.slip_repo.get_by_container(container_id, skip, limit)

        # Build responses with author info
        responses = []
        for slip in slips:
            author = self.user_repo.get_by_id(slip.author_id)
            responses.append(
                SlipResponse(
                    slip_id=slip.slip_id,
                    container_id=slip.container_id,
                    author_id=slip.author_id,
                    text_content=slip.text_content,
                    created_at=slip.created_at,
                    location_data=slip.location_data,
                    author_username=author.username if author else None,
                    author_email=author.email if author else None
                )
            )

        return responses

    def get_user_slips(
        self,
        author_id: int,
        current_user_id: int,
        skip: int = 0,
        limit: int = 50
    ) -> List[SlipResponse]:
        """
        Get all slips by a user
        - Returns only slips in containers current_user has access to
        """
        # Get all slips by author
        slips = self.slip_repo.get_by_author(author_id, skip, limit)

        # Filter by access and build responses
        responses = []
        author = self.user_repo.get_by_id(author_id)

        for slip in slips:
            # Check if current user has access to this slip's container
            if self.membership_repo.is_member(current_user_id, slip.container_id):
                responses.append(
                    SlipResponse(
                        slip_id=slip.slip_id,
                        container_id=slip.container_id,
                        author_id=slip.author_id,
                        text_content=slip.text_content,
                        created_at=slip.created_at,
                        location_data=slip.location_data,
                        author_username=author.username if author else None,
                        author_email=author.email if author else None
                    )
                )

        return responses

    def update_slip(
        self,
        slip_id: int,
        slip_data: SlipUpdate,
        user_id: int
    ) -> SlipResponse:
        """
        Update slip
        - Only author can update
        """
        slip = self.slip_repo.get_by_id(slip_id)
        if not slip:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Slip not found"
            )

        # Only author can update
        if slip.author_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the author can update this slip"
            )

        # Update slip
        updated_slip = self.slip_repo.update(slip_id, slip_data)
        if not updated_slip:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update slip"
            )

        # Get author info
        author = self.user_repo.get_by_id(updated_slip.author_id)

        return SlipResponse(
            slip_id=updated_slip.slip_id,
            container_id=updated_slip.container_id,
            author_id=updated_slip.author_id,
            text_content=updated_slip.text_content,
            created_at=updated_slip.created_at,
            location_data=updated_slip.location_data,
            author_username=author.username if author else None,
            author_email=author.email if author else None
        )

    def delete_slip(self, slip_id: int, user_id: int) -> dict:
        """
        Delete slip
        - Author or container admin can delete
        """
        slip = self.slip_repo.get_by_id(slip_id)
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
                detail="Only the author or container admin can delete this slip"
            )

        # Delete slip
        success = self.slip_repo.delete(slip_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to delete slip"
            )

        return {"message": "Slip deleted successfully"}
