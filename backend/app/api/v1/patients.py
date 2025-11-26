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
        'klinik-bandar-utama': 'Klinik Bandar Utama',
        'klinik-sri-hartamas': 'Klinik Sri Hartamas', 
        'klinik-desa-jaya': 'Pusat Kesihatan Setapak',
        'klinik-wangsa': 'Klinik Famili Wangsa Maju',
        # Add more mappings as needed
    }
    
    return clinic_name_mapping.get(clinic_id, clinic_id.replace('-', ' ').title())

router = APIRouter()

@router.get("/clinics")
async def get_available_clinics():
    """
    Get list of available clinics - redirect to main clinics endpoint
    """
    from app.api.v1.clinics import get_all_clinics
    return await get_all_clinics()

@router.post("/chat/sop", response_model=ChatResponse)
async def ask_sop(request: ChatRequest):
    """
    Handles clinic-specific SOP questions: 'Buka pukul berapa?', 'Ada vaksin?'
    Requires clinic_id to route to correct knowledge base
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        answer = await jamai_service.pdf_sop_answering(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            user_query=request.message,
            language=request.language
        )
        return ChatResponse(
            reply=answer,
            source_document=f"{request.clinic_id}-sop-knowledge"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing SOP query: {str(e)}")

@router.post("/chat/faq", response_model=ChatResponse)
async def ask_faq(request: ChatRequest):
    """
    Handles clinic-specific FAQ questions
    """
    try:
        answer = await jamai_service.chat_with_faqs(
            clinic_id=request.clinic_id,
            user_query=request.message,
            language=request.language
        )
        return ChatResponse(
            reply=answer,
            source_document=f"{request.clinic_id}-faqs-knowledge"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing FAQ query: {str(e)}")

@router.post("/chat/pdf", response_model=ChatResponse)
async def search_pdf_sop(request: ChatRequest):
    """
    Search through clinic-specific PDFs and SOPs using Action Table B (PDF/SOP Answering)
    Input: user query, clinic_name → Output: user-friendly response
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
    Input: user query, clinic_name → Output: booking response with user-friendly message
    Understands intent, fetches slots, checks SOPs, drafts recommendations
    """
    try:
        clinic_name = get_clinic_name_from_id(request.clinic_id, request.clinic_name)
        booking_result = await jamai_service.appointment_booking(
            clinic_id=request.clinic_id,
            clinic_name=clinic_name,
            user_input=request.message,
            language=request.language
        )
        return ChatResponse(
            reply=booking_result.get("refined_user_message", "Appointment processed"),
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