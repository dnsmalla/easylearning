#!/usr/bin/env python3
"""
NPLearn Cursor Content Generator - COMPLETE DATA GENERATOR
===========================================================
Generates ALL content types the NPLearn app needs using Cursor AI.
NO API KEYS NEEDED - Works directly with Cursor's built-in AI!

DATA TYPES:
  1. Flashcards (vocabulary)
  2. Grammar Points
  3. Practice Questions (vocabulary, grammar, listening, speaking, writing, reading)
  4. Games (matching, flashcard, sentence, fill_blank, translation, dictation)
  5. Reading Passages
  6. Speaking Dialogues
  7. Writing Exercises

Usage:
    python3 cursor_content_generator.py --type all --level beginner
    python3 cursor_content_generator.py --type flashcards --level intermediate --count 50
    python3 cursor_content_generator.py --type games --level beginner
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Dict, List
import re

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR = Path(__file__).parent
RESOURCES_PATH = SCRIPT_DIR.parent.parent.parent / "NPLearn" / "Resources"
PROMPTS_PATH = SCRIPT_DIR.parent.parent / "prompts"

RESOURCES_PATH.mkdir(parents=True, exist_ok=True)
PROMPTS_PATH.mkdir(parents=True, exist_ok=True)

# ═══════════════════════════════════════════════════════════════════════════════
# COMPLETE PROMPT TEMPLATES
# ═══════════════════════════════════════════════════════════════════════════════

# 1. FLASHCARDS (Vocabulary)
FLASHCARDS_PROMPT = '''Generate {count} Nepali vocabulary flashcards for {level} level learners.
Category: {category}

Requirements:
- Authentic Nepali in Devanagari script
- Accurate romanization (Latin transliteration)  
- Clear English translations
- Example sentences using each word

Output as valid JSON array:
```json
[
  {{
    "id": "{level}_vocab_{category}_001",
    "front": "नमस्ते",
    "back": "Hello/Greetings",
    "romanization": "namaste",
    "meaning": "Traditional Nepali greeting used at any time of day",
    "level": "{level_cap}",
    "category": "{category}",
    "examples": ["नमस्ते, तपाईंलाई कस्तो छ?"],
    "isFavorite": false,
    "reviewCount": 0,
    "correctCount": 0
  }}
]
```

Generate {count} flashcards for category: {category}
Level: {level_cap}
'''

# 2. GRAMMAR POINTS
GRAMMAR_PROMPT = '''Generate {count} Nepali grammar points for {level} level learners.

Requirements:
- Clear pattern explanation with Nepali text
- Multiple example sentences (nepali, romanization, english)
- Practical usage notes
- Notes on exceptions or related patterns

Output as valid JSON array:
```json
[
  {{
    "id": "grammar_{level}_001",
    "title": "Present Tense (Simple)",
    "pattern": "Subject + Verb Stem + छु/छ/छन्",
    "meaning": "Used to express habitual or current actions",
    "usage": "For daily activities and general truths",
    "examples": [
      {{
        "nepali": "म खान्छु।",
        "romanization": "Ma khanchhu.",
        "english": "I eat."
      }},
      {{
        "nepali": "ऊ पढ्छ।",
        "romanization": "U padhchha.",
        "english": "He/She studies."
      }}
    ],
    "level": "{level_cap}",
    "notes": "The suffix changes based on subject: छु (I), छ (he/she/you informal), छन् (they/you formal)"
  }}
]
```

Generate {count} grammar points for level: {level_cap}
'''

# 3. PRACTICE QUESTIONS (All Categories)
PRACTICE_PROMPT = '''Generate practice questions for {level} level Nepali learners.
Generate {count} questions for EACH of these 6 categories:

Categories:
1. vocabulary - Word meaning questions
2. grammar - Sentence completion, conjugation
3. listening - Audio comprehension (provide audioText)
4. speaking - Pronunciation and conversation
5. writing - Writing/typing exercises
6. reading - Reading comprehension

Output as valid JSON:
```json
{{
  "vocabulary": [
    {{
      "id": "{level}_vocab_q_001",
      "question": "What does 'नमस्ते' mean?",
      "options": ["Hello/Greetings", "Thank you", "Please", "Sorry"],
      "correctAnswer": "Hello/Greetings",
      "explanation": "नमस्ते (namaste) is the traditional Nepali greeting",
      "category": "vocabulary",
      "level": "{level_cap}",
      "audioText": "नमस्ते"
    }}
  ],
  "grammar": [
    {{
      "id": "{level}_grammar_q_001",
      "question": "Complete: म खाना ___। (I eat food)",
      "options": ["खान्छु", "खान्छ", "खान्छन्", "खान्छौ"],
      "correctAnswer": "खान्छु",
      "explanation": "खान्छु is the first person singular present tense",
      "category": "grammar",
      "level": "{level_cap}"
    }}
  ],
  "listening": [
    {{
      "id": "{level}_listen_q_001",
      "question": "Listen and select the correct meaning",
      "options": ["Hello", "Goodbye", "Thank you", "Please"],
      "correctAnswer": "Hello",
      "explanation": "The audio says 'नमस्ते' meaning 'Hello'",
      "category": "listening",
      "level": "{level_cap}",
      "audioText": "नमस्ते"
    }}
  ],
  "speaking": [
    {{
      "id": "{level}_speak_q_001",
      "question": "How do you say 'Hello' in Nepali?",
      "options": ["नमस्ते", "धन्यवाद", "माफ गर्नुहोस्", "कृपया"],
      "correctAnswer": "नमस्ते",
      "explanation": "नमस्ते (namaste) is how you say Hello",
      "category": "speaking",
      "level": "{level_cap}",
      "audioText": "नमस्ते"
    }}
  ],
  "writing": [
    {{
      "id": "{level}_write_q_001",
      "question": "Write the Nepali word for 'water'",
      "options": ["पानी", "खाना", "दूध", "चिया"],
      "correctAnswer": "पानी",
      "explanation": "पानी (pani) means water",
      "category": "writing",
      "level": "{level_cap}"
    }}
  ],
  "reading": [
    {{
      "id": "{level}_read_q_001",
      "question": "What does this sentence mean: 'म नेपाली हुँ'?",
      "options": ["I am Nepali", "I am Indian", "I am American", "I am student"],
      "correctAnswer": "I am Nepali",
      "explanation": "'म नेपाली हुँ' means 'I am Nepali'",
      "category": "reading",
      "level": "{level_cap}"
    }}
  ]
}}
```

Generate {count} questions per category.
Level: {level_cap}
'''

# 4. GAMES
GAMES_PROMPT = '''Generate game content for {level} level Nepali learners.
Create content for these game types:

1. **matching** - Word Match (match Nepali words with meanings)
2. **flashcard** - Speed Cards (quick flashcard review)
3. **sentence** - Sentence Builder (arrange words to form sentences)
4. **fill_blank** - Fill in the Blank (complete sentences)
5. **translation** - Quick Translate (translate sentences)
6. **dictation** - Dictation (write what you hear)

Output as valid JSON:
```json
{{
  "games": [
    {{
      "id": "{level}_game_matching_001",
      "type": "matching",
      "title": "Word Match",
      "titleNepali": "शब्द मिलान",
      "description": "Match Nepali words with their English meanings",
      "icon": "rectangle.grid.2x2",
      "timeLimit": 60,
      "level": "{level_cap}",
      "points": 100,
      "pairs": [
        {{"nepali": "नमस्ते", "romanization": "namaste", "meaning": "Hello"}},
        {{"nepali": "धन्यवाद", "romanization": "dhanyabad", "meaning": "Thank you"}},
        {{"nepali": "पानी", "romanization": "pani", "meaning": "Water"}},
        {{"nepali": "खाना", "romanization": "khana", "meaning": "Food"}}
      ]
    }},
    {{
      "id": "{level}_game_sentence_001",
      "type": "sentence",
      "title": "Sentence Builder",
      "titleNepali": "वाक्य निर्माण",
      "description": "Arrange words to form correct sentences",
      "icon": "text.alignleft",
      "timeLimit": 120,
      "level": "{level_cap}",
      "points": 150,
      "questions": [
        {{
          "sentence": "म नेपाली हुँ",
          "translation": "I am Nepali",
          "words": ["म", "नेपाली", "हुँ"],
          "correctOrder": [0, 1, 2]
        }}
      ]
    }},
    {{
      "id": "{level}_game_fillblank_001",
      "type": "fill_blank",
      "title": "Fill in the Blank",
      "titleNepali": "खाली ठाउँ भर्नुहोस्",
      "description": "Complete the sentences",
      "icon": "rectangle.and.pencil.and.ellipsis",
      "timeLimit": 90,
      "level": "{level_cap}",
      "points": 120,
      "questions": [
        {{
          "sentence": "म ___ खान्छु।",
          "options": ["खाना", "पानी", "किताब", "कलम"],
          "correctAnswer": "खाना",
          "translation": "I eat food."
        }}
      ]
    }},
    {{
      "id": "{level}_game_translation_001",
      "type": "translation",
      "title": "Quick Translate",
      "titleNepali": "छिटो अनुवाद",
      "description": "Translate sentences quickly",
      "icon": "globe",
      "timeLimit": 120,
      "level": "{level_cap}",
      "points": 150,
      "questions": [
        {{
          "word": "नमस्ते",
          "romanization": "namaste",
          "correctMeaning": "Hello",
          "options": ["Hello", "Goodbye", "Thank you", "Please"]
        }}
      ]
    }}
  ]
}}
```

Generate 2-3 games per type for level: {level_cap}
Make content appropriate for {level} learners.
'''

# 5. READING PASSAGES
READING_PROMPT = '''Generate {count} Nepali reading passages for {level} level learners.

Requirements:
- Appropriate vocabulary and sentence complexity for {level} level
- Include vocabulary list with romanization
- Comprehension questions with multiple choice answers
- Both Nepali text and English translation

Output as valid JSON array:
```json
[
  {{
    "id": "{level}_read_001",
    "title": "मेरो परिवार",
    "englishTitle": "My Family",
    "difficulty": "{difficulty}",
    "paragraphs": [
      "मेरो नाम राम हो। म नेपालमा बस्छु।",
      "मेरो परिवारमा चार जना छन्।"
    ],
    "englishParagraphs": [
      "My name is Ram. I live in Nepal.",
      "There are four people in my family."
    ],
    "vocabulary": [
      {{"nepali": "परिवार", "english": "family", "romanization": "pariwar"}},
      {{"nepali": "बस्नु", "english": "to live", "romanization": "basnu"}}
    ],
    "questions": [
      {{
        "question": "रामको परिवारमा कति जना छन्?",
        "options": ["दुई जना", "तीन जना", "चार जना", "पाँच जना"],
        "correctAnswer": "चार जना"
      }}
    ],
    "level": "{level_cap}"
  }}
]
```

Generate {count} reading passages for level: {level_cap}
Topics appropriate for {level}: {topics}
'''

# 6. SPEAKING/DIALOGUES
SPEAKING_PROMPT = '''Generate {count} speaking/dialogue lessons for {level} level Nepali learners.
Scenario: {scenario}

Requirements:
- Practical conversational phrases
- Natural dialogue flow between speakers
- Romanization for pronunciation
- Appropriate formality level

Output as valid JSON:
```json
{{
  "id": "{level}_speak_001",
  "title": "{scenario}",
  "titleNepali": "Nepali title here",
  "description": "Learn phrases for {scenario}",
  "level": "{level_cap}",
  "phrases": [
    {{
      "nepali": "नमस्ते, तपाईंलाई कस्तो छ?",
      "romanization": "Namaste, tapailai kasto chha?",
      "english": "Hello, how are you?",
      "audioText": "नमस्ते, तपाईंलाई कस्तो छ?"
    }}
  ],
  "dialogues": [
    {{
      "speaker": "A",
      "nepali": "नमस्ते!",
      "romanization": "Namaste!",
      "english": "Hello!"
    }},
    {{
      "speaker": "B",
      "nepali": "नमस्ते, कस्तो छ?",
      "romanization": "Namaste, kasto chha?",
      "english": "Hello, how are you?"
    }}
  ],
  "keyPhrases": [
    {{"nepali": "कस्तो छ?", "english": "How are you?", "romanization": "kasto chha?"}}
  ]
}}
```

Generate content for scenario: {scenario}
Level: {level_cap}
'''

# 7. WRITING EXERCISES
WRITING_PROMPT = '''Generate {count} writing exercises for {level} level Nepali learners.

Requirements:
- Appropriate writing tasks for {level} level
- Include prompt, expected response elements, vocabulary hints
- Different writing types: fill-blank, translation, composition

Output as valid JSON array:
```json
[
  {{
    "id": "{level}_write_001",
    "type": "fill_blank",
    "title": "Complete the Sentence",
    "instructions": "Fill in the blank with the correct word",
    "prompt": "म ___ हुँ। (I am a student)",
    "answer": "विद्यार्थी",
    "hints": ["It means 'student'"],
    "level": "{level_cap}"
  }},
  {{
    "id": "{level}_write_002",
    "type": "translation",
    "title": "Translate to Nepali",
    "instructions": "Write the Nepali translation",
    "prompt": "My name is [Your Name].",
    "answer": "मेरो नाम ___ हो।",
    "hints": ["मेरो = my", "नाम = name", "हो = is"],
    "level": "{level_cap}"
  }},
  {{
    "id": "{level}_write_003",
    "type": "composition",
    "title": "Write About Your Family",
    "instructions": "Write 3-5 sentences about your family in Nepali",
    "prompt": "Introduce your family members",
    "vocabulary": [
      {{"nepali": "परिवार", "english": "family"}},
      {{"nepali": "बुबा", "english": "father"}},
      {{"nepali": "आमा", "english": "mother"}}
    ],
    "sampleAnswer": "मेरो परिवारमा चार जना छन्।",
    "level": "{level_cap}"
  }}
]
```

Generate {count} writing exercises for level: {level_cap}
'''

# ═══════════════════════════════════════════════════════════════════════════════
# CATEGORIES AND TOPICS BY LEVEL
# ═══════════════════════════════════════════════════════════════════════════════

VOCAB_CATEGORIES = {
    "beginner": ["greetings", "numbers", "family", "food", "colors", "days", "pronouns", "basic_verbs"],
    "elementary": ["travel", "weather", "body_parts", "emotions", "shopping", "directions", "time", "clothes"],
    "intermediate": ["work", "education", "health", "nature", "culture", "relationships", "hobbies"],
    "advanced": ["politics", "economics", "technology", "environment", "media", "law"],
    "proficient": ["philosophy", "literature", "science", "history", "art", "religion"]
}

READING_TOPICS = {
    "beginner": ["My Family", "My Day", "My House", "At School", "Food I Like"],
    "elementary": ["Going to Market", "A Trip to Pokhara", "The Weather", "My Friend", "At the Restaurant"],
    "intermediate": ["Nepali Festivals", "Education in Nepal", "A Day at Work", "Health and Exercise"],
    "advanced": ["Nepal's Economy", "Environmental Issues", "Technology Today", "News Article"],
    "proficient": ["Nepali Literature", "Philosophy of Life", "Historical Events", "Academic Paper"]
}

SPEAKING_SCENARIOS = {
    "beginner": ["Greetings", "Self Introduction", "Counting", "Ordering Food", "Asking for Help"],
    "elementary": ["At Restaurant", "Asking Directions", "Shopping", "At Hotel", "Phone Call"],
    "intermediate": ["Doctor Visit", "Job Interview", "Making Plans", "Discussing News", "At Bank"],
    "advanced": ["Business Meeting", "Debate Topic", "Formal Presentation", "Negotiation"],
    "proficient": ["Academic Discussion", "Cultural Analysis", "Philosophical Debate", "Interview"]
}

DIFFICULTY_MAP = {
    "beginner": "easy",
    "elementary": "easy-medium",
    "intermediate": "medium",
    "advanced": "medium-hard",
    "proficient": "hard"
}

# ═══════════════════════════════════════════════════════════════════════════════
# GENERATOR FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def generate_flashcards_prompt(level: str, category: str = None, count: int = 20) -> str:
    if not category:
        category = VOCAB_CATEGORIES.get(level, ["greetings"])[0]
    return FLASHCARDS_PROMPT.format(
        count=count, level=level, level_cap=level.capitalize(), category=category
    )


def generate_grammar_prompt(level: str, count: int = 5) -> str:
    return GRAMMAR_PROMPT.format(
        count=count, level=level, level_cap=level.capitalize()
    )


def generate_practice_prompt(level: str, count: int = 5) -> str:
    return PRACTICE_PROMPT.format(
        level=level, level_cap=level.capitalize(), count=count
    )


def generate_games_prompt(level: str) -> str:
    return GAMES_PROMPT.format(
        level=level, level_cap=level.capitalize()
    )


def generate_reading_prompt(level: str, count: int = 3) -> str:
    topics = ", ".join(READING_TOPICS.get(level, READING_TOPICS["beginner"]))
    difficulty = DIFFICULTY_MAP.get(level, "medium")
    return READING_PROMPT.format(
        count=count, level=level, level_cap=level.capitalize(),
        topics=topics, difficulty=difficulty
    )


def generate_speaking_prompt(level: str, scenario: str = None) -> str:
    if not scenario:
        scenario = SPEAKING_SCENARIOS.get(level, ["Greetings"])[0]
    return SPEAKING_PROMPT.format(
        count=1, level=level, level_cap=level.capitalize(), scenario=scenario
    )


def generate_writing_prompt(level: str, count: int = 5) -> str:
    return WRITING_PROMPT.format(
        count=count, level=level, level_cap=level.capitalize()
    )


def generate_complete_level_prompt(level: str) -> str:
    """Generate ALL data types for a complete level."""
    categories = VOCAB_CATEGORIES.get(level, VOCAB_CATEGORIES["beginner"])
    
    prompt = f"""# NPLearn Complete Data Generation - {level.upper()} Level
    
Generate ALL content needed for the NPLearn Nepali learning app.
This is for {level.upper()} level learners.

═══════════════════════════════════════════════════════════════════════════════
SECTION 1: FLASHCARDS (Vocabulary)
═══════════════════════════════════════════════════════════════════════════════

{generate_flashcards_prompt(level, categories[0], 20)}

For additional categories, generate 15 flashcards each for:
{', '.join(categories[1:4])}

═══════════════════════════════════════════════════════════════════════════════
SECTION 2: GRAMMAR POINTS
═══════════════════════════════════════════════════════════════════════════════

{generate_grammar_prompt(level, 5)}

═══════════════════════════════════════════════════════════════════════════════
SECTION 3: PRACTICE QUESTIONS (All 6 Categories)
═══════════════════════════════════════════════════════════════════════════════

{generate_practice_prompt(level, 5)}

═══════════════════════════════════════════════════════════════════════════════
SECTION 4: GAMES
═══════════════════════════════════════════════════════════════════════════════

{generate_games_prompt(level)}

═══════════════════════════════════════════════════════════════════════════════
SECTION 5: READING PASSAGES
═══════════════════════════════════════════════════════════════════════════════

{generate_reading_prompt(level, 3)}

═══════════════════════════════════════════════════════════════════════════════
SECTION 6: SPEAKING/DIALOGUES
═══════════════════════════════════════════════════════════════════════════════

Generate speaking content for these scenarios:
{', '.join(SPEAKING_SCENARIOS.get(level, SPEAKING_SCENARIOS["beginner"])[:3])}

{generate_speaking_prompt(level)}

═══════════════════════════════════════════════════════════════════════════════
SECTION 7: WRITING EXERCISES
═══════════════════════════════════════════════════════════════════════════════

{generate_writing_prompt(level, 5)}

═══════════════════════════════════════════════════════════════════════════════
OUTPUT FORMAT
═══════════════════════════════════════════════════════════════════════════════

Please generate each section as valid JSON that can be copied directly.
Use Nepali script (Devanagari) for all Nepali text.
Include romanization for pronunciation.
"""
    return prompt


def save_prompt_file(prompt: str, filename: str) -> Path:
    filepath = PROMPTS_PATH / filename
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(prompt)
    return filepath


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def print_instructions(prompt_file: Path, content_type: str, level: str):
    print()
    print("═" * 60)
    print("📋 CURSOR AI INSTRUCTIONS")
    print("═" * 60)
    print()
    print(f"Prompt saved to: {prompt_file}")
    print()
    print("To generate content:")
    print("  1. Copy the prompt below (or open the saved file)")
    print("  2. Paste into Cursor chat")
    print("  3. Copy the JSON output to NPLearn/Resources/")
    print()
    print("Or ask me directly:")
    print(f'  "Generate {content_type} for {level} level Nepali learners"')
    print()


def main():
    parser = argparse.ArgumentParser(
        description="NPLearn Cursor Content Generator - Generate ALL app data types"
    )
    parser.add_argument("--type", 
        choices=["flashcards", "grammar", "practice", "games", "reading", "speaking", "writing", "all"],
        default="all", 
        help="Type of content to generate")
    parser.add_argument("--level", 
        choices=["beginner", "elementary", "intermediate", "advanced", "proficient"],
        default="beginner", 
        help="Learning level")
    parser.add_argument("--count", type=int, default=10, help="Number of items")
    parser.add_argument("--category", help="Vocabulary category")
    parser.add_argument("--scenario", help="Speaking scenario")
    
    args = parser.parse_args()
    
    print()
    print("═" * 60)
    print("🇳🇵 NPLearn Complete Content Generator")
    print("═" * 60)
    print()
    print(f"Type: {args.type.upper()}")
    print(f"Level: {args.level.upper()}")
    print()
    
    # Generate appropriate prompt
    if args.type == "all":
        prompt = generate_complete_level_prompt(args.level)
        filename = f"cursor_prompt_{args.level}_COMPLETE.md"
    elif args.type == "flashcards":
        prompt = generate_flashcards_prompt(args.level, args.category, args.count)
        filename = f"cursor_prompt_{args.level}_flashcards.md"
    elif args.type == "grammar":
        prompt = generate_grammar_prompt(args.level, args.count)
        filename = f"cursor_prompt_{args.level}_grammar.md"
    elif args.type == "practice":
        prompt = generate_practice_prompt(args.level, args.count)
        filename = f"cursor_prompt_{args.level}_practice.md"
    elif args.type == "games":
        prompt = generate_games_prompt(args.level)
        filename = f"cursor_prompt_{args.level}_games.md"
    elif args.type == "reading":
        prompt = generate_reading_prompt(args.level, args.count)
        filename = f"cursor_prompt_{args.level}_reading.md"
    elif args.type == "speaking":
        prompt = generate_speaking_prompt(args.level, args.scenario)
        filename = f"cursor_prompt_{args.level}_speaking.md"
    elif args.type == "writing":
        prompt = generate_writing_prompt(args.level, args.count)
        filename = f"cursor_prompt_{args.level}_writing.md"
    
    prompt_file = save_prompt_file(prompt, filename)
    print_instructions(prompt_file, args.type, args.level)
    
    # Show the prompt
    print("═" * 60)
    print("📝 PROMPT:")
    print("═" * 60)
    print()
    # For "all", show summary; for specific types, show full prompt
    if args.type == "all":
        print(prompt[:3000] + "\n\n... [Full prompt saved to file] ...")
    else:
        print(prompt)
    print()


if __name__ == "__main__":
    main()
