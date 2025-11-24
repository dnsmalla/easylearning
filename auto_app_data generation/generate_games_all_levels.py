#!/usr/bin/env python3
"""
Generate 8 standard games for all JLPT levels (N5, N4, N3, N2, N1).
Each level gets the same game types, just with level-specific content.
"""

import json
import random
from pathlib import Path
from typing import List, Dict, Any

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
SOURCE_DIR = PROJECT_ROOT / "jpleanrning"

LEVELS = ["n5", "n4", "n3", "n2", "n1"]

def load_level_data(level: str) -> Dict[str, Any]:
    """Load existing data for a level."""
    file_path = SOURCE_DIR / f"japanese_learning_data_{level}_jisho.json"
    
    if not file_path.exists():
        print(f"⚠️  Warning: {file_path.name} not found")
        return {}
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def generate_vocabulary_match_game(level: str, flashcards: List[Dict], level_num: int) -> Dict:
    """Game 1: Vocabulary Matching"""
    # Select 10 random flashcards
    sample_cards = random.sample(flashcards[:50] if len(flashcards) > 50 else flashcards, min(10, len(flashcards)))
    
    pairs = []
    for card in sample_cards:
        pairs.append({
            "kanji": card.get("front", ""),
            "reading": card.get("back", card.get("reading", "")),
            "meaning": card.get("meaning", "").split(";")[0].strip()  # First meaning only
        })
    
    return {
        "id": f"{level}_vocab_match_001",
        "title": "単語マッチング",
        "titleEnglish": "Vocabulary Match",
        "type": "matching",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "漢字とひらがなをマッチングしてください",
        "timeLimit": 60,
        "pairs": pairs,
        "points": 20
    }


def generate_kanji_reading_quiz(level: str, kanji_list: List[Dict], level_num: int) -> Dict:
    """Game 2: Kanji Reading Quiz"""
    questions = []
    
    # Select up to 10 kanji
    sample_kanji = random.sample(kanji_list, min(10, len(kanji_list)))
    
    for k in sample_kanji:
        # Get correct reading (use first onyomi or kunyomi)
        readings = k.get("readings", {})
        onyomi = readings.get("onyomi", [])
        kunyomi = readings.get("kunyomi", [])
        
        correct_reading = onyomi[0] if onyomi else (kunyomi[0] if kunyomi else k.get("character", ""))
        
        # Generate wrong options
        all_readings = [correct_reading]
        for other_k in kanji_list:
            other_readings = other_k.get("readings", {})
            all_readings.extend(other_readings.get("onyomi", [])[:1])
            all_readings.extend(other_readings.get("kunyomi", [])[:1])
        
        # Remove duplicates and sample wrong answers
        all_readings = list(set(all_readings))
        wrong_options = [r for r in all_readings if r != correct_reading]
        random.shuffle(wrong_options)
        options = [correct_reading] + wrong_options[:3]
        random.shuffle(options)
        
        questions.append({
            "word": k.get("character", ""),
            "correctMeaning": correct_reading,
            "options": options[:4]  # Ensure 4 options
        })
    
    return {
        "id": f"{level}_kanji_quiz_001",
        "title": "漢字読みクイズ",
        "titleEnglish": "Kanji Reading Quiz",
        "type": "kanji_quiz",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "漢字の正しい読み方を選んでください",
        "timeLimit": 90,
        "questions": questions,
        "points": 30
    }


def generate_grammar_fillblank(level: str, grammar: List[Dict], level_num: int) -> Dict:
    """Game 3: Grammar Fill-in-the-Blank"""
    questions = []
    
    # Select up to 8 grammar points
    sample_grammar = random.sample(grammar, min(8, len(grammar)))
    
    for g in sample_grammar:
        examples = g.get("examples", [])
        if not examples:
            continue
        
        example = examples[0]
        japanese = example.get("japanese", "")
        english = example.get("english", "")
        pattern = g.get("pattern", "")
        
        # Create a fill-in-the-blank by replacing the pattern
        if pattern and pattern in japanese:
            blank_sentence = japanese.replace(pattern, "____")
        else:
            # If pattern not found, just use the sentence
            blank_sentence = japanese
        
        # Generate options including the correct pattern
        correct_answer = pattern
        # Get other patterns as wrong options
        all_patterns = [gp.get("pattern", "") for gp in grammar if gp.get("pattern")]
        wrong_options = [p for p in all_patterns if p != correct_answer]
        random.shuffle(wrong_options)
        
        options = [correct_answer] + wrong_options[:3]
        random.shuffle(options)
        
        questions.append({
            "sentence": blank_sentence,
            "correctAnswer": correct_answer,
            "options": options[:4],
            "translation": english
        })
    
    return {
        "id": f"{level}_grammar_fill_001",
        "title": "文法穴埋め",
        "titleEnglish": "Grammar Fill-in-the-Blank",
        "type": "grammar_fill",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "正しい文法を選んで文を完成させてください",
        "timeLimit": 120,
        "questions": questions,
        "points": 40
    }


def generate_listening_game(level: str, flashcards: List[Dict], level_num: int) -> Dict:
    """Game 4: Listening Comprehension"""
    questions = []
    
    # Select 10 vocabulary items
    sample_cards = random.sample(flashcards[:40] if len(flashcards) > 40 else flashcards, min(10, len(flashcards)))
    
    for card in sample_cards:
        word = card.get("front", "")
        correct_meaning = card.get("meaning", "").split(";")[0].strip()
        
        # Generate wrong options from other cards
        all_meanings = [c.get("meaning", "").split(";")[0].strip() for c in flashcards]
        all_meanings = list(set(all_meanings))
        wrong_options = [m for m in all_meanings if m != correct_meaning]
        random.shuffle(wrong_options)
        
        options = [correct_meaning] + wrong_options[:3]
        random.shuffle(options)
        
        questions.append({
            "word": word,
            "reading": card.get("back", card.get("reading", "")),
            "correctMeaning": correct_meaning,
            "options": options[:4]
        })
    
    return {
        "id": f"{level}_listening_001",
        "title": "リスニング",
        "titleEnglish": "Listening Comprehension",
        "type": "listening",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "音声を聞いて正しい意味を選んでください",
        "timeLimit": 90,
        "questions": questions,
        "points": 30
    }


def generate_speed_translation(level: str, flashcards: List[Dict], level_num: int) -> Dict:
    """Game 5: Speed Translation"""
    questions = []
    
    # Select 15 words for speed challenge
    sample_cards = random.sample(flashcards[:30] if len(flashcards) > 30 else flashcards, min(15, len(flashcards)))
    
    for card in sample_cards:
        questions.append({
            "word": card.get("front", ""),
            "reading": card.get("back", card.get("reading", "")),
            "correctMeaning": card.get("meaning", "").split(";")[0].strip(),
            "options": []  # Speed game, no options needed
        })
    
    return {
        "id": f"{level}_speed_trans_001",
        "title": "スピード翻訳",
        "titleEnglish": "Speed Translation",
        "type": "speed_quiz",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "30秒で何問答えられますか？",
        "timeLimit": 30,
        "questions": questions,
        "points": 50
    }


def generate_sentence_builder(level: str, grammar: List[Dict], level_num: int) -> Dict:
    """Game 6: Sentence Builder"""
    questions = []
    
    # Select up to 5 grammar examples
    sample_grammar = random.sample(grammar, min(5, len(grammar)))
    
    for g in sample_grammar:
        examples = g.get("examples", [])
        if not examples:
            continue
        
        example = examples[0]
        sentence = example.get("japanese", "")
        translation = example.get("english", "")
        
        # Split sentence into words (simplified)
        words = []
        if sentence:
            # Split by common Japanese particles and spaces
            import re
            parts = re.split(r'([はがをにへとでもからまで、。！？])', sentence)
            words = [p for p in parts if p.strip()]
        
        questions.append({
            "sentence": sentence,
            "options": words if words else [sentence],  # Use whole sentence if splitting fails
            "translation": translation
        })
    
    return {
        "id": f"{level}_sentence_builder_001",
        "title": "文章を作ろう",
        "titleEnglish": "Sentence Builder",
        "type": "sentence_builder",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "正しい順番に並べて文章を完成させてください",
        "timeLimit": 90,
        "questions": questions,
        "points": 40
    }


def generate_particle_challenge(level: str, grammar: List[Dict], level_num: int) -> Dict:
    """Game 7: Particle Challenge"""
    questions = []
    
    particles = ["は", "が", "を", "に", "へ", "と", "で", "も", "から", "まで"]
    
    # Select grammar examples with particles
    sample_grammar = random.sample(grammar, min(8, len(grammar)))
    
    for g in sample_grammar:
        examples = g.get("examples", [])
        if not examples:
            continue
        
        example = examples[0]
        sentence = example.get("japanese", "")
        
        # Find a particle in the sentence
        correct_particle = None
        for p in particles:
            if p in sentence:
                correct_particle = p
                break
        
        if not correct_particle:
            correct_particle = "は"  # Default
        
        # Replace particle with blank
        blank_sentence = sentence.replace(correct_particle, "___", 1)
        
        # Generate options
        options = [correct_particle] + random.sample([p for p in particles if p != correct_particle], min(3, len(particles)-1))
        random.shuffle(options)
        
        questions.append({
            "sentence": blank_sentence,
            "correctParticle": correct_particle,
            "options": options[:4],
            "translation": example.get("english", "")
        })
    
    return {
        "id": f"{level}_particle_001",
        "title": "助詞チャレンジ",
        "titleEnglish": "Particle Challenge",
        "type": "particle_quiz",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "正しい助詞を選んでください",
        "timeLimit": 90,
        "questions": questions,
        "points": 35
    }


def generate_mixed_review(level: str, flashcards: List[Dict], kanji: List[Dict], grammar: List[Dict], level_num: int) -> Dict:
    """Game 8: Mixed Review"""
    questions = []
    
    # Mix of vocabulary (3), kanji (3), grammar (2)
    vocab_samples = random.sample(flashcards[:30] if len(flashcards) > 30 else flashcards, min(3, len(flashcards)))
    kanji_samples = random.sample(kanji, min(3, len(kanji)))
    grammar_samples = random.sample(grammar, min(2, len(grammar)))
    
    # Add vocabulary questions
    for card in vocab_samples:
        questions.append({
            "word": card.get("front", ""),
            "correctMeaning": card.get("meaning", "").split(";")[0].strip(),
            "options": []  # Will be filled with random options
        })
    
    # Add kanji questions
    for k in kanji_samples:
        readings = k.get("readings", {})
        correct = readings.get("onyomi", [""])[0] or readings.get("kunyomi", [""])[0]
        questions.append({
            "word": k.get("character", ""),
            "correctMeaning": correct,
            "options": []
        })
    
    # Add grammar questions
    for g in grammar_samples:
        questions.append({
            "sentence": g.get("pattern", ""),
            "correctMeaning": g.get("meaning", ""),
            "options": []
        })
    
    return {
        "id": f"{level}_mixed_review_001",
        "title": "総合復習",
        "titleEnglish": "Mixed Review",
        "type": "mixed_quiz",
        "difficulty": get_difficulty(level_num),
        "level": level.upper(),
        "description": "色々な問題にチャレンジしよう！",
        "timeLimit": 120,
        "questions": questions,
        "points": 60
    }


def get_difficulty(level_num: int) -> str:
    """Map level to difficulty."""
    difficulty_map = {
        1: "beginner",
        2: "elementary",
        3: "intermediate",
        4: "upper-intermediate",
        5: "advanced"
    }
    return difficulty_map.get(6 - level_num, "intermediate")  # N5=1, N4=2, etc.


def generate_all_games_for_level(level: str, level_num: int) -> List[Dict]:
    """Generate all 8 games for a level."""
    print(f"🎮 Generating 8 games for {level.upper()}...")
    
    data = load_level_data(level)
    if not data:
        print(f"⚠️  Skipping {level.upper()} - no data found")
        return []
    
    flashcards = data.get("flashcards", [])
    kanji = data.get("kanji", [])
    grammar = data.get("grammar", [])
    
    if not flashcards or not kanji or not grammar:
        print(f"⚠️  Warning: {level.upper()} missing some data types")
        return []
    
    games = []
    
    try:
        games.append(generate_vocabulary_match_game(level, flashcards, level_num))
        games.append(generate_kanji_reading_quiz(level, kanji, level_num))
        games.append(generate_grammar_fillblank(level, grammar, level_num))
        games.append(generate_listening_game(level, flashcards, level_num))
        games.append(generate_speed_translation(level, flashcards, level_num))
        games.append(generate_sentence_builder(level, grammar, level_num))
        games.append(generate_particle_challenge(level, grammar, level_num))
        games.append(generate_mixed_review(level, flashcards, kanji, grammar, level_num))
        
        print(f"✅ Generated {len(games)} games for {level.upper()}")
    except Exception as e:
        print(f"❌ Error generating games for {level.upper()}: {e}")
    
    return games


def update_level_json_with_games(level: str, games: List[Dict]):
    """Update the level JSON file with new games."""
    file_path = SOURCE_DIR / f"japanese_learning_data_{level}_jisho.json"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data["games"] = games
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"💾 Updated {file_path.name} with {len(games)} games")


def main():
    print("━" * 60)
    print("🎮 GENERATING 8 GAMES FOR ALL LEVELS")
    print("━" * 60)
    print()
    
    level_nums = {"n5": 1, "n4": 2, "n3": 3, "n2": 4, "n1": 5}
    
    for level in LEVELS:
        print(f"\n{'='*60}")
        print(f"Processing {level.upper()}")
        print('='*60)
        
        level_num = level_nums[level]
        games = generate_all_games_for_level(level, level_num)
        
        if games:
            update_level_json_with_games(level, games)
        print()
    
    print("━" * 60)
    print("✅ GAME GENERATION COMPLETE!")
    print("━" * 60)
    print()
    print("📊 Summary:")
    print("   - Each level now has 8 games")
    print("   - Same game types across all levels")
    print("   - Content adapted to each level's vocabulary/grammar")
    print()
    print("🎯 Next steps:")
    print("   1. Copy updated JSONs to app Resources/")
    print("   2. Test the games in the app")
    print("   3. Push to GitHub")


if __name__ == "__main__":
    main()

