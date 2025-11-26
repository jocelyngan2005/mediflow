# Entry point (FastAPI app initialization)
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Import the routers we planned
# Note: Ensure you have created the files in app/api/v1/ as discussed previously
from app.api.v1 import patients, staff, clinics
from app.core.config import settings

app = FastAPI(
    title="MediFlow AI Backend",
    description="Multilingual AI Nurse API for JamAI Base Hackathon",
    version="1.0.0"
)

# --- CORS CONFIGURATION ---
# This is crucial for your Flutter mobile app to communicate with this backend.
# allow_origins=["*"] allows requests from anywhere (good for hackathon/dev).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- REGISTER ROUTERS ---
# 1. Patient Routes (Public: FAQs, Triage, SOPs)
app.include_router(
    patients.router, 
    prefix="/api/v1/patients", 
    tags=["Patients"]
)

# 2. Staff Routes (Protected: Medication Lookup)
app.include_router(
    staff.router, 
    prefix="/api/v1/staff", 
    tags=["Clinic Staff"]
)

# 3. Clinic Management Routes (Public clinic list, Protected admin functions)
app.include_router(
    clinics.router, 
    prefix="/api/v1", 
    tags=["Clinic Management"]
)

@app.get("/")
async def health_check():
    """
    Simple health check to verify backend is running.
    """
    return {
        "status": "online",
        "service": "MediFlow AI Nurse - Multi-Clinic Edition",
        "project_id": settings.JAMAI_PROJECT_ID,
        "features": [
            "Multi-clinic support",
            "AI FAQ Nurse (BM/English)", 
            "AI Appointment Triage",
            "PDF & SOP Search",
            "Medication Quick Lookup (Staff Only)",
            "Multilingual Support"
        ],
        "configured_clinics": settings.get_all_clinic_ids(),
        "version": "2.0.0"
    }

if __name__ == "__main__":
    # Use this for debugging. In production, run with: uvicorn app.main:app --reload
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)


"""
### How to Run This

1.  **Environment Setup:**
    Create a `.env` file in your `backend/` root:
    ```env
    JAMAI_API_KEY="your_jamai_pat_here"
    JAMAI_PROJECT_ID="your_project_id_here"
    
    # Table IDs
    KNOWLEDGE_TABLE_SOP="sop-knowledge-table"
    KNOWLEDGE_TABLE_MEDS="meds-knowledge-table"
    ACTION_TABLE_TRIAGE="triage-action-table"
    
    # Security
    CLINIC_SECRET_CODE="MEDIFLOW2024" 
    ```

2.  **Start the Server:**
    Open your terminal in `backend/` and run:
    ```bash
    uvicorn app.main:app --reload
"""