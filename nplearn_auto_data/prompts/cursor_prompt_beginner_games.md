Generate game content for beginner level Nepali learners.
Create content for these game types:

1. **matching** - Word Match (match Nepali words with meanings)
2. **flashcard** - Speed Cards (quick flashcard review)
3. **sentence** - Sentence Builder (arrange words to form sentences)
4. **fill_blank** - Fill in the Blank (complete sentences)
5. **translation** - Quick Translate (translate sentences)
6. **dictation** - Dictation (write what you hear)

Output as valid JSON:
```json
{
  "games": [
    {
      "id": "beginner_game_matching_001",
      "type": "matching",
      "title": "Word Match",
      "titleNepali": "शब्द मिलान",
      "description": "Match Nepali words with their English meanings",
      "icon": "rectangle.grid.2x2",
      "timeLimit": 60,
      "level": "Beginner",
      "points": 100,
      "pairs": [
        {"nepali": "नमस्ते", "romanization": "namaste", "meaning": "Hello"},
        {"nepali": "धन्यवाद", "romanization": "dhanyabad", "meaning": "Thank you"},
        {"nepali": "पानी", "romanization": "pani", "meaning": "Water"},
        {"nepali": "खाना", "romanization": "khana", "meaning": "Food"}
      ]
    },
    {
      "id": "beginner_game_sentence_001",
      "type": "sentence",
      "title": "Sentence Builder",
      "titleNepali": "वाक्य निर्माण",
      "description": "Arrange words to form correct sentences",
      "icon": "text.alignleft",
      "timeLimit": 120,
      "level": "Beginner",
      "points": 150,
      "questions": [
        {
          "sentence": "म नेपाली हुँ",
          "translation": "I am Nepali",
          "words": ["म", "नेपाली", "हुँ"],
          "correctOrder": [0, 1, 2]
        }
      ]
    },
    {
      "id": "beginner_game_fillblank_001",
      "type": "fill_blank",
      "title": "Fill in the Blank",
      "titleNepali": "खाली ठाउँ भर्नुहोस्",
      "description": "Complete the sentences",
      "icon": "rectangle.and.pencil.and.ellipsis",
      "timeLimit": 90,
      "level": "Beginner",
      "points": 120,
      "questions": [
        {
          "sentence": "म ___ खान्छु।",
          "options": ["खाना", "पानी", "किताब", "कलम"],
          "correctAnswer": "खाना",
          "translation": "I eat food."
        }
      ]
    },
    {
      "id": "beginner_game_translation_001",
      "type": "translation",
      "title": "Quick Translate",
      "titleNepali": "छिटो अनुवाद",
      "description": "Translate sentences quickly",
      "icon": "globe",
      "timeLimit": 120,
      "level": "Beginner",
      "points": 150,
      "questions": [
        {
          "word": "नमस्ते",
          "romanization": "namaste",
          "correctMeaning": "Hello",
          "options": ["Hello", "Goodbye", "Thank you", "Please"]
        }
      ]
    }
  ]
}
```

Generate 2-3 games per type for level: Beginner
Make content appropriate for beginner learners.
