"""
Test server to verify the backend is working
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="MediFlow Test Server")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "MediFlow AI Nurse Test Server",
        "version": "1.0.0"
    }

@app.get("/api/v1/clinics")
async def get_clinics():
    """Mock clinics endpoint"""
    return [
        {
            "clinic_id": "cid_01_public",
            "name": "Public Clinic Bandar Utama",
            "address": "123 Main St, Bandar Utama",
            "phone": "+60-3-1234-5678",
            "operating_hours": "Mon-Fri: 8:00 AM - 6:00 PM",
            "languages_supported": ["English", "Bahasa Malaysia"],
            "services": ["General Medicine", "Pediatrics", "Vaccination"],
            "is_active": True
        },
        {
            "clinic_id": "cid_02_private",
            "name": "Private Health Center",
            "address": "456 Health Ave, Petaling Jaya",
            "phone": "+60-3-2345-6789",
            "operating_hours": "Mon-Sun: 9:00 AM - 9:00 PM",
            "languages_supported": ["English", "Bahasa Malaysia", "Mandarin"],
            "services": ["General Medicine", "Specialist Consultations", "Lab Tests"],
            "is_active": True
        }
    ]

@app.post("/api/v1/patients/appointment")
async def mock_appointment():
    """Mock appointment booking endpoint"""
    return {
        "reply": "I understand you'd like to book an appointment. Based on your request, I recommend booking a consultation for today or tomorrow. Available time slots: 10:00 AM, 2:00 PM, 4:00 PM.",
        "structured_response": '{"recommended_urgency": "medium", "suggested_times": ["10:00 AM", "2:00 PM", "4:00 PM"], "booking_message": "Please select your preferred time slot to complete your appointment booking."}'
    }

@app.post("/api/v1/staff/medication-lookup")
async def mock_staff_lookup():
    """Mock staff medication lookup endpoint"""
    return {
        "reply": "Based on your search, I found several relevant medications. Please check the detailed information below.",
        "medications": [
            {
                "name": "Paracetamol",
                "dosage": "500mg",
                "description": "Pain relief and fever reducer",
                "usage": "Take 1-2 tablets every 4-6 hours as needed"
            }
        ]
    }

if __name__ == "__main__":
    uvicorn.run("test_server:app", host="0.0.0.0", port=8000, reload=True)