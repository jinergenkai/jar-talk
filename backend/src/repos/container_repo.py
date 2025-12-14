from sqlmodel import Session, select
from typing import Optional, List
from ..models.container import Container, ContainerCreate, ContainerUpdate


class ContainerRepository:
    """Repository for Container database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, container_id: int) -> Optional[Container]:
        """Get container by ID"""
        return self.session.get(Container, container_id)

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Container]:
        """Get all containers"""
        statement = select(Container).offset(skip).limit(limit)
        return list(self.session.exec(statement).all())

    def get_by_owner(self, owner_id: int) -> List[Container]:
        """Get all containers owned by a user"""
        statement = select(Container).where(Container.owner_id == owner_id)
        return list(self.session.exec(statement).all())

    def create(self, container_data: ContainerCreate, owner_id: int) -> Container:
        """Create a new container"""
        container = Container(
            **container_data.model_dump(),
            owner_id=owner_id
        )
        self.session.add(container)
        self.session.commit()
        self.session.refresh(container)
        return container

    def update(self, container_id: int, container_data: ContainerUpdate) -> Optional[Container]:
        """Update a container"""
        container = self.get_by_id(container_id)
        if not container:
            return None

        update_data = container_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(container, key, value)

        self.session.add(container)
        self.session.commit()
        self.session.refresh(container)
        return container

    def delete(self, container_id: int) -> bool:
        """Delete a container"""
        container = self.get_by_id(container_id)
        if not container:
            return False

        self.session.delete(container)
        self.session.commit()
        return True
