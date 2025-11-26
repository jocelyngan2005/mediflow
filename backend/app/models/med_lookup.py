# for the protected Medication Lookup (Staff only) 
from pydantic import BaseModel
from typing import Optional

class MedLookupRequest(BaseModel):
    clinic_id: str  # Required clinic identifier
    clinic_name: Optional[str] = None  # Optional clinic name for JamAI action tables
    drug_name: str

class MedLookupResponse(BaseModel):
    drug_entry: str  # JSON format from action table
    medication_message: str  # Human-readable message from action table
    
# Legacy response format for backward compatibility    
class LegacyMedLookupResponse(BaseModel):
    drug_name: str
    stock_count: str  # Kept as string to handle "Low", "10 boxes", etc.
    location: str     
    price: str
    raw_context: str  # The raw text found in the CSV for verification
