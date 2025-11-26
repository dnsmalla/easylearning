#!/usr/bin/env python3
"""
NPLearn Data Processor
=======================
Processes web search results and validates JSON structure
"""

import json
import re
from pathlib import Path
from typing import Optional, Dict, List, Tuple
from datetime import datetime

class DataValidator:
    """Validates NPLearn JSON data structure"""
    
    REQUIRED_FLASHCARD_FIELDS = ['front', 'back', 'romanization', 'level', 'category']
    REQUIRED_GRAMMAR_FIELDS = ['title', 'pattern', 'examples', 'level']
    REQUIRED_READING_FIELDS = ['title', 'content', 'level', 'vocabulary']
    REQUIRED_GAME_FIELDS = ['id', 'type', 'title', 'level']
    
    def __init__(self):
        self.errors = []
        self.warnings = []
    
    def validate_flashcard(self, card: dict) -> bool:
        """Validate a single flashcard"""
        for field in self.REQUIRED_FLASHCARD_FIELDS:
            if field not in card:
                self.errors.append(f"Missing field '{field}' in flashcard")
                return False
        return True
    
    def validate_grammar(self, grammar: dict) -> bool:
        """Validate a grammar point"""
        for field in self.REQUIRED_GRAMMAR_FIELDS:
            if field not in grammar:
                self.errors.append(f"Missing field '{field}' in grammar")
                return False
        return True
    
    def validate_reading(self, passage: dict) -> bool:
        """Validate a reading passage"""
        for field in self.REQUIRED_READING_FIELDS:
            if field not in passage:
                self.errors.append(f"Missing field '{field}' in reading")
                return False
        return True
    
    def validate_vocab_response(self, data: dict) -> Tuple[bool, List[dict]]:
        """Validate vocabulary response from web search"""
        self.errors = []
        valid_cards = []
        
        if 'words' not in data:
            self.errors.append("Missing 'words' array in response")
            return False, []
        
        level = data.get('level', 'Unknown')
        category = data.get('category', 'unknown')
        
        for i, word in enumerate(data['words']):
            card = {
                "id": f"{level.lower()}_{category}_{i+1:03d}",
                "front": word.get('nepali', ''),
                "back": word.get('english', ''),
                "romanization": word.get('romanization', ''),
                "meaning": word.get('english', ''),
                "level": level,
                "category": category,
                "examples": [word.get('example', '')] if word.get('example') else [],
                "isFavorite": False,
                "reviewCount": 0,
                "correctCount": 0
            }
            
            if card['front'] and card['back']:
                valid_cards.append(card)
            else:
                self.warnings.append(f"Skipping incomplete word at index {i}")
        
        return len(valid_cards) > 0, valid_cards
    
    def get_report(self) -> str:
        """Get validation report"""
        report = []
        if self.errors:
            report.append("❌ ERRORS:")
            for e in self.errors:
                report.append(f"  - {e}")
        if self.warnings:
            report.append("⚠️  WARNINGS:")
            for w in self.warnings:
                report.append(f"  - {w}")
        return "\n".join(report)


class DataProcessor:
    """Processes web search results into NPLearn format"""
    
    def __init__(self, resources_dir: Path):
        self.resources_dir = resources_dir
        self.validator = DataValidator()
        self.processed_data = {}
    
    def extract_json_from_text(self, text: str) -> Optional[dict]:
        """Extract JSON from markdown or plain text"""
        # Try to find JSON in code blocks
        json_match = re.search(r'```(?:json)?\s*([\s\S]*?)\s*```', text)
        if json_match:
            try:
                return json.loads(json_match.group(1))
            except json.JSONDecodeError:
                pass
        
        # Try to parse the whole text as JSON
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        
        # Try to find JSON object in text
        json_match = re.search(r'\{[\s\S]*\}', text)
        if json_match:
            try:
                return json.loads(json_match.group())
            except json.JSONDecodeError:
                pass
        
        return None
    
    def process_vocab_response(self, response_text: str, level: str, category: str) -> Tuple[bool, int]:
        """Process vocabulary response from web search"""
        data = self.extract_json_from_text(response_text)
        
        if not data:
            print("❌ Could not extract JSON from response")
            return False, 0
        
        # Add level and category if missing
        data['level'] = level.title()
        data['category'] = category
        
        is_valid, flashcards = self.validator.validate_vocab_response(data)
        
        if not is_valid:
            print(self.validator.get_report())
            return False, 0
        
        # Store processed data
        key = f"{level}_{category}"
        self.processed_data[key] = flashcards
        
        print(f"✅ Processed {len(flashcards)} flashcards for {level}/{category}")
        return True, len(flashcards)
    
    def merge_into_level_file(self, level: str) -> bool:
        """Merge all processed data for a level into the level file"""
        level_file = self.resources_dir / f"nepali_learning_data_{level}.json"
        
        # Load existing data or create new
        if level_file.exists():
            with open(level_file, 'r', encoding='utf-8') as f:
                level_data = json.load(f)
        else:
            level_data = {
                "level": level.title(),
                "version": "3.0",
                "description": f"{level.title()} level Nepali learning data",
                "flashcards": [],
                "grammar": [],
                "practice": []
            }
        
        # Merge new flashcards
        existing_ids = {card['id'] for card in level_data.get('flashcards', [])}
        
        for key, flashcards in self.processed_data.items():
            if key.startswith(level):
                for card in flashcards:
                    if card['id'] not in existing_ids:
                        level_data['flashcards'].append(card)
                        existing_ids.add(card['id'])
        
        # Update metadata
        level_data['lastUpdated'] = datetime.now().isoformat()
        
        # Save
        with open(level_file, 'w', encoding='utf-8') as f:
            json.dump(level_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Saved {len(level_data['flashcards'])} flashcards to {level_file.name}")
        return True
    
    def get_stats(self) -> dict:
        """Get current data statistics"""
        stats = {}
        
        for level in ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']:
            level_file = self.resources_dir / f"nepali_learning_data_{level}.json"
            if level_file.exists():
                with open(level_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                stats[level] = {
                    'flashcards': len(data.get('flashcards', [])),
                    'grammar': len(data.get('grammar', [])),
                    'practice': len(data.get('practice', []))
                }
            else:
                stats[level] = {'flashcards': 0, 'grammar': 0, 'practice': 0}
        
        return stats
    
    def print_stats(self):
        """Print current statistics"""
        stats = self.get_stats()
        
        print("\n📊 Current Data Statistics")
        print("="*50)
        
        total_fc = 0
        for level, data in stats.items():
            fc = data['flashcards']
            total_fc += fc
            status = "✅" if fc >= 100 else "⚠️"
            print(f"  {status} {level.title()}: {fc} flashcards, {data['grammar']} grammar")
        
        print("="*50)
        print(f"  Total: {total_fc} flashcards")
        
        return stats


def process_clipboard_data():
    """Interactive mode to process data from clipboard/paste"""
    print("""
╔══════════════════════════════════════════════════════════════╗
║  NPLearn Data Processor - Interactive Mode                   ║
╠══════════════════════════════════════════════════════════════╣
║  Paste the JSON response from @Web search, then press        ║
║  Ctrl+D (Mac/Linux) or Ctrl+Z (Windows) when done.           ║
╚══════════════════════════════════════════════════════════════╝
    """)
    
    level = input("Enter level (beginner/elementary/intermediate/advanced/proficient): ").strip().lower()
    category = input("Enter category: ").strip().lower()
    
    print("\nPaste JSON response (Ctrl+D when done):\n")
    
    lines = []
    try:
        while True:
            line = input()
            lines.append(line)
    except EOFError:
        pass
    
    response_text = "\n".join(lines)
    
    resources_dir = Path(__file__).parent.parent.parent.parent / "NPLearn" / "Resources"
    processor = DataProcessor(resources_dir)
    
    success, count = processor.process_vocab_response(response_text, level, category)
    
    if success:
        processor.merge_into_level_file(level)
        processor.print_stats()


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "stats":
        resources_dir = Path(__file__).parent.parent.parent.parent / "NPLearn" / "Resources"
        processor = DataProcessor(resources_dir)
        processor.print_stats()
    else:
        process_clipboard_data()

