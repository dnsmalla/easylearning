# Educa - Student Information Aggregator

A professional iOS app built with SwiftUI, converted from the Flutter Educa app. This is a **JSON-driven** application that fetches content from local JSON files or a remote GitHub repository.

## 🎓 Features

### Study Hub
- Browse universities worldwide
- View course details and tuition fees
- Filter by rating, price, and popularity
- Save favorites for later

### Journey
- Country-specific visa information
- Document checklists
- Success rates and processing times
- Cost of living estimates

### Placement
- Job listings for students
- Full-time, part-time, and internship opportunities
- Filter by job type and location
- Save and apply directly

### Remittance
- Compare money transfer providers
- Exchange rates and fees
- Transfer time estimates

### Profile
- Save universities, courses, and jobs
- Track your application progress
- App settings and preferences

## 🚀 Quick Start

### Option 1: Using XcodeGen (Recommended)

```bash
# Install XcodeGen if you haven't
brew install xcodegen

# Navigate to project directory
cd Educa

# Generate Xcode project
xcodegen generate

# Open the project
open Educa.xcodeproj
```

### Option 2: Manual Xcode Setup

1. Create new Xcode project: **File → New → Project → iOS App**
2. Name it "Educa"
3. Delete the auto-generated files
4. Drag the `Sources/` folder into Xcode
5. Drag the `Resources/` folder into Xcode
6. Build and run

## 📁 Project Structure

```
Educa/
├── Sources/
│   ├── App/
│   │   └── EducaApp.swift          # App entry point
│   ├── Models/
│   │   ├── AppState.swift          # Global state
│   │   └── Models.swift            # Data models
│   ├── Views/
│   │   ├── Main/
│   │   │   └── ContentView.swift   # Tab container
│   │   ├── Home/
│   │   │   └── HomeView.swift      # Home screen
│   │   ├── StudyHub/
│   │   │   └── StudyHubView.swift  # Universities
│   │   ├── Journey/
│   │   │   └── JourneyView.swift   # Visa info
│   │   ├── Placement/
│   │   │   └── PlacementView.swift # Jobs
│   │   ├── Profile/
│   │   │   └── ProfileView.swift   # User profile
│   │   └── Shared/
│   │       ├── SharedComponents.swift
│   │       ├── DetailViews.swift
│   │       └── PlaceholderViews.swift
│   ├── Services/
│   │   ├── DataService.swift       # Data fetching
│   │   ├── HapticManager.swift     # Haptic feedback
│   │   └── UserDataManager.swift   # User preferences
│   ├── Utilities/
│   │   └── Theme.swift             # Colors, fonts, spacing
│   ├── Assets.xcassets/
│   └── Info.plist
├── Resources/
│   └── Data/
│       ├── universities.json
│       ├── countries.json
│       ├── courses.json
│       ├── jobs.json
│       ├── guides.json
│       ├── services.json
│       └── remittance.json
├── Tests/
├── UITests/
├── project.yml                     # XcodeGen config
└── README.md
```

## 🔧 Configuration

### Bundle ID
Current: `com.educa.app`

To change, edit `project.yml`:
```yaml
settings:
  PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.educa
```

### Brand Color
Current: `#2196F3` (Material Blue)

To change, edit `Theme.swift`:
```swift
static let brand = Color(hex: "YOUR_HEX_COLOR")
```

### Remote Data (GitHub)

To enable live content updates from GitHub:

1. Create a GitHub repository for your data
2. Upload the JSON files from `Resources/Data/`
3. Enable GitHub Pages (Settings → Pages → Deploy from branch)
4. Update `DataService.swift`:

```swift
private let githubBaseURL = "https://raw.githubusercontent.com/YOUR_USERNAME/educa-data/main/data"
```

## 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🎨 Customization

### Adding New Universities/Countries/Jobs

Edit the corresponding JSON file in `Resources/Data/`. The app will automatically display the new content.

### Adding New Features

1. Create model in `Models/`
2. Add JSON file in `Resources/Data/`
3. Update `DataService.swift` to load the data
4. Create view in `Views/`

## 📖 JSON Schema

### University
```json
{
  "id": "uni-001",
  "title": "University Name",
  "location": "City, State",
  "country": "Country",
  "description": "Description...",
  "image": "https://image-url.com/image.jpg",
  "rating": 4.5,
  "programs": ["Program 1", "Program 2"],
  "annual_fee": "USD 30,000",
  "ranking": 50,
  "website": "https://university.edu",
  "student_count": 25000,
  "founded_year": 1950
}
```

### Country
```json
{
  "id": "country-001",
  "name": "Country Name",
  "flag": "🇺🇸",
  "visa_type": "Student Visa",
  "visa_fee": 160,
  "processing_time": "2-4 weeks",
  "success_rate": 90,
  "currency": "USD",
  "language_requirements": "IELTS 6.5...",
  "financial_requirements": "Bank balance of...",
  "document_checklist": ["Passport", "Admission Letter"],
  "health_insurance": "Required",
  "work_permission": "20 hours/week",
  "cost_of_living": "$1500-2000/month",
  "student_benefits": ["Work permit", "Healthcare"],
  "visa_validity": "Duration of study",
  "embassy_website": "https://embassy.gov"
}
```

## 🚀 Deployment

### TestFlight

```bash
# Using dns_system
bash .cursorrules testflight
```

Or manually:
1. Archive: **Product → Archive**
2. Distribute: **Distribute App → App Store Connect**

## 📄 License

MIT License - See LICENSE file for details.

## 🙏 Credits

- Original Flutter app: Educa
- Converted to Swift using DNS System v3.0
- Icons: SF Symbols
- Images: Unsplash, Pexels

---

**Generated by:** DNS Swift App Generator  
**Version:** 1.0.0  
**Date:** December 2024

