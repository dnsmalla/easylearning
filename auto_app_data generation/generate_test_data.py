#!/usr/bin/env python3
"""
Test Data Generator for JLearn - Generates sample data to verify structure
No external dependencies needed
"""

import json
from pathlib import Path

def generate_test_data(level: str, num_flashcards: int = 200) -> dict:
    """Generate test data with correct structure"""
    
    flashcards = []
    grammar = []
    practice = []
    
    # Generate Flashcards
    vocab_words = [
        ("学校", "がっこう", "school", ["私は学校に行く - I go to school", "学校は大きい - The school is big"]),
        ("先生", "せんせい", "teacher", ["先生は優しい - The teacher is kind"]),
        ("本", "ほん", "book", ["本を読む - Read a book", "この本は面白い - This book is interesting"]),
        ("水", "みず", "water", ["水を飲む - Drink water"]),
        ("食べる", "たべる", "to eat", ["ご飯を食べる - Eat rice"]),
        ("見る", "みる", "to see; to watch", ["映画を見る - Watch a movie"]),
        ("行く", "いく", "to go", ["学校に行く - Go to school"]),
        ("来る", "くる", "to come", ["ここに来る - Come here"]),
        ("勉強", "べんきょう", "study", ["日本語を勉強する - Study Japanese"]),
        ("仕事", "しごと", "work; job", ["仕事をする - Do work"]),
    ]
    
    kanji_items = [
        ("日", "ひ・にち", "sun; day", ["今日 - today", "日本 - Japan"]),
        ("月", "つき・げつ", "moon; month", ["月曜日 - Monday", "一月 - January"]),
        ("火", "ひ・か", "fire", ["火曜日 - Tuesday", "火事 - fire"]),
        ("水", "みず・すい", "water", ["水曜日 - Wednesday", "水道 - water supply"]),
        ("木", "き・もく", "tree; wood", ["木曜日 - Thursday", "木 - tree"]),
    ]
    
    # Generate vocabulary flashcards
    for i in range(min(num_flashcards // 2, len(vocab_words) * 20)):
        idx = i % len(vocab_words)
        word = vocab_words[idx]
        flashcards.append({
            "id": f"{level.lower()}_flash_v_{i+1:04d}",
            "front": word[0],
            "back": word[1],
            "reading": word[1],
            "meaning": word[2],
            "examples": word[3],
            "level": level,
            "category": "vocabulary"
        })
    
    # Generate kanji flashcards
    for i in range(min(num_flashcards // 2, len(kanji_items) * 20)):
        idx = i % len(kanji_items)
        kanji = kanji_items[idx]
        flashcards.append({
            "id": f"{level.lower()}_flash_k_{i+1:04d}",
            "front": kanji[0],
            "back": kanji[1],
            "reading": kanji[1],
            "meaning": kanji[2],
            "examples": kanji[3],
            "level": level,
            "category": "kanji"
        })
    
    # Generate Grammar Points
    grammar_templates = [
        {
            "title": "です (desu)",
            "pattern": "Noun + です",
            "meaning": "to be (polite)",
            "usage": "Used to state what something is in a polite way",
            "examples": [
                {
                    "japanese": "私は学生です。",
                    "reading": "わたしはがくせいです。",
                    "english": "I am a student."
                },
                {
                    "japanese": "これは本です。",
                    "reading": "これはほんです。",
                    "english": "This is a book."
                }
            ],
            "notes": "The copula です is one of the most basic grammar patterns"
        },
        {
            "title": "～は～です",
            "pattern": "Topic + は + Noun + です",
            "meaning": "As for [topic], it is [noun]",
            "usage": "は marks the topic of the sentence",
            "examples": [
                {
                    "japanese": "私は田中です。",
                    "reading": "わたしはたなかです。",
                    "english": "I am Tanaka."
                }
            ],
            "notes": "は (wa) is the topic marker particle"
        },
        {
            "title": "～ます",
            "pattern": "Verb stem + ます",
            "meaning": "Polite verb ending",
            "usage": "Makes verbs polite in present/future tense",
            "examples": [
                {
                    "japanese": "食べます。",
                    "reading": "たべます。",
                    "english": "I eat. / I will eat."
                }
            ],
            "notes": "ます form is the polite present/future tense"
        },
    ]
    
    num_grammar = 80 if level == "N5" else 150
    for i in range(num_grammar):
        template = grammar_templates[i % len(grammar_templates)]
        grammar.append({
            "id": f"{level.lower()}_grammar_{i+1:03d}",
            "title": template["title"],
            "pattern": template["pattern"],
            "meaning": template["meaning"],
            "usage": template["usage"],
            "examples": template["examples"],
            "level": level,
            "notes": template.get("notes", "")
        })
    
    # Generate Practice Questions
    num_practice = 50 if level == "N5" else 100
    
    # Create diverse practice question categories
    practice_categories = ["vocabulary", "kanji", "grammar", "listening", "speaking", "reading"]
    questions_per_category = num_practice // len(practice_categories)
    
    for category_idx, category in enumerate(practice_categories):
        for i in range(questions_per_category):
            question_id = f"{level.lower()}_practice_{(category_idx * questions_per_category + i + 1):04d}"
            
            if category == "vocabulary":
                word = vocab_words[i % len(vocab_words)]
                practice.append({
                    "id": question_id,
                    "question": f"What does {word[0]} mean?",
                    "options": [word[2], "house", "car", "food"],
                    "correctAnswer": word[2],
                    "explanation": f"{word[0]} ({word[1]}) means {word[2]}",
                    "category": "vocabulary",
                    "level": level
                })
            
            elif category == "kanji":
                kanji = kanji_items[i % len(kanji_items)]
                practice.append({
                    "id": question_id,
                    "question": f"What is the reading of: {kanji[0]}",
                    "options": [kanji[1].split("・")[0], "あ", "か", "さ"],
                    "correctAnswer": kanji[1].split("・")[0],
                    "explanation": f"{kanji[0]} is read as {kanji[1]}",
                    "category": "kanji",
                    "level": level
                })
            
            elif category == "grammar":
                grammar_q = grammar_templates[i % len(grammar_templates)]
                practice.append({
                    "id": question_id,
                    "question": "What does です mean?",
                    "options": ["to be (polite)", "to go", "to eat", "to see"],
                    "correctAnswer": "to be (polite)",
                    "explanation": "です is the polite copula meaning 'to be'",
                    "category": "grammar",
                    "level": level
                })
            
            elif category == "listening":
                word = vocab_words[i % len(vocab_words)]
                practice.append({
                    "id": question_id,
                    "question": "Listen to the word. What does it mean?",
                    "audioText": word[1],  # Japanese reading for TTS
                    "options": [word[2], "friend", "house", "time"],
                    "correctAnswer": word[2],
                    "explanation": f"You heard {word[1]}, which means {word[2]}",
                    "category": "listening",
                    "level": level
                })
            
            elif category == "speaking":
                word = vocab_words[i % len(vocab_words)]
                practice.append({
                    "id": question_id,
                    "question": f"How do you say '{word[2]}' in Japanese?",
                    "targetWord": word[0],
                    "targetReading": word[1],
                    "options": [word[0], "家", "車", "時間"],
                    "correctAnswer": word[0],
                    "explanation": f"'{word[2]}' is {word[0]} ({word[1]}) in Japanese",
                    "category": "speaking",
                    "level": level
                })
            
            elif category == "reading":
                word = vocab_words[i % len(vocab_words)]
                # Create simple reading comprehension
                passage = f"私は{word[0]}が好きです。毎日{word[0]}を使います。"
                practice.append({
                    "id": question_id,
                    "passage": passage,
                    "passageReading": f"わたしは{word[1]}がすきです。まいにち{word[1]}をつかいます。",
                    "question": f"What does the person like?",
                    "options": [word[2], "music", "sports", "games"],
                    "correctAnswer": word[2],
                    "explanation": f"The passage says they like {word[0]} ({word[2]})",
                    "category": "reading",
                    "level": level
                })
    
    return {
        "flashcards": flashcards,
        "grammar": grammar,
        "practice": practice
    }

def main():
    """Generate test data for all levels"""
    script_dir = Path(__file__).parent
    output_dir = script_dir.parent / "JPLearning" / "Resources"
    
    print("=" * 70)
    print("📚 JLearn Test Data Generator")
    print("=" * 70)
    print("\nGenerating sample data with correct structure...\n")
    
    levels = {
        "N5": 200,
        "N4": 300,
        "N3": 400,
        "N2": 500,
        "N1": 600
    }
    
    for level, num_cards in levels.items():
        print(f"🔄 Generating {level} data...")
        data = generate_test_data(level, num_cards)
        
        output_file = output_dir / f"japanese_learning_data_{level.lower()}_jisho.json"
        
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        # Verify structure
        print(f"   ✓ Flashcards: {len(data['flashcards'])} (vocab + kanji)")
        print(f"   ✓ Grammar: {len(data['grammar'])} points")
        print(f"   ✓ Practice: {len(data['practice'])} questions")
        
        # Check first flashcard structure
        if data['flashcards']:
            fc = data['flashcards'][0]
            print(f"   ✓ Flashcard structure: {list(fc.keys())}")
            print(f"   ✓ Has examples: {len(fc.get('examples', [])) > 0}")
        
        print(f"   ✓ Saved to: {output_file.name}\n")
    
    print("=" * 70)
    print("✅ Test data generation complete!")
    print("=" * 70)
    print("\n📋 Summary:")
    print("- All files have: flashcards, grammar, practice")
    print("- Flashcards include: examples, readings, categories")
    print("- Grammar includes: patterns, examples, notes")
    print("- Practice includes: questions, options, explanations")
    print("\n🧪 Next step: Test the app with this data!")

if __name__ == "__main__":
    main()

