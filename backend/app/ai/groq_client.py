"""
GROQ AI Client
"""
from typing import List, Optional
from groq import Groq
from app.core.config import settings


class GroqClient:
    def __init__(self):
        self.client = None
        if settings.GROQ_API_KEY:
            self.client = Groq(api_key=settings.GROQ_API_KEY)
        self.model = "llama3-8b-8192"  # GROQ free tier model

    async def chat(
        self,
        message: str,
        system_prompt: str,
        context: Optional[List[dict]] = None,
    ) -> str:
        """Send a message to GROQ and get a response"""
        if not self.client:
            return "AI service is not configured. Please add your GROQ API key."

        messages = [{"role": "system", "content": system_prompt}]

        # Add context
        if context:
            for msg in context[-10:]:  # Last 10 messages for context
                messages.append({"role": msg["role"], "content": msg["content"]})

        # Add current message
        messages.append({"role": "user", "content": message})

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.7,
                max_tokens=1024,
            )
            return response.choices[0].message.content
        except Exception as e:
            return f"I'm having trouble responding right now. Please try again. Error: {str(e)}"
