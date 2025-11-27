# Medication Lookup, Admin (Protected)
from fastapi import APIRouter, Depends, HTTPException, Query
from app.services.jamai_services import jamai_service
from app.api.dependencies import verify_staff_token
from app.models.med_lookup import MedLookupRequest, MedLookupResponse
from typing import List

def get_clinic_name_from_id(clinic_id: str, clinic_name: str = None) -> str:
    """
    Get clinic name for JamAI action tables.
    If clinic_name is provided, use it. Otherwise derive from clinic_id.
    """
    if clinic_name:
        return clinic_name
    
    # Default mapping - should match the one in patients.py
    clinic_name_mapping = {
        'clinic_001': 'Klinik Bandar Utama',
        'clinic_002': 'Klinik Dr. Ahmad',
        'clinic_003': 'Pusat Kesihatan Setapak',
        'clinic_004': 'Klinik Famili Wangsa Maju',
        # Legacy mappings for backward compatibility
        'klinik-bandar-utama': 'Klinik Bandar Utama',
        'klinik-sri-hartamas': 'Klinik Sri Hartamas', 
        'klinik-desa-jaya': 'Pusat Kesihatan Setapak',
        'klinik-wangsa': 'Klinik Famili Wangsa Maju',
        # Add more mappings as needed
    }
    
    return clinic_name_mapping.get(clinic_id, clinic_id.replace('-', ' ').title())

router = APIRouter()

@router.get("/medication-lookup", dependencies=[Depends(verify_staff_token)])
async def lookup_medication(
    clinic_id: str = Query(..., description="Clinic ID to search medication in"),
    drug_name: str = Query(..., description="Name of the medication to lookup"),
    clinic_name: str = Query(None, description="Optional clinic name for JamAI action tables")
):
    """
    Protected endpoint using Action Table C (Medication Lookup)
    Input: staff query about drug, clinic_name → Output: stock/price/alternatives response
    """
    try:
        resolved_clinic_name = get_clinic_name_from_id(clinic_id, clinic_name)
        user_input = f"Check stock and availability for {drug_name}"
        lookup_result = await jamai_service.medication_lookup_staff(
            clinic_name=resolved_clinic_name,
            user_input=user_input
        )
        return {
            "clinic_id": clinic_id,
            "clinic_name": resolved_clinic_name,
            "drug_name": drug_name,
            "drug_entry": lookup_result.get("drug_entry", "{}"),
            "medication_message": lookup_result.get("medication_message", "No information found"),
            "action_table_used": "medication_lookup"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error looking up medication: {str(e)}")

@router.post("/medication-lookup", dependencies=[Depends(verify_staff_token)])
async def lookup_medication_post(request: MedLookupRequest):
    """
    Protected endpoint using Action Table C (Medication Lookup) with POST method
    Supports more complex queries about medications
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        user_input = f"I need information about {request.drug_name} - check stock, price, and any alternatives available"
        lookup_result = await jamai_service.medication_lookup_staff(
            clinic_name=clinic_name,
            user_input=user_input
        )
        
        return {
            "clinic_id": request.clinic_id,
            "clinic_name": clinic_name,
            "drug_name": request.drug_name,
            "drug_entry": lookup_result.get("drug_entry", "{}"),
            "medication_message": lookup_result.get("medication_message", "No information found"),
            "action_table_used": "medication_lookup",
            "query_processed": user_input
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error looking up medication: {str(e)}")

@router.get("/clinics", dependencies=[Depends(verify_staff_token)])
async def get_staff_accessible_clinics():
    """
    Get list of clinics that staff can access.
    In a production system, this would be filtered based on staff permissions.
    """
    try:
        clinics = await jamai_service.get_available_clinics()
        return {
            "accessible_clinics": clinics,
            "note": "Staff access to all configured clinics"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching accessible clinics: {str(e)}")

@router.get("/clinic-status/{clinic_id}", dependencies=[Depends(verify_staff_token)])
async def get_clinic_status(clinic_id: str):
    """
    Get operational status and basic info for a specific clinic.
    This could include system health, table status, etc.
    """
    try:
        # In a real implementation, you might check if JamAI tables exist and are accessible
        clinic_config = jamai_service._get_clinic_tables(clinic_id)
        return {
            "clinic_id": clinic_id,
            "status": "operational",
            "configured_tables": clinic_config,
            "timestamp": "2024-11-26T00:00:00Z"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error checking clinic status: {str(e)}")

# Simple chat endpoint for staff assistant
@router.post("/chat")
async def staff_chat_message(request: dict):
    """
    Simple chat endpoint for staff assistant medication lookup
    No authentication for hackathon demo
    """
    try:
        clinic_id = request.get('clinic_id', '')
        message = request.get('message', '')
        
        resolved_clinic_name = get_clinic_name_from_id(clinic_id)
        lookup_result = await jamai_service.medication_lookup_staff(
            clinic_name=resolved_clinic_name,
            user_input=message
        )
        return {
            "clinic_id": clinic_id,
            "clinic_name": resolved_clinic_name,
            "drug_entry": lookup_result.get("drug_entry", "{}"),
            "medication_message": lookup_result.get("medication_message", "No information found"),
            "action_table_used": "medication_lookup"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing staff chat: {str(e)}")

# Admin endpoints for clinic management (future expansion)
@router.post("/medication-query", dependencies=[Depends(verify_staff_token)])
async def complex_medication_query(clinic_id: str, query: str, clinic_name: str = None):
    """
    Advanced medication queries using Action Table C
    Handles complex staff questions like "What alternatives do we have for Panadol?"
    """
    try:
        resolved_clinic_name = get_clinic_name_from_id(clinic_id, clinic_name)
        lookup_result = await jamai_service.medication_lookup_staff(
            clinic_name=resolved_clinic_name,
            user_input=query
        )
        return {
            "clinic_id": clinic_id,
            "clinic_name": resolved_clinic_name,
            "staff_query": query,
            "drug_entry": lookup_result.get("drug_entry", "{}"),
            "medication_message": lookup_result.get("medication_message", "No information found"),
            "action_table_used": "medication_lookup"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing medication query: {str(e)}")

@router.post("/admin/clinic-config", dependencies=[Depends(verify_staff_token)])
async def update_clinic_config(clinic_id: str, config: dict):
    """
    Admin endpoint to update clinic configuration.
    This is a placeholder for future clinic management features.
    """
    # This would typically update the clinic configuration in a database
    # For now, return a placeholder response
    return {
        "message": f"Clinic configuration update requested for {clinic_id}",
        "config": config,
        "status": "pending_implementation"
    }