# Data Investigation Report

## Issue Summary
User reported that N5 and N4 show the same vocabulary and kanji counts in the app.

## Investigation Results

### Actual Data in JSON Files

**Main Learning Content:**

| Level | Flashcards | Kanji | Grammar |
|-------|-----------|-------|---------|
| N1    | 100       | 10    | 20      |
| N2    | 100       | 10    | 20      |
| N3    | 100       | 10    | 20      |
| N4    | 100       | 10    | 20      |
| N5    | 101       | 30    | 25      |

**Practice Questions (Reading, Listening, Speaking, etc.):**

| Level | Total | Reading | Listening | Speaking | Vocabulary | Grammar | Kanji |
|-------|-------|---------|-----------|----------|------------|---------|-------|
| N1    | 65    | 15      | 10        | 10       | 10         | 10      | 10    |
| N2    | 65    | 15      | 10        | 10       | 10         | 10      | 10    |
| N3    | 65    | 15      | 10        | 10       | 10         | 10      | 10    |
| N4    | 65    | 15      | 10        | 10       | 10         | 10      | 10    |
| N5    | 65    | 15      | 10        | 10       | 10         | 10      | 10    |

### Key Findings

1. **ALL Levels Have Identical Practice Question Counts**: Every level (N1-N5) has the exact same practice structure:
   - 15 Reading questions
   - 10 Listening questions
   - 10 Speaking questions
   - 10 Vocabulary practice questions
   - 10 Grammar practice questions
   - 10 Kanji practice questions
   - **Total: 65 practice questions per level**

2. **N1-N4 Have Identical Main Content Counts**: All four levels (N1, N2, N3, N4) have the same data structure for main content:
   - 100 flashcards
   - 10 kanji characters
   - 20 grammar points

3. **Only N5 Has Slightly Different Main Content**: N5 is the only level with different counts for main content:
   - 101 flashcards (including a test update card)
   - 30 kanji characters
   - 25 grammar points

4. **Content IS Different (But Placeholder)**: Despite having the same counts, the actual content is different between levels:
   - **N5**: "Reading question 1 for N5", "Listening question 1 for N5"
   - **N4**: "Reading question 1 for N4", "Listening question 1 for N4"
   - However, these are clearly **template/placeholder questions**, not real JLPT content

5. **Vocabulary Content IS Different**: The flashcard vocabulary words are genuinely different:
   - **N5**: 学校 (school), 仕事 (work), etc.
   - **N4**: 周り (circumference), 上げる (to raise), 人形 (doll), etc.

6. **Code is Working Correctly**: The `LearningDataService` properly loads different JSON files for each level. The filename is correctly constructed as `japanese_learning_data_N{level}_jisho.json`.

## Root Cause

The JSON files contain **placeholder/template data** that was likely:
- Auto-generated with standardized counts for testing purposes
- Never properly populated with full level-appropriate content
- Using identical structures across levels to ensure app compatibility

**Specifically:**

1. **Practice Questions**: ALL levels (N1-N5) have exactly 65 practice questions with the same breakdown:
   - The questions are labeled per level ("Reading question 1 for N5", "Reading question 1 for N4")
   - But they're generic placeholders, not real JLPT practice content
   - All levels show "15 reading", "10 listening", "10 speaking" making it impossible to distinguish levels

2. **Main Content (N1-N4)**: These levels all have:
   - 100 vocabulary flashcards (content is different, but count is same)
   - 10 kanji (same count across all)
   - 20 grammar points (same count across all)

3. **N5 Exception**: N5 has slightly more content but still uses the same practice question structure

## Why It Appears the Same

When switching between **ANY levels** (N1, N2, N3, N4, or N5):

**Practice Sections (Reading, Listening, Speaking):**
- Always shows: "15 reading", "10 listening", "10 speaking"
- The counts NEVER change between levels
- The actual question content is different ("for N5" vs "for N4") but they're just placeholder text
- Users see identical numbers and assume the data is the same

**Main Content (when switching N1↔N2↔N3↔N4):**
- The counts remain: "100 words", "10 characters", "20 points"
- This makes it APPEAR as if no data change occurred
- The actual vocabulary/kanji/grammar content IS different, but users don't notice

**Main Content (when switching to/from N5):**
- The counts change to: "101 words", "30 characters", "25 points"
- This is visually obvious that different data loaded
- Practice counts still remain the same (65 questions)

## Solution Options

### Option 1: Generate Real Data (Recommended)
Use the data generation scripts in `auto_app_data generation/` to create proper level-appropriate content for each JLPT level with unique, realistic counts.

**Pros:**
- Professional, realistic data for each level
- Proper JLPT progression
- Educational value

**Cons:**
- Requires setting up Python environment
- Needs `requests` library installed
- May need API keys for dictionary sources

### Option 2: Manually Diversify Counts
Quickly edit the JSON files to have different counts to make level switching more obvious:

**Main Content:**

| Level | Target Flashcards | Target Kanji | Target Grammar |
|-------|------------------|--------------|----------------|
| N1    | 150              | 50           | 40             |
| N2    | 130              | 40           | 35             |
| N3    | 110              | 30           | 30             |
| N4    | 100              | 20           | 25             |
| N5    | 101              | 30           | 25             |

**Practice Questions:**

| Level | Reading | Listening | Speaking | Total |
|-------|---------|-----------|----------|-------|
| N1    | 25      | 20        | 15       | 100+  |
| N2    | 20      | 15        | 15       | 85+   |
| N3    | 18      | 12        | 12       | 75+   |
| N4    | 15      | 10        | 10       | 65    |
| N5    | 15      | 10        | 10       | 65    |

**Pros:**
- Quick and easy
- Makes level switching visually obvious
- No dependencies needed

**Cons:**
- Still placeholder data, not real JLPT content
- Requires manual JSON editing
- Need to create/copy practice questions

### Option 3: Use Remote Data Service
The app has a `RemoteDataService` that can fetch data from GitHub. You could:
1. Host proper JLPT data on GitHub
2. Update the remote URLs
3. Let users download proper data

**Pros:**
- Can update data without app updates
- Centralized data management
- Progressive download

**Cons:**
- Requires hosting/maintaining data repository
- Users need internet connection for first load
- More complex setup

## Code Changes Made

✅ **Added Enhanced Logging**: Modified `LearningDataService.swift` to log the first 3 flashcards and kanji when data is loaded, making it easier to verify that different data is being loaded for each level.

✅ **Fixed Kanji Count Display**: Updated `HomeView.swift` to correctly show kanji count from `learningDataService.kanji` instead of trying to find kanji in the flashcards array.

## Next Steps

Choose one of the solution options above based on your priorities:
- **Quick fix**: Option 2 (diversify counts manually)
- **Professional**: Option 1 (generate real data)
- **Scalable**: Option 3 (remote data service)

## Conclusion

**The app code is working correctly.** It properly loads different JSON files for each level.

**The actual issue:** ALL JSON files (N1-N5) contain **identical practice question counts** (65 questions: 15 reading, 10 listening, 10 speaking, etc.), and N1-N4 also have **identical main content counts** (100 vocab, 10 kanji, 20 grammar).

**User Experience Impact:**
- When switching between any levels, Reading/Listening/Speaking sections show the same numbers
- When switching between N1-N4, main content also shows the same numbers
- Only when switching to/from N5 do main content numbers change slightly
- This creates the illusion that "all levels have the same data"

**Reality:**
- The vocabulary/kanji/grammar **content** is actually different between levels
- The practice questions are labeled per level but are generic placeholders
- The **counts** being identical makes it impossible for users to visually confirm level switching worked

**Required Action:** The JSON data files need to be populated with:
1. Different practice question counts per level (especially reading, listening, speaking)
2. Different main content counts for N1-N4 (not all 100, 10, 20)
3. Real JLPT-appropriate content instead of placeholders like "Reading question 1 for N5"

