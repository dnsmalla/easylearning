#!/bin/bash
set -e

echo "🔍 COMPREHENSIVE DIAGNOSTIC BUILD"
echo "=================================="
echo ""

cd /Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn/JPLearning

# Step 1: Clean everything
echo "1️⃣ Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/JLearn-* 2>/dev/null || true
xcodebuild clean -project JLearn.xcodeproj -scheme JLearn >/dev/null 2>&1 || true
echo "   ✅ Clean complete"

# Step 2: Build
echo ""
echo "2️⃣ Building app (this will take 30-60 seconds)..."
xcodebuild build -project JLearn.xcodeproj -scheme JLearn -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tee /tmp/build_output.log | grep -E "(error:|warning:|Build Succeeded|Build Failed)" || true

if grep -q "BUILD SUCCEEDED" /tmp/build_output.log; then
    echo "   ✅ Build succeeded!"
else
    echo "   ❌ Build failed! Check errors above"
    exit 1
fi

# Step 3: Find the built app
echo ""
echo "3️⃣ Checking built app bundle..."
APP_PATH=$(grep -o "\/Users.*\.app" /tmp/build_output.log | tail -1)

if [ -z "$APP_PATH" ]; then
    echo "   ⚠️  Could not find app path, searching..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "JLearn.app" -type d 2>/dev/null | head -1)
fi

if [ -n "$APP_PATH" ]; then
    echo "   📂 App bundle: $APP_PATH"
    
    # List JSON files in the built app
    echo ""
    echo "4️⃣ JSON files in BUILT app:"
    FOUND_JSON=false
    for json in "$APP_PATH"/*.json; do
        if [ -f "$json" ]; then
            FOUND_JSON=true
            SIZE=$(stat -f%z "$json" 2>/dev/null || echo "?")
            BASENAME=$(basename "$json")
            echo "   ✅ $BASENAME ($SIZE bytes)"
        fi
    done
    
    if [ "$FOUND_JSON" = false ]; then
        echo "   ❌❌❌ NO JSON FILES IN BUILT APP!"
        echo "   This is the problem! Files are not being copied to the app bundle!"
        echo ""
        echo "   🔧 SOLUTION: Open Xcode and check:"
        echo "   1. Select project in navigator"
        echo "   2. Select 'JLearn' target"
        echo "   3. Go to 'Build Phases' tab"
        echo "   4. Expand 'Copy Bundle Resources'"
        echo "   5. Ensure all japanese_learning_data_*.json files are listed"
        exit 1
    fi
else
    echo "   ⚠️  Could not find built app"
fi

# Step 5: Kill simulator app
echo ""
echo "5️⃣ Stopping old app instance..."
xcrun simctl terminate booted com.yourcompany.JLearn 2>/dev/null || true
echo "   ✅ Old instance stopped"

# Step 6: Install and launch
echo ""
echo "6️⃣ Installing app to simulator..."
if [ -n "$APP_PATH" ]; then
    xcrun simctl install booted "$APP_PATH"
    echo "   ✅ App installed"
    
    echo ""
    echo "7️⃣ Launching app..."
    xcrun simctl launch --console-pty booted com.yourcompany.JLearn 2>&1 &
    LAUNCH_PID=$!
    
    echo ""
    echo "=================================="
    echo "🎯 APP IS LAUNCHING!"
    echo "=================================="
    echo ""
    echo "👀 WATCH FOR THESE LOGS:"
    echo "   📂 Bundle path: ..."
    echo "   📋 JSON files found: 5"
    echo "   ✅ Data loaded correctly!"
    echo ""
    echo "❌ IF YOU SEE THESE, THERE'S A PROBLEM:"
    echo "   ❌ File not found in bundle"
    echo "   ❌ NO JSON FILES"
    echo "   🚨 [FAILSAFE] Attempting emergency data load"
    echo ""
    echo "Press Ctrl+C to stop watching logs"
    echo "=================================="
    
    # Wait for logs
    sleep 5
    wait $LAUNCH_PID 2>/dev/null || true
else
    echo "   ❌ Cannot install - app path not found"
fi

echo ""
echo "Done! Check the simulator and Xcode console."

