# Schemas for Appointments 
from pydantic import BaseModel
from typing import List, Optional

class TriageRequest(BaseModel):
    symptoms: str
    patient_age: Optional[int] = None
    is_emergency: bool = False

class TriageResponse(BaseModel):
    assessment_summary: str
    urgency_level: str  # e.g., "Low", "Medium", "High (Go to Hospital)"
    suggested_specialty: str  # e.g., "General", "Pediatrics", "Trauma"
    available_slots: List[str] = []