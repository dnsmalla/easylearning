#!/usr/bin/env python3
"""
Utility script to generate level-based JSON data for the JLearn app.

This script is designed to be run from the project root directory.
It fetches vocabulary / kanji from the Jisho API by JLPT level and
outputs JSON in the same shape as `japanese_learning_data.json`:

{
  "flashcards": [...],
  "grammar":    [...],
  "practice":   [...]
}

Only `flashcards` are auto-generated here (vocabulary + kanji).
You can later merge the output into your main JSON file or keep it
as a separate source.

Usage examples:

    python generate_learning_data.py --level N5 --max-vocab 100 --max-kanji 50 \
        --output japanese_learning_data_N5_auto.json

    python generate_learning_data.py --level N4 --max-vocab 200 --output n4_vocab.json
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import List, Dict, Any

import requests

try:
    # Optional: used only when --source ai is selected
    from openai import OpenAI  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    OpenAI = None  # type: ignore


JISHO_API = "https://jisho.org/api/v1/search/words"
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
EASYLEARNING_DIR = SCRIPT_DIR / "easylearning"


# ---------------------------------------------------------------------------
# Models matching the app's JSON schema
# ---------------------------------------------------------------------------

@dataclass
class FlashcardJSON:
    id: str
    front: str
    back: str
    reading: str
    meaning: str
    example: str
    exampleReading: str
    exampleMeaning: str
    level: str
    category: str
    tags: List[str]


def is_single_kanji(text: str) -> bool:
    return len(text) == 1


def fetch_jisho(level: str, max_items: int = 100) -> List[Dict[str, Any]]:
    """Fetch raw Jisho entries by JLPT level tag."""
    tag = f"#jlpt-{level.lower()}"  # e.g. N5 -> #jlpt-n5
    params = {"keyword": tag}
    resp = requests.get(JISHO_API, params=params, timeout=15)
    resp.raise_for_status()
    data = resp.json()
    return data.get("data", [])[: max_items]


def normalize_entry(entry: Dict[str, Any]) -> Dict[str, Any]:
    japanese = (entry.get("japanese") or [{}])[0]
    senses = entry.get("senses") or [{}]
    sense = senses[0]
    word = japanese.get("word") or japanese.get("reading") or ""
    reading = japanese.get("reading") or ""
    meanings = sense.get("english_definitions") or []
    jlpt_tags = entry.get("jlpt") or []
    jlpt_level = None
    for tag in jlpt_tags:
        tag = tag.lower()
        if tag.startswith("jlpt-n"):
            digit = tag.split("jlpt-n", 1)[1].strip()
            if digit in {"1", "2", "3", "4", "5"}:
                jlpt_level = f"N{digit}"
                break
    parts_of_speech = sense.get("parts_of_speech") or []
    return {
        "word": word,
        "reading": reading,
        "meanings": meanings,
        "jlptLevel": jlpt_level,
        "partsOfSpeech": parts_of_speech,
    }


def build_flashcards(
    level: str,
    entries: List[Dict[str, Any]],
    category: str,
    start_index: int = 1,
) -> List[FlashcardJSON]:
    flashcards: List[FlashcardJSON] = []
    base_tag = level.lower()
    for idx, entry in enumerate(entries, start=start_index):
        word = entry["word"]
        reading = entry["reading"]
        meanings = entry["meanings"]
        jlpt = entry["jlptLevel"] or level
        if not word or not reading or not meanings:
            continue
        meaning_str = "; ".join(meanings)
        card_id = f"web_{base_tag}_{category}_{idx:03d}"
        flashcards.append(
            FlashcardJSON(
                id=card_id,
                front=word,
                back=reading,
                reading=reading,
                meaning=meaning_str,
                example=word,
                exampleReading=reading,
                exampleMeaning=meaning_str,
                level=jlpt,
                category=category,
                tags=["web", "auto", base_tag, category],
            )
        )
    return flashcards


def generate_for_level(level: str, max_vocab: int, max_kanji: int) -> Dict[str, Any]:
    """Generate flashcards for vocabulary and kanji for a JLPT level."""
    raw_entries = fetch_jisho(level, max_items=max(max_vocab, max_kanji) * 2)
    normalized = [normalize_entry(e) for e in raw_entries]

    vocab_entries: List[Dict[str, Any]] = []
    kanji_entries: List[Dict[str, Any]] = []

    for e in normalized:
        word = e["word"]
        if not word:
            continue
        if is_single_kanji(word):
            if len(kanji_entries) < max_kanji:
                kanji_entries.append(e)
        else:
            if len(vocab_entries) < max_vocab:
                vocab_entries.append(e)

        if len(vocab_entries) >= max_vocab and len(kanji_entries) >= max_kanji:
            break

    flashcards: List[FlashcardJSON] = []
    flashcards.extend(build_flashcards(level, vocab_entries, category="vocabulary"))
    flashcards.extend(
        build_flashcards(
            level,
            kanji_entries,
            category="kanji",
            start_index=len(flashcards) + 1,
        )
    )

    return {
        "flashcards": [asdict(c) for c in flashcards],
        "grammar": [],
        "practice": [],
    }


# ---------------------------------------------------------------------------
# AI prompt-based generation (via OpenAI)
# ---------------------------------------------------------------------------

PROMPT_SCHEMA_DESCRIPTION = """
You are helping generate JSON learning content for the JLearn iOS app.
The JSON MUST be valid and follow this exact structure:

{
  "flashcards": [
    {
      "id": "string, unique id like web_n5_vocabulary_001",
      "front": "Japanese word or kanji",
      "back": "reading (kana)",
      "reading": "reading (kana, same as back)",
      "meaning": "short English meaning(s), semicolon-separated if multiple",
      "example": "short Japanese example sentence (optional, can reuse front)",
      "exampleReading": "reading of example (optional)",
      "exampleMeaning": "English translation of example",
      "level": "JLPT level string, e.g. \\"N5\\"",
      "category": "one of: vocabulary, kanji",
      "tags": ["web", "auto", "n5", "vocabulary"]
    }
  ],
  "grammar": [],
  "practice": []
}

Only include the keys shown above. Do not add other top‑level keys.
"""


def build_ai_prompt(level: str, max_vocab: int, max_kanji: int) -> str:
    """Create a natural-language prompt for the LLM."""
    return (
        f"{PROMPT_SCHEMA_DESCRIPTION}\n\n"
        f"Task:\n"
        f"- Generate up to {max_vocab} JLPT {level} vocabulary flashcards.\n"
        f"- Generate up to {max_kanji} JLPT {level} kanji flashcards.\n"
        f"- Focus on high-frequency items that are useful for learners.\n"
        f"- Use realistic, simple example sentences suitable for the level.\n"
        f"- Return ONLY the JSON object, no explanation text.\n"
    )


def generate_with_ai(level: str, max_vocab: int, max_kanji: int) -> Dict[str, Any]:
    """Generate flashcards using an LLM via the OpenAI API."""
    if OpenAI is None:
        raise RuntimeError(
            "openai package is not installed. "
            "Install with `pip install openai` and set OPENAI_API_KEY."
        )

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable is not set.")

    client = OpenAI(api_key=api_key)
    model = os.getenv("OPENAI_MODEL", "gpt-4.1-mini")

    prompt = build_ai_prompt(level, max_vocab, max_kanji)
    print("\n--- Generated Prompt ---\n")
    print(prompt)
    print("\n--- Running LLM to generate JSON data ---\n")

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": "You are a precise JSON generator."},
            {"role": "user", "content": prompt},
        ],
        temperature=0.3,
    )

    content = response.choices[0].message.content or ""

    # Try to extract pure JSON from the response
    start = content.find("{")
    end = content.rfind("}")
    if start == -1 or end == -1:
        raise ValueError("Model response did not contain a JSON object.")

    json_str = content[start : end + 1]
    return json.loads(json_str)


def main(argv: List[str]) -> int:
    parser = argparse.ArgumentParser(description="Generate JSON data for JLearn.")
    parser.add_argument(
        "--level",
        required=True,
        help="JLPT level, e.g. N5, N4, N3, N2, N1",
    )
    parser.add_argument(
        "--max-vocab",
        type=int,
        default=100,
        help="Maximum number of vocabulary flashcards to generate.",
    )
    parser.add_argument(
        "--max-kanji",
        type=int,
        default=50,
        help="Maximum number of kanji flashcards to generate.",
    )
    parser.add_argument(
        "--source",
        choices=["jisho", "ai"],
        default="jisho",
        help="Data source: 'jisho' (web API, default) or 'ai' (LLM-generated JSON).",
    )
    parser.add_argument(
        "--output",
        help="Path to output JSON file. "
        "If omitted, a default path under EasyLearning/ will be used.",
    )

    args = parser.parse_args(argv)
    level = args.level.upper()

    # Default output path if none provided
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = (
            EASYLEARNING_DIR
            / "jpleanrning"
            / f"japanese_learning_data_{level.lower()}_{args.source}.json"
        )

    try:
        if args.source == "jisho":
            payload = generate_for_level(level, args.max_vocab, args.max_kanji)
        else:
            payload = generate_with_ai(level, args.max_vocab, args.max_kanji)
    except Exception as exc:  # pylint: disable=broad-except
        print(f"❌ Failed to generate data for level {level}: {exc}", file=sys.stderr)
        return 1

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2, sort_keys=True)

    print(
        f"✅ Generated JSON for level {level}: "
        f"{len(payload['flashcards'])} flashcards "
        f"(vocab+kanji) → {output_path}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))


