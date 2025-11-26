# Clinic management models
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class Clinic(BaseModel):
    clinic_id: str
    name: str
    address: str
    phone: str
    email: Optional[str] = None
    operating_hours: str
    languages_supported: List[str] = ["BM", "EN"]
    services: List[str] = []
    is_active: bool = True
    
class ClinicResponse(BaseModel):
    clinic_id: str
    name: str
    address: str
    phone: str
    email: Optional[str] = None
    operating_hours: str
    languages_supported: List[str]
    services: List[str]
    is_active: bool

class ClinicRequest(BaseModel):
    name: str
    address: str
    phone: str
    email: Optional[str] = None
    operating_hours: str
    languages_supported: List[str] = ["BM", "EN"]
    services: List[str] = []

class ClinicTableConfig(BaseModel):
    """Configuration for clinic-specific JamAI tables"""
    clinic_id: str
    knowledge_table_sop: str
    knowledge_table_meds: str
    knowledge_table_faqs: str
    # The 3 Action Tables from JamAI Base
    action_table_appointment_booking: str      # A. Appointment Booking
    action_table_pdf_sop_answering: str       # B. PDF/SOP Answering  
    action_table_medication_lookup: str       # C. Medication Lookup (staff only)