# Schemas for Appointments 
from pydantic import BaseModel
from typing import Optional
from typing import List, Optional

class TriageRequest(BaseModel):
    clinic_id: str  # Required clinic identifier
    clinic_name: Optional[str] = None  # Optional clinic name for JamAI action tables
    symptoms: str
    patient_age: Optional[int] = None
    is_emergency: bool = False

class TriageResponse(BaseModel):
    assessment_summary: str
    urgency_level: str  # 
    suggested_specialty: str  # e.g., "General", "Pediatrics", "Trauma"
    available_slots: List[str] = []