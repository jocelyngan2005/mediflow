# FAQ, SOP Search, Triage (Public/Patient) 
from fastapi import APIRouter
from app.services.jamai_service import jamai_service
from app.models.chat import ChatRequest

router = APIRouter()

@router.post("/chat/sop")
async def ask_sop(request: ChatRequest):
    """
    Handles: 'Buka pukul berapa?', 'Ada vaksin?'
    """
    answer = await jamai_service.chat_with_sop(request.message)
    return {"response": answer}

@router.post("/triage")
async def trigger_triage(symptoms: str):
    """
    Handles: 'Demam panas 3 hari' -> Returns advice + booking category
    """
    triage_result = await jamai_service.triage_symptoms(symptoms)
    return {"assessment": triage_result}