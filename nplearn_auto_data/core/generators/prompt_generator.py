#!/usr/bin/env python3
"""
NPLearn Web Search Prompt Generator
=====================================
Generates prompts for Cursor @Web to search for Nepali learning data
"""

import json
from pathlib import Path
from datetime import datetime

# Categories for each level
CATEGORIES = {
    "beginner": [
        "greetings", "numbers", "family", "colors", "days", "months",
        "food", "body_parts", "basic_verbs", "basic_adjectives", "places"
    ],
    "elementary": [
        "travel", "time", "animals", "weather", "emotions", "shopping",
        "directions", "household", "occupations", "school"
    ],
    "intermediate": [
        "work", "education", "health", "culture", "nature", "sports",
        "technology_basic", "media", "cooking", "relationships"
    ],
    "advanced": [
        "politics", "economics", "technology", "environment", "law",
        "business", "science", "medicine", "social_issues", "history"
    ],
    "proficient": [
        "literature", "philosophy", "academics", "legal_terms",
        "journalism", "diplomacy", "arts", "religion", "proverbs"
    ]
}

def generate_vocab_prompt(level: str, category: str, count: int = 25) -> str:
    """Generate a web search prompt for vocabulary"""
    return f"""@Web Search for {count} common Nepali {category.replace('_', ' ')} vocabulary words for {level} level learners.

For each word, I need:
- Nepali word (Devanagari script)
- English meaning
- Romanization (how to pronounce)
- Example sentence in Nepali

Format as JSON:
```json
{{
  "category": "{category}",
  "level": "{level.title()}",
  "words": [
    {{
      "nepali": "नेपाली शब्द",
      "english": "English meaning",
      "romanization": "pronunciation",
      "example": "Example sentence"
    }}
  ]
}}
```

Search sources: Nepali language learning sites, dictionaries, educational resources."""

def generate_grammar_prompt(level: str, topic: str) -> str:
    """Generate a web search prompt for grammar"""
    topics = {
        "beginner": ["present tense", "past tense", "question words", "negation", "postpositions"],
        "elementary": ["past continuous", "comparatives", "modal verbs", "conjunctions"],
        "intermediate": ["conditionals", "passive voice", "relative clauses", "subjunctive"],
        "advanced": ["causative verbs", "reported speech", "honorifics", "complex sentences"],
        "proficient": ["literary forms", "proverbs", "formal writing", "classical constructions"]
    }
    
    return f"""@Web Search for Nepali grammar rule: {topic} for {level} level.

I need:
- Grammar pattern/rule
- Explanation in English
- 3-5 example sentences with translations
- Common mistakes to avoid

Format as JSON:
```json
{{
  "title": "{topic}",
  "level": "{level.title()}",
  "pattern": "Grammar pattern",
  "explanation": "How it works",
  "examples": [
    {{"nepali": "...", "romanization": "...", "english": "..."}}
  ],
  "notes": "Additional tips"
}}
```

Search: Nepali grammar guides, language learning resources."""

def generate_reading_prompt(level: str, topic: str) -> str:
    """Generate a web search prompt for reading passages"""
    return f"""@Web Search for a short Nepali reading passage about {topic} suitable for {level} level learners.

I need:
- Nepali text (100-200 words for {level})
- English translation
- 5-10 vocabulary words with meanings
- 3 comprehension questions

Format as JSON:
```json
{{
  "title": "Title in Nepali",
  "titleEnglish": "English title",
  "level": "{level.title()}",
  "content": "Nepali passage...",
  "translation": "English translation...",
  "vocabulary": [
    {{"word": "...", "meaning": "...", "romanization": "..."}}
  ],
  "questions": [
    {{"question": "...", "answer": "..."}}
  ]
}}
```

Search: Nepali stories, educational texts, news for learners."""

def generate_all_prompts(output_dir: Path):
    """Generate all prompts and save to files"""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    prompts = []
    
    for level, categories in CATEGORIES.items():
        for category in categories:
            prompt = {
                "type": "vocabulary",
                "level": level,
                "category": category,
                "prompt": generate_vocab_prompt(level, category),
                "output_file": f"vocab_{level}_{category}.json"
            }
            prompts.append(prompt)
    
    # Save prompts index
    index_file = output_dir / "prompts_index.json"
    with open(index_file, 'w', encoding='utf-8') as f:
        json.dump({
            "generated": datetime.now().isoformat(),
            "total_prompts": len(prompts),
            "prompts": prompts
        }, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Generated {len(prompts)} prompts")
    print(f"📁 Saved to: {index_file}")
    
    return prompts

def get_next_prompt(prompts_file: Path) -> dict:
    """Get the next prompt that hasn't been processed"""
    with open(prompts_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for prompt in data['prompts']:
        if not prompt.get('completed', False):
            return prompt
    
    return None

def print_prompt_for_cursor(level: str = None, category: str = None, prompt_type: str = "vocabulary"):
    """Print a prompt ready to copy for Cursor @Web"""
    
    if prompt_type == "vocabulary" and level and category:
        print("\n" + "="*60)
        print("📋 COPY THIS PROMPT FOR CURSOR @Web:")
        print("="*60 + "\n")
        print(generate_vocab_prompt(level, category))
        print("\n" + "="*60)
    
    elif prompt_type == "grammar" and level:
        topics = {
            "beginner": "present tense verbs",
            "elementary": "past continuous tense",
            "intermediate": "conditional sentences",
            "advanced": "causative verbs",
            "proficient": "literary forms"
        }
        print("\n" + "="*60)
        print("📋 COPY THIS PROMPT FOR CURSOR @Web:")
        print("="*60 + "\n")
        print(generate_grammar_prompt(level, topics.get(level, "basic grammar")))
        print("\n" + "="*60)

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("""
NPLearn Prompt Generator
========================

Usage:
  python prompt_generator.py vocab <level> <category>
  python prompt_generator.py grammar <level>
  python prompt_generator.py reading <level> <topic>
  python prompt_generator.py all

Examples:
  python prompt_generator.py vocab beginner greetings
  python prompt_generator.py vocab elementary animals
  python prompt_generator.py grammar intermediate
  python prompt_generator.py all
        """)
        sys.exit(0)
    
    cmd = sys.argv[1]
    
    if cmd == "vocab" and len(sys.argv) >= 4:
        level = sys.argv[2]
        category = sys.argv[3]
        print_prompt_for_cursor(level, category, "vocabulary")
    
    elif cmd == "grammar" and len(sys.argv) >= 3:
        level = sys.argv[2]
        print_prompt_for_cursor(level, prompt_type="grammar")
    
    elif cmd == "all":
        output_dir = Path(__file__).parent / "prompts"
        generate_all_prompts(output_dir)
    
    else:
        print("Invalid arguments. Run without arguments for help.")

