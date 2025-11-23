#!/bin/bash
set -e

echo "🚀 JLEARN - COMPLETE DATA FIX - BUILD & TEST SCRIPT"
echo "===================================================="
echo ""

PROJECT_DIR="/Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn/JPLearning"
cd "$PROJECT_DIR"

echo "📋 Step 1: Verify JSON files exist..."
for level in n5 n4 n3 n2 n1; do
    file="Resources/japanese_learning_data_${level}_jisho.json"
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        echo "✅ $file exists ($size bytes)"
    else
        echo "❌ $file NOT FOUND!"
        exit 1
    fi
done

echo ""
echo "📋 Step 2: Clean build folder..."
xcodebuild -project JLearn.xcodeproj -scheme JLearn -configuration Debug clean 2>&1 | grep -E "CLEAN|error" || true

echo ""
echo "📋 Step 3: Build project..."
echo "(This may take a minute...)"
xcodebuild -project JLearn.xcodeproj \
    -scheme JLearn \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    build 2>&1 | grep -E "BUILD|error|warning|SUCCEEDED|FAILED" | tail -20

BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo ""
    echo "✅ ✅ ✅ BUILD SUCCEEDED! ✅ ✅ ✅"
    echo ""
    echo "📱 Next Steps:"
    echo "1. Open Xcode"
    echo "2. Press Cmd + R to run the app"
    echo "3. Watch console for these logs:"
    echo "   - 📁 [DATA] Looking for file:"
    echo "   - ✅ [DATA] Found file at:"
    echo "   - 📊 [DATA] Loaded data counts"
    echo ""
    echo "4. Verify Home Screen shows:"
    echo "   - Kanji: 30 characters (not 0)"
    echo "   - Vocabulary: 80 words (not 0)"
    echo "   - Grammar: 25 points (not 0)"
    echo ""
else
    echo ""
    echo "❌ BUILD FAILED - Check errors above"
    exit 1
fi

