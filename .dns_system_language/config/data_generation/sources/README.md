# Master source for automated data generation

Single source of truth for **all levels** and **all categories** (flashcards, vocabulary practice, listening practice). Add or edit entries here, then run **generate** to refresh level files and practice.json with consistent IDs and `audioText`.

## Files (created by build-master)

- **vocabulary_master.json** – Per-level list: `{ "Beginner": [ { "word", "romanization", "meaning", "category" }, ... ], ... }`
- **grammar_master.json** – Per-level grammar points (id, pattern, title, meaning, usage, examples, level)

## Workflow

1. **First time (seed from existing data)**  
   From repo root:
   ```bash
   bash .dns_system_language/scripts/generate_learning_data.sh build-master
   ```
   This reads `nplearning/nepali_learning_data_*.json` and writes `vocabulary_master.json` and `grammar_master.json` here.

2. **Add or edit content**  
   Edit `vocabulary_master.json`: add entries under each level (`Beginner`, `Elementary`, …) with `word`, `romanization`, `meaning`, `category`.  
   Optionally edit `grammar_master.json` for grammar points.

3. **Regenerate app data**  
   ```bash
   bash .dns_system_language/scripts/generate_learning_data.sh generate
   ```
   This writes:
   - All level files: `nplearning/nepali_learning_data_beginner.json`, … (flashcards + grammar + practice with Vocabulary and Listening, each with `audioText`)
   - `nplearning/practice.json` (levels.beginner.vocabulary, .grammar, .listening)

4. **Validate**  
   ```bash
   bash .dns_system_language/scripts/generate_learning_data.sh validate
   ```

## Consistency

- **IDs:** `beginner_vocab_greetings_001`, `beginner_listen_q_001`, etc.
- **Listening:** Every vocabulary entry becomes one listening question with `audioText` = word and explanation `The word was '…' meaning '…'`.
- **Options:** Generated with correct answer plus 3 wrong options from the same level.
