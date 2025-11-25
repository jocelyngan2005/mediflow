# Env vars (JamAI Token, Project ID) 
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    JAMAI_API_KEY: str
    JAMAI_PROJECT_ID: str
    
    # Table IDs (From your JamAI Dashboard)
    KNOWLEDGE_TABLE_SOP: str = "sop-knowledge-table"
    KNOWLEDGE_TABLE_MEDS: str = "meds-knowledge-table"
    ACTION_TABLE_TRIAGE: str = "triage-action-table"

    class Config:
        env_file = ".env"

settings = Settings()