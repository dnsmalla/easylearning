#!/usr/bin/env python3
"""
Restructure data from level-based to category-based format.

Current: 5 files (N5, N4, N3, N2, N1), each with all categories
New: 6 files (vocabulary, grammar, kanji, practice, games, reading), each with all levels
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
SOURCE_DIR = PROJECT_ROOT / "jpleanrning"
OUTPUT_DIR = SOURCE_DIR  # Output to same directory

# Level files to process
LEVELS = ["n5", "n4", "n3", "n2", "n1"]
LEVEL_FILES = [f"japanese_learning_data_{level}_jisho.json" for level in LEVELS]

# Category structure
CATEGORIES = {
    "vocabulary": "flashcards",
    "grammar": "grammar",
    "kanji": "kanji",
    "practice": "practice",
    "games": "games",
    "reading": "readingPassages"
}


def load_level_data(level: str) -> Dict[str, Any]:
    """Load data from a level file."""
    file_path = SOURCE_DIR / f"japanese_learning_data_{level}_jisho.json"
    
    if not file_path.exists():
        print(f"⚠️  Warning: {file_path.name} not found, skipping...")
        return {}
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"✅ Loaded {level.upper()}: ", end="")
    for category_key in CATEGORIES.values():
        count = len(data.get(category_key, []))
        print(f"{category_key}={count} ", end="")
    print()
    
    return data


def restructure_data() -> Dict[str, Dict[str, List[Any]]]:
    """
    Restructure data from level-based to category-based.
    
    Returns:
        Dict with category names as keys, each containing a dict of levels
    """
    # Initialize category structure
    category_data = {
        category: {level: [] for level in LEVELS}
        for category in CATEGORIES.keys()
    }
    
    # Load all level files and redistribute by category
    for level in LEVELS:
        level_data = load_level_data(level)
        
        if not level_data:
            continue
        
        # Distribute data to categories
        for category_name, category_key in CATEGORIES.items():
            items = level_data.get(category_key, [])
            category_data[category_name][level] = items
    
    return category_data


def write_category_file(category: str, data: Dict[str, List[Any]]):
    """Write category data to JSON file."""
    output_file = OUTPUT_DIR / f"{category}.json"
    
    # Calculate total items
    total_items = sum(len(items) for items in data.values())
    
    # Create clean structure
    output_data = {
        "category": category,
        "description": f"All {category} data organized by JLPT level",
        "levels": data
    }
    
    # Write to file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Created {output_file.name} ({total_items} total items)")
    
    # Show level breakdown
    for level in LEVELS:
        count = len(data[level])
        if count > 0:
            print(f"   - {level.upper()}: {count} items")


def create_manifest():
    """Create new manifest.json for category-based structure."""
    manifest_file = OUTPUT_DIR / "manifest.json"
    
    manifest_data = {
        "version": "4.0",
        "releaseDate": "2025-01-24",
        "structure": "category-based",
        "description": "Category-based data structure with levels inside each category",
        "categories": {
            category: {
                "file": f"{category}.json",
                "url": f"https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/{category}.json",
                "checksum": "0000",  # Will be calculated by GitHub
                "levels": ["N5", "N4", "N3", "N2", "N1"]
            }
            for category in CATEGORIES.keys()
        }
    }
    
    with open(manifest_file, 'w', encoding='utf-8') as f:
        json.dump(manifest_data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Created {manifest_file.name}")


def main():
    print("━" * 60)
    print("🔄 RESTRUCTURING DATA: LEVEL-BASED → CATEGORY-BASED")
    print("━" * 60)
    print()
    
    # Load and restructure
    print("📂 Loading level-based data...")
    category_data = restructure_data()
    print()
    
    # Write category files
    print("💾 Writing category-based files...")
    for category, data in category_data.items():
        write_category_file(category, data)
    print()
    
    # Create manifest
    print("📋 Creating new manifest...")
    create_manifest()
    print()
    
    print("━" * 60)
    print("✅ RESTRUCTURING COMPLETE!")
    print("━" * 60)
    print()
    print("📁 Generated files:")
    for category in CATEGORIES.keys():
        print(f"   - {category}.json")
    print(f"   - manifest.json")
    print()
    print("🎯 Next steps:")
    print("   1. Review generated files")
    print("   2. Update Swift code to load category files")
    print("   3. Copy files to Resources/")
    print("   4. Test the app")
    print("   5. Push to GitHub")


if __name__ == "__main__":
    main()


