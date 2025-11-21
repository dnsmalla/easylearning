#!/usr/bin/env python3
"""
Automated Learning Data Management System for JLearn App

This script automates the entire pipeline:
1. Generates learning data from various sources (Jisho API, AI)
2. Validates the generated data structure and content
3. Merges with existing data intelligently (no duplicates)
4. Updates app resources
5. Commits changes to git with proper messages

Usage:
    python automate_data_sync.py --generate --validate --sync --commit
    python automate_data_sync.py --level N5 --source jisho --sync
    python automate_data_sync.py --all-levels --validate-only
"""

import argparse
import json
import os
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
import hashlib

# Paths
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
EASYLEARNING_DIR = SCRIPT_DIR / "easylearning" / "jpleanrning"
APP_RESOURCES_DIR = REPO_ROOT / "JPLearning" / "Resources"
GENERATOR_SCRIPT = SCRIPT_DIR / "generate_learning_data.py"
SCHEMA_FILE = SCRIPT_DIR / "app_data_schema.json"

# Load schema
def load_schema() -> Dict[str, Any]:
    """Load the app data schema"""
    if not SCHEMA_FILE.exists():
        print_error(f"Schema file not found: {SCHEMA_FILE}")
        return {}
    
    try:
        with open(SCHEMA_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print_error(f"Failed to load schema: {e}")
        return {}

SCHEMA = load_schema()

# JLPT Levels - Load from schema
def get_jlpt_levels() -> List[str]:
    """Get JLPT levels from schema"""
    if SCHEMA and "metadata" in SCHEMA and "jlpt_levels" in SCHEMA["metadata"]:
        return list(SCHEMA["metadata"]["jlpt_levels"].keys())
    return ["N5", "N4", "N3", "N2", "N1"]

def get_expected_counts() -> Dict[str, Dict[str, int]]:
    """Get expected counts from schema"""
    if SCHEMA and "metadata" in SCHEMA and "jlpt_levels" in SCHEMA["metadata"]:
        counts = {}
        for level, info in SCHEMA["metadata"]["jlpt_levels"].items():
            counts[level] = {
                "min_flashcards": info.get("min_flashcards", 50),
                "max_flashcards": info.get("max_flashcards", 10000)
            }
        return counts
    return {
        "N5": {"min_flashcards": 50, "max_flashcards": 1000},
        "N4": {"min_flashcards": 50, "max_flashcards": 1500},
        "N3": {"min_flashcards": 50, "max_flashcards": 2000},
        "N2": {"min_flashcards": 50, "max_flashcards": 3000},
        "N1": {"min_flashcards": 50, "max_flashcards": 5000},
    }

JLPT_LEVELS = get_jlpt_levels()
EXPECTED_COUNTS = get_expected_counts()


@dataclass
class ValidationResult:
    """Result of data validation"""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    stats: Dict[str, Any]


def print_header(text: str) -> None:
    """Print a formatted header"""
    print(f"\n{'=' * 70}")
    print(f"  {text}")
    print(f"{'=' * 70}\n")


def print_success(text: str) -> None:
    """Print success message"""
    print(f"✅ {text}")


def print_error(text: str) -> None:
    """Print error message"""
    print(f"❌ {text}", file=sys.stderr)


def print_warning(text: str) -> None:
    """Print warning message"""
    print(f"⚠️  {text}")


def print_info(text: str) -> None:
    """Print info message"""
    print(f"ℹ️  {text}")


def run_command(cmd: List[str], cwd: Optional[Path] = None) -> Tuple[bool, str]:
    """Run a shell command and return success status and output"""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd or REPO_ROOT,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        return False, str(e)


def generate_data(level: str, source: str = "jisho", max_vocab: int = 500, max_kanji: int = 200) -> bool:
    """Generate learning data for a specific level"""
    print_info(f"Generating data for level {level} from {source}...")
    
    output_path = EASYLEARNING_DIR / f"japanese_learning_data_{level.lower()}_jisho.json"
    
    cmd = [
        sys.executable,
        str(GENERATOR_SCRIPT),
        "--level", level,
        "--max-vocab", str(max_vocab),
        "--max-kanji", str(max_kanji),
        "--source", source,
        "--output", str(output_path)
    ]
    
    success, output = run_command(cmd)
    
    if success:
        print_success(f"Generated data for {level} → {output_path.name}")
        return True
    else:
        print_error(f"Failed to generate data for {level}: {output}")
        return False


def validate_flashcard(flashcard: Dict[str, Any], index: int) -> List[str]:
    """Validate a single flashcard structure against schema"""
    errors = []
    
    # Get required fields from schema
    if SCHEMA and "definitions" in SCHEMA and "flashcard" in SCHEMA["definitions"]:
        required_fields = SCHEMA["definitions"]["flashcard"].get("required", [])
        properties = SCHEMA["definitions"]["flashcard"].get("properties", {})
    else:
        required_fields = ["id", "front", "back", "reading", "meaning", "level", "category"]
        properties = {}
    
    # Check required fields
    for field in required_fields:
        if field not in flashcard:
            errors.append(f"Flashcard {index}: Missing required field '{field}'")
        elif not flashcard[field]:
            errors.append(f"Flashcard {index}: Empty value for '{field}'")
    
    # Validate category
    if "category" in flashcard:
        valid_categories = ["vocabulary", "kanji", "grammar"]
        if properties and "category" in properties and "enum" in properties["category"]:
            valid_categories = properties["category"]["enum"]
        
        if flashcard["category"] not in valid_categories:
            errors.append(f"Flashcard {index}: Invalid category '{flashcard['category']}' (expected: {', '.join(valid_categories)})")
    
    # Validate level format
    if "level" in flashcard:
        level = flashcard["level"]
        valid_levels = JLPT_LEVELS
        if properties and "level" in properties and "enum" in properties["level"]:
            valid_levels = properties["level"]["enum"]
        
        if level not in valid_levels:
            errors.append(f"Flashcard {index}: Invalid level '{level}' (expected: {', '.join(valid_levels)})")
    
    return errors


def validate_data(data: Dict[str, Any], level: str) -> ValidationResult:
    """Validate the structure and content of learning data"""
    errors = []
    warnings = []
    stats = {
        "total_flashcards": 0,
        "vocabulary_count": 0,
        "kanji_count": 0,
        "grammar_count": 0,
        "practice_count": 0,
        "duplicate_ids": 0
    }
    
    # Check top-level structure
    required_keys = ["flashcards", "grammar", "practice"]
    for key in required_keys:
        if key not in data:
            errors.append(f"Missing required key: '{key}'")
    
    if "flashcards" in data:
        flashcards = data["flashcards"]
        
        if not isinstance(flashcards, list):
            errors.append("'flashcards' must be a list")
        else:
            stats["total_flashcards"] = len(flashcards)
            
            # Check for duplicates
            seen_ids = set()
            for i, card in enumerate(flashcards):
                if not isinstance(card, dict):
                    errors.append(f"Flashcard {i}: Not a dictionary")
                    continue
                
                # Validate structure
                card_errors = validate_flashcard(card, i)
                errors.extend(card_errors)
                
                # Check for duplicate IDs
                card_id = card.get("id", "")
                if card_id in seen_ids:
                    stats["duplicate_ids"] += 1
                    warnings.append(f"Duplicate ID found: {card_id}")
                seen_ids.add(card_id)
                
                # Count categories
                category = card.get("category", "")
                if category == "vocabulary":
                    stats["vocabulary_count"] += 1
                elif category == "kanji":
                    stats["kanji_count"] += 1
                elif category == "grammar":
                    stats["grammar_count"] += 1
            
            # Validate counts against expected ranges
            expected = EXPECTED_COUNTS.get(level, {})
            min_count = expected.get("min_flashcards", 0)
            max_count = expected.get("max_flashcards", 10000)
            
            if stats["total_flashcards"] < min_count:
                warnings.append(
                    f"Flashcard count ({stats['total_flashcards']}) is below "
                    f"expected minimum ({min_count}) for {level}"
                )
            elif stats["total_flashcards"] > max_count:
                warnings.append(
                    f"Flashcard count ({stats['total_flashcards']}) exceeds "
                    f"expected maximum ({max_count}) for {level}"
                )
    
    # Validate grammar and practice arrays
    for key in ["grammar", "practice"]:
        if key in data and not isinstance(data[key], list):
            errors.append(f"'{key}' must be a list")
        elif key in data:
            stats[f"{key}_count"] = len(data[key])
    
    is_valid = len(errors) == 0
    return ValidationResult(is_valid, errors, warnings, stats)


def compute_file_hash(file_path: Path) -> str:
    """Compute SHA256 hash of a file"""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            sha256.update(chunk)
    return sha256.hexdigest()


def merge_flashcards(existing: List[Dict], new: List[Dict]) -> List[Dict]:
    """Merge flashcards, avoiding duplicates based on front+reading"""
    existing_keys = {(card.get("front", ""), card.get("reading", "")) for card in existing}
    existing_ids = {card.get("id", "") for card in existing}
    
    merged = existing.copy()
    added = 0
    duplicates = 0
    
    for card in new:
        key = (card.get("front", ""), card.get("reading", ""))
        card_id = card.get("id", "")
        
        # Check if this exact content already exists
        if key in existing_keys:
            duplicates += 1
            continue
        
        # Check for ID collision and generate new ID if needed
        if card_id in existing_ids:
            # Generate new unique ID
            base_id = card_id
            counter = 1
            while f"{base_id}_{counter}" in existing_ids:
                counter += 1
            card["id"] = f"{base_id}_{counter}"
        
        merged.append(card)
        existing_ids.add(card["id"])
        added += 1
    
    print_info(f"Merged {added} new flashcards, skipped {duplicates} duplicates")
    return merged


def sync_to_app(level: str, dry_run: bool = False) -> bool:
    """Sync data from easylearning to app resources"""
    source_file = EASYLEARNING_DIR / f"japanese_learning_data_{level.lower()}_jisho.json"
    target_file = APP_RESOURCES_DIR / f"japanese_learning_data_{level.lower()}_jisho.json"
    
    if not source_file.exists():
        print_error(f"Source file not found: {source_file}")
        return False
    
    # Load and validate source data
    try:
        with open(source_file, 'r', encoding='utf-8') as f:
            source_data = json.load(f)
    except Exception as e:
        print_error(f"Failed to load source file: {e}")
        return False
    
    print_info(f"Validating data for {level}...")
    validation = validate_data(source_data, level)
    
    # Print validation results
    if validation.errors:
        print_error(f"Validation failed for {level}:")
        for error in validation.errors:
            print(f"  - {error}")
        return False
    
    if validation.warnings:
        print_warning(f"Validation warnings for {level}:")
        for warning in validation.warnings:
            print(f"  - {warning}")
    
    print_success(f"Validation passed for {level}")
    print(f"  📊 Stats:")
    for key, value in validation.stats.items():
        print(f"     - {key}: {value}")
    
    # Check if target exists and merge if needed
    if target_file.exists():
        try:
            with open(target_file, 'r', encoding='utf-8') as f:
                target_data = json.load(f)
            
            # Compute hashes to check if files are different
            source_hash = compute_file_hash(source_file)
            target_hash = compute_file_hash(target_file)
            
            if source_hash == target_hash:
                print_info(f"Files are identical, skipping sync for {level}")
                return True
            
            # Merge flashcards
            print_info(f"Merging with existing data for {level}...")
            merged_flashcards = merge_flashcards(
                target_data.get("flashcards", []),
                source_data.get("flashcards", [])
            )
            source_data["flashcards"] = merged_flashcards
            
        except Exception as e:
            print_warning(f"Could not load existing target file: {e}")
            print_info("Will overwrite with new data")
    
    if dry_run:
        print_info(f"[DRY RUN] Would sync {level} → {target_file.name}")
        return True
    
    # Write to target
    try:
        target_file.parent.mkdir(parents=True, exist_ok=True)
        with open(target_file, 'w', encoding='utf-8') as f:
            json.dump(source_data, f, ensure_ascii=False, indent=2, sort_keys=True)
        print_success(f"Synced {level} → {target_file}")
        return True
    except Exception as e:
        print_error(f"Failed to write target file: {e}")
        return False


def git_commit_changes(message: Optional[str] = None) -> bool:
    """Commit changes to git"""
    print_header("Git Operations")
    
    # Check git status
    success, output = run_command(["git", "status", "--porcelain"])
    if not success:
        print_error("Failed to check git status")
        return False
    
    if not output.strip():
        print_info("No changes to commit")
        return True
    
    print_info("Changes detected:")
    print(output)
    
    # Add changed files
    files_to_add = [
        str(APP_RESOURCES_DIR / "*.json"),
        str(EASYLEARNING_DIR / "*.json"),
    ]
    
    for pattern in files_to_add:
        run_command(["git", "add", pattern])
    
    # Create commit message
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if message is None:
        message = f"chore: Update learning data - {timestamp}"
    
    # Commit
    success, output = run_command(["git", "commit", "-m", message])
    if success:
        print_success(f"Committed changes: {message}")
        return True
    else:
        print_error(f"Failed to commit: {output}")
        return False


def print_schema_info():
    """Print schema information"""
    print_header("App Data Schema Information")
    
    if not SCHEMA:
        print_error("Schema not loaded")
        return
    
    print(f"📋 Schema Version: {SCHEMA.get('version', 'Unknown')}")
    print(f"📱 App Version: {SCHEMA.get('app_version', 'Unknown')}")
    print(f"📅 Last Updated: {SCHEMA.get('last_updated', 'Unknown')}")
    print(f"📄 Description: {SCHEMA.get('description', 'N/A')}")
    
    if "metadata" in SCHEMA and "jlpt_levels" in SCHEMA["metadata"]:
        print(f"\n🎯 JLPT Levels:")
        for level, info in SCHEMA["metadata"]["jlpt_levels"].items():
            print(f"   {level} ({info['name']}): {info['target_vocab']} vocab, {info['target_kanji']} kanji, {info['target_grammar']} grammar")
    
    if "definitions" in SCHEMA:
        print(f"\n📦 Data Types:")
        for def_name in SCHEMA["definitions"].keys():
            def_info = SCHEMA["definitions"][def_name]
            required = def_info.get("required", [])
            print(f"   - {def_name}: {len(required)} required fields")
    
    if "changelog" in SCHEMA and SCHEMA["changelog"]:
        print(f"\n📜 Recent Changes:")
        latest = SCHEMA["changelog"][-1]
        print(f"   Version {latest['version']} ({latest['date']}):")
        for change in latest['changes']:
            print(f"      - {change}")
    
    print(f"\n✅ Schema loaded successfully from: {SCHEMA_FILE.name}")


def main():
    parser = argparse.ArgumentParser(
        description="Automated Learning Data Management for JLearn"
    )
    parser.add_argument(
        "--level",
        choices=JLPT_LEVELS,
        help="JLPT level to process"
    )
    parser.add_argument(
        "--all-levels",
        action="store_true",
        help="Process all JLPT levels"
    )
    parser.add_argument(
        "--generate",
        action="store_true",
        help="Generate new data"
    )
    parser.add_argument(
        "--source",
        choices=["jisho", "ai"],
        default="jisho",
        help="Data source for generation"
    )
    parser.add_argument(
        "--validate",
        action="store_true",
        help="Validate data"
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate, don't sync or commit"
    )
    parser.add_argument(
        "--sync",
        action="store_true",
        help="Sync data to app resources"
    )
    parser.add_argument(
        "--commit",
        action="store_true",
        help="Commit changes to git"
    )
    parser.add_argument(
        "--commit-message",
        help="Custom git commit message"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes"
    )
    parser.add_argument(
        "--schema-info",
        action="store_true",
        help="Display schema information and exit"
    )
    
    args = parser.parse_args()
    
    # Show schema info if requested
    if args.schema_info:
        print_schema_info()
        return 0
    
    # Determine levels to process
    levels = JLPT_LEVELS if args.all_levels else ([args.level] if args.level else [])
    
    if not levels and not args.validate_only:
        parser.error("Must specify --level or --all-levels")
    
    print_header("JLearn Automated Data Management")
    print(f"🎯 Target levels: {', '.join(levels) if levels else 'All existing files'}")
    print(f"📁 EasyLearning: {EASYLEARNING_DIR}")
    print(f"📱 App Resources: {APP_RESOURCES_DIR}")
    
    success_count = 0
    total_operations = 0
    
    # Process each level
    for level in levels:
        print_header(f"Processing Level {level}")
        total_operations += 1
        level_success = True
        
        # Generate
        if args.generate:
            if not generate_data(level, args.source):
                level_success = False
        
        # Validate and Sync
        if args.validate or args.sync or args.validate_only:
            if not sync_to_app(level, dry_run=args.dry_run or args.validate_only):
                level_success = False
        
        if level_success:
            success_count += 1
            print_success(f"Successfully processed {level}")
    
    # Commit changes
    if args.commit and not args.dry_run and not args.validate_only:
        if success_count > 0:
            git_commit_changes(args.commit_message)
    
    # Final summary
    print_header("Summary")
    print(f"✅ Successful: {success_count}/{total_operations}")
    if success_count < total_operations:
        print_error(f"❌ Failed: {total_operations - success_count}/{total_operations}")
        return 1
    
    print_success("All operations completed successfully! 🎉")
    return 0


if __name__ == "__main__":
    sys.exit(main())

