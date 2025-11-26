# MediFlow Multi-Clinic AI Assistant Backend

A FastAPI backend that powers a multi-clinic AI assistant app with clinic-specific knowledge bases and operations.

## 🏥 Multi-Clinic Features

### Core Functionality per Clinic:
1. **AI FAQ Nurse** - Clinic-specific FAQs in BM/English
2. **AI Appointment Triage** - Clinic-specific triage rules and booking
3. **PDF & SOP Search** - Clinic-specific documents and KKM circulars  
4. **Medication Lookup** - Clinic-specific medication inventory (Staff only)
5. **Multilingual Support** - BM/English responses per clinic preference

### How Multi-Clinic Works:
- Each clinic has isolated knowledge tables (SOPs, medications, FAQs)
- Each clinic has separate action tables (triage, appointments, PDF Q&A)
- Users select clinic first → all AI operations use clinic-specific data
- Complete data isolation between clinics
- Staff access controlled by clinic permissions

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your JamAI credentials and clinic configurations
```

### 2. Configure Clinics
Edit the `CLINIC_CONFIGS` in `.env`:
```json
{
  "klinik-sunway": {
    "knowledge_table_sop": "sunway-sop-knowledge",
    "knowledge_table_meds": "sunway-meds-knowledge",
    "knowledge_table_faqs": "sunway-faqs-knowledge", 
    "action_table_triage": "sunway-triage-action",
    "action_table_appointment": "sunway-appointment-action",
    "action_table_pdf_qa": "sunway-pdf-qa-action"
  },
  "klinik-ampang": {
    "knowledge_table_sop": "ampang-sop-knowledge",
    "knowledge_table_meds": "ampang-meds-knowledge",
    "knowledge_table_faqs": "ampang-faqs-knowledge",
    "action_table_triage": "ampang-triage-action", 
    "action_table_appointment": "ampang-appointment-action",
    "action_table_pdf_qa": "ampang-pdf-qa-action"
  }
}
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Run the Server
```bash
# Development
uvicorn app.main:app --reload --port 8080

# Production
uvicorn app.main:app --host 0.0.0.0 --port 8080
```

## 📋 API Endpoints

### Public Endpoints (Patients)

#### Get Available Clinics
```http
GET /api/v1/clinics
```
Returns list of all available clinics for patient selection.

#### Clinic-Specific FAQ/SOP Chat
```http
POST /api/v1/patients/chat/sop
Content-Type: application/json

{
  "clinic_id": "klinik-sunway",
  "message": "Klinik ni buka pukul berapa?", 
  "language": "BM"
}
```

#### Clinic-Specific FAQ Chat
```http
POST /api/v1/patients/chat/faq
Content-Type: application/json

{
  "clinic_id": "klinik-ampang",
  "message": "Ada vaksin COVID tak?",
  "language": "BM" 
}
```

#### PDF/SOP Document Search
```http
POST /api/v1/patients/chat/pdf
Content-Type: application/json

{
  "clinic_id": "klinik-pj",
  "message": "KKM guideline untuk dengue",
  "language": "EN"
}
```

#### AI Triage Assessment
```http
POST /api/v1/patients/triage
Content-Type: application/json

{
  "clinic_id": "klinik-sunway",
  "symptoms": "Demam panas 3 hari, sakit kepala",
  "patient_age": 30,
  "is_emergency": false
}
```

### Protected Endpoints (Staff Only)

Include header: `X-Clinic-Code: MEDIFLOW-ADMIN-2024`

#### Medication Stock Lookup
```http
GET /api/v1/staff/medication-lookup?clinic_id=klinik-sunway&drug_name=Panadol
X-Clinic-Code: MEDIFLOW-ADMIN-2024
```

#### Get Accessible Clinics (Staff)
```http
GET /api/v1/staff/clinics
X-Clinic-Code: MEDIFLOW-ADMIN-2024
```

#### Clinic Status Check
```http
GET /api/v1/staff/clinic-status/klinik-sunway
X-Clinic-Code: MEDIFLOW-ADMIN-2024
```

### Admin Endpoints

#### Get All Clinics (Public)
```http
GET /api/v1/clinics
```

#### Get Clinic Details
```http
GET /api/v1/clinics/klinik-sunway
```

#### Get Clinic Table Configuration (Staff)
```http
GET /api/v1/clinics/klinik-sunway/config
X-Clinic-Code: MEDIFLOW-ADMIN-2024
```

## 🗄️ JamAI Base Setup

### Required Tables per Clinic

Each clinic needs the following tables in JamAI Base:

#### Knowledge Tables:
- `{clinic-id}-sop-knowledge` - Operating hours, services, pricing
- `{clinic-id}-meds-knowledge` - Medication inventory (CSV format)
- `{clinic-id}-faqs-knowledge` - Common patient questions & answers

#### Action Tables:
- `{clinic-id}-triage-action` - Symptom analysis → appointment recommendations
- `{clinic-id}-appointment-action` - Booking flow logic
- `{clinic-id}-pdf-qa-action` - PDF document search and summarization

### Example Table Structure

#### Knowledge Table (SOPs):
```csv
Topic,Content,Language
Operating Hours,"Monday-Friday: 8:00AM-6:00PM, Saturday: 8:00AM-2:00PM",BM
Vaksin COVID,"Ada vaksin Pfizer dan Moderna. Hubungi untuk appointment.",BM
Pricing,"General consultation: RM30, Health screening: RM150",EN
```

#### Knowledge Table (Medications):
```csv
Drug Name,Stock Count,Price,Location,Notes
Panadol,50 boxes,RM8.50,Shelf A1,Regular stock
Augmentin,12 boxes,RM45.00,Shelf B3,Prescription only
Chlorpheniramine,30 boxes,RM3.20,Shelf A2,Available
```

#### Action Table (Triage):
Input columns: `clinic_id`, `symptoms`, `patient_age`, `language`
Output column: `triage_result` 

## 🔒 Security

- **Staff Authentication**: Simple header-based authentication with `X-Clinic-Code`
- **Data Isolation**: Complete separation of clinic data through table routing
- **API Rate Limiting**: Recommended for production deployment
- **CORS**: Configured for mobile app integration

## 🌐 Multilingual Support

The system supports:
- **BM** (Bahasa Malaysia) - Primary language
- **EN** (English) - Secondary language  
- Automatic language detection from user preference
- Clinic-specific language preferences

## 📱 Frontend Integration

### Flutter App Integration:
1. Get clinic list from `/api/v1/clinics`
2. User selects clinic → store `clinic_id`  
3. All subsequent API calls include selected `clinic_id`
4. Language toggle affects `language` parameter in requests

### Example Flutter Usage:
```dart
// 1. Get clinics
final clinics = await http.get('/api/v1/clinics');

// 2. User selects clinic
String selectedClinicId = 'klinik-sunway';

// 3. Ask FAQ
final response = await http.post('/api/v1/patients/chat/faq', 
  body: json.encode({
    'clinic_id': selectedClinicId,
    'message': 'Ada vaksin tak?',
    'language': 'BM'
  }));
```

## 🛠️ Development

### Project Structure:
```
backend/
├── app/
│   ├── api/v1/          # API routes
│   │   ├── patients.py  # Patient endpoints  
│   │   ├── staff.py     # Staff endpoints
│   │   └── clinics.py   # Clinic management
│   ├── models/          # Pydantic models
│   │   ├── chat.py      # Chat requests/responses
│   │   ├── triage.py    # Triage models
│   │   ├── med_lookup.py # Medication lookup
│   │   └── clinic.py    # Clinic models  
│   ├── services/        # Business logic
│   │   └── jamai_services.py # JamAI integration
│   ├── core/            # Configuration
│   │   └── config.py    # Settings & clinic configs
│   └── main.py          # FastAPI app
├── requirements.txt
├── .env.example
└── README.md
```

### Adding New Clinics:
1. Update `CLINIC_CONFIGS` in `.env`
2. Create corresponding JamAI tables
3. Upload clinic-specific knowledge data
4. Test with API endpoints

### Testing:
```bash
# Test health check
curl http://localhost:8000/

# Test clinic list
curl http://localhost:8000/api/v1/clinics

# Test FAQ (replace with actual clinic_id)
curl -X POST http://localhost:8000/api/v1/patients/chat/faq \
  -H "Content-Type: application/json" \
  -d '{"clinic_id":"demo-clinic-1","message":"Buka pukul berapa?","language":"BM"}'
```

## 🚀 Deployment

### Environment Variables:
- `JAMAI_API_KEY` - Your JamAI Personal Access Token
- `JAMAI_PROJECT_ID` - Your JamAI project ID  
- `CLINIC_CONFIGS` - JSON configuration for all clinics
- `CLINIC_SECRET_CODE` - Staff authentication code

### Production Considerations:
- Use proper database for clinic configurations (not just JSON)
- Implement proper authentication (JWT tokens)
- Add API rate limiting  
- Set up monitoring and logging
- Use environment-specific settings
- Consider load balancing for multiple clinics

## 📞 Support

For questions about multi-clinic setup:
1. Check that JamAI tables exist for your clinic
2. Verify `CLINIC_CONFIGS` JSON format
3. Test with `/api/v1/clinics/{clinic_id}/config` endpoint
4. Check server logs for specific errors

## 🔄 Migration from Single Clinic

If upgrading from single clinic version:
1. Keep existing table IDs in `.env` for backward compatibility
2. Add `CLINIC_CONFIGS` for new clinics  
3. Update frontend to send `clinic_id` in requests
4. Gradually migrate existing data to clinic-specific tables