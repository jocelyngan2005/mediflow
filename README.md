# ClinicFlow+ 🏥

**The Multilingual AI Nurse for Malaysia's Small Clinics**

A BM/English AI nurse assistant that helps small Malaysian clinics handle their overwhelming manual workload—FAQs, appointment triage, medicine availability checks, SOP lookup, and PDF searches.

## Features 🚀

### Core Functionality
- **AI FAQ Nurse** (BM/English) - Answers common clinic FAQs
- **AI Appointment Triage** - Symptom-based appointment scheduling
- **PDF & SOP Search** - Instant Q&A from KKM circulars and clinic SOPs
- **Medication Quick Lookup** - Staff-only medication stock lookup
- **Multilingual Support** - BM ⇄ English translation

## UI Structure 📱

### 1️⃣ Splash Screen
- Beautiful animated splash screen with app branding
- Auto-navigates to onboarding after 3 seconds

### 2️⃣ Onboarding
- Welcome message
- Language selection (🇲🇾 BM | 🇬🇧 EN)
- Location services setup
- Swipeable pages with progress indicators

### 3️⃣ Login / Signup / Guest
- Login (email/phone + password)
- Signup (name, contact, optional health ID, password)
- **Continue as Guest** (highlighted) - disables profile saving

### 4️⃣ Clinic Selection
- Map view toggle (placeholder)
- Scrollable clinic cards with:
  - Clinic name
  - Address & distance
  - Operating hours
  - Open/Closed status
  - "Select & Chat" button

### 5️⃣ Main Menu - Card Grid
Large, tappable cards in 2x3 grid:

| Card | Icon | Color | Purpose |
|------|------|-------|---------|
| **AI Nurse** | 🤖 | Blue | Chat with AI for FAQs |
| **Appointments** | 📅 | Green | Symptom → urgency → slots |
| **SOP Search** | 📄 | Orange | Q&A on PDFs & guidelines |
| **Medication** | 💊 | Red | Staff-only stock lookup (PIN protected) |
| **User Profile** | 👤 | Peach | Personal info, language, appointments |

## Theme & Design 🎨

### Color Palette (Soft Pastels)
- **Primary Blue**: `#6BA5E7` - Info & AI Nurse
- **Soft Green**: `#9FD8A5` - Appointments
- **Soft Orange**: `#FFB366` - SOP Search
- **Soft Red**: `#FF8080` - Medication (Staff)
- **Soft Peach**: `#FFB4A8` - Profile
- **Background**: `#F8FAFB` - Light neutral

### Design Features
- ✨ Rounded corners (16-30px border radius)
- 🎨 Soft pastel backgrounds
- 📐 Card-based layouts
- 🎭 Subtle shadows
- 📱 Mobile-first responsive design
- 🌊 Smooth animations

## Project Structure 📂

```
lib/
├── main.dart                          # App entry point
├── theme/
│   └── app_theme.dart                 # Color scheme & theme
├── screens/
│   ├── splash_screen.dart             # Animated splash
│   ├── onboarding_screen.dart         # Welcome & language selection
│   ├── login_screen.dart              # Login/Signup/Guest
│   ├── clinic_selection_screen.dart   # Clinic list & map
│   └── main_menu_screen.dart          # Main card grid menu
└── widgets/
    ├── menu_card.dart                 # Reusable menu card component
    └── clinic_card.dart               # Clinic info card component
```

## Getting Started 🏃

### Prerequisites
- Flutter SDK (3.9.0+)
- Dart SDK (3.9.0+)

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

3. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## Features Implementation Status ✅

### ✅ Completed (UI)
- [x] Splash screen with animation
- [x] Onboarding flow with language selection
- [x] Login/Signup/Guest authentication
- [x] Clinic selection with list view
- [x] Main menu with card-based navigation
- [x] Staff PIN protection for medication
- [x] Guest mode indicators
- [x] Soft pastel theme

### 🚧 To Be Implemented (Backend)
- [ ] JamAI Base RAG integration
- [ ] Knowledge Table for PDFs & SOPs
- [ ] Action Table for appointment triage
- [ ] Multilingual AI chat (BM/English)
- [ ] Map view integration
- [ ] Medication CSV lookup
- [ ] User authentication backend
- [ ] Profile persistence
- [ ] Real-time appointment booking

## Development Notes 📝

### Testing Guest Mode
- Click "Continue as Guest" on login screen
- Guest mode shows warning banner on clinic selection
- Profile screen prompts login

### Testing Staff Authentication
- Click "Medication" card on main menu
- Enter PIN: `1234` (demo PIN)
- Real implementation will use secure staff authentication

### Customization
- Edit colors in `lib/theme/app_theme.dart`
- Modify clinic data in `lib/screens/clinic_selection_screen.dart`
- Add new menu cards in `lib/screens/main_menu_screen.dart`

## Design Inspiration 🎨

The UI follows modern mobile app design principles with:
- **Soft, friendly colors** for healthcare environment
- **Large, tappable targets** for accessibility
- **Clear visual hierarchy** with cards and spacing
- **Consistent iconography** from Material Design
- **Smooth transitions** for better UX

## Next Steps 🔜

1. **Backend Integration**
   - Set up JamAI Base RAG
   - Create Knowledge Tables for clinic data
   - Implement Action Tables for triage

2. **AI Features**
   - Connect to multilingual AI model
   - Implement chat interface
   - Add voice input support

3. **Map Integration**
   - Google Maps / OpenStreetMap
   - Clinic location markers
   - Distance calculation

4. **Real Authentication**
   - Firebase / Supabase integration
   - Secure user data storage
   - Staff role management

---

**Made with ❤️ for Malaysian Clinics**
