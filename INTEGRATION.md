# Frontend-Backend Integration Guide

## 🔗 Connection Overview

Your Flutter app is now connected to the multi-clinic backend! Here's how it works:

### 📱 **Frontend Changes:**
- Added `ApiService` class to handle all backend communication
- Updated `AIAssistantScreen` to use real API calls instead of mock responses
- Added proper error handling with retry buttons
- Added loading states with informative messages
- Updated `Clinic` model to include `clinicId` for backend routing

### 🔌 **API Endpoints Used:**

#### FAQ Tab (Action Table B: PDF/SOP Answering):
```
POST /api/v1/patients/chat/sop
{
  "clinic_id": "klinik-bandar",
  "message": "Waktu operasi",
  "language": "BM"
}
```

#### Document Tab (Action Table B: PDF/SOP Answering):
```
POST /api/v1/patients/chat/pdf  
{
  "clinic_id": "klinik-ahmad",
  "message": "Jadual imunisasi KKM",
  "language": "EN"
}
```

### 🏥 **Multi-Clinic Flow:**
1. User selects clinic from `ClinicSelectionScreen`
2. `clinic.clinicId` is passed to `AIAssistantScreen`
3. All API calls include the `clinic_id` parameter
4. Backend routes to clinic-specific JamAI tables
5. AI responds with clinic-specific information

### ⚙️ **Configuration:**

#### 1. Update Backend URL:
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:8000/api/v1';
```

#### 2. Start Backend:
```bash
cd backend/
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 3. Configure Clinics in Backend:
Update your `.env` file with clinic configurations:
```env
CLINIC_CONFIGS='{
  "klinik-bandar": {
    "knowledge_table_sop": "bandar-sop-knowledge",
    "action_table_pdf_sop_answering": "bandar-pdf-sop-answering"
  },
  "klinik-ahmad": {
    "knowledge_table_sop": "ahmad-sop-knowledge", 
    "action_table_pdf_sop_answering": "ahmad-pdf-sop-answering"
  }
}'
```

### 🧪 **Testing:**

#### 1. Run API Tests:
```bash
flutter test test/api_test.dart
```

#### 2. Test with Real Backend:
```bash
# Terminal 1: Start backend
cd backend/
uvicorn app.main:app --reload

# Terminal 2: Run Flutter app
flutter run
```

#### 3. Test Flow:
1. Select a clinic (e.g., "Klinik Kesihatan Bandar") 
2. Go to AI Assistant
3. Try FAQ questions: "Waktu operasi", "Rawatan tersedia"
4. Switch to Document tab
5. Try document searches: "Jadual imunisasi", "COVID-19"

### 🔧 **Troubleshooting:**

#### No Backend Connection:
- Check if backend is running on `http://localhost:8000`
- Verify `/api/v1/clinics` endpoint returns clinic data
- Check network connectivity from Flutter app

#### API Errors:
- Look for error messages in chat (red bubbles with retry button)
- Check backend logs for JamAI table access issues
- Verify clinic IDs match between frontend and backend

#### Missing Responses:
- Ensure JamAI tables exist for the selected clinic
- Check Action Table configuration in backend
- Verify knowledge bases have been uploaded

### 🚀 **Production Deployment:**

#### Frontend:
- Update `baseUrl` to production backend URL
- Add proper SSL/HTTPS support
- Consider adding authentication tokens

#### Backend: 
- Deploy to cloud (Railway, Render, AWS, etc.)
- Set production environment variables
- Ensure JamAI tables are properly configured

### 📊 **Monitoring:**

#### Success Indicators:
- ✅ Chat shows "powered by JamAI Base" in welcome message
- ✅ Loading indicators show "Searching for answer..." 
- ✅ Responses include source document citations
- ✅ Different clinics return different information
- ✅ Language switching works (BM/EN)

#### Error Indicators:
- ❌ Red error bubbles with network errors
- ❌ Generic fallback responses
- ❌ Missing source document citations
- ❌ Same responses across different clinics

The integration is complete! Your Flutter app now communicates with the multi-clinic backend powered by JamAI Base Action Tables. 🎉