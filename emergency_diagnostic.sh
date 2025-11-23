#!/bin/bash
set -e

echo "🚨 EMERGENCY DIAGNOSTIC - FINDING THE ROOT CAUSE"
echo "=================================================="
echo ""

cd /Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn

echo "1️⃣ Checking N5 JSON file..."
N5_FILE="JPLearning/Resources/japanese_learning_data_n5_jisho.json"

if [ ! -f "$N5_FILE" ]; then
    echo "❌ CRITICAL: N5 file not found!"
    exit 1
fi

echo "✅ File exists: $(wc -c < "$N5_FILE") bytes"

# Parse JSON
python3 << 'PYEOF'
import json

with open('JPLearning/Resources/japanese_learning_data_n5_jisho.json', 'r') as f:
    data = json.load(f)

flashcards = len(data.get('flashcards', []))
grammar = len(data.get('grammar', []))
kanji = len(data.get('kanji', []))
practice = len(data.get('practice', []))
games = len(data.get('games', []))

print(f"\n📊 N5 DATA IN FILE:")
print(f"   Flashcards: {flashcards}")
print(f"   Grammar: {grammar}")
print(f"   Kanji: {kanji}")
print(f"   Practice: {practice}")
print(f"   Games: {games}")

if flashcards == 0:
    print("\n❌ PROBLEM: N5 JSON file has ZERO flashcards!")
    print("   The JSON file is corrupt or empty!")
else:
    print("\n✅ JSON file has data")
    print(f"\n   First flashcard: {data['flashcards'][0].get('front', 'N/A')}")
PYEOF

echo ""
echo "2️⃣ Checking if file is in Xcode project..."
if grep -q "japanese_learning_data_n5_jisho.json" JPLearning/JLearn.xcodeproj/project.pbxproj; then
    echo "✅ N5 file is referenced in Xcode project"
else
    echo "❌ N5 file NOT in Xcode project!"
fi

echo ""
echo "3️⃣ Checking built app bundle..."
DERIVED_DATA=$(find ~/Library/Developer/Xcode/DerivedData -name "JLearn-*" -type d 2>/dev/null | head -1)

if [ -n "$DERIVED_DATA" ]; then
    APP_PATH=$(find "$DERIVED_DATA/Build/Products" -name "JLearn.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📂 Found app at: $APP_PATH"
        
        if [ -f "$APP_PATH/japanese_learning_data_n5_jisho.json" ]; then
            SIZE=$(wc -c < "$APP_PATH/japanese_learning_data_n5_jisho.json")
            echo "✅ N5 file in app bundle: $SIZE bytes"
        else
            echo "❌ CRITICAL: N5 file NOT in app bundle!"
            echo "   This is why the app shows 0!"
            echo ""
            echo "   Files in app bundle:"
            ls -lh "$APP_PATH"/*.json 2>/dev/null || echo "   NO JSON FILES!"
        fi
    else
        echo "⚠️  App bundle not found"
    fi
else
    echo "⚠️  DerivedData not found"
fi

echo ""
echo "=================================================="
echo "📋 CONCLUSION:"
echo "=================================================="
echo ""
echo "If JSON file has data but app shows 0:"
echo "   → Data is NOT being loaded from JSON files"
echo "   → Check Xcode console for errors"
echo ""
echo "Next step: Send me the Xcode console output!"
echo "   View → Debug Area → Show Debug Area (Cmd+Shift+Y)"
echo "   Copy all text and send it"
echo ""

