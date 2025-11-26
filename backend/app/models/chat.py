# Schemas for Chat/FAQ 
from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    language: str = "BM"  # Default to Bahasa Malaysia if not specified
    history: Optional[list] = []  # To maintain conversation context if needed

class ChatResponse(BaseModel):
    reply: str
    source_document: Optional[str] = None  # To show which PDF the answer came from