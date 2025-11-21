# ✅ COMPLETE DATA FLOW TEST CHECKLIST

## 📋 TEST PROCEDURE

Follow these steps in order and check the console output in Xcode:

---

## TEST 1: ✅ Data Loads from JSON Correctly

### What to Check:
Open Xcode Console and look for these messages when app launches:

```
🔄 [DATA] Starting loadLearningData for level: N5
✅ Loaded from bundled JSON: 101 flashcards, 25 grammar, XX practice
📚 [KANJI] Starting to load kanji for level: N5
📚 [KANJI] Calling RemoteDataService.loadKanjiData...
✅ Loaded 30 kanji from bundled JSON
📚 [KANJI] Received 30 kanji from RemoteDataService
📚 [KANJI] First kanji: 一 (level: N5)
📚 [KANJI] Filtering for level: N5
📚 [KANJI] After filtering: 30 kanji
✅ [KANJI] Successfully loaded 30 kanji for level N5
```

### Expected Results:
- [ ] See "✅ Loaded from bundled JSON" message
- [ ] See "✅ Loaded XX kanji from bundled JSON"
- [ ] Kanji count matches JSON file (N5=30, N4-N1=10)
- [ ] First kanji character is shown (e.g., 一)

### ❌ If You See:
- "❌ Failed to parse kanji from bundled JSON" → JSON parsing error
- "⚠️ No kanji data available" → Kanji never loaded
- "⚠️ Filtering returned 0 kanji!" → Level mismatch

---

## TEST 2: ✅ Data Assigned to @Published Properties

### What to Check:
Look for this in console after loading:

```
📊 [DATA] Loaded data counts:
   - Lessons: X
   - Flashcards: 101
   - Grammar: 25
   - Kanji: 30
   - Exercises: X
✅ [DATA] All data assigned to @Published properties
   - self.kanji.count = 30
```

### Expected Results:
- [ ] "Kanji: 30" matches your level's count
- [ ] "self.kanji.count = 30" confirms assignment
- [ ] No errors between loading and assignment

### ❌ If You See:
- "Kanji: 0" → Loading failed completely
- Different count than JSON → Filtering removed data

---

## TEST 3: ✅ Numbers Update on Home Screen

### What to Check:
1. Look at Home Screen
2. Select different levels (N5, N4, N3, N2, N1)
3. Watch "Study Materials" counts update

### Expected Results for Each Level:

| Level | Kanji | Vocabulary | Grammar |
|-------|-------|------------|---------|
| N5    | 30    | 101        | 25      |
| N4    | 10    | 100        | 20      |
| N3    | 10    | 100        | 20      |
| N2    | 10    | 100        | 20      |
| N1    | 10    | 100        | 20      |

### Test Checklist:
- [ ] N5 shows 30 kanji, 101 words, 25 grammar
- [ ] N4 shows 10 kanji, 100 words, 20 grammar
- [ ] N3 shows 10 kanji, 100 words, 20 grammar
- [ ] N2 shows 10 kanji, 100 words, 20 grammar
- [ ] N1 shows 10 kanji, 100 words, 20 grammar
- [ ] Counts CHANGE when switching levels
- [ ] No "3" for everything (that means cached data!)

---

## TEST 4: ✅ Level Data Used Correctly

### What to Check:
1. Switch to N5 level
2. Go to Kanji Practice
3. Check console logs:

```
👀 [KANJI VIEW] View appeared
👀 [KANJI VIEW] Current level: N5
👀 [KANJI VIEW] Kanji count: 30
🎯 [KANJI VIEW] kanjiList computed: 30 kanji
🎯 [KANJI VIEW] Current level: N5
✅ [KANJI VIEW] First kanji: 一
```

4. Switch to N4 level
5. Go to Kanji Practice again
6. Verify console shows:

```
👀 [KANJI VIEW] Current level: N4
👀 [KANJI VIEW] Kanji count: 10
🎯 [KANJI VIEW] kanjiList computed: 10 kanji
✅ [KANJI VIEW] First kanji: (N4 first kanji)
```

### Expected Results:
- [ ] Console shows correct level name
- [ ] Kanji count matches that level
- [ ] First kanji character is displayed
- [ ] NO "❌ [KANJI VIEW] Kanji list is EMPTY!"

### ❌ If You See:
- "Kanji count: 0" → Data not reaching view
- Same count for all levels → Not switching data
- "Kanji list is EMPTY!" → Array is empty in view

---

## TEST 5: ✅ Kanji Practice Shows Data

### What to Check:
1. Open Kanji Practice
2. Should see large kanji character (e.g., 一)
3. Click "Show Answer"
4. Should see:
   - Meaning: "one"
   - 音読み: イチ, イツ
   - 訓読み: ひと
   - Strokes: 1
   - Examples: 一人 (ひとり), 一つ (ひとつ)

### Test Each Level:
- [ ] N5: Shows 30 different kanji when navigating
- [ ] N4: Shows 10 different kanji
- [ ] N3: Shows 10 different kanji
- [ ] N2: Shows 10 different kanji
- [ ] N1: Shows 10 different kanji

### Expected Console (when viewing kanji):
```
🎯 [KANJI VIEW] kanjiList computed: 30 kanji
✅ [KANJI VIEW] First kanji: 一
```

### ❌ If You See:
- "No Kanji Available" → Array is empty
- Same kanji in all levels → Not filtering by level
- Missing details → Kanji model incomplete

---

## 🔍 COMMON ISSUES & SOLUTIONS

### Issue 1: Still seeing "3" for all counts
**Cause**: Old cached data in UserDefaults
**Solution**: 
1. Delete app from simulator
2. Clean build folder (⌘ + Shift + K)
3. Run again

### Issue 2: "No Kanji Available" screen
**Cause**: Kanji array is empty
**Check Console For**:
- "❌ [KANJI] Remote data loading for kanji failed"
- "⚠️ [KANJI] No kanji data available"
- "❌ [KANJI VIEW] Kanji list is EMPTY!"

**Solutions**:
1. Check bundled JSON files exist in app bundle
2. Verify JSON has "kanji" section
3. Check jlptLevel matches (uppercase N5, N4, etc.)

### Issue 3: Wrong numbers on home screen
**Cause**: Counting logic issue in HomeView
**Check**: `LearningLevel.kanjiCount` property values

### Issue 4: Console shows errors
**Look For**:
- "Failed to parse kanji" → JSON structure mismatch
- "File not found" → JSON not bundled
- "Decoding failed" → Model doesn't match JSON

---

## ✅ SUCCESS CRITERIA

**All tests pass when:**
1. ✅ Console shows "Loaded XX kanji from bundled JSON"
2. ✅ Console shows correct counts after loading
3. ✅ Home screen shows different numbers for each level
4. ✅ Switching levels updates all counts
5. ✅ Kanji Practice shows kanji cards (not empty state)
6. ✅ Each kanji has: character, meaning, readings, examples
7. ✅ Different levels show different kanji

---

## 🐛 DEBUGGING COMMANDS

### Check if JSON files are in app bundle:
In Xcode:
1. Product > Show Build Folder in Finder
2. Navigate to `Products/Debug-iphonesimulator/JLearn.app`
3. Right-click > Show Package Contents
4. Should see all 5 `japanese_learning_data_nX_jisho.json` files

### Verify JSON structure:
```bash
cd JPLearning/Resources
grep -c '"id":' japanese_learning_data_n5_jisho.json
# Should show ~250+ (101 flashcards + 25 grammar + 30 kanji + practice)

grep '"jlptLevel":' japanese_learning_data_n5_jisho.json | head -3
# Should show "jlptLevel": "N5" (uppercase!)
```

### Clear all cached data:
1. Simulator > Device > Erase All Content and Settings
2. Or: Delete app > Clean build > Run again

---

## 📊 EXPECTED CONSOLE OUTPUT (Complete Flow)

When everything works, you should see this in console:

```
🔄 [DATA] Starting loadLearningData for level: N5

// Flashcards loading
✅ Loaded from bundled JSON: 101 flashcards, 25 grammar, XX practice

// Kanji loading
📚 [KANJI] Starting to load kanji for level: N5
📚 [KANJI] Calling RemoteDataService.loadKanjiData...
🔄 Loading kanji for N5...
✅ Loaded 30 kanji from bundled JSON
📚 [KANJI] Received 30 kanji from RemoteDataService
📚 [KANJI] First kanji: 一 (level: N5)
📚 [KANJI] Filtering for level: N5
📚 [KANJI] After filtering: 30 kanji
✅ [KANJI] Successfully loaded 30 kanji for level N5

// Final counts
📊 [DATA] Loaded data counts:
   - Lessons: X
   - Flashcards: 101
   - Grammar: 25
   - Kanji: 30
   - Exercises: X
✅ [DATA] All data assigned to @Published properties
   - self.kanji.count = 30

// When opening Kanji Practice
👀 [KANJI VIEW] View appeared
👀 [KANJI VIEW] Current level: N5
👀 [KANJI VIEW] Kanji count: 30
🎯 [KANJI VIEW] kanjiList computed: 30 kanji
🎯 [KANJI VIEW] Current level: N5
✅ [KANJI VIEW] First kanji: 一
```

---

## 🎯 NEXT STEPS

1. **Clean Build**:
   - Product > Clean Build Folder (⌘ + Shift + K)

2. **Delete App**:
   - In Simulator: Long press > Remove App

3. **Build & Run**:
   - Product > Run (⌘ + R)

4. **Watch Console**:
   - Look for all the log messages above
   - Identify where the flow breaks

5. **Test Each Item**:
   - Follow this checklist step by step
   - Check off each completed test
   - Note any failures with console output

6. **Report Issues**:
   - Share console output if something fails
   - Specify which test failed
   - Include what you see vs. what's expected

