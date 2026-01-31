"""
Resources API endpoints
"""
from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()


class Resource(BaseModel):
    id: str
    type: str  # 'article' or 'course'
    title: str
    description: Optional[str] = None
    thumbnail_url: Optional[str] = None
    category: str
    author: Optional[str] = None
    duration_minutes: Optional[int] = None


# Sample data
SAMPLE_ARTICLES = [
    Resource(
        id="1",
        type="article",
        title="Understanding Anxiety: A Beginner's Guide",
        description="Learn about the basics of anxiety and how to manage it.",
        category="Mental Health",
        author="Dr. Sarah Johnson",
    ),
    Resource(
        id="2",
        type="article",
        title="The Power of Mindful Breathing",
        description="Discover how breathing exercises can reduce stress.",
        category="Mindfulness",
        author="Michael Chen",
    ),
]

SAMPLE_COURSES = [
    Resource(
        id="c1",
        type="course",
        title="7-Day Meditation Challenge",
        description="Start your mindfulness journey with this beginner course.",
        category="Meditation",
        duration_minutes=70,
    ),
    Resource(
        id="c2",
        type="course",
        title="Sleep Better Tonight",
        description="Improve your sleep quality with proven techniques.",
        category="Sleep",
        duration_minutes=45,
    ),
]


@router.get("/articles", response_model=List[Resource])
async def get_articles(category: Optional[str] = None, limit: int = 20):
    """Get articles, optionally filtered by category"""
    if category:
        return [a for a in SAMPLE_ARTICLES if a.category.lower() == category.lower()]
    return SAMPLE_ARTICLES[:limit]


@router.get("/articles/{article_id}", response_model=Resource)
async def get_article(article_id: str):
    """Get a specific article by ID"""
    for article in SAMPLE_ARTICLES:
        if article.id == article_id:
            return article
    return {"error": "Article not found"}


@router.get("/courses", response_model=List[Resource])
async def get_courses(category: Optional[str] = None, limit: int = 20):
    """Get courses, optionally filtered by category"""
    if category:
        return [c for c in SAMPLE_COURSES if c.category.lower() == category.lower()]
    return SAMPLE_COURSES[:limit]


@router.get("/courses/{course_id}", response_model=Resource)
async def get_course(course_id: str):
    """Get a specific course by ID"""
    for course in SAMPLE_COURSES:
        if course.id == course_id:
            return course
    return {"error": "Course not found"}
