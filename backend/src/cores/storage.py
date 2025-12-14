"""
Storage service for MinIO (S3-compatible)
Handles file upload/download with presigned URLs
"""
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError
from .config import settings
import uuid
from datetime import timedelta
from typing import Optional


class StorageService:
    """MinIO/S3 storage service with presigned URLs"""

    def __init__(self):
        # Initialize S3 client for MinIO
        self.s3_client = boto3.client(
            's3',
            endpoint_url=f"http://{settings.STORAGE_ENDPOINT}",
            aws_access_key_id=settings.STORAGE_ACCESS_KEY,
            aws_secret_access_key=settings.STORAGE_SECRET_KEY,
            region_name=settings.STORAGE_REGION,
            config=Config(signature_version='s3v4')
        )
        self.bucket_name = settings.STORAGE_BUCKET
        self._ensure_bucket_exists()

    def _ensure_bucket_exists(self):
        """Create bucket if it doesn't exist"""
        try:
            self.s3_client.head_bucket(Bucket=self.bucket_name)
            print(f"✅ Bucket '{self.bucket_name}' exists")
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == '404':
                # Bucket doesn't exist, create it
                try:
                    self.s3_client.create_bucket(Bucket=self.bucket_name)
                    print(f"✅ Created bucket '{self.bucket_name}'")
                except Exception as create_error:
                    print(f"❌ Failed to create bucket: {create_error}")
            else:
                print(f"❌ Error checking bucket: {e}")

    def generate_upload_url(
        self,
        file_type: str,
        content_type: str,
        expires_in: int = None
    ) -> dict:
        """
        Generate presigned URL for uploading file

        Args:
            file_type: Type of file ('image' or 'audio')
            content_type: MIME type (e.g., 'image/jpeg', 'audio/mp3')
            expires_in: URL expiry in seconds (default: 1 hour)

        Returns:
            {
                "upload_url": "presigned URL for upload",
                "file_key": "path/to/file in storage",
                "expires_in": seconds
            }
        """
        if expires_in is None:
            expires_in = settings.PRESIGNED_URL_EXPIRY

        # Generate unique file key
        file_extension = self._get_extension_from_content_type(content_type)
        file_key = f"{file_type}/{uuid.uuid4()}{file_extension}"

        try:
            # Generate presigned URL for PUT
            upload_url = self.s3_client.generate_presigned_url(
                'put_object',
                Params={
                    'Bucket': self.bucket_name,
                    'Key': file_key,
                    'ContentType': content_type
                },
                ExpiresIn=expires_in
            )

            return {
                "upload_url": upload_url,
                "file_key": file_key,
                "content_type": content_type,
                "expires_in": expires_in
            }
        except ClientError as e:
            print(f"Error generating upload URL: {e}")
            raise Exception(f"Failed to generate upload URL: {str(e)}")

    def generate_download_url(
        self,
        file_key: str,
        expires_in: int = None
    ) -> str:
        """
        Generate presigned URL for downloading file

        Args:
            file_key: File path in storage
            expires_in: URL expiry in seconds (default: 1 hour)

        Returns:
            Presigned URL for download
        """
        if expires_in is None:
            expires_in = settings.PRESIGNED_URL_EXPIRY

        try:
            download_url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={
                    'Bucket': self.bucket_name,
                    'Key': file_key
                },
                ExpiresIn=expires_in
            )
            return download_url
        except ClientError as e:
            print(f"Error generating download URL: {e}")
            raise Exception(f"Failed to generate download URL: {str(e)}")

    def delete_file(self, file_key: str) -> bool:
        """
        Delete file from storage

        Args:
            file_key: File path in storage

        Returns:
            True if successful
        """
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=file_key
            )
            print(f"✅ Deleted file: {file_key}")
            return True
        except ClientError as e:
            print(f"Error deleting file: {e}")
            return False

    def file_exists(self, file_key: str) -> bool:
        """Check if file exists in storage"""
        try:
            self.s3_client.head_object(
                Bucket=self.bucket_name,
                Key=file_key
            )
            return True
        except ClientError:
            return False

    def _get_extension_from_content_type(self, content_type: str) -> str:
        """Get file extension from MIME type"""
        mime_to_ext = {
            # Images
            'image/jpeg': '.jpg',
            'image/jpg': '.jpg',
            'image/png': '.png',
            'image/gif': '.gif',
            'image/webp': '.webp',
            'image/svg+xml': '.svg',
            # Audio
            'audio/mpeg': '.mp3',
            'audio/mp3': '.mp3',
            'audio/wav': '.wav',
            'audio/ogg': '.ogg',
            'audio/aac': '.aac',
            'audio/m4a': '.m4a',
            # Video (future)
            'video/mp4': '.mp4',
            'video/webm': '.webm',
        }
        return mime_to_ext.get(content_type.lower(), '')


# Global storage instance
storage_service = StorageService()
