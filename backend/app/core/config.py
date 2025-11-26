# Env vars (JamAI Token, Project ID) 
from pydantic_settings import BaseSettings
from typing import Dict, Any
import json
import os

class Settings(BaseSettings):
    JAMAI_API_KEY: str
    JAMAI_PROJECT_ID: str
    JAMAI_BASE_URL: str = "https://api.jamaibase.com"
    
    # Shared Action Tables (used by all clinics)
    KNOWLEDGE_TABLE_SOP: str = "sop-knowledge-table"
    KNOWLEDGE_TABLE_MEDS: str = "meds-knowledge-table"
    ACTION_TABLE_TRIAGE: str = "Appointment Booking"
    ACTION_TABLE_LOOKUP: str = "Medical Lookup"
    ACTION_TABLE_SOP_QNA: str = "SOP QnA"
    
    # Security
    CLINIC_SECRET_CODE: str = "MEDIFLOW2025"
    
    # Multi-clinic configuration
    # This can be overridden by environment variable CLINIC_CONFIGS as JSON string
    CLINIC_CONFIGS: str = "{}"

    class Config:
        env_file = ".env"
    
    def get_clinic_config(self, clinic_id: str) -> Dict[str, str]:
        """Get clinic-specific table configuration"""
        try:
            clinic_configs = json.loads(self.CLINIC_CONFIGS) if self.CLINIC_CONFIGS else {}
        except json.JSONDecodeError:
            clinic_configs = {}
            
        # Default configuration if clinic not found
        # Aligned with the 3 action tables in JamAI Base project
        default_config = {
            "knowledge_table_sop": f"{clinic_id}-sop-knowledge",
            "knowledge_table_meds": f"{clinic_id}-meds-knowledge", 
            "knowledge_table_faqs": f"{clinic_id}-faqs-knowledge",
            "action_table_appointment_booking": f"{clinic_id}-appointment-booking",
            "action_table_pdf_sop_answering": f"{clinic_id}-pdf-sop-answering",
            "action_table_medication_lookup": f"{clinic_id}-medication-lookup"
        }
        
        return clinic_configs.get(clinic_id, default_config)
    
    def get_all_clinic_ids(self) -> list:
        """Get list of all configured clinic IDs"""
        try:
            clinic_configs = json.loads(self.CLINIC_CONFIGS) if self.CLINIC_CONFIGS else {}
            return list(clinic_configs.keys())
        except json.JSONDecodeError:
            return []

settings = Settings()