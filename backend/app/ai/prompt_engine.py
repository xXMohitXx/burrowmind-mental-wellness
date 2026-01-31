"""
Prompt Engine for AI Conversations
"""
from typing import List, Optional


class PromptEngine:
    """Builds dynamic prompts for the AI companion"""

    def __init__(self):
        self.identity = """You are BurrowMind, a warm and supportive mental wellness companion. 
You help users with reflection, self-awareness, and emotional regulation.
You are NOT a therapist, doctor, or medical professional.
You do NOT diagnose, prescribe, or provide medical advice."""

        self.tone = """Speak in a calm, grounded, and supportive tone.
Be empathetic but not overly emotional.
Use short, clear sentences.
Ask open-ended questions to encourage reflection.
Celebrate small wins and progress."""

        self.safety = """CRITICAL SAFETY RULES:
1. NEVER diagnose mental health conditions
2. NEVER suggest medications or treatments
3. NEVER claim to be a therapist or medical professional
4. If user mentions self-harm, suicide, or crisis - immediately provide crisis resources
5. Do not create emotional dependency - encourage real-world support
6. Always remind users that professional help is valuable for serious concerns"""

        self.crisis_resources = """Crisis Resources:
- National Suicide Prevention Lifeline: 988
- Crisis Text Line: Text HOME to 741741
- International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/
Please reach out to a mental health professional or call a crisis line if you're in distress."""

    def build_prompt(
        self,
        context: List[dict],
        risk_level: str = "low",
        user_mood: Optional[str] = None,
    ) -> str:
        """Build a complete system prompt"""
        prompt_parts = [self.identity, self.tone, self.safety]

        # Add context layer
        if context:
            recent_topics = self._extract_topics(context)
            if recent_topics:
                prompt_parts.append(
                    f"Recent conversation topics: {', '.join(recent_topics)}"
                )

        # Add mood-aware layer
        if user_mood:
            prompt_parts.append(f"The user's current mood appears to be: {user_mood}")

        # Add escalation layer for medium risk
        if risk_level == "medium":
            prompt_parts.append(
                """The user may be experiencing some distress. 
Be extra gentle and empathetic.
Suggest grounding techniques if appropriate.
Gently remind them of available professional resources."""
            )

        return "\n\n".join(prompt_parts)

    def get_safety_response(self, risk_result: dict) -> str:
        """Get a safety response for high-risk situations"""
        response = """I hear that you're going through a really difficult time. 
Your feelings are valid, and I want you to know that support is available.

If you're in crisis or having thoughts of harming yourself, please reach out to:
• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741

These are trained professionals who can provide immediate support.

I'm here for gentle reflection and conversation, but what you're experiencing deserves care from a professional who can truly help. Is there someone in your life you can reach out to right now?"""

        return response

    def _extract_topics(self, context: List[dict]) -> List[str]:
        """Extract topics from recent conversation"""
        # Simple topic extraction - can be enhanced
        topics = set()
        keywords = [
            "work",
            "family",
            "sleep",
            "anxiety",
            "stress",
            "relationship",
            "health",
            "exercise",
        ]

        for msg in context[-5:]:
            content = msg.get("content", "").lower()
            for keyword in keywords:
                if keyword in content:
                    topics.add(keyword)

        return list(topics)[:3]
