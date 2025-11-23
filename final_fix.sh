#!/bin/bash

echo "🚀 FINAL FIX - COMPLETE RESET & REBUILD"
echo "========================================"
echo ""

# 1. Kill everything
echo "🛑 Stopping Xcode and Simulator..."
killall Xcode 2>/dev/null || true
killall Simulator 2>/dev/null || true
sleep 2

# 2. Delete all caches
echo "🗑️  Deleting all caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
rm -rf ~/Library/Caches/com.apple.dt.Xcode 2>/dev/null || true

# 3. Reset simulator
echo "🔄 Resetting simulator..."
xcrun simctl shutdown all 2>/dev/null || true
xcrun simctl erase all 2>/dev/null || true

echo ""
echo "✅ RESET COMPLETE!"
echo ""
echo "========================================" 
echo "NOW DO THIS IN XCODE:"
echo "========================================"
echo ""
echo "1. Open Xcode (double-click JLearn.xcodeproj)"
echo ""
echo "2. Product → Clean Build Folder (Shift + Cmd + K)"
echo "   Wait for 'Clean Complete'"
echo ""
echo "3. Product → Build (Cmd + B)"
echo "   Watch for build success"
echo ""
echo "4. Product → Run (Cmd + R)"
echo ""
echo "5. WATCH CONSOLE (bottom of Xcode) for:"
echo "   📂 Bundle path:"
echo "   📋 JSON files in bundle: 5"
echo "   ✅ [DATA] Found file at:"
echo "   📊 [DATA] Loaded data counts:"
echo "   - Flashcards: 80"
echo "   - Grammar: 25"  
echo "   - Kanji: 30"
echo ""
echo "6. If you see '❌ [FAILSAFE]' messages:"
echo "   The JSON files are NOT in the bundle!"
echo "   You need to add them manually in Xcode."
echo ""
echo "========================================" 
echo ""
echo "If data STILL shows 0 after this, send me:"
echo "- Screenshot of Xcode console output"
echo "- Screenshot of Project Navigator showing Resources folder"
echo ""

