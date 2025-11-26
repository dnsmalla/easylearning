# NPLearn App - Level-Based Data Architecture

## ✅ COMPLETED: Level-Driven Data System

### Data Structure
```
nplearning/
├── reading.json (16KB)
│   └── levels: { beginner, elementary, intermediate, advanced, proficient }
├── writing.json (11KB)
│   └── levels: { beginner, elementary, intermediate, advanced, proficient }
├── speaking.json (11KB)
│   └── levels: { beginner, elementary, intermediate, advanced, proficient }
├── games.json (2KB)
├── manifest.json (2KB)
└── nepali_learning_data_*.json (5 files, 127KB total)
```

### App Flow

#### 1. Home Level Selection
```swift
@Published var currentLevel: LearningLevel = .beginner
```
**User changes level → Entire app updates**

#### 2. Data Loading (Level-Filtered)
```swift
// LearningDataService.swift
func loadLearningData() async {
    let level = currentLevel  // e.g., .beginner
    
    // Load level-specific data
    let speaking = JSONParserService.shared.parseSpeaking(from: "speaking", level: level)
    let writing = JSONParserService.shared.parseWriting(from: "writing", level: level)
    let reading = JSONParserService.shared.parseReading(from: "reading", level: level)
    
    // All data is now filtered to currentLevel
}
```

#### 3. Parsing with Level Filter
```swift
// JSONParserService.swift
func parseSpeaking(from filename: String, level: LearningLevel) -> [SpeakingExercise] {
    let levelKey = level.rawValue.lowercased()  // "beginner"
    return speakingData.levels[levelKey] ?? []  // Returns only beginner data
}
```

### Key Features

#### ✅ Single Source of Truth
- Home level selection (`currentLevel`) controls ALL views
- No duplicate level selectors needed per view
- Consistent experience across the entire app

#### ✅ Automatic Updates
When user changes level:
1. `LearningDataService.setLevel(.elementary)`
2. Triggers `loadLearningData()`
3. Reloads all data filtered by new level
4. `@Published` properties notify all views
5. UI updates automatically

#### ✅ Data Organization
Each JSON contains ALL levels:
```json
{
  "category": "speaking",
  "levels": {
    "beginner": [/* beginner exercises */],
    "elementary": [/* elementary exercises */],
    "intermediate": [/* intermediate exercises */],
    ...
  }
}
```

### Views Using Level-Filtered Data

| View | Data Source | Filtered By |
|------|-------------|-------------|
| Reading | `readingPassages` | `currentLevel` |
| Writing | `writingExercises` | `currentLevel` |
| Speaking | `speakingExercises` | `currentLevel` |
| Flashcards | `flashcards` | `currentLevel` |
| Grammar | `grammarPoints` | `currentLevel` |
| Games | `games` | `currentLevel` |

### Data Generation & Sync

#### Automated Sync Script
```bash
python3 nplearn_auto_data/core/tools/sync_to_app.py
```
- Validates JSON structure
- Syncs `nplearning/` → `NPLearn/Resources/`
- Ensures data integrity

#### GitHub Push
```bash
# Only push data folders (never app source)
git add nplearning/*.json
git commit -m "Update learning data"
git push
```

### Technical Implementation

#### Models
- `SpeakingExercise` - Phrases & dialogues
- `WritingExercise` - Script & composition exercises
- `ReadingPassageModel` - Comprehension passages
- All support `level: String` property

#### Services
- `JSONParserService` - Parses & filters JSON by level
- `LearningDataService` - Manages data loading & level switching
- `RemoteDataService` - Downloads updates from GitHub

#### Published Properties
```swift
@Published var speakingExercises: [SpeakingExercise] = []
@Published var writingExercises: [WritingExercise] = []
@Published var readingPassages: [ReadingPassageModel] = []
```

### Benefits

1. **User Experience**
   - One level selection controls everything
   - No confusion with multiple level selectors
   - Consistent difficulty across all features

2. **Developer Experience**
   - Easy to add new content (just edit JSON)
   - Level-based organization is intuitive
   - No hardcoded data in app

3. **Data Management**
   - All levels in one file = easier to manage
   - Automated sync prevents errors
   - GitHub-hosted data for easy updates

4. **Performance**
   - Only loads data for current level
   - Smaller memory footprint
   - Faster data loading

---

**Status**: ✅ Complete & Production-Ready
**Last Updated**: Nov 26, 2024
