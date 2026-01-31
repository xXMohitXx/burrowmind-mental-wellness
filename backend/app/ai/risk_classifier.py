"""
Risk Classifier for AI Safety
"""
import re
from typing import Dict, List


class RiskClassifier:
    """Classifies message risk levels for safety filtering"""

    def __init__(self):
        # High-risk keywords (immediate escalation)
        self.high_risk_patterns = [
            r"\b(suicide|suicidal)\b",
            r"\b(kill myself|end my life|don't want to live)\b",
            r"\b(self.?harm|cutting|hurt myself)\b",
            r"\b(overdose|od)\b",
            r"\b(want to die|better off dead)\b",
        ]

        # Medium-risk keywords (gentle escalation)
        self.medium_risk_patterns = [
            r"\b(hopeless|no hope)\b",
            r"\b(worthless|useless)\b",
            r"\b(can't go on|give up)\b",
            r"\b(crisis|emergency)\b",
            r"\b(panic attack)\b",
            r"\b(abuse|abused)\b",
        ]

        # Topics to avoid (redirect)
        self.redirect_patterns = [
            r"\b(medication|prescription|dosage)\b",
            r"\b(diagnose|diagnosis)\b",
            r"\b(treatment plan)\b",
        ]

    def analyze(self, message: str) -> Dict:
        """Analyze a message for risk level"""
        message_lower = message.lower()
        concerns: List[str] = []

        # Check high-risk patterns
        for pattern in self.high_risk_patterns:
            if re.search(pattern, message_lower):
                concerns.append(f"High-risk content detected")
                return {
                    "risk_level": "high",
                    "concerns": concerns,
                    "flag": "crisis_escalation",
                    "action": "provide_resources",
                }

        # Check medium-risk patterns
        for pattern in self.medium_risk_patterns:
            if re.search(pattern, message_lower):
                concerns.append("Potential distress indicators")

        if concerns:
            return {
                "risk_level": "medium",
                "concerns": concerns,
                "flag": "distress_detected",
                "action": "gentle_support",
            }

        # Check redirect patterns
        for pattern in self.redirect_patterns:
            if re.search(pattern, message_lower):
                return {
                    "risk_level": "low",
                    "concerns": ["Medical topic detected"],
                    "flag": "redirect_needed",
                    "action": "redirect_to_professional",
                }

        # Default: low risk
        return {
            "risk_level": "low",
            "concerns": [],
            "flag": None,
            "action": "normal_response",
        }
