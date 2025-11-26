# Clinic Management API (Admin functions)
from fastapi import APIRouter, Depends, HTTPException, status
from app.api.dependencies import verify_staff_token
from app.models.clinic import Clinic, ClinicRequest, ClinicResponse, ClinicTableConfig
from app.core.config import settings
from typing import List, Dict
import json

router = APIRouter()

@router.get("/clinics", response_model=List[ClinicResponse])
async def get_all_clinics():
    """
    Get all configured clinics (public endpoint for clinic selection)
    """
    try:
        clinic_ids = settings.get_all_clinic_ids()
        
        # For demo purposes, return basic clinic info
        # In production, this would come from a database
        clinics = []
        for clinic_id in clinic_ids:
            clinic = ClinicResponse(
                clinic_id=clinic_id,
                name=f"{clinic_id.title()} Medical Clinic",
                address=f"Address for {clinic_id}",
                phone="+60-XXX-XXXXXX",
                email=f"info@{clinic_id.lower()}.com",
                operating_hours="Mon-Fri: 8:00AM-6:00PM, Sat: 8:00AM-2:00PM",
                languages_supported=["BM", "EN"],
                services=["General Practice", "Vaccination", "Health Screening"],
                is_active=True
            )
            clinics.append(clinic)
            
        # If no clinics configured, return demo clinics
        if not clinics:
            demo_clinics = [
                ClinicResponse(
                    clinic_id="demo-clinic-1",
                    name="Demo Clinic KL",
                    address="Kuala Lumpur, Malaysia",
                    phone="+60-3-XXXX-XXXX",
                    email="info@democlinic1.com",
                    operating_hours="Mon-Fri: 8:00AM-6:00PM, Sat: 8:00AM-2:00PM",
                    languages_supported=["BM", "EN"],
                    services=["General Practice", "Vaccination", "Health Screening"],
                    is_active=True
                ),
                ClinicResponse(
                    clinic_id="demo-clinic-2", 
                    name="Demo Clinic Selangor",
                    address="Selangor, Malaysia",
                    phone="+60-3-YYYY-YYYY",
                    email="info@democlinic2.com",
                    operating_hours="Mon-Sun: 9:00AM-9:00PM",
                    languages_supported=["BM", "EN", "ZH"],
                    services=["General Practice", "Emergency Care", "Specialist Referral"],
                    is_active=True
                )
            ]
            return demo_clinics
            
        return clinics
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching clinics: {str(e)}")

@router.get("/clinics/{clinic_id}", response_model=ClinicResponse)
async def get_clinic_details(clinic_id: str):
    """
    Get detailed information about a specific clinic
    """
    try:
        clinic_config = settings.get_clinic_config(clinic_id)
        
        # Return clinic details (in production, this would come from a database)
        clinic = ClinicResponse(
            clinic_id=clinic_id,
            name=f"{clinic_id.title()} Medical Clinic",
            address=f"Address for {clinic_id}",
            phone="+60-XXX-XXXXXX",
            email=f"info@{clinic_id.lower()}.com",
            operating_hours="Mon-Fri: 8:00AM-6:00PM, Sat: 8:00AM-2:00PM",
            languages_supported=["BM", "EN"],
            services=["General Practice", "Vaccination", "Health Screening"],
            is_active=True
        )
        
        return clinic
        
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Clinic {clinic_id} not found")

@router.get("/clinics/{clinic_id}/config", dependencies=[Depends(verify_staff_token)])
async def get_clinic_table_config(clinic_id: str):
    """
    Get JamAI table configuration for a specific clinic (Staff only)
    """
    try:
        clinic_config = settings.get_clinic_config(clinic_id)
        
        config = ClinicTableConfig(
            clinic_id=clinic_id,
            knowledge_table_sop=clinic_config["knowledge_table_sop"],
            knowledge_table_meds=clinic_config["knowledge_table_meds"],
            knowledge_table_faqs=clinic_config["knowledge_table_faqs"],
            action_table_appointment_booking=clinic_config["action_table_appointment_booking"],
            action_table_pdf_sop_answering=clinic_config["action_table_pdf_sop_answering"],
            action_table_medication_lookup=clinic_config["action_table_medication_lookup"]
        )
        
        return config
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching clinic config: {str(e)}")

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
    clinic_ids = settings.get_all_clinic_ids()
    
    status_report = {
        "total_clinics": len(clinic_ids),
        "active_clinics": clinic_ids,
        "jamai_project_id": settings.JAMAI_PROJECT_ID,
        "system_health": "operational",
        "timestamp": "2024-11-26T00:00:00Z"
    }
    
    return status_report