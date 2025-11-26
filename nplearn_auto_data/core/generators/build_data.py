#!/usr/bin/env python3
"""
NPLearn Data Builder
=====================
Builds JSON data from seed data + web search extensions
"""

import json
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, List

from seed_data import SEED_DATA, count_items

BASE_DIR = Path(__file__).parent.parent.parent.parent
RESOURCES_DIR = BASE_DIR / "NPLearn" / "Resources"
VERSION = "3.1"

class DataBuilder:
    """Builds NPLearn JSON data files"""
    
    def __init__(self):
        self.resources_dir = RESOURCES_DIR
        self.resources_dir.mkdir(parents=True, exist_ok=True)
    
    def create_flashcard(self, nepali: str, english: str, romanization: str, 
                         example: str, level: str, category: str, idx: int) -> dict:
        """Create a flashcard entry"""
        prefix = level[0].lower()
        return {
            "id": f"{prefix}_{category}_{idx:03d}",
            "front": nepali,
            "back": english,
            "romanization": romanization,
            "meaning": english,
            "level": level.title(),
            "category": category,
            "examples": [example] if example else [],
            "isFavorite": False,
            "reviewCount": 0,
            "correctCount": 0
        }
    
    def build_level_data(self, level: str) -> dict:
        """Build complete data for a level"""
        level_data = SEED_DATA.get(level, {})
        flashcards = []
        idx = 1
        
        for category, words in level_data.items():
            for nepali, english, roman, example in words:
                flashcards.append(self.create_flashcard(
                    nepali, english, roman, example, level, category, idx
                ))
                idx += 1
        
        # Generate practice questions from flashcards
        practice = self.generate_practice(flashcards, level)
        
        return {
            "level": level.title(),
            "version": VERSION,
            "description": f"{level.title()} level Nepali learning data",
            "generated": datetime.now().isoformat(),
            "flashcards": flashcards,
            "grammar": self.get_grammar_for_level(level),
            "practice": practice
        }
    
    def generate_practice(self, flashcards: List[dict], level: str) -> List[dict]:
        """Generate practice questions from flashcards"""
        practice = []
        
        # Group flashcards by category for better options
        by_category = {}
        for card in flashcards:
            cat = card['category']
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(card)
        
        idx = 1
        for cat, cards in by_category.items():
            # Generate questions for each category
            for i, card in enumerate(cards[:10]):  # Limit to 10 per category
                # Get wrong options from same category
                wrong_opts = [c['back'] for c in cards if c['id'] != card['id']][:3]
                if len(wrong_opts) < 3:
                    wrong_opts.extend(["Unknown", "Other", "None"])
                
                options = [card['back']] + wrong_opts[:3]
                import random
                random.shuffle(options)
                
                practice.append({
                    "id": f"{level[0].lower()}_prac_{idx:03d}",
                    "question": f"What does '{card['front']}' mean?",
                    "options": options,
                    "correctAnswer": card['back'],
                    "explanation": f"{card['front']} ({card['romanization']}) means {card['back']}",
                    "category": "vocabulary",
                    "level": level.title()
                })
                idx += 1
        
        return practice
    
    def get_grammar_for_level(self, level: str) -> List[dict]:
        """Get grammar points for a level"""
        grammar = {
            "beginner": [
                {"id": "b_gram_001", "title": "Present Tense", "pattern": "Verb + छु/छौ/छ/छौं/छन्", "meaning": "Habitual actions", "examples": [{"nepali": "म खान्छु।", "romanization": "Ma khanchhu.", "english": "I eat."}], "level": "Beginner", "notes": "छु for I, छौ for you, छ for he/she"},
                {"id": "b_gram_002", "title": "Past Tense", "pattern": "Verb + एँ/यौ/यो", "meaning": "Completed actions", "examples": [{"nepali": "म गएँ।", "romanization": "Ma gaen.", "english": "I went."}], "level": "Beginner", "notes": "Past endings vary"},
                {"id": "b_gram_003", "title": "Question Words", "pattern": "के/को/कहाँ/किन/कति", "meaning": "Question formation", "examples": [{"nepali": "के हो?", "romanization": "Ke ho?", "english": "What is it?"}], "level": "Beginner", "notes": "Question word + sentence"},
                {"id": "b_gram_004", "title": "Negation", "pattern": "Verb + दिन/दैन", "meaning": "Negative sentences", "examples": [{"nepali": "म जान्दिनँ।", "romanization": "Ma jandina.", "english": "I don't go."}], "level": "Beginner", "notes": "दिनँ for I, दैन for he/she"},
                {"id": "b_gram_005", "title": "Postpositions", "pattern": "Noun + मा/बाट/सँग/लाई/को", "meaning": "Position words", "examples": [{"nepali": "घरमा", "romanization": "gharma", "english": "at home"}], "level": "Beginner", "notes": "मा=in/at, बाट=from, सँग=with"},
            ],
            "elementary": [
                {"id": "e_gram_001", "title": "Past Continuous", "pattern": "Verb + दै थिएँ/थियो", "meaning": "Was doing", "examples": [{"nepali": "म पढ्दै थिएँ।", "romanization": "Ma padhdai thien.", "english": "I was reading."}], "level": "Elementary", "notes": "For ongoing past actions"},
                {"id": "e_gram_002", "title": "Comparatives", "pattern": "Noun + भन्दा + Adj", "meaning": "Comparing", "examples": [{"nepali": "यो त्यो भन्दा ठूलो छ।", "romanization": "Yo tyo bhanda thulo chha.", "english": "This is bigger than that."}], "level": "Elementary", "notes": "भन्दा means than"},
                {"id": "e_gram_003", "title": "Must/Have to", "pattern": "Verb + नुपर्छ", "meaning": "Obligation", "examples": [{"nepali": "मैले जानुपर्छ।", "romanization": "Maile januparchha.", "english": "I have to go."}], "level": "Elementary", "notes": "Express necessity"},
            ],
            "intermediate": [
                {"id": "i_gram_001", "title": "Conditional", "pattern": "यदि...भने", "meaning": "If...then", "examples": [{"nepali": "यदि पानी पर्यो भने म जान्न।", "romanization": "Yadi pani paryo bhane ma janna.", "english": "If it rains, I won't go."}], "level": "Intermediate", "notes": "यदि=if, भने=then"},
                {"id": "i_gram_002", "title": "Passive Voice", "pattern": "Object + इन्छ/इयो", "meaning": "Passive", "examples": [{"nepali": "खाना खाइयो।", "romanization": "Khana khaiyo.", "english": "Food was eaten."}], "level": "Intermediate", "notes": "Subject becomes object"},
            ],
            "advanced": [
                {"id": "a_gram_001", "title": "Causative", "pattern": "Verb + आउनु", "meaning": "Make someone do", "examples": [{"nepali": "आमाले खुवाउनुहुन्छ।", "romanization": "Amaale khuwaunuhunchha.", "english": "Mother feeds."}], "level": "Advanced", "notes": "Causative verbs"},
                {"id": "a_gram_002", "title": "Reported Speech", "pattern": "भन्यो कि...", "meaning": "Indirect speech", "examples": [{"nepali": "उसले भन्यो कि ऊ आउँछ।", "romanization": "Usle bhanyo ki u aaunchha.", "english": "He said he will come."}], "level": "Advanced", "notes": "Quoting others"},
            ],
            "proficient": [
                {"id": "p_gram_001", "title": "Literary Forms", "pattern": "Classical constructions", "meaning": "Formal writing", "examples": [{"nepali": "यो कार्य सम्पन्न भयो।", "romanization": "Yo karya sampanna bhayo.", "english": "This work was completed."}], "level": "Proficient", "notes": "For formal writing"},
                {"id": "p_gram_002", "title": "Proverbs", "pattern": "Fixed expressions", "meaning": "Traditional sayings", "examples": [{"nepali": "जे बोए त्यही काटिन्छ।", "romanization": "Je boe tyahi katinchha.", "english": "As you sow, so shall you reap."}], "level": "Proficient", "notes": "Common proverbs"},
            ],
        }
        return grammar.get(level, [])
    
    def build_all(self):
        """Build all JSON files"""
        print("\n🇳🇵 NPLearn Data Builder")
        print("="*60)
        
        total_fc = 0
        
        for level in ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']:
            data = self.build_level_data(level)
            
            file_path = self.resources_dir / f"nepali_learning_data_{level}.json"
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            fc_count = len(data['flashcards'])
            total_fc += fc_count
            print(f"  ✅ {level.title()}: {fc_count} flashcards, {len(data['grammar'])} grammar, {len(data['practice'])} practice")
        
        # Build standalone files
        self.build_games()
        self.build_reading()
        self.build_manifest()
        
        print("="*60)
        print(f"  📊 Total: {total_fc} flashcards")
        print(f"  📁 Saved to: {self.resources_dir}")
        
        return total_fc
    
    def build_games(self):
        """Build games.json"""
        games = {
            "games": [
                {
                    "id": "beginner_matching_greetings",
                    "type": "matching",
                    "title": "Match Greetings",
                    "titleNepali": "अभिवादन मिलाउनुहोस्",
                    "level": "Beginner",
                    "pairs": [
                        {"nepali": "नमस्ते", "meaning": "Hello"},
                        {"nepali": "धन्यवाद", "meaning": "Thank you"},
                        {"nepali": "माफ गर्नुहोस्", "meaning": "Sorry"},
                        {"nepali": "कृपया", "meaning": "Please"},
                    ]
                },
                {
                    "id": "beginner_matching_numbers",
                    "type": "matching",
                    "title": "Match Numbers",
                    "titleNepali": "संख्या मिलाउनुहोस्",
                    "level": "Beginner",
                    "pairs": [
                        {"nepali": "एक", "meaning": "One"},
                        {"nepali": "दुई", "meaning": "Two"},
                        {"nepali": "तीन", "meaning": "Three"},
                        {"nepali": "पाँच", "meaning": "Five"},
                    ]
                },
                {
                    "id": "beginner_matching_colors",
                    "type": "matching",
                    "title": "Match Colors",
                    "titleNepali": "रङ मिलाउनुहोस्",
                    "level": "Beginner",
                    "pairs": [
                        {"nepali": "रातो", "meaning": "Red"},
                        {"nepali": "निलो", "meaning": "Blue"},
                        {"nepali": "हरियो", "meaning": "Green"},
                        {"nepali": "सेतो", "meaning": "White"},
                    ]
                },
            ]
        }
        
        file_path = self.resources_dir / "games.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(games, f, ensure_ascii=False, indent=2)
        print(f"  ✅ games.json: {len(games['games'])} games")
    
    def build_reading(self):
        """Build reading.json"""
        reading = {
            "passages": [
                {
                    "id": "beginner_intro",
                    "title": "मेरो परिचय",
                    "titleEnglish": "My Introduction",
                    "level": "Beginner",
                    "content": "नमस्ते! मेरो नाम रितु हो। म नेपाली हुँ। म काठमाडौंमा बस्छु। मेरो परिवारमा चार जना छन्।",
                    "translation": "Hello! My name is Ritu. I am Nepali. I live in Kathmandu. There are four people in my family.",
                    "vocabulary": [
                        {"word": "परिचय", "meaning": "Introduction"},
                        {"word": "परिवार", "meaning": "Family"},
                    ]
                },
                {
                    "id": "beginner_daily",
                    "title": "मेरो दिनचर्या",
                    "titleEnglish": "My Daily Routine",
                    "level": "Beginner",
                    "content": "म बिहान ६ बजे उठ्छु। म दाँत माझ्छु र मुख धुन्छु। म खाना खान्छु। म स्कुल जान्छु।",
                    "translation": "I wake up at 6 in the morning. I brush my teeth and wash my face. I eat food. I go to school.",
                    "vocabulary": [
                        {"word": "दिनचर्या", "meaning": "Daily routine"},
                        {"word": "उठ्नु", "meaning": "To wake up"},
                    ]
                },
            ]
        }
        
        file_path = self.resources_dir / "reading.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(reading, f, ensure_ascii=False, indent=2)
        print(f"  ✅ reading.json: {len(reading['passages'])} passages")
    
    def build_manifest(self):
        """Build manifest.json"""
        manifest = {
            "version": VERSION,
            "lastUpdated": datetime.now().isoformat(),
            "files": [
                "nepali_learning_data_beginner.json",
                "nepali_learning_data_elementary.json",
                "nepali_learning_data_intermediate.json",
                "nepali_learning_data_advanced.json",
                "nepali_learning_data_proficient.json",
                "games.json",
                "reading.json",
            ]
        }
        
        file_path = self.resources_dir / "manifest.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
        print(f"  ✅ manifest.json updated")
    
    def validate(self) -> bool:
        """Validate all JSON files"""
        print("\n🔍 Validating data...")
        all_valid = True
        
        for level in ['beginner', 'elementary', 'intermediate', 'advanced', 'proficient']:
            file_path = self.resources_dir / f"nepali_learning_data_{level}.json"
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                fc = len(data.get('flashcards', []))
                status = "✅" if fc > 0 else "❌"
                print(f"  {status} {file_path.name}: {fc} flashcards")
            except Exception as e:
                print(f"  ❌ {file_path.name}: {e}")
                all_valid = False
        
        return all_valid
    
    def push_to_github(self):
        """Push changes to GitHub"""
        print("\n📤 Pushing to GitHub...")
        try:
            subprocess.run(['git', 'add', '.'], cwd=BASE_DIR, check=True)
            
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
            msg = f"🇳🇵 NPLearn data update - {timestamp}"
            
            subprocess.run(['git', 'commit', '-m', msg], cwd=BASE_DIR, check=True)
            subprocess.run(['git', 'push'], cwd=BASE_DIR, check=True)
            
            print("  ✅ Pushed to GitHub!")
            return True
        except subprocess.CalledProcessError as e:
            print(f"  ❌ Git error: {e}")
            return False


def main():
    import sys
    
    builder = DataBuilder()
    
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "build":
            builder.build_all()
        elif cmd == "validate":
            builder.validate()
        elif cmd == "push":
            builder.push_to_github()
        elif cmd == "all":
            builder.build_all()
            if builder.validate():
                builder.push_to_github()
    else:
        # Default: build all
        builder.build_all()
        builder.validate()


if __name__ == "__main__":
    main()

