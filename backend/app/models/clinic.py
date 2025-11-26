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