#!/bin/bash

# Verify JSON data counts
echo "================================"
echo "JSON Data Verification Script"
echo "================================"
echo ""

FILE="JPLearning/Resources/japanese_learning_data_n5_jisho.json"

if [ ! -f "$FILE" ]; then
    echo "❌ ERROR: JSON file not found at $FILE"
    exit 1
fi

echo "✅ File found: $FILE"
echo ""

# Count flashcards by category
vocab_count=$(grep -c '"category": "vocabulary"' "$FILE")
kanji_flashcards=$(grep -c '"category": "kanji"' "$FILE")

# Count kanji items (separate kanji section)
kanji_items=$(grep -c '"jlptLevel": "N5"' "$FILE")

# Count grammar points
grammar_count=$(grep -c '"pattern":' "$FILE")

# Count practice questions
practice_count=$(grep -c '"correctAnswer":' "$FILE")

# Total items
total_ids=$(grep -o '"id"' "$FILE" | wc -l | tr -d ' ')

echo "📊 N5 Data Counts:"
echo "  - Total items: $total_ids"
echo "  - Vocabulary flashcards: $vocab_count"
echo "  - Kanji flashcards: $kanji_flashcards"
echo "  - Kanji items (separate): $kanji_items"
echo "  - Grammar points: $grammar_count"
echo "  - Practice questions: $practice_count"
echo ""

echo "🎯 Expected HomeView Display:"
echo "  - Kanji: $kanji_items characters"
echo "  - Vocabulary: $vocab_count words"
echo "  - Grammar: $grammar_count points"
echo ""

echo "================================"
echo "Verification complete!"
echo "================================"

