# MediFlow 🏥

**Multi-Clinic AI Assistant App for Malaysians**

A BM/English AI nurse assistant that helps small Malaysian clinics handle their overwhelming manual workload—FAQs, appointment triage, medicine availability checks, SOP lookup, and PDF searches—using JamAI Base RAG + Action Tables on a simple mobile-first interface.

## 🎯 Domain: Embedded LLM 

Track: Generative AI for Malaysian Industries with JamAI Base

## 💻 Submission 

Demo Video: https://www.canva.com/design/DAG54kXfSOc/OxRV3edYxUTe5T3BJF3K9A/watch?utm_content=DAG54kXfSOc&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=hdc37d9f2bd

Presentation Slides: 

## 📌 Problem Statement 

Malaysia's small clinics face operational challenges:

**Patient Experience Issues:**
- Long waiting times for basic inquiries
- Language barriers for foreign workers
- Difficulty booking appointments outside clinic hours
- Lack of medication availability information

**Staff Operational Burden:**
- Overloaded front-desk staff with repetitive tasks
- Manual appointment scheduling and management
- Time-consuming medication inventory tracking

Small clinics can't afford expensive custom solutions, making MediFlow the perfect accessible alternative.


## 👥 Target Users

### **Patients**
- Local Malaysian patients seeking convenient healthcare access
- Foreign workers needing multilingual medical support
- Walk-in patients requiring appointment booking and clinic information
- Users wanting to check medication availability and clinic services

### **Clinic Staff**
- Front-desk staff managing appointments and patient inquiries
- Medical assistants handling medication inventory
- Healthcare workers requiring quick access to medical information


## 🚀 Core Features

### **1. AI FAQ Nurse (BM/English) 🤖**
Answers common clinic FAQs using Knowledge Table (PDFs, clinic SOPs, service list).

**RAG retrieval from:**
- Clinic operating hours and contact information
- Available treatments and medical services
- Vaccine schedules and immunization programs
- Medication availability (manual entries or CSV uploads)

**Example Query (BM):**
*"Klinik ni ada buat medical check up untuk kerja kilang tak?"*
→ AI retrieves relevant information → summarizes → replies in Bahasa Malaysia

### **2. AI Appointment Triage 📅**
Patients describe symptoms → AI classifies urgency → proposes available appointment slots.
*(Sorting patients based on clinic rules, not medical diagnosis)*

**Process using Action Table:**
- Understand patient symptoms and concerns
- Fetch clinic SOP guidelines (e.g., fever protocols, cough management, injury procedures)
- Suggest appropriate appointment categories (routine, urgent, emergency)
- Check real-time slot availability
- Draft appointment confirmation → user approval required

### **3. PDF & SOP Search (KKM Circulars) 📄**
Upload and search through important healthcare documents:

e.g.
- Immunisation Schedule
- Clinic SOPs
- Child Vaccination Guidelines
- Dengue Management

### **4. Medication Quick Lookup 💊**
**Staff-only access** for inventory management:
- *"Panadol stock tinggal berapa?"* (How much Panadol stock left?)
- *"Do we have Chlorpheniramine available?"*
- AI reads uploaded CSV files stored in Knowledge Table
- **Access Control:** Patients blocked from accessing medication stock information

### **5. Multilingual Support 🌐**
**Seamless BM ⇄ English translation** throughout the application.

**Particularly useful for:**
- **Bangladeshi workers** seeking medical care
- **Nepali workers** navigating healthcare services
- **Elderly Malaysian patients** preferring Bahasa Malaysia
- **Mixed-language consultations** and documentation

### **Administrative Tools**
- **📊 Staff Analytics Dashboard** - Performance metrics and operational insights
- **🔐 Role-based Access Control** - Separate interfaces for patients vs. staff
- **📱 Cross-platform Support** - Native iOS and Android applications
- **☁️ JamAI Base Integration** - RAG-powered Knowledge and Action Tables


## Deep Use of JamAI Base 🧠

### **Knowledge Table**
Stores comprehensive clinic information for RAG retrieval:

- **Clinic FAQs + SOPs** - Standard operating procedures and frequently asked questions
- **Treatment & Vaccine Information** - Available services and immunization schedules
- **KKM PDF Circulars** - Ministry of Health guidelines and protocols
- **Timetable CSV** - Appointment availability and scheduling data
- **Medication CSV** - Drug inventory, pricing, and stock information

**Process:** Queries → RAG → Summarized answers in preferred language

### **Action Table (Multi-Step Reasoning)**
Custom pipelines for complex clinic operations:

#### **Action Chain: Appointment Booking**
1. **Understand intent** - Parse patient symptoms and preferences
2. **Fetch available time slots** - Query real-time appointment availability
3. **Cross-check SOP** - Match case type with clinic protocols
4. **Draft recommended time** - Suggest optimal appointment slot
5. **Refine into BM/English** - Generate user-friendly message
6. **Write final booking record** - Store appointment data (JSON format)

#### **Action Chain: PDF/SOP Answering**
1. **Parse question** - Understand healthcare query context
2. **Retrieve relevant PDF segments** - Find matching document sections
3. **Summarize with clinical-safe wording** - Ensure accurate medical information
4. **Respond in preferred language** - Deliver answer in BM or English

#### **Action Chain: Medication Lookup**
1. **Interpret drug name** - Handle various medication name formats
2. **Search medication CSV** - Query inventory database
3. **Return stock, price, alternatives** - Comprehensive medication information


## 🛠️ Tech Stack

### **Frontend**
- **Flutter** - Cross-platform mobile development framework
- **BM/English Language Selector** - Built-in multilingual interface switching

### **Backend**
- **JamAI Base (Cloud)** - Managed AI infrastructure and RAG engine
- **Python SDK** - Integration with JamAI Base services
- **RAG Engine Components:**
  - **Embeddings** - Vector representation of clinic documents and FAQs
  - **Vector Search** - Semantic similarity matching for intelligent responses


## 🚀 Setup Guide

### Prerequisites
- **Flutter SDK** (3.19.0+)
- **Dart SDK** (3.3.0+)
- **Python** (3.9+) - for backend development

### 📱 Frontend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/jocelyngan2005/mediflow.git
   cd mediflow
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the mobile app**
   ```bash
   # Development mode with hot reload
   flutter run
   
   # Run on specific platform
   flutter run -d android    # Android device/emulator
   flutter run -d ios        # iOS simulator/device
   ```

4. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # Android App Bundle (Play Store)
   flutter build appbundle --release
   
   # iOS (requires Xcode)
   flutter build ios --release
   ```

### 🖥️ Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create and activate virtual environment**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   # Create .env file with required variables
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Run the backend server**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8080

   # If running on Android device 
   adb reverse tcp:8080 tcp:8080 
   # Then run the backend server 
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
   
   ```

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help improve MediFlow:

### **How to Contribute**
1. **Fork the repository** on GitHub
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** and ensure code quality
4. **Test thoroughly** - Add tests for new features
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to your branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request** with a detailed description

### **Development Guidelines**
- Follow Flutter/Dart best practices and style guidelines
- Ensure all new features have appropriate test coverage
- Update documentation for any new features or changes
- Test multilingual support (BM/English) for UI changes
- Verify compatibility across iOS and Android platforms

### **Areas for Contribution**
- **🌐 Localization** - Additional language support beyond BM/English
- **🎨 UI/UX Improvements** - Enhanced user experience and accessibility
- **🔧 Backend Integration** - API optimizations and new endpoints
- **📊 Analytics Features** - Additional reporting and dashboard capabilities
- **🧪 Testing** - Unit tests, integration tests, and automated testing
- **📱 Platform Features** - iOS/Android specific optimizations

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for Malaysian Clinics**
