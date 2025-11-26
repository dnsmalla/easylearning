# NPLearn - Nepali Language Learning App 🇳🇵

A beautifully crafted iOS application for learning Nepali, built with SwiftUI and Firebase with enterprise-grade architecture.

## ✨ Features

### 🎓 Comprehensive Learning System
- **Level-based Learning** (Beginner to Proficient)
  - Beginner: 500 Vocabulary, 30 Grammar points
  - Elementary: 1,000 Vocabulary, 50 Grammar points
  - Intermediate: 2,000 Vocabulary, 80 Grammar points
  - Advanced: 4,000 Vocabulary, 120 Grammar points
  - Proficient: 8,000 Vocabulary, 200 Grammar points

- **Multiple Practice Modes**
  - Vocabulary Builder with Devanagari script and romanization
  - Grammar Lessons with detailed explanations
  - Listening Exercises for comprehension training
  - Speaking Practice with speech recognition
  - Writing Practice for script mastery
  - Reading Practice for comprehension

### 🎮 Interactive Learning Games
- **Daily Quest** - Complete daily challenges
- **Word Match** - Match words with meanings
- **Time Attack** - Quick-fire question rounds
- **Quick Quiz** - Test your knowledge

### 📚 Study Tools
- **Flashcard System** with spaced repetition
- **Audio Pronunciation** with Text-to-Speech (Nepali)
- **Progress Tracking** with streaks and statistics
- **Favorites System** for bookmarking content
- **Romanization Support** for learning Devanagari script

### 🔐 Authentication
- Email/Password sign-in
- Sign in with Apple
- Secure Firebase authentication
- Profile management

### 📊 Progress Tracking
- Total points earned
- Daily study streak
- Completed lessons tracking
- Level progression
- Performance analytics
- Accuracy statistics

## 🏗 Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)** architecture
- **SwiftUI** for declarative UI
- **Combine** for reactive programming
- **Async/await** for concurrency
- **Protocol-oriented** design

### Tech Stack

#### Frontend
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming
- **AVFoundation** - Audio playback and recording
- **Speech** - Speech recognition
- **AVSpeechSynthesizer** - Text-to-Speech for Nepali

#### Backend & Services
- **Firebase Authentication** - User management
- **Local Storage** - UserDefaults for offline data
- **JSON Data** - Embedded learning content

#### Utilities
- **Network** - Connectivity monitoring
- **CryptoKit** - Secure authentication
- **AuthenticationServices** - Sign in with Apple

## 📁 Project Structure

```
NPLearn/
├── Sources/
│   ├── NPLearnApp.swift          # Main app entry point
│   │
│   ├── Core/
│   │   ├── AppTheme.swift              # Design system (Nepal colors)
│   │   ├── AppTheme+Extensions.swift   # Theme utilities
│   │   ├── AppConfiguration.swift      # App configuration
│   │   ├── FeatureFlags.swift          # Feature toggles
│   │   └── ProductionConfig.swift      # Production settings
│   │
│   ├── Models/
│   │   └── LearningModels.swift        # All data models
│   │       - UserModel
│   │       - Lesson
│   │       - Flashcard
│   │       - GrammarPoint
│   │       - Exercise
│   │       - PracticeQuestion
│   │
│   ├── Services/
│   │   ├── AuthService.swift           # Authentication
│   │   ├── LearningDataService.swift   # Data management
│   │   ├── AudioService.swift          # Audio & TTS (Nepali)
│   │   ├── JSONParserService.swift     # JSON parsing
│   │   └── SampleDataService.swift     # Demo data
│   │
│   ├── Utilities/
│   │   ├── NetworkMonitor.swift        # Network status
│   │   ├── AppError.swift              # Error handling
│   │   ├── InputValidator.swift        # Input validation
│   │   ├── Haptics.swift               # Haptic feedback
│   │   ├── AppLogger.swift             # Logging system
│   │   ├── ToastManager.swift          # Toast notifications
│   │   ├── AccessibilityIdentifiers.swift  # UI testing
│   │   └── RetryManager.swift          # Retry logic
│   │
│   ├── Views/
│   │   ├── Auth/
│   │   │   └── SignInView.swift        # Sign in & sign up
│   │   ├── Home/
│   │   │   └── HomeView.swift          # Home screen
│   │   ├── Practice/
│   │   │   └── PracticeViews.swift     # All practice screens
│   │   ├── Flashcards/
│   │   │   └── FlashcardViews.swift    # Flashcard system
│   │   ├── Games/
│   │   │   └── GamesView.swift         # Learning games
│   │   └── Profile/
│   │       └── ProfileView.swift       # User profile
│   │
│   ├── Assets.xcassets/                # App icons & images
│   ├── Info.plist
│   ├── NPLearn.entitlements
│   └── GoogleService-Info.plist
│
├── Tests/                              # Unit tests
├── UITests/                            # UI tests
├── nepali_learning_data.json          # Learning content
├── project.yml                         # XcodeGen project file
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- **Xcode** 15.0 or later
- **iOS** 16.0 or later
- **Firebase** project (optional)
- **Apple Developer** account (for Sign in with Apple)
- **XcodeGen** (for project generation)

### Installation

1. **Navigate to the project directory**
   ```bash
   cd /Users/dinsmallade/Desktop/auto_sys/auto_swift/NPLearn
   ```

2. **Configure Firebase** (Optional)
   - Create a Firebase project at https://console.firebase.google.com
   - Add an iOS app to your Firebase project
   - Download `GoogleService-Info.plist` and replace the placeholder
   - Enable Authentication (Email/Password and Apple)

3. **Install XcodeGen**
   ```bash
   brew install xcodegen
   ```

4. **Generate Xcode project**
   ```bash
   xcodegen generate
   ```

5. **Open the project**
   ```bash
   open NPLearn.xcodeproj
   ```

6. **Configure signing**
   - Update the `DEVELOPMENT_TEAM` in `project.yml` with your team ID
   - Enable Sign in with Apple capability in Xcode
   - Configure your bundle identifier if needed

7. **Run the app**
   - Select a simulator or device
   - Build and run (⌘R)

## 🎨 Design System

### Color Palette
- **Primary**: Red (#E63946) - Nepal flag color
- **Secondary**: Blue (#3366CC) - Nepal flag color
- **Tertiary**: Orange (#FF9F1C) - Highlights
- **Accent**: Purple (#9C27B0) - Special actions

### Category Colors
- **Vocabulary**: Green tint
- **Grammar**: Orange tint
- **Listening**: Purple tint
- **Speaking**: Red tint
- **Writing**: Teal tint
- **Reading**: Blue tint

### Typography
- **Devanagari**: System font for best Nepali rendering
- **Romanization**: Caption-sized for pronunciation help
- **English**: Rounded system font for UI elements

## 🔧 Configuration

### App Configuration (`AppConfiguration.swift`)
- Learning levels and content counts
- Audio settings (Nepali TTS)
- Practice session sizes
- Network timeouts
- Feature flags

### User Defaults
- Current level
- Study streak
- Last study date
- Audio preferences
- Notifications settings
- Romanization toggle

## 📱 App Features

### Tab Navigation
1. **Home** - Level selection and progress overview
2. **Practice** - All practice modes (6 categories)
3. **Flashcards** - Flashcard system with spaced repetition
4. **Games** - Interactive learning games
5. **Profile** - User profile and settings

### Practice Categories
- Vocabulary Practice (Devanagari + Romanization)
- Grammar Practice (Nepali grammar rules)
- Listening Practice (Audio comprehension)
- Speaking Practice (Pronunciation)
- Writing Practice (Devanagari script)
- Reading Practice (Comprehension)

### Learning Games
- Daily Quest - Daily challenges
- Word Match - Matching game
- Time Attack - Timed questions
- Quick Quiz - Knowledge test

## 🔐 Security

- Firebase Security Rules (if enabled)
- Secure authentication with Firebase Auth
- Sign in with Apple for privacy
- Input validation on all user inputs
- Local data encryption

## 🧪 Testing

### Unit Tests
```bash
⌘U in Xcode (NPLearnTests scheme)
```

### UI Tests
```bash
Select NPLearnUITests scheme and ⌘U
```

## 📦 Dependencies

### Swift Package Manager
- Firebase SDK (Auth) - Optional

### System Frameworks
- SwiftUI
- Combine
- AVFoundation
- Speech
- Network
- CryptoKit
- AuthenticationServices

## 🌐 Localization

Currently supports:
- English (UI)
- Nepali (Learning content with Devanagari script)
- Romanization for pronunciation help

## 🚀 Building for Release

1. Update version in `project.yml`
2. Run `xcodegen generate`
3. Archive the app (Product → Archive)
4. Upload to App Store Connect

### App Store Information
- **Category**: Education
- **Age Rating**: 4+
- **Price**: Free
- **Keywords**: Nepali, Learning, Language, Nepal, Devanagari

## 📝 Learning Content

The app includes:
- **15+ Flashcards** for Beginner level
- **5+ Grammar Points** covering essential Nepali grammar
- **10+ Practice Questions** across all categories
- **Sample Data Service** for demonstration
- **JSON-based** expandable content structure

### Adding More Content

Edit `nepali_learning_data.json` to add:
- More flashcards
- Additional grammar points
- New practice questions
- Different levels (Elementary, Intermediate, etc.)

## 🤝 Contributing

This app is based on the JLearn architecture, adapted for Nepali language learning.

## 📄 License

Copyright © 2025 NPLearn. All rights reserved.

## 🙏 Acknowledgments

- **Firebase** for backend services
- **SF Symbols** for icons
- **JLearn** app architecture for reference
- Nepali language resources and grammar references

## 📧 Support

For support, contact: support@nplearn.com

## 📚 Nepali Language Features

### Devanagari Script
- Full Devanagari (देवनागरी) character support
- Romanization for pronunciation guidance
- Unicode range: U+0900–U+097F

### Text-to-Speech
- Native Nepali TTS using AVSpeechSynthesizer
- Language code: "ne-NP"
- Adjustable speech rate for learning

### Grammar Support
- Nepali verb conjugations
- Case markers (को, ले, लाई, मा)
- Tenses and aspects
- Honorific forms

---

**Built with ❤️ for Nepali learners worldwide using SwiftUI and Firebase**

🇳🇵 **नमस्ते! Start your Nepali learning journey today!** 🇳🇵

