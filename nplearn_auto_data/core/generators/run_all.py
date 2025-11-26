#!/usr/bin/env python3
"""
Master Data Generator for NPLearn
===================================
Runs all generators and validates data
"""

import json
import sys
from pathlib import Path
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from gen_flashcards import (
    BEGINNER_VOCAB, ELEMENTARY_VOCAB, INTERMEDIATE_VOCAB, 
    ADVANCED_VOCAB, PROFICIENT_VOCAB, generate_level_flashcards
)
from gen_games import generate_games
from gen_grammar import generate_grammar
from gen_reading import generate_reading
from gen_practice import generate_practice
from validator import DataValidator

BASE_DIR = Path(__file__).parent.parent.parent.parent
RESOURCES_DIR = BASE_DIR / "NPLearn" / "Resources"
VERSION = "3.0"

def save_json(data: dict, file_path: Path):
    """Save data as formatted JSON"""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  ✓ Saved {file_path.name}")

def generate_level_data(level: str, vocab_dict: dict, prefix: str) -> dict:
    """Generate complete data for a level"""
    flashcards = generate_level_flashcards(level, vocab_dict, prefix)
    
    # Generate grammar for this level
    all_grammar = generate_grammar()['grammar']
    level_grammar = [g for g in all_grammar if g['level'] == level]
    
    # Generate practice for this level
    all_practice = generate_practice()['practice']
    level_practice = [p for p in all_practice if p['level'] == level]
    
    return {
        "level": level,
        "version": VERSION,
        "description": f"Comprehensive {level} level Nepali learning data",
        "generated": datetime.now().isoformat(),
        "flashcards": flashcards,
        "grammar": level_grammar,
        "practice": level_practice
    }

def generate_manifest() -> dict:
    """Generate manifest.json for version control"""
    return {
        "version": VERSION,
        "lastUpdated": datetime.now().isoformat(),
        "files": {
            "levels": [
                "nepali_learning_data_beginner.json",
                "nepali_learning_data_elementary.json",
                "nepali_learning_data_intermediate.json",
                "nepali_learning_data_advanced.json",
                "nepali_learning_data_proficient.json"
            ],
            "standalone": [
                "games.json",
                "grammar.json",
                "practice.json",
                "reading.json",
                "speaking.json",
                "writing.json"
            ]
        }
    }

def main():
    print("\n" + "="*60)
    print("🇳🇵 NPLearn Data Generator")
    print("="*60 + "\n")
    
    # Ensure resources directory exists
    RESOURCES_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate level-specific data
    print("📚 Generating Level Data...")
    
    levels = [
        ("Beginner", BEGINNER_VOCAB, "b"),
        ("Elementary", ELEMENTARY_VOCAB, "e"),
        ("Intermediate", INTERMEDIATE_VOCAB, "i"),
        ("Advanced", ADVANCED_VOCAB, "a"),
        ("Proficient", PROFICIENT_VOCAB, "p"),
    ]
    
    for level_name, vocab, prefix in levels:
        data = generate_level_data(level_name, vocab, prefix)
        file_path = RESOURCES_DIR / f"nepali_learning_data_{level_name.lower()}.json"
        save_json(data, file_path)
        print(f"    {level_name}: {len(data['flashcards'])} flashcards, {len(data['grammar'])} grammar, {len(data['practice'])} practice")
    
    # Generate standalone files
    print("\n🎮 Generating Standalone Files...")
    
    # Games
    games_data = generate_games()
    save_json(games_data, RESOURCES_DIR / "games.json")
    print(f"    Games: {len(games_data['games'])} games")
    
    # Grammar (combined)
    grammar_data = generate_grammar()
    save_json(grammar_data, RESOURCES_DIR / "grammar.json")
    print(f"    Grammar: {len(grammar_data['grammar'])} points")
    
    # Practice (combined)
    practice_data = generate_practice()
    save_json(practice_data, RESOURCES_DIR / "practice.json")
    print(f"    Practice: {len(practice_data['practice'])} questions")
    
    # Reading
    reading_data = generate_reading()
    save_json(reading_data, RESOURCES_DIR / "reading.json")
    print(f"    Reading: {len(reading_data['passages'])} passages")
    
    # Manifest
    manifest = generate_manifest()
    save_json(manifest, RESOURCES_DIR / "manifest.json")
    print("    Manifest: Updated")
    
    # Validate all data
    print("\n" + "="*60)
    validator = DataValidator(RESOURCES_DIR)
    is_valid, summary = validator.validate_all()
    
    print("\n" + "="*60)
    if is_valid:
        print("✅ All data generated and validated successfully!")
        print(f"📁 Data saved to: {RESOURCES_DIR}")
    else:
        print("❌ Data validation failed. Please check errors above.")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

