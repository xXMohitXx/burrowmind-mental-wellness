"""
Support API endpoints
"""
from fastapi import APIRouter
from pydantic import BaseModel, EmailStr
from typing import Optional

router = APIRouter()


class ContactRequest(BaseModel):
    email: EmailStr
    subject: str
    message: str


class FeedbackRequest(BaseModel):
    type: str  # 'bug', 'feature', 'general'
    message: str
    rating: Optional[int] = None


class MessageResponse(BaseModel):
    message: str
    ticket_id: Optional[str] = None


@router.post("/contact", response_model=MessageResponse)
async def contact_support(request: ContactRequest):
    """Submit a contact request"""
    # TODO: Implement actual ticket creation
    return MessageResponse(
        message="Your message has been received. We'll get back to you soon.",
        ticket_id="TKT-001",
    )


@router.post("/feedback", response_model=MessageResponse)
async def submit_feedback(request: FeedbackRequest):
    """Submit app feedback"""
    # TODO: Store feedback
    return MessageResponse(message="Thank you for your feedback!")


@router.get("/faq")
async def get_faq():
    """Get frequently asked questions"""
    return {
        "faqs": [
            {
                "question": "What is BurrowMind?",
                "answer": "BurrowMind is your personal AI-assisted mental wellness companion, designed for reflection, self-awareness, and emotional regulation.",
            },
            {
                "question": "Is my data private?",
                "answer": "Yes! Your data is stored locally on your device. We prioritize your privacy and do not share personal information.",
            },
            {
                "question": "Is the AI a therapist?",
                "answer": "No. BurrowMind's AI is designed for reflection and self-awareness, not therapy or medical advice. If you're in crisis, please contact a mental health professional.",
            },
        ]
    }
