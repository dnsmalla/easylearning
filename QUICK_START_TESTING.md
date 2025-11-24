# 🚀 Quick Start Testing Guide

## Open and Run the App

### Step 1: Open in Xcode
```bash
open JPLearning/JLearn.xcodeproj
```

### Step 2: Select Simulator
- Choose any iPhone simulator from the device dropdown
- Recommended: iPhone 15, iPhone 16, or iPhone SE

### Step 3: Build and Run
- Press **⌘+R** (or click the Play button)
- Wait for app to launch in simulator

---

## What to Test

### ✅ App Launch
- App should launch without crashes
- Loading screen appears briefly
- Sign-in screen displays

### ✅ Sign In
- Tap "Sign In" or "Continue without Account"
- Home screen should appear

### ✅ Data Loading
**Watch Console Logs (⌘+⇧+C to show console):**
```
✅ Found bundled JSON for n5
📊 Loaded data counts for level n5:
   - Lessons: 8
   - Flashcards: 101
   - Grammar: 25
   - Kanji: 30
```

### ✅ Home Screen
- Should show 4 cards: Learn, Practice, Flashcards, Games
- Current level badge (N5) should display
- Streak counter should show

### ✅ Navigation
Test each tab:
1. **Home** - Main dashboard
2. **Practice** - Practice exercises
3. **Flashcards** - Flashcard review
4. **Games** - Learning games
5. **Profile** - User profile & settings

### ✅ Level Switching
1. Go to Profile tab
2. Tap Settings
3. Change JLPT Level (try N4, N3, N2, N1)
4. Return to Home
5. Verify new level data loads

---

## Expected Console Output

```
🚀 JLearn launched - Japanese Learning App
✅ Firebase configured successfully (or demo mode message)
🔄 [DATA] Starting loadLearningData for level: n5
📁 [DATA] Looking for file: japanese_learning_data_n5_jisho.json
✅ [DATA] Found file at: [...]/Resources/japanese_learning_data_n5_jisho.json
✅ Found bundled JSON for n5
📊 [DATA] Loaded data counts for level n5:
   - Lessons: 8
   - Flashcards: 101
   - Grammar: 25
   - Kanji: 30
   - Exercises: 7
   - Games: 4
📝 First 3 flashcards:
   1. テスト更新 - 🎉 UPDATE TEST - GitHub data updated successfully!
   2. 学校 - school
   3. 仕事 - work; job; labor; labour; business
```

---

## Troubleshooting

### App Doesn't Launch
```bash
# Clean build folder
cd JPLearning
rm -rf ~/Library/Developer/Xcode/DerivedData/JLearn*
xcodebuild clean -project JLearn.xcodeproj -scheme JLearn
```

### Data Not Loading
```bash
# Verify data files exist
ls -lh JPLearning/Resources/*.json
```

### Build Errors
```bash
# Rebuild from command line
cd JPLearning
xcodebuild -project JLearn.xcodeproj -scheme JLearn -configuration Debug build
```

---

## Success Indicators

✅ App launches without crash  
✅ Console shows "BUILD SUCCEEDED"  
✅ Data counts appear in logs  
✅ Home screen displays content  
✅ Navigation works smoothly  
✅ Level switching loads new data  

---

## Performance Metrics

Expected load times:
- **App Launch:** < 2 seconds
- **Data Loading:** < 1 second (bundled)
- **Level Switch:** < 0.5 seconds
- **Screen Navigation:** Instant

---

## Report Issues

If you find any issues:

1. **Check Console Logs** - Look for ❌ or ⚠️ messages
2. **Screenshot the Error** - Helps with debugging
3. **Note the Steps** - What did you do before the issue?
4. **Check Data Files** - Run `bash verify_data_integrity.sh`

---

**All systems ready! Start testing now! 🎉**
