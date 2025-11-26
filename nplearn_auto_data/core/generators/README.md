# 🇳🇵 NPLearn Data Generation System

## Web Search Based Data Generation

This system generates Nepali learning data using Cursor's @Web search capability.

## Quick Start

### Step 1: Generate a Search Prompt

```bash
python3 workflow.py prompt beginner greetings
```

This generates a prompt like:
```
@Web Search for 25 common Nepali greetings vocabulary words...
```

### Step 2: Use @Web in Cursor

Copy the generated prompt and paste it in Cursor chat with `@Web` prefix.

### Step 3: Process the Response

```bash
python3 data_processor.py
```

Then paste the JSON response from @Web search.

### Step 4: Validate & Push

```bash
python3 workflow.py validate
python3 workflow.py push
```

## Files

| File | Purpose |
|------|---------|
| `prompt_generator.py` | Generates @Web search prompts |
| `data_processor.py` | Processes web search responses |
| `workflow.py` | Complete workflow manager |

## Categories by Level

### Beginner
- greetings, numbers, family, colors, days, months
- food, body_parts, basic_verbs, basic_adjectives, places

### Elementary  
- travel, time, animals, weather, emotions, shopping
- directions, household, occupations, school

### Intermediate
- work, education, health, culture, nature, sports
- technology_basic, media, cooking, relationships

### Advanced
- politics, economics, technology, environment, law
- business, science, medicine, social_issues, history

### Proficient
- literature, philosophy, academics, legal_terms
- journalism, diplomacy, arts, religion, proverbs

## Example Workflow

```bash
# 1. Check what's missing
python3 workflow.py missing

# 2. Generate prompt for missing data
python3 workflow.py prompt beginner food 30

# 3. Copy prompt, use with @Web in Cursor

# 4. Process the response
python3 data_processor.py

# 5. Validate all data
python3 workflow.py validate

# 6. Push to GitHub
python3 workflow.py push
```

## Direct @Web Prompts

### For Vocabulary:
```
@Web Search for 30 common Nepali [CATEGORY] vocabulary words for [LEVEL] level learners with Devanagari script, English meaning, romanization, and example sentence. Format as JSON array.
```

### For Grammar:
```
@Web Search for Nepali grammar rule [TOPIC] with pattern, explanation, 5 example sentences with translations. Format as JSON.
```

### For Reading:
```
@Web Search for short Nepali reading passage about [TOPIC] for [LEVEL] learners (100-200 words) with translation and vocabulary list.
```

