from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # App
    APP_NAME: str = "Jar Talk API"
    DEBUG: bool = False

    # Database
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = ""
    DB_NAME: str = "jar_talk"

    # Firebase (Backend chỉ cần credentials file)
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None

    # JWT
    SECRET_KEY: str = "your-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Storage (MinIO/S3)
    STORAGE_ENDPOINT: str = "192.168.0.101:9000"
    STORAGE_ACCESS_KEY: str = "admin"
    STORAGE_SECRET_KEY: str = "strongpassword123"
    STORAGE_BUCKET: str = "jar-talk"
    STORAGE_REGION: str = "us-east-1"
    STORAGE_USE_SSL: bool = False
    PRESIGNED_URL_EXPIRY: int = 3600  # 1 hour

    # CORS
    ALLOWED_ORIGINS: list = ["*"]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
