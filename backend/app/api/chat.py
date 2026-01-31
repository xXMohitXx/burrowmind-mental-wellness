"""
AI Chat API endpoints
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from app.ai.groq_client import GroqClient
from app.ai.prompt_engine import PromptEngine
from app.ai.risk_classifier import RiskClassifier

router = APIRouter()
groq_client = GroqClient()
prompt_engine = PromptEngine()
risk_classifier = RiskClassifier()


class ChatMessage(BaseModel):
    role: str  # 'user' or 'assistant'
    content: str


class ChatRequest(BaseModel):
    message: str
    session_id: str
    context: Optional[List[ChatMessage]] = None


class ChatResponse(BaseModel):
    message: str
    session_id: str
    safety_flag: Optional[str] = None


class SafetyCheckRequest(BaseModel):
    message: str


class SafetyCheckResponse(BaseModel):
    is_safe: bool
    risk_level: str
    concerns: List[str]


@router.post("/send", response_model=ChatResponse)
async def send_message(request: ChatRequest):
    """Send a message to the AI companion"""
    try:
        # Check for safety concerns
        risk_result = risk_classifier.analyze(request.message)
        
        if risk_result["risk_level"] == "high":
            # Return safety response instead
            return ChatResponse(
                message=prompt_engine.get_safety_response(risk_result),
                session_id=request.session_id,
                safety_flag="escalation_detected",
            )

        # Build prompt with context
        system_prompt = prompt_engine.build_prompt(
            context=request.context or [],
            risk_level=risk_result["risk_level"],
        )

        # Get AI response
        response = await groq_client.chat(
            message=request.message,
            system_prompt=system_prompt,
            context=request.context or [],
        )

        return ChatResponse(
            message=response,
            session_id=request.session_id,
            safety_flag=risk_result.get("flag"),
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/safety-check", response_model=SafetyCheckResponse)
async def safety_check(request: SafetyCheckRequest):
    """Check a message for safety concerns"""
    result = risk_classifier.analyze(request.message)
    return SafetyCheckResponse(
        is_safe=result["risk_level"] == "low",
        risk_level=result["risk_level"],
        concerns=result.get("concerns", []),
    )


@router.get("/context/{session_id}")
async def get_context(session_id: str, limit: int = 10):
    """Get conversation context for a session"""
    # TODO: Implement actual context retrieval from database
    return {"session_id": session_id, "messages": [], "limit": limit}
