#!/usr/bin/env python3
"""
NPLearn – Automated data generator (all levels, all categories).

Single source of truth: sources/vocabulary_master.json (and grammar_master.json).
- build-master: Extract from existing level JSONs → vocabulary_master.json, grammar_master.json
- generate:     From master → all level files + practice.json (consistent IDs, audioText)
- validate:     Check generated JSON against schema

Run from repo root:
  python3 config/data_generation/generator.py build-master
  python3 config/data_generation/generator.py generate
  python3 config/data_generation/generator.py validate
"""

import json
import os
import random
import re
import sys
import argparse
from typing import Dict, List, Any, Optional

# Level display name -> file suffix and ID prefix
LEVEL_MAP = {
    "Beginner": ("beginner", "beginner"),
    "Elementary": ("elementary", "elementary"),
    "Intermediate": ("intermediate", "intermediate"),
    "Advanced": ("advanced", "adv"),
    "Proficient": ("proficient", "prof"),
}

DATA_LEVELS = list(LEVEL_MAP.keys())
DEFAULT_OUTPUT_DIR = "nplearning"
DEFAULT_LEVEL_PREFIX = "nepali_learning_data"


def level_short(level: str) -> str:
    return LEVEL_MAP.get(level, (level.lower(), level.lower()))[1]


def level_file_suffix(level: str) -> str:
    return LEVEL_MAP.get(level, (level.lower(),))[0]


def get_workspace_root() -> str:
    """Repo root: config/data_generation -> config -> .dns_system_language -> repo root."""
    if os.environ.get("WORKSPACE_ROOT"):
        return os.path.abspath(os.environ["WORKSPACE_ROOT"])
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def get_output_dir(args: argparse.Namespace) -> str:
    out = getattr(args, "output_dir", None) or os.environ.get("OUTPUT_DIR", DEFAULT_OUTPUT_DIR)
    if not os.path.isabs(out):
        out = os.path.join(get_workspace_root(), out)
    return out


def get_sources_dir(args: argparse.Namespace) -> str:
    path = getattr(args, "sources_dir", None) or os.environ.get("SOURCES_DIR")
    if path and os.path.isabs(path):
        return path
    base = os.path.dirname(__file__)
    return path or os.path.join(base, "sources")


def get_level_prefix(args: argparse.Namespace) -> str:
    return getattr(args, "level_prefix", None) or os.environ.get("LEVEL_FILE_PREFIX", DEFAULT_LEVEL_PREFIX)


# ---------------------------------------------------------------------------
# build-master: read level files → vocabulary_master.json, grammar_master.json
# ---------------------------------------------------------------------------

def extract_word_from_explanation(explanation: str) -> Optional[str]:
    """Extract Nepali word from 'The word was 'X' meaning ...'."""
    if not explanation:
        return None
    m = re.search(r"The word was\s+['\"]([^'\"]+)['\"]", explanation)
    return m.group(1).strip() if m else None


def build_master(output_dir: str, sources_dir: str, level_prefix: str) -> None:
    os.makedirs(sources_dir, exist_ok=True)
    vocabulary_master: Dict[str, List[Dict]] = {level: [] for level in DATA_LEVELS}
    grammar_master: Dict[str, List[Dict]] = {level: [] for level in DATA_LEVELS}
    seen: Dict[str, set] = {level: set() for level in DATA_LEVELS}

    for level in DATA_LEVELS:
        suffix = level_file_suffix(level)
        path = os.path.join(output_dir, f"{level_prefix}_{suffix}.json")
        if not os.path.isfile(path):
            continue
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        # Flashcards → vocabulary_master
        for card in data.get("flashcards", []):
            word = (card.get("front") or "").strip()
            if not word or word in seen[level]:
                continue
            seen[level].add(word)
            vocabulary_master[level].append({
                "word": word,
                "romanization": card.get("romanization", ""),
                "meaning": card.get("back", ""),
                "category": card.get("category", "general"),
            })
        # Grammar
        grammar_master[level] = data.get("grammar", [])
        # Listening: ensure we have audioText in master (from practice)
        for p in data.get("practice", []):
            if (p.get("category") or "").lower() != "listening":
                continue
            audio_text = p.get("audioText") or extract_word_from_explanation(p.get("explanation") or "")
            correct = (p.get("correctAnswer") or "").strip()
            if audio_text and correct and audio_text not in seen[level]:
                seen[level].add(audio_text)
                vocabulary_master[level].append({
                    "word": audio_text,
                    "romanization": "",
                    "meaning": correct,
                    "category": "listening",
                })

    vocab_path = os.path.join(sources_dir, "vocabulary_master.json")
    with open(vocab_path, "w", encoding="utf-8") as f:
        json.dump(vocabulary_master, f, indent=2, ensure_ascii=False)
    print(f"Wrote {vocab_path}")

    grammar_path = os.path.join(sources_dir, "grammar_master.json")
    with open(grammar_path, "w", encoding="utf-8") as f:
        json.dump(grammar_master, f, indent=2, ensure_ascii=False)
    print(f"Wrote {grammar_path}")


# ---------------------------------------------------------------------------
# generate: vocabulary_master + grammar_master → level files + practice.json
# ---------------------------------------------------------------------------

def make_options(correct: str, all_meanings: List[str], k: int = 4) -> List[str]:
    """Build 4 options with correct answer; shuffle others from all_meanings."""
    others = [m for m in all_meanings if m != correct]
    opts = [correct]
    if len(others) >= k - 1:
        opts.extend(random.sample(others, k - 1))
    else:
        opts.extend(others)
    random.shuffle(opts)
    return opts


def generate_level(
    level: str,
    vocab_list: List[Dict],
    grammar_list: List[Dict],
    level_prefix: str,
) -> Dict[str, Any]:
    short = level_short(level)
    suffix = level_file_suffix(level)
    all_meanings = [v["meaning"] for v in vocab_list]

    # Flashcards
    flashcards = []
    for i, v in enumerate(vocab_list, 1):
        cat = (v.get("category") or "general").replace(" ", "_")
        fid = f"{short}_vocab_{cat}_{i:03d}"
        flashcards.append({
            "id": fid,
            "front": v["word"],
            "back": v["meaning"],
            "romanization": v.get("romanization", ""),
            "meaning": v.get("meaning", v["meaning"]),
            "level": level,
            "category": v.get("category", "general"),
            "examples": [v["word"]],
            "isFavorite": False,
            "reviewCount": 0,
            "correctCount": 0,
        })

    # Practice: Vocabulary + Listening (each word → one vocab question + one listening question)
    practice = []
    for i, v in enumerate(vocab_list, 1):
        word = v["word"]
        meaning = v["meaning"]
        opts_v = make_options(meaning, all_meanings)
        opts_l = make_options(meaning, all_meanings)
        cat = (v.get("category") or "general").replace(" ", "_")
        # Vocabulary question
        practice.append({
            "id": f"{short}_vocab_q_{i:03d}",
            "question": f"What does '{word}' mean?",
            "options": opts_v,
            "correctAnswer": meaning,
            "explanation": f"{word} means {meaning}",
            "audioText": word,
            "category": "Vocabulary",
            "level": level,
        })
        # Listening question
        practice.append({
            "id": f"{short}_listen_q_{i:03d}",
            "question": "Listen and select the correct meaning",
            "options": opts_l,
            "correctAnswer": meaning,
            "audioText": word,
            "explanation": f"The word was '{word}' meaning '{meaning}'",
            "category": "Listening",
            "level": level,
        })

    # Grammar practice: keep existing grammar quiz items from grammar_list if they're practice-shaped
    # grammar_master holds raw grammar points; practice grammar questions can be appended separately or kept from file
    # For now we only merge grammar points; grammar practice questions stay from existing file during merge (see below)

    return {
        "level": level,
        "version": "1.0",
        "description": f"{level} level Nepali learning data",
        "flashcards": flashcards,
        "grammar": grammar_list,
        "practice": practice,
    }


def merge_existing_grammar_and_extra_practice(
    generated: Dict,
    output_dir: str,
    level_prefix: str,
    level: str,
) -> None:
    """Keep existing grammar array and add existing Grammar practice items from level file."""
    suffix = level_file_suffix(level)
    path = os.path.join(output_dir, f"{level_prefix}_{suffix}.json")
    if not os.path.isfile(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        existing = json.load(f)
    # Keep existing grammar if we didn't load any from master
    if not generated.get("grammar") and existing.get("grammar"):
        generated["grammar"] = existing["grammar"]
    # Append existing practice items that are Grammar (not Vocabulary/Listening) so we don't drop them
    existing_practice = existing.get("practice", [])
    for p in existing_practice:
        cat = (p.get("category") or "").strip()
        if cat.lower() == "grammar":
            generated["practice"].append(p)


def generate(
    output_dir: str,
    sources_dir: str,
    level_prefix: str,
    merge_with_existing: bool = True,
) -> None:
    vocab_path = os.path.join(sources_dir, "vocabulary_master.json")
    grammar_path = os.path.join(sources_dir, "grammar_master.json")
    if not os.path.isfile(vocab_path):
        print(f"Missing {vocab_path}. Run: build-master", file=sys.stderr)
        sys.exit(1)
    with open(vocab_path, "r", encoding="utf-8") as f:
        vocabulary_master = json.load(f)
    grammar_master = {}
    if os.path.isfile(grammar_path):
        with open(grammar_path, "r", encoding="utf-8") as f:
            grammar_master = json.load(f)

    os.makedirs(output_dir, exist_ok=True)

    practice_aggregate: Dict[str, Dict[str, List]] = {
        "category": "practice",
        "description": "Practice questions organized by level and category",
        "levels": {},
    }

    for level in DATA_LEVELS:
        vocab_list = vocabulary_master.get(level, [])
        grammar_list = grammar_master.get(level, [])
        payload = generate_level(level, vocab_list, grammar_list, level_prefix)
        if merge_with_existing:
            merge_existing_grammar_and_extra_practice(payload, output_dir, level_prefix, level)
        suffix = level_file_suffix(level)
        out_path = os.path.join(output_dir, f"{level_prefix}_{suffix}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)
        print(f"Wrote {out_path}")

        # practice.json levels: beginner.vocabulary, beginner.grammar, beginner.listening
        lev_key = suffix.lower()
        practice_aggregate["levels"][lev_key] = {
            "vocabulary": [p for p in payload["practice"] if (p.get("category") or "").lower() == "vocabulary"],
            "grammar": [p for p in payload["practice"] if (p.get("category") or "").lower() == "grammar"],
            "listening": [p for p in payload["practice"] if (p.get("category") or "").lower() == "listening"],
        }

    practice_path = os.path.join(output_dir, "practice.json")
    with open(practice_path, "w", encoding="utf-8") as f:
        json.dump(practice_aggregate, f, indent=2, ensure_ascii=False)
    print(f"Wrote {practice_path}")


# ---------------------------------------------------------------------------
# validate
# ---------------------------------------------------------------------------

def validate(output_dir: str, level_prefix: str, schema_path: str) -> bool:
    try:
        import jsonschema
    except ImportError:
        print("Optional: pip install jsonschema for validate", file=sys.stderr)
        return True
    if not os.path.isfile(schema_path):
        return True
    with open(schema_path, "r", encoding="utf-8") as f:
        schema = json.load(f)
    ok = True
    for level in DATA_LEVELS:
        suffix = level_file_suffix(level)
        path = os.path.join(output_dir, f"{level_prefix}_{suffix}.json")
        if not os.path.isfile(path):
            continue
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        try:
            jsonschema.validate(data, schema)
            print(f"Valid: {path}")
        except jsonschema.ValidationError as e:
            print(f"Invalid {path}: {e.message}", file=sys.stderr)
            ok = False
    return ok


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="NPLearn data generator (build-master | generate | validate)")
    parser.add_argument("command", choices=["build-master", "generate", "validate"], help="Command")
    parser.add_argument("--output-dir", default=os.environ.get("OUTPUT_DIR", DEFAULT_OUTPUT_DIR), help="Output directory (default: nplearning)")
    parser.add_argument("--sources-dir", default=os.environ.get("SOURCES_DIR"), help="Sources dir (default: config/data_generation/sources)")
    parser.add_argument("--level-prefix", default=os.environ.get("LEVEL_FILE_PREFIX", DEFAULT_LEVEL_PREFIX), help="Level file prefix")
    parser.add_argument("--no-merge", action="store_true", help="Do not merge existing grammar/grammar practice into generate")
    parser.add_argument("--schema", default=os.environ.get("SCHEMA_FILE"), help="Schema file for validate")
    args = parser.parse_args()

    workspace = get_workspace_root()
    output_dir = get_output_dir(args)
    sources_dir = get_sources_dir(args)
    level_prefix = get_level_prefix(args)

    if args.command == "build-master":
        build_master(output_dir, sources_dir, level_prefix)
    elif args.command == "generate":
        generate(output_dir, sources_dir, level_prefix, merge_with_existing=not args.no_merge)
    elif args.command == "validate":
        schema_path = args.schema or os.path.join(os.path.dirname(__file__), "schema.json")
        if not validate(output_dir, level_prefix, schema_path):
            sys.exit(1)


if __name__ == "__main__":
    main()
