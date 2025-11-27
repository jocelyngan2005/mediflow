# FAQ, SOP Search, Triage (Public/Patient) 
from fastapi import APIRouter, HTTPException
from app.services.jamai_services import jamai_service
from app.models.chat import ChatRequest, ChatResponse
from app.models.triage import TriageRequest, TriageResponse
from typing import List

def get_clinic_name_from_id(clinic_id: str, clinic_name: str = None) -> str:
    """
    Get clinic name for JamAI action tables.
    If clinic_name is provided in request, use it. Otherwise derive from clinic_id.
    """
    if clinic_name:
        return clinic_name
    
    # Default mapping - you may want to use a database lookup in production
    clinic_name_mapping = {
        'clinic_001': 'Klinik Bandar Utama',
        'clinic_002': 'Klinik Sri Hartamas',
        'clinic_003': 'Klinik Desa Jaya',
        'clinic_004': 'Klinik Famili Wangsa Maju',
        # Legacy mappings for backward compatibility
        'klinik-bandar-utama': 'Klinik Bandar Utama',
        'klinik-sri-hartamas': 'Klinik Sri Hartamas', 
        'klinik-desa-jaya': 'Klinik Desa Jaya',
        'klinik-wangsa': 'Klinik Famili Wangsa Maju',
        # Add more mappings as needed
    }
    
    return clinic_name_mapping.get(clinic_id, clinic_id.replace('-', ' ').title())

router = APIRouter()

@router.get("/clinics")
async def get_available_clinics():
    """
    Get list of available clinics - simplified version to avoid circular imports
    """
    return [
        {
            "clinic_id": "klinik-bandar-utama",
            "name": "Klinik Bandar Utama",
            "address": "Bandar Utama, Petaling Jaya",
            "phone": "+603-7725-0123",
            "email": "info@klinikbandarutama.com",
            "operating_hours": "Mon-Fri: 8AM-10PM, Sat-Sun: 8AM-6PM",
            "languages_supported": ["English", "Bahasa Malaysia", "Mandarin"],
            "services": ["General Consultation", "Health Screening", "Vaccination", "Minor Surgery"],
            "is_active": True
        },
        {
            "clinic_id": "klinik-sri-hartamas", 
            "name": "Klinik Sri Hartamas",
            "address": "Sri Hartamas, Kuala Lumpur",
            "phone": "+603-6201-9876",
            "email": "contact@klinikshartamas.com",
            "operating_hours": "Mon-Fri: 9AM-9PM, Sat: 9AM-5PM, Sun: Closed",
            "languages_supported": ["English", "Bahasa Malaysia", "Tamil"],
            "services": ["Family Medicine", "Pediatrics", "Women's Health", "Travel Medicine"],
            "is_active": True
        }
    ]

@router.post("/chat", response_model=ChatResponse)
async def unified_chat(request: ChatRequest):
    """
    Unified chat endpoint for both FAQ and SOP questions
    Uses SOP QnA Action Table to answer all types of questions
    Input: user question, clinic_name → Output: response, source_document
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        sop_result = await jamai_service.pdf_sop_answering(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            question=request.message,
            language=request.language
        )
        return ChatResponse(
            reply=sop_result.get("response", "No answer found"),
            source_document=sop_result.get("source_document", "")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing chat query: {str(e)}")

@router.post("/chat/pdf", response_model=ChatResponse)
async def search_pdf_sop(request: ChatRequest):
    """
    Legacy endpoint - Search through clinic-specific PDFs and SOPs using Action Table B (SOP QnA)
    Redirects to the same SOP QnA action table as the unified chat endpoint
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        sop_result = await jamai_service.pdf_sop_answering(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            question=request.message,
            language=request.language
        )
        return ChatResponse(
            reply=sop_result.get("response", "No answer found"),
            source_document=sop_result.get("source_document", "")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching PDF documents: {str(e)}")

@router.post("/appointment", response_model=ChatResponse)
async def book_appointment(request: ChatRequest):
    """
    Handles appointment booking using Action Table A (Appointment Booking)
    Input: user_input, clinic_name → Output: structured appointment data
    Returns all appointment booking fields in the reply as JSON
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        booking_result = await jamai_service.appointment_booking(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            user_input=request.message,
            language=request.language
        )
        
        # Return structured data in reply field as JSON string
        import json
        structured_response = {
            "available_time_slots": booking_result.get("available_time_slots", "[]"),
            "case_type": booking_result.get("case_type", "{}"),
            "recommended_time": booking_result.get("recommended_time", "{}"),
            "refined_user_message": booking_result.get("refined_user_message", "Appointment processed")
        }
        
        return ChatResponse(
            reply=json.dumps(structured_response),
            source_document=booking_result.get("booking_record", "{}")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing appointment booking: {str(e)}")

@router.post("/triage")
async def trigger_triage(request: TriageRequest):
    """
    Legacy triage endpoint - now redirects to appointment booking workflow
    Uses Action Table A for symptom analysis and booking recommendations
    """
    try:
        # Convert triage request to user query for appointment booking
        user_query = f"I have these symptoms: {request.symptoms}"
        if request.patient_age:
            user_query += f". I am {request.patient_age} years old."
        if request.is_emergency:
            user_query += " This is urgent/emergency."
        
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        booking_result = await jamai_service.appointment_booking(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            user_input=user_query,
            language="BM"
        )
        
        return {
            "clinic_id": request.clinic_id,
            "clinic_name": clinic_name,
            "assessment": booking_result.get("refined_user_message", "Appointment processed"),
            "booking_record": booking_result.get("booking_record", "{}"),
            "symptoms_provided": request.symptoms,
            "patient_age": request.patient_age,
            "action_table_used": "appointment_booking"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing triage: {str(e)}")

# Legacy endpoint for backward compatibility
@router.post("/triage/simple")
async def simple_triage(clinic_id: str, symptoms: str, clinic_name: str = None):
    """
    Simple triage endpoint for quick integration
    """
    try:
        resolved_clinic_name = get_clinic_name_from_id(clinic_id, clinic_name)
        booking_result = await jamai_service.appointment_booking(
            clinic_id=clinic_id,
            clinic_name=resolved_clinic_name,
            user_input=f"Symptoms: {symptoms}",
            language="BM"
        )
        return {
            "assessment": booking_result.get("refined_user_message", "Appointment processed"),
            "booking_record": booking_result.get("booking_record", "{}"),
            "clinic_name": resolved_clinic_name
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing simple triage: {str(e)}")