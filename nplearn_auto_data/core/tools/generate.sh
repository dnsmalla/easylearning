#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# Generate Learning Data
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"

print_section "Generate Learning Data"

# Step 1: Run the Python data generator to create comprehensive data
log_step 1 2 "Generating comprehensive vocabulary, grammar, and practice data..."
echo ""

python3 "$SCRIPT_DIR/data_generator.py"

echo ""

# Step 2: Generate level-specific combined files
log_step 2 2 "Generating level-specific JSON files..."
echo ""

generate_level_data() {
    local level=$1
    local level_lower=$(echo "$level" | tr '[:upper:]' '[:lower:]')
    local output_file="$APP_RESOURCES_PATH/nepali_learning_data_${level_lower}.json"
    
    log_task "Generating $level level data"
    
    python3 << EOF
import json
import os

resources_path = "$APP_RESOURCES_PATH"
level = "$level"
level_lower = "$level_lower"
output_file = "$output_file"

# Load vocabulary
flashcards = []
try:
    with open(os.path.join(resources_path, 'vocabulary.json'), 'r') as f:
        vocab_data = json.load(f)
        vocab_items = vocab_data.get('levels', {}).get(level_lower, [])
        for item in vocab_items:
            flashcards.append({
                "id": item.get('id', ''),
                "front": item.get('nepali', ''),
                "back": item.get('english', ''),
                "romanization": item.get('romanization'),
                "meaning": item.get('meaning', ''),
                "level": level,
                "category": item.get('category', 'vocabulary'),
                "examples": item.get('examples', []),
                "isFavorite": False,
                "reviewCount": 0,
                "correctCount": 0
            })
except Exception as e:
    print(f"Warning: Could not load vocabulary: {e}")

# Load grammar
grammar = []
try:
    with open(os.path.join(resources_path, 'grammar.json'), 'r') as f:
        grammar_data = json.load(f)
        grammar_items = grammar_data.get('levels', {}).get(level_lower, [])
        for item in grammar_items:
            grammar.append({
                "id": item.get('id', ''),
                "title": item.get('title', ''),
                "pattern": item.get('pattern', ''),
                "meaning": item.get('meaning', ''),
                "usage": item.get('usage', ''),
                "examples": item.get('examples', []),
                "level": level,
                "notes": item.get('notes')
            })
except Exception as e:
    print(f"Warning: Could not load grammar: {e}")

# Load practice
practice = []
try:
    with open(os.path.join(resources_path, 'practice.json'), 'r') as f:
        practice_data = json.load(f)
        level_practice = practice_data.get('levels', {}).get(level_lower, {})
        
        for category in ['vocabulary', 'grammar', 'listening']:
            questions = level_practice.get(category, [])
            for q in questions:
                practice.append({
                    "id": q.get('id', ''),
                    "question": q.get('question', ''),
                    "options": q.get('options', []),
                    "correctAnswer": q.get('correctAnswer', ''),
                    "explanation": q.get('explanation'),
                    "category": q.get('category', category.capitalize()),
                    "level": level
                })
except Exception as e:
    print(f"Warning: Could not load practice: {e}")

# Create level data
level_data = {
    "level": level,
    "version": "1.0",
    "description": f"{level} level Nepali learning data",
    "flashcards": flashcards,
    "grammar": grammar,
    "practice": practice
}

# Write output file
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(level_data, f, indent=2, ensure_ascii=False)

print(f"  Generated: {len(flashcards)} flashcards, {len(grammar)} grammar, {len(practice)} practice")
EOF
    
    log_task_done
}

# Generate data for all levels
for level in "Beginner" "Elementary" "Intermediate" "Advanced" "Proficient"; do
    generate_level_data "$level"
done

echo ""
log_success "Data generation complete!"
echo ""
log_info "Run './toolkit verify' to validate generated data"
log_info "Run './toolkit sync' to upload to GitHub"

