"""
Authentication API endpoints
"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
)

router = APIRouter()


# Request/Response Models
class UserRegister(BaseModel):
    email: EmailStr
    password: str
    display_name: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class MessageResponse(BaseModel):
    message: str


# In-memory user store (replace with database in production)
fake_users_db: dict = {}


@router.post("/register", response_model=TokenResponse)
async def register(user: UserRegister):
    """Register a new user"""
    if user.email in fake_users_db:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    hashed_password = get_password_hash(user.password)
    fake_users_db[user.email] = {
        "email": user.email,
        "hashed_password": hashed_password,
        "display_name": user.display_name,
    }

    access_token = create_access_token(data={"sub": user.email})
    refresh_token = create_refresh_token(data={"sub": user.email})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )


@router.post("/login", response_model=TokenResponse)
async def login(user: UserLogin):
    """Login with email and password"""
    db_user = fake_users_db.get(user.email)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not verify_password(user.password, db_user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    access_token = create_access_token(data={"sub": user.email})
    refresh_token = create_refresh_token(data={"sub": user.email})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )


@router.post("/forgot-password", response_model=MessageResponse)
async def forgot_password(email: EmailStr):
    """Request password reset"""
    # TODO: Implement actual email sending
    return MessageResponse(message="Password reset email sent if account exists")


@router.post("/logout", response_model=MessageResponse)
async def logout():
    """Logout user (client should discard tokens)"""
    return MessageResponse(message="Logged out successfully")
