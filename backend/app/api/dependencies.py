# Auth logic (Patient vs Staff) 
from fastapi import Header, HTTPException, status
import os
from dotenv import load_dotenv

load_dotenv()

# In a real app, this would be in your config.py
# For now, we load it directly or set a default for the Hackathon
CLINIC_SECRET_CODE = os.getenv("CLINIC_SECRET_CODE", "MEDIFLOW-ADMIN-2024")

async def verify_staff_token(x_clinic_code: str = Header(..., description="The secret clinic passcode")):
    """
    Validates that the request comes from an authorized Clinic Staff member.
    Checks the 'X-Clinic-Code' header against the environment variable.
    """
    if x_clinic_code != CLINIC_SECRET_CODE:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Access Denied: Invalid Clinic Code. Staff access only.",
        )
    return True 