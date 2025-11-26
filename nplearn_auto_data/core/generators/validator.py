#!/usr/bin/env python3
"""
Data Validator for NPLearn
===========================
Validates all generated JSON data
"""

import json
from pathlib import Path
from typing import Dict, List, Tuple

# Validation thresholds
MIN_FLASHCARDS_PER_LEVEL = 100
MIN_GRAMMAR_PER_LEVEL = 5
MIN_PRACTICE_PER_LEVEL = 10
MIN_GAMES_PER_LEVEL = 3
MIN_READING_PER_LEVEL = 2

class DataValidator:
    def __init__(self, resources_dir: Path):
        self.resources_dir = resources_dir
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.stats: Dict[str, dict] = {}
    
    def validate_json_syntax(self, file_path: Path) -> bool:
        """Check if JSON file is valid"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                json.load(f)
            return True
        except json.JSONDecodeError as e:
            self.errors.append(f"❌ Invalid JSON in {file_path.name}: {e}")
            return False
        except Exception as e:
            self.errors.append(f"❌ Error reading {file_path.name}: {e}")
            return False
    
    def validate_flashcard(self, card: dict, file_name: str) -> bool:
        """Validate a single flashcard"""
        required_fields = ['id', 'front', 'back', 'romanization', 'level', 'category']
        for field in required_fields:
            if field not in card:
                self.errors.append(f"❌ Missing field '{field}' in flashcard {card.get('id', 'unknown')} in {file_name}")
                return False
        return True
    
    def validate_grammar(self, grammar: dict, file_name: str) -> bool:
        """Validate a single grammar point"""
        required_fields = ['id', 'title', 'pattern', 'examples', 'level']
        for field in required_fields:
            if field not in grammar:
                self.errors.append(f"❌ Missing field '{field}' in grammar {grammar.get('id', 'unknown')} in {file_name}")
                return False
        return True
    
    def validate_practice(self, practice: dict, file_name: str) -> bool:
        """Validate a single practice question"""
        required_fields = ['id', 'question', 'options', 'correctAnswer', 'level']
        for field in required_fields:
            if field not in practice:
                self.errors.append(f"❌ Missing field '{field}' in practice {practice.get('id', 'unknown')} in {file_name}")
                return False
        
        # Check correct answer is in options
        if practice['correctAnswer'] not in practice['options']:
            self.errors.append(f"❌ Correct answer not in options for {practice['id']} in {file_name}")
            return False
        return True
    
    def validate_level_file(self, file_path: Path) -> dict:
        """Validate a level-specific data file"""
        stats = {'flashcards': 0, 'grammar': 0, 'practice': 0, 'valid': True}
        
        if not self.validate_json_syntax(file_path):
            stats['valid'] = False
            return stats
        
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Validate flashcards
        if 'flashcards' in data:
            for card in data['flashcards']:
                if self.validate_flashcard(card, file_path.name):
                    stats['flashcards'] += 1
        
        # Validate grammar
        if 'grammar' in data:
            for gram in data['grammar']:
                if self.validate_grammar(gram, file_path.name):
                    stats['grammar'] += 1
        
        # Validate practice
        if 'practice' in data:
            for prac in data['practice']:
                if self.validate_practice(prac, file_path.name):
                    stats['practice'] += 1
        
        return stats
    
    def validate_games(self, file_path: Path) -> dict:
        """Validate games.json"""
        stats = {'total': 0, 'by_level': {}}
        
        if not self.validate_json_syntax(file_path):
            return stats
        
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'games' in data:
            for game in data['games']:
                level = game.get('level', 'Unknown')
                stats['by_level'][level] = stats['by_level'].get(level, 0) + 1
                stats['total'] += 1
        
        return stats
    
    def validate_reading(self, file_path: Path) -> dict:
        """Validate reading.json"""
        stats = {'total': 0, 'by_level': {}}
        
        if not self.validate_json_syntax(file_path):
            return stats
        
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'passages' in data:
            for passage in data['passages']:
                level = passage.get('level', 'Unknown')
                stats['by_level'][level] = stats['by_level'].get(level, 0) + 1
                stats['total'] += 1
        
        return stats
    
    def check_minimums(self):
        """Check if data meets minimum requirements"""
        levels = ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']
        
        for level in levels:
            level_stats = self.stats.get(level, {})
            
            fc_count = level_stats.get('flashcards', 0)
            if fc_count < MIN_FLASHCARDS_PER_LEVEL:
                self.warnings.append(f"⚠️  {level.title()}: Only {fc_count} flashcards (need {MIN_FLASHCARDS_PER_LEVEL})")
            
            gr_count = level_stats.get('grammar', 0)
            if gr_count < MIN_GRAMMAR_PER_LEVEL:
                self.warnings.append(f"⚠️  {level.title()}: Only {gr_count} grammar points (need {MIN_GRAMMAR_PER_LEVEL})")
    
    def validate_all(self) -> Tuple[bool, str]:
        """Validate all data files"""
        print("\n🔍 Validating NPLearn Data...\n")
        
        # Validate level files
        levels = ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']
        for level in levels:
            file_path = self.resources_dir / f"nepali_learning_data_{level}.json"
            if file_path.exists():
                stats = self.validate_level_file(file_path)
                self.stats[level] = stats
                print(f"  ✓ {level.title()}: {stats['flashcards']} flashcards, {stats['grammar']} grammar, {stats['practice']} practice")
            else:
                self.warnings.append(f"⚠️  Missing file: {file_path.name}")
        
        # Validate standalone files
        for filename in ['games.json', 'grammar.json', 'practice.json', 'reading.json', 'speaking.json', 'writing.json']:
            file_path = self.resources_dir / filename
            if file_path.exists():
                if self.validate_json_syntax(file_path):
                    print(f"  ✓ {filename}: Valid JSON")
            else:
                self.warnings.append(f"⚠️  Missing file: {filename}")
        
        # Check minimums
        self.check_minimums()
        
        # Print summary
        print("\n" + "="*60)
        
        if self.errors:
            print("\n❌ ERRORS:")
            for error in self.errors:
                print(f"  {error}")
        
        if self.warnings:
            print("\n⚠️  WARNINGS:")
            for warning in self.warnings:
                print(f"  {warning}")
        
        total_fc = sum(s.get('flashcards', 0) for s in self.stats.values())
        total_gr = sum(s.get('grammar', 0) for s in self.stats.values())
        
        print(f"\n📊 TOTALS:")
        print(f"  Total Flashcards: {total_fc}")
        print(f"  Total Grammar: {total_gr}")
        
        is_valid = len(self.errors) == 0
        
        if is_valid:
            print("\n✅ All data is valid!")
        else:
            print(f"\n❌ Found {len(self.errors)} error(s)")
        
        return is_valid, f"Errors: {len(self.errors)}, Warnings: {len(self.warnings)}"

def main():
    resources = Path(__file__).parent.parent.parent.parent / "NPLearn" / "Resources"
    validator = DataValidator(resources)
    is_valid, summary = validator.validate_all()
    return 0 if is_valid else 1

if __name__ == "__main__":
    exit(main())

