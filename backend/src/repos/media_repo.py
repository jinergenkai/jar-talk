from sqlmodel import Session, select
from typing import Optional, List
from ..models.media import Media, MediaCreate, MediaUpdate


class MediaRepository:
    """Repository for Media database operations"""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, media_id: int) -> Optional[Media]:
        """Get media by ID"""
        return self.session.get(Media, media_id)

    def get_by_slip(self, slip_id: int) -> List[Media]:
        """Get all media for a slip"""
        statement = select(Media).where(Media.slip_id == slip_id).order_by(Media.created_at)
        return list(self.session.exec(statement).all())

    def create(self, media_data: MediaCreate) -> Media:
        """Create new media"""
        media = Media(**media_data.model_dump())
        self.session.add(media)
        self.session.commit()
        self.session.refresh(media)
        return media

    def update(self, media_id: int, media_data: MediaUpdate) -> Optional[Media]:
        """Update media"""
        media = self.get_by_id(media_id)
        if not media:
            return None

        update_data = media_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(media, key, value)

        self.session.add(media)
        self.session.commit()
        self.session.refresh(media)
        return media

    def delete(self, media_id: int) -> bool:
        """Delete media"""
        media = self.get_by_id(media_id)
        if not media:
            return False

        self.session.delete(media)
        self.session.commit()
        return True

    def count_by_slip(self, slip_id: int) -> int:
        """Count media for a slip"""
        statement = select(Media).where(Media.slip_id == slip_id)
        return len(list(self.session.exec(statement).all()))
