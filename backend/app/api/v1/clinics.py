# Clinic Management API (Admin functions)
from fastapi import APIRouter, Depends, HTTPException, status
from app.api.dependencies import verify_staff_token
from app.models.clinic import Clinic, ClinicRequest, ClinicResponse
from app.core.config import settings
from typing import List, Dict
import json

router = APIRouter()

@router.get("/clinics", response_model=List[ClinicResponse])
async def get_all_clinics():
    """
    Get all available clinics (public endpoint for clinic selection)
    Using shared JamAI tables with clinic_name column
    """
    try:
        # Return predefined clinics - all use shared JamAI tables
        clinics = [
            ClinicResponse(
                clinic_id="klinik-bandar-utama",
                name="Klinik Bandar Utama",
                address="Bandar Utama, Petaling Jaya, Selangor",
                phone="+60-3-7725-0123",
                email="info@klinikbandarutama.com",
                operating_hours="Mon-Fri: 8:00AM-10:00PM, Sat-Sun: 8:00AM-6:00PM",
                languages_supported=["BM", "EN", "ZH"],
                services=["General Consultation", "Health Screening", "Vaccination", "Minor Surgery"],
                is_active=True
            ),
            ClinicResponse(
                clinic_id="klinik-sri-hartamas",
                name="Klinik Sri Hartamas",
                address="Sri Hartamas, Kuala Lumpur",
                phone="+60-3-6201-9876",
                email="contact@klinikshartamas.com",
                operating_hours="Mon-Fri: 9:00AM-9:00PM, Sat: 9:00AM-5:00PM, Sun: Closed",
                languages_supported=["BM", "EN", "TA"],
                services=["Family Medicine", "Pediatrics", "Women's Health", "Travel Medicine"],
                is_active=True
            ),
            ClinicResponse(
                clinic_id="pusat-kesihatan-setapak",
                name="Pusat Kesihatan Setapak",
                address="Setapak, Kuala Lumpur",
                phone="+60-3-4142-5678",
                email="info@pksetapak.gov.my",
                operating_hours="Mon-Sun: 8:00AM-12:00AM (24 hours emergency)",
                languages_supported=["BM", "EN", "ZH", "TA"],
                services=["Emergency Care", "Maternal Care", "Immunization", "Chronic Disease Management"],
                is_active=True
            )
        ]
        
        return clinics
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching clinics: {str(e)}")

@router.get("/clinics/{clinic_id}", response_model=ClinicResponse)
async def get_clinic_details(clinic_id: str):
    """
    Get detailed information about a specific clinic
    """
    try:
        # Get all clinics and find the requested one
        all_clinics = await get_all_clinics()
        clinic = next((c for c in all_clinics if c.clinic_id == clinic_id), None)
        
        if not clinic:
            raise HTTPException(status_code=404, detail=f"Clinic {clinic_id} not found")
            
        return clinic
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching clinic details: {str(e)}")

@router.get("/shared-tables", dependencies=[Depends(verify_staff_token)])
async def get_shared_table_info():
    """
    Get shared JamAI table information (Staff only)
    All clinics use the same tables with clinic_name column for filtering
    """
    return {
        "shared_tables": {
            "action_table_appointment_booking": settings.ACTION_TABLE_TRIAGE,
            "action_table_pdf_sop_answering": settings.ACTION_TABLE_SOP_QNA,
            "action_table_medication_lookup": settings.ACTION_TABLE_LOOKUP
        },
        "note": "All tables are shared across clinics, filtered by clinic_name column",
        "jamai_project_id": settings.JAMAI_PROJECT_ID
    }

@router.post("/admin/clinics", dependencies=[Depends(verify_staff_token)], response_model=ClinicResponse)
async def create_clinic(clinic_request: ClinicRequest):
    """
    Create a new clinic configuration (Admin only)
    This is a placeholder for future implementation
    """
    # Generate clinic_id from name
    clinic_id = clinic_request.name.lower().replace(" ", "-").replace("_", "-")
    
    # In production, this would:
    # 1. Create database entry for clinic
    # 2. Set up JamAI tables
    # 3. Initialize knowledge bases
    
    clinic = ClinicResponse(
        clinic_id=clinic_id,
        name=clinic_request.name,
        address=clinic_request.address,
        phone=clinic_request.phone,
        email=clinic_request.email,
        operating_hours=clinic_request.operating_hours,
        languages_supported=clinic_request.languages_supported,
        services=clinic_request.services,
        is_active=True
    )
    
    return clinic

@router.put("/admin/clinics/{clinic_id}", dependencies=[Depends(verify_staff_token)], response_model=ClinicResponse)
async def update_clinic(clinic_id: str, clinic_request: ClinicRequest):
    """
    Update clinic information (Admin only)
    """
    # In production, this would update the database
    clinic = ClinicResponse(
        clinic_id=clinic_id,
        name=clinic_request.name,
        address=clinic_request.address,
        phone=clinic_request.phone,
        email=clinic_request.email,
        operating_hours=clinic_request.operating_hours,
        languages_supported=clinic_request.languages_supported,
        services=clinic_request.services,
        is_active=True
    )
    
    return clinic

@router.delete("/admin/clinics/{clinic_id}", dependencies=[Depends(verify_staff_token)])
async def deactivate_clinic(clinic_id: str):
    """
    Deactivate a clinic (Admin only)
    """
    # In production, this would update the database to set is_active=False
    return {"message": f"Clinic {clinic_id} deactivated successfully"}

@router.get("/admin/system-status", dependencies=[Depends(verify_staff_token)])
async def get_system_status():
    """
    Get overall system status for all clinics (Admin only)
    """
    all_clinics = await get_all_clinics()
    active_clinics = [c.clinic_id for c in all_clinics if c.is_active]
    
    status_report = {
        "total_clinics": len(all_clinics),
        "active_clinics": active_clinics,
        "jamai_project_id": settings.JAMAI_PROJECT_ID,
        "shared_tables": {
            "appointment_booking": settings.ACTION_TABLE_TRIAGE,
            "sop_qna": settings.ACTION_TABLE_SOP_QNA,
            "medication_lookup": settings.ACTION_TABLE_LOOKUP
        },
        "system_health": "operational",
        "timestamp": "2024-11-27T00:00:00Z"
    }
    
    return status_report