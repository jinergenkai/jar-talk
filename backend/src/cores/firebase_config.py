import firebase_admin
from firebase_admin import credentials, auth
from .config import settings
import os


firebase_app = None


def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    global firebase_app

    if firebase_app is not None:
        return firebase_app

    try:
        if settings.FIREBASE_CREDENTIALS_PATH and os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_app = firebase_admin.initialize_app(cred)
            print("Firebase initialized successfully with credentials file")
        else:
            # Initialize with default credentials (for cloud deployment)
            firebase_app = firebase_admin.initialize_app()
            print("Firebase initialized with default credentials")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        raise

    return firebase_app


def verify_firebase_token(token: str) -> dict:
    """Verify Firebase ID token and return decoded token"""
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise ValueError(f"Invalid token: {str(e)}")


def get_firebase_user(uid: str):
    """Get Firebase user by UID"""
    try:
        return auth.get_user(uid)
    except Exception as e:
        raise ValueError(f"User not found: {str(e)}")
