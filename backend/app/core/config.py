# Env vars (JamAI Token, Project ID) 
from pydantic_settings import BaseSettings

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

    class Config:
        env_file = ".env"
    
    def get_all_clinic_ids(self):
        """Return list of configured clinic IDs"""
        return ["cid_01_public", "cid_02_private", "cid_03_specialist"]

settings = Settings()