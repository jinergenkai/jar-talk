from sqlmodel import Session, select
from typing import Optional
from ..models.user import User, UserCreate


class UserRepository:
    """
    Repository for User database operations
    All users are authenticated via Firebase
    """

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return self.session.get(User, user_id)

    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        statement = select(User).where(User.email == email)
        return self.session.exec(statement).first()

    def get_by_username(self, username: str) -> Optional[User]:
        """Get user by username"""
        statement = select(User).where(User.username == username)
        return self.session.exec(statement).first()

    def get_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        """Get user by Firebase UID"""
        statement = select(User).where(User.firebase_uid == firebase_uid)
        return self.session.exec(statement).first()

    def create(self, user_data: UserCreate) -> User:
        """Create a new user"""
        user = User(**user_data.model_dump())
        self.session.add(user)
        self.session.commit()
        self.session.refresh(user)
        return user

    def update(self, user: User) -> User:
        """Update user"""
        self.session.add(user)
        self.session.commit()
        self.session.refresh(user)
        return user

    def delete(self, user_id: int) -> bool:
        """Delete user"""
        user = self.get_by_id(user_id)
        if user:
            self.session.delete(user)
            self.session.commit()
            return True
        return False

    def email_exists(self, email: str) -> bool:
        """Check if email already exists"""
        return self.get_by_email(email) is not None

    def username_exists(self, username: str) -> bool:
        """Check if username already exists"""
        return self.get_by_username(username) is not None
