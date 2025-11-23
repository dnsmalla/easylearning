# ⌨️ XCODE BUILD COMMANDS

## 🎯 Your Next Steps

Xcode is **already open** with your project. Just follow these keyboard shortcuts:

---

## 🔨 BUILD STEPS

### 1️⃣ Clean Build Folder
```
Press: ⌘ + Shift + K
(Command + Shift + K)
```
This removes old build artifacts.

### 2️⃣ Build Project
```
Press: ⌘ + B
(Command + B)
```
This compiles all the code.

**Expected:** "Build Succeeded" ✅

### 3️⃣ Run App
```
Press: ⌘ + R
(Command + R)
```
This launches the app in simulator.

---

## 🧪 TESTING STEPS

### Test Reading Practice:
1. App launches
2. Tap **Practice** tab (bottom)
3. Tap **Reading** card
4. **CHECK:**
   - ✅ See Japanese passage first
   - ✅ See vocabulary (word, reading, meaning)
   - ✅ See question
   - ✅ See options labeled **A, B, C, D** (not "Option 1, 2, 3")
5. Select an answer
6. **CHECK:**
   - ✅ Correct answer shows green circle + ✓
   - ✅ Wrong answer shows red circle + ✗
7. Tap "Next Passage"

### Test Listening Practice:
1. Go back to Practice
2. Tap **Listening** card
3. **CHECK:**
   - ✅ See question FIRST (before audio)
   - ✅ See audio player
4. Tap "Play Audio"
5. **CHECK:**
   - ✅ See "Played 1 time"
6. Tap again
7. **CHECK:**
   - ✅ See "Played 2 times"
8. Select answer (A, B, C, D)
9. **CHECK:**
   - ✅ See transcript
   - ✅ See translation

---

## ✅ SUCCESS INDICATORS

### Build Succeeded If:
- ✅ No red errors in Xcode
- ✅ "Build Succeeded" message
- ✅ App icon appears in simulator

### Practice Views Work If:
- ✅ Reading shows passage + vocabulary
- ✅ Options show A, B, C, D (with circles)
- ✅ Listening shows question first
- ✅ Audio can be replayed
- ✅ Colors change when selecting answers

---

## 🐛 IF BUILD FAILS

### Error: "Cannot find X in scope"
**Solution:**
```
1. Clean: ⌘ + Shift + K
2. Close Xcode
3. Reopen Xcode
4. Build: ⌘ + B
```

### Error: "Duplicate symbols"
**Solution:**
Check for duplicate files:
```bash
cd JPLearning/Sources/Views/Practice
ls -la
# Should see only these files:
# - PracticeViews.swift
# - ReadingPracticeView.swift
# - (other practice files)
```

### Error: "Missing imports"
**Solution:**
All files should import SwiftUI - already done!

---

## 📱 SIMULATOR CONTROLS

### Keyboard Shortcuts:
- **Rotate**: ⌘ + Left/Right Arrow
- **Home**: ⌘ + Shift + H
- **Screenshot**: ⌘ + S

### In App:
- Tap with mouse = Touch with finger
- Scroll with mouse = Swipe gesture

---

## 🎯 WHAT YOU SHOULD SEE

### Reading Practice Screen:
```
┌─────────────────────────────┐
│ ← Reading Practice          │
├─────────────────────────────┤
│ Progress: 1 of 3            │
│ Score: 0 correct            │
├─────────────────────────────┤
│                              │
│ 📖 Read the passage...      │
│ [Japanese text here]        │
│                              │
│ 📚 Key Vocabulary           │
│ • Word (reading) - meaning  │
│                              │
│ ❓ Answer the question      │
│ [Question here]             │
│                              │
│ ⓐ Option A                 │
│ ⓑ Option B                 │
│ ⓒ Option C                 │
│ ⓓ Option D                 │
└─────────────────────────────┘
```

### Listening Practice Screen:
```
┌─────────────────────────────┐
│ ← Listening Practice        │
├─────────────────────────────┤
│ Progress: 1 of 4            │
│ Score: 0 correct            │
├─────────────────────────────┤
│                              │
│ ❓ Question                 │
│ [Question text here]        │
│                              │
│ 🎧 Listen Carefully         │
│     [Audio icon]            │
│   [▶ Play Audio]           │
│   Played 0 times            │
│                              │
│ ⓐ Option A                 │
│ ⓑ Option B                 │
│ ⓒ Option C                 │
│ ⓓ Option D                 │
└─────────────────────────────┘
```

---

## 🎉 SUMMARY

**Status:** ✅ Ready to build!  
**Files:** ✅ All updated  
**Errors:** ✅ None found  
**Next:** Press `⌘ + B` in Xcode!

---

## 📚 More Info

See these files for details:
- `FINAL_SUMMARY.md` - Complete overview
- `BUILD_AND_TEST_GUIDE.md` - Detailed testing
- `WHAT_CHANGED.md` - Before/after comparison
- `QUICK_REFERENCE.md` - Quick visual guide

---

**Good luck!** 🚀

The practice views are now:
- ✅ Professional
- ✅ Educational
- ✅ With A, B, C, D options (not "Option 1, 2, 3")
- ✅ With proper flow (passage → vocab → question)
- ✅ Ready to test!

