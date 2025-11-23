# Practice Views Fixed - Now Loading from JSON

## Problem Identified

**User Report:** "Only vocabulary and grammar works, other sections are not correctly changing according to level."

## Root Cause

The practice views were loading data in different ways:

### ✅ **Working Correctly (Already using JSON):**
1. **Vocabulary** - Uses `learningDataService.flashcards` (loaded from JSON)
2. **Grammar** - Uses `learningDataService.grammarPoints` (loaded from JSON)
3. **Listening** - Uses `learningDataService.loadPracticeQuestions(category: .listening)` (loads from JSON)

### ❌ **NOT Working (Using hardcoded data):**
1. **Reading** - Was using `ReadingPassage.samplePassages` (hardcoded samples)
2. **Speaking** - Was only doing speech recognition, not loading any practice content
3. **Kanji** - Was using `learningDataService.kanji` (which IS from JSON), but the count display was wrong

## Changes Made

### 1. Fixed Reading Practice View
**File:** `JPLearning/Sources/Views/Practice/ReadingPracticeView.swift`

**Before:**
```swift
private func loadPassages() async {
    isLoading = true
    passages = ReadingPassage.samplePassages  // ❌ Hardcoded
    isLoading = false
}
```

**After:**
```swift
private func loadPassages() async {
    isLoading = true
    // ✅ Load reading questions from JSON data
    let readingQuestions = await learningDataService.loadPracticeQuestions(category: .reading)
    
    // Convert practice questions to reading passages
    if !readingQuestions.isEmpty {
        passages = readingQuestions.enumerated().map { index, question in
            ReadingPassage(
                title: "Reading \(index + 1)",
                content: question.question,
                questions: [
                    ReadingQuestion(
                        question: question.question,
                        options: question.options,
                        correctAnswer: question.correctAnswer,
                        explanation: nil
                    )
                ],
                level: learningDataService.currentLevel
            )
        }
    } else {
        // Fallback to sample passages if no JSON data
        passages = ReadingPassage.samplePassages
    }
    isLoading = false
}
```

### 2. Completely Rewrote Speaking Practice View
**File:** `JPLearning/Sources/Views/Practice/PracticeViews.swift`

**Before:**
- Simple speech recognition interface
- No practice questions or prompts
- No level-specific content

**After:**
- ✅ Loads speaking questions from JSON: `learningDataService.loadPracticeQuestions(category: .speaking)`
- Shows question prompts from JSON data
- Speech recognition for practice
- "Show Answer" button
- Progress tracking and scoring
- Results view at the end
- Reloads when level changes with `.reloadOnLevelChange`

### 3. Added Missing Category to Enum
**File:** `JPLearning/Sources/Models/LearningModels.swift`

**Problem:** The JSON files contained "reading" category, but the Swift enum didn't have it.

**Fix:**
```swift
enum PracticeCategory: String, Codable, CaseIterable {
    case kanji = "Kanji"
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case reading = "Reading"      // ✅ Added
    case listening = "Listening"
    case speaking = "Speaking"
    case writing = "Writing"
}
```

### 4. Fixed Kanji Count Display (Earlier Fix)
**File:** `JPLearning/Sources/Views/Home/HomeView.swift`

Changed from looking for kanji in flashcards (which don't exist) to using the actual kanji array:

```swift
private var todayKanjiDue: Int {
    return learningDataService.kanji.count  // ✅ Now shows correct count (30 for N5)
}
```

## How It Works Now

All practice sections now follow the **same pattern** as Vocabulary and Grammar:

1. **Data Source:** Load from `learningDataService.practiceQuestions` (which comes from JSON)
2. **Level Changes:** Automatically reload when user switches levels using `.reloadOnLevelChange` modifier
3. **Fallback:** If no JSON data exists, show "No exercises" or use sample data

## Data Flow

```
JSON Files (Resources/)
    ↓
LearningDataService.loadLearningData()
    ↓
JSONParserService.parseAllData()
    ↓
learningDataService.practiceQuestions = parsed.practice
    ↓
Practice Views call loadPracticeQuestions(category: .xxx)
    ↓
Filter by category (reading, listening, speaking, etc.)
    ↓
Display questions to user
```

## Current JSON Data Status

⚠️ **Important Note:** While all views now correctly load from JSON, the JSON files themselves still have **identical counts** across levels:

| Level | Reading | Listening | Speaking |
|-------|---------|-----------|----------|
| ALL   | 15      | 10        | 10       |

This means the counts will still appear the same when switching levels **until the JSON files are populated with level-specific content**.

## What This Fixes

✅ **Reading, Listening, and Speaking now:**
- Load from JSON (not hardcoded samples)
- Change when user switches levels
- Use the same data architecture as Vocabulary and Grammar

✅ **Kanji:**
- Shows correct count (was showing 0, now shows 30 for N5)

## What Still Needs to Be Done

To make level switching visually obvious, the JSON files need to be populated with different quantities of practice questions per level. See `DATA_INVESTIGATION_REPORT.md` for recommendations.

## Testing

Run the app and:
1. ✅ Reading practice should show 15 questions from JSON
2. ✅ Speaking practice should show 10 prompts with speech recognition
3. ✅ Listening practice should show 10 audio questions
4. ✅ Kanji should show "30 due" instead of "0 due"
5. ✅ When switching levels, all sections should reload their content

The **counts** will still be the same across N1-N4 because the JSON data has identical quantities, but the **content** will be different (questions will be labeled "for N5", "for N4", etc.).

