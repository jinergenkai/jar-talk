from sqlmodel import Field, SQLModel
from datetime import datetime
from typing import Optional
from enum import Enum


class MediaType(str, Enum):
    """Media types"""
    IMAGE = "image"
    AUDIO = "audio"


class Media(SQLModel, table=True):
    """
    Media - Images or audio attached to slips
    """
    __tablename__ = "media"

    media_id: Optional[int] = Field(default=None, primary_key=True)
    slip_id: int = Field(foreign_key="slip.slip_id")
    media_type: str = Field(max_length=50)  # 'image' or 'audio'
    storage_url: str = Field(max_length=500)  # S3/MinIO file key
    caption: Optional[str] = Field(default=None, max_length=500)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class MediaCreate(SQLModel):
    """Schema for creating media"""
    slip_id: int
    media_type: str
    storage_url: str  # File key from upload
    caption: Optional[str] = None


class MediaUpdate(SQLModel):
    """Schema for updating media"""
    caption: Optional[str] = None


class MediaResponse(SQLModel):
    """Schema for media response"""
    media_id: int
    slip_id: int
    media_type: str
    storage_url: str
    caption: Optional[str] = None
    created_at: datetime
    # Presigned download URL (generated on-the-fly)
    download_url: Optional[str] = None


class UploadUrlRequest(SQLModel):
    """Request for upload URL"""
    file_type: str  # 'image' or 'audio'
    content_type: str  # MIME type: 'image/jpeg', 'audio/mp3', etc.


class UploadUrlResponse(SQLModel):
    """Response with presigned upload URL"""
    upload_url: str
    file_key: str
    content_type: str
    expires_in: int
