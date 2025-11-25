# for the protected Medication Lookup (Staff only) 
from pydantic import BaseModel

class MedLookupRequest(BaseModel):
    drug_name: str

class MedLookupResponse(BaseModel):
    drug_name: str
    stock_count: str  # Kept as string to handle "Low", "10 boxes", etc.
    location: str     # e.g., "Shelf A2"
    price: str
    raw_context: str  # The raw text found in the CSV for verification
