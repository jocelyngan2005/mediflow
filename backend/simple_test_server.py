from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

app = FastAPI(title="Simple Test API")

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    clinic_id: str
    message: str
    language: str

class ChatResponse(BaseModel):
    reply: str
    source_document: str = ""

@app.get("/")
async def health():
    return {"status": "ok", "message": "Simple test server running"}

@app.post("/api/v1/patients/chat")
async def chat(request: ChatRequest):
    return ChatResponse(
        reply=f"Test response for: {request.message}",
        source_document="test.pdf"
    )

@app.get("/api/v1/clinics")
async def clinics():
    return [
        {
            "clinic_id": "test-clinic",
            "name": "Test Clinic",
            "address": "Test Address",
            "phone": "123-456-7890",
            "operating_hours": "24/7",
            "languages_supported": ["English", "Bahasa Malaysia"],
            "services": ["Test Service"],
            "is_active": True
        }
    ]

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8080)