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

    # CORS
    ALLOWED_ORIGINS: list = ["*"]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
