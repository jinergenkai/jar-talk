from sqlmodel import Session, select
from typing import Optional, List
from ..models.slip import Slip, SlipCreate, SlipUpdate


class SlipRepository:
    """Repository for Slip database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, slip_id: int) -> Optional[Slip]:
        """Get slip by ID"""
        return self.session.get(Slip, slip_id)

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Slip]:
        """Get all slips"""
        statement = select(Slip).offset(skip).limit(limit).order_by(Slip.created_at.desc())
        return list(self.session.exec(statement).all())

    def get_by_container(self, container_id: int, skip: int = 0, limit: int = 100) -> List[Slip]:
        """Get all slips in a container"""
        statement = (
            select(Slip)
            .where(Slip.container_id == container_id)
            .order_by(Slip.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(self.session.exec(statement).all())

    def get_by_author(self, author_id: int, skip: int = 0, limit: int = 100) -> List[Slip]:
        """Get all slips by an author"""
        statement = (
            select(Slip)
            .where(Slip.author_id == author_id)
            .order_by(Slip.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return list(self.session.exec(statement).all())

    def create(self, slip_data: SlipCreate, author_id: int) -> Slip:
        """Create a new slip"""
        slip = Slip(
            **slip_data.model_dump(),
            author_id=author_id
        )
        self.session.add(slip)
        self.session.commit()
        self.session.refresh(slip)
        return slip

    def update(self, slip_id: int, slip_data: SlipUpdate) -> Optional[Slip]:
        """Update a slip"""
        slip = self.get_by_id(slip_id)
        if not slip:
            return None

        update_data = slip_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(slip, key, value)

        self.session.add(slip)
        self.session.commit()
        self.session.refresh(slip)
        return slip

    def delete(self, slip_id: int) -> bool:
        """Delete a slip"""
        slip = self.get_by_id(slip_id)
        if not slip:
            return False

        self.session.delete(slip)
        self.session.commit()
        return True

    def count_by_container(self, container_id: int) -> int:
        """Count slips in a container"""
        statement = select(Slip).where(Slip.container_id == container_id)
        return len(list(self.session.exec(statement).all()))
