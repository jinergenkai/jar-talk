from sqlmodel import Session
from fastapi import HTTPException, status
from typing import List

from ..models.container import Container, ContainerCreate, ContainerUpdate, ContainerResponse
from ..models.membership import MembershipCreate, MemberRole
from ..repos.container_repo import ContainerRepository
from ..repos.membership_repo import MembershipRepository


class ContainerService:
    """Service for container business logic"""

    def __init__(self, session: Session):
        self.session = session
        self.container_repo = ContainerRepository(session)
        self.membership_repo = MembershipRepository(session)

    def create_container(self, container_data: ContainerCreate, owner_id: int) -> ContainerResponse:
        """
        Create a new container
        - Creates the container
        - Automatically adds creator as admin member
        """
        # Create container
        container = self.container_repo.create(container_data, owner_id)

        # Add creator as admin
        membership_data = MembershipCreate(
            user_id=owner_id,
            container_id=container.container_id,
            role=MemberRole.ADMIN.value
        )
        self.membership_repo.create(membership_data)

        return ContainerResponse(
            container_id=container.container_id,
            name=container.name,
            owner_id=container.owner_id,
            jar_style_settings=container.jar_style_settings,
            created_at=container.created_at,
            user_role=MemberRole.ADMIN.value,
            member_count=1
        )

    def get_container(self, container_id: int, user_id: int) -> ContainerResponse:
        """
        Get container by ID
        - Checks user has access to this container
        """
        container = self.container_repo.get_by_id(container_id)
        if not container:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Container not found"
            )

        # Check access
        membership = self.membership_repo.get_user_membership(user_id, container_id)
        if not membership:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have access to this container"
            )

        # Get member count
        members = self.membership_repo.get_container_members(container_id)

        return ContainerResponse(
            container_id=container.container_id,
            name=container.name,
            owner_id=container.owner_id,
            jar_style_settings=container.jar_style_settings,
            created_at=container.created_at,
            user_role=membership.role,
            member_count=len(members)
        )

    def get_user_containers(self, user_id: int) -> List[ContainerResponse]:
        """Get all containers user is member of"""
        memberships = self.membership_repo.get_user_containers(user_id)

        containers = []
        for membership in memberships:
            container = self.container_repo.get_by_id(membership.container_id)
            if container:
                members = self.membership_repo.get_container_members(container.container_id)
                containers.append(
                    ContainerResponse(
                        container_id=container.container_id,
                        name=container.name,
                        owner_id=container.owner_id,
                        jar_style_settings=container.jar_style_settings,
                        created_at=container.created_at,
                        user_role=membership.role,
                        member_count=len(members)
                    )
                )

        return containers

    def update_container(
        self,
        container_id: int,
        container_data: ContainerUpdate,
        user_id: int
    ) -> ContainerResponse:
        """
        Update container
        - Only admin can update
        """
        # Check if user is admin
        if not self.membership_repo.is_admin(user_id, container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only admins can update container"
            )

        container = self.container_repo.update(container_id, container_data)
        if not container:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Container not found"
            )

        members = self.membership_repo.get_container_members(container_id)
        membership = self.membership_repo.get_user_membership(user_id, container_id)

        return ContainerResponse(
            container_id=container.container_id,
            name=container.name,
            owner_id=container.owner_id,
            jar_style_settings=container.jar_style_settings,
            created_at=container.created_at,
            user_role=membership.role if membership else None,
            member_count=len(members)
        )

    def delete_container(self, container_id: int, user_id: int) -> dict:
        """
        Delete container
        - Only owner can delete
        """
        container = self.container_repo.get_by_id(container_id)
        if not container:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Container not found"
            )

        # Only owner can delete
        if container.owner_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only owner can delete container"
            )

        # Delete container (memberships and slips will be deleted by CASCADE)
        success = self.container_repo.delete(container_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to delete container"
            )

        return {"message": "Container deleted successfully"}

    def add_member(self, container_id: int, member_user_id: int, current_user_id: int, role: str = MemberRole.MEMBER.value) -> dict:
        """
        Add member to container
        - Only admin can add members
        """
        # Check if current user is admin
        if not self.membership_repo.is_admin(current_user_id, container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only admins can add members"
            )

        # Check if already member
        if self.membership_repo.is_member(member_user_id, container_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already a member"
            )

        # Add member
        membership_data = MembershipCreate(
            user_id=member_user_id,
            container_id=container_id,
            role=role
        )
        membership = self.membership_repo.create(membership_data)

        return {
            "message": "Member added successfully",
            "membership": membership.model_dump()
        }

    def remove_member(self, container_id: int, member_user_id: int, current_user_id: int) -> dict:
        """
        Remove member from container
        - Admin can remove members
        - Users can remove themselves
        """
        # Check if removing self
        if member_user_id == current_user_id:
            # User removing themselves
            membership = self.membership_repo.get_user_membership(member_user_id, container_id)
            if membership:
                self.membership_repo.delete(membership.participant_id)
                return {"message": "You left the container"}
            else:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="You are not a member of this container"
                )

        # Removing someone else - must be admin
        if not self.membership_repo.is_admin(current_user_id, container_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only admins can remove members"
            )

        membership = self.membership_repo.get_user_membership(member_user_id, container_id)
        if not membership:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User is not a member"
            )

        self.membership_repo.delete(membership.participant_id)
        return {"message": "Member removed successfully"}
