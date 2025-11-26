# Schemas for Chat/FAQ 
from pydantic import BaseModel
from typing import Optional
from typing import Optional

class ChatRequest(BaseModel):
    clinic_id: str  # Required clinic identifier
    clinic_name: Optional[str] = None  # Optional clinic name for JamAI action tables
    message: str
    language: str = "BM"  # Default to Bahasa Malaysia if not specified

class ChatResponse(BaseModel):
    reply: str
    source_document: Optional[str] = None  # To show which PDF the answer came from