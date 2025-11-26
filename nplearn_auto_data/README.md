# 🇳🇵 NPLearn Data Toolkit

A unified CLI for generating and managing Nepali learning data using **Cursor AI** - no API keys needed!

## ⚡ Quick Start

```bash
# Make toolkit executable
chmod +x toolkit

# Generate content prompts
./toolkit generate beginner all

# Copy the prompt to Cursor chat, let AI generate content
# Then validate
./toolkit validate
```

## 🎯 How It Works

This toolkit leverages **Cursor's built-in AI** to generate authentic Nepali learning content:

1. **Generate Prompt** → Toolkit creates structured prompts
2. **Copy to Cursor** → Paste prompt in Cursor chat
3. **AI Generates** → Cursor AI creates the content in JSON
4. **Save & Validate** → Copy output to Resources folder

**No API keys. No external services. Just Cursor!**

## 📋 Commands

| Command | Description |
|---------|-------------|
| `generate <level> [type]` | Generate content prompt for Cursor AI |
| `quick <level>` | Quick generate all content types |
| `validate` | Validate all JSON files |
| `list` | List all resource files |
| `stats` | Show content statistics |
| `merge <level>` | Merge generated content |
| `backup` | Backup current resources |
| `clean` | Clean temporary files |

### Levels
- `beginner` - Basic greetings, numbers, family
- `elementary` - Travel, weather, shopping
- `intermediate` - Work, education, culture
- `advanced` - Politics, technology, media
- `proficient` - Literature, philosophy, academics

### Content Types
- `vocab` - Vocabulary flashcards
- `grammar` - Grammar points with examples
- `reading` - Reading passages with comprehension
- `speaking` - Conversational dialogues
- `practice` - Quiz questions
- `all` - Generate all types

## 🚀 Workflow Example

### Step 1: Generate Prompt
```bash
./toolkit generate beginner vocab
```

This creates a prompt like:
```
Generate 10 Nepali vocabulary words for beginner level learners...
```

### Step 2: Copy to Cursor Chat

Open Cursor and paste the prompt. The AI will generate content like:

```json
[
  {
    "id": "beginner_vocab_greetings_001",
    "nepali": "नमस्ते",
    "english": "Hello",
    "romanization": "namaste",
    "meaning": "Traditional greeting",
    "examples": ["नमस्ते, तपाईंलाई कस्तो छ?"],
    "category": "greetings",
    "level": "Beginner"
  }
]
```

### Step 3: Save Output

Copy the JSON and save to:
```
NPLearn/Resources/nepali_learning_data_beginner.json
```

### Step 4: Validate
```bash
./toolkit validate
```

## 📁 File Structure

```
nplearn_auto_data/
├── toolkit                 # Main CLI entry point
├── prompts/                # Generated prompt files
├── core/
│   ├── tools/
│   │   └── cursor_content_generator.py
│   └── lib/
└── backups/               # Backup storage
```

## 💡 Tips for Best Results

### When Using Cursor Chat

1. **Be specific** - The generated prompts are detailed, follow them
2. **Request JSON** - Ask for "valid JSON output"
3. **One at a time** - Generate one content type per conversation
4. **Verify Nepali** - Check Devanagari script accuracy

### Sample Cursor Prompts

**For Vocabulary:**
```
Generate 20 Nepali vocabulary words for intermediate level.
Category: travel
Include: nepali (Devanagari), romanization, english, example sentence
Output as valid JSON array.
```

**For Grammar:**
```
Create a Nepali grammar lesson about past tense verbs.
Level: elementary
Include pattern, examples with romanization, usage notes.
Output as valid JSON.
```

**For Reading:**
```
Write a short Nepali reading passage about "Going to Market".
Level: elementary
Include: original text, translation, vocabulary list, comprehension questions.
Output as valid JSON.
```

## 📊 Content Templates

### Vocabulary JSON
```json
{
  "id": "beginner_vocab_001",
  "nepali": "नमस्ते",
  "english": "Hello",
  "romanization": "namaste",
  "meaning": "Traditional greeting used at any time",
  "examples": ["नमस्ते, कस्तो छ?"],
  "category": "greetings",
  "level": "Beginner"
}
```

### Grammar JSON
```json
{
  "id": "grammar_beginner_present",
  "title": "Present Tense",
  "pattern": "Subject + Verb + छु/छ/छन्",
  "meaning": "Expresses current actions",
  "usage": "For habitual or ongoing actions",
  "examples": [
    {
      "nepali": "म खान्छु।",
      "romanization": "Ma khanchhu.",
      "english": "I eat."
    }
  ],
  "level": "Beginner",
  "notes": "The ending changes based on subject"
}
```

### Reading JSON
```json
{
  "id": "reading_beginner_family",
  "title": "मेरो परिवार",
  "englishTitle": "My Family",
  "difficulty": "beginner",
  "paragraphs": ["Nepali text..."],
  "englishParagraphs": ["Translation..."],
  "vocabulary": [
    {"nepali": "परिवार", "english": "family", "romanization": "pariwar"}
  ],
  "questions": [
    {
      "question": "Question?",
      "options": ["A", "B", "C", "D"],
      "correctAnswer": "A"
    }
  ],
  "level": "Beginner"
}
```

## 🔧 Troubleshooting

### Invalid JSON
- Use `./toolkit validate` to check files
- Ensure JSON has no trailing commas
- Verify all strings use double quotes

### Missing Content
- Generate with `./toolkit generate <level> all`
- Check `prompts/` folder for saved prompts

### Cursor Not Generating Good Content
- Be more specific in the prompt
- Ask for "authentic Nepali" content
- Request examples with romanization

## 📝 Notes

- All Nepali text should be in Devanagari script
- Include romanization for learner pronunciation
- Follow CEFR-aligned difficulty progression
- Keep vocabulary appropriate for each level
