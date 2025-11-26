# Medication Lookup, Admin (Protected)
from fastapi import APIRouter, Depends, HTTPException
from app.services.jamai_service import jamai_service
from app.api.dependencies import verify_staff_token # Simple auth function

router = APIRouter()

@router.get("/medication-lookup", dependencies=[Depends(verify_staff_token)])
async def lookup_medication(drug_name: str):
    """
    Protected endpoint. Only accessible with valid Staff Token.
    """
    result = await jamai_service.check_medication_stock(drug_name)
    return {"data": result}