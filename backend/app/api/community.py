"""
Community API endpoints
"""
from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()


class CommunityPost(BaseModel):
    id: str
    author_name: str
    author_avatar: Optional[str] = None
    content: str
    image_url: Optional[str] = None
    likes_count: int = 0
    comments_count: int = 0
    created_at: str


# Sample data
SAMPLE_POSTS = [
    CommunityPost(
        id="p1",
        author_name="Anonymous User",
        content="Today I practiced gratitude for 5 minutes. Small wins matter! 🌱",
        likes_count=24,
        comments_count=3,
        created_at="2024-01-15T10:30:00Z",
    ),
    CommunityPost(
        id="p2",
        author_name="Wellness Warrior",
        content="Completed my first week of daily meditation. The journey begins!",
        likes_count=42,
        comments_count=8,
        created_at="2024-01-14T15:45:00Z",
    ),
]


@router.get("/posts", response_model=List[CommunityPost])
async def get_posts(limit: int = 20, offset: int = 0):
    """Get community posts (read-only in v1)"""
    return SAMPLE_POSTS[offset : offset + limit]


@router.get("/posts/{post_id}", response_model=CommunityPost)
async def get_post(post_id: str):
    """Get a specific post by ID"""
    for post in SAMPLE_POSTS:
        if post.id == post_id:
            return post
    return {"error": "Post not found"}
