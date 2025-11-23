#!/bin/bash

echo "🔥 NUCLEAR OPTION - COMPLETE RESET 🔥"
echo "===================================="
echo ""

# 1. Kill simulator
echo "📱 Killing iOS Simulator..."
killall Simulator 2>/dev/null || true

# 2. Kill Xcode
echo "🛑 Killing Xcode..."
killall Xcode 2>/dev/null || true

sleep 2

# 3. Delete derived data
echo "🗑️  Deleting DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/JLearn-* 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/*JLearn* 2>/dev/null || true

# 4. Reset simulator
echo "🔄 Resetting iOS Simulator..."
xcrun simctl shutdown all 2>/dev/null || true
xcrun simctl erase all 2>/dev/null || true

echo ""
echo "✅ COMPLETE RESET DONE!"
echo ""
echo "NOW DO THIS:"
echo "1. Open Xcode"
echo "2. Product → Clean Build Folder (Shift + Cmd + K)"
echo "3. Product → Build (Cmd + B)"
echo "4. Product → Run (Cmd + R)"
echo ""
echo "5. WATCH THE CONSOLE for:"
echo "   🚨 EMERGENCY DIAGNOSTIC START 🚨"
echo "   📋 JSON files found: X"
echo ""
echo "6. Take a screenshot of the console and show me!"

