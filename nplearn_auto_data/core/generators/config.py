"""
NPLearn Data Generation Configuration
=====================================
Central config for all data generators
"""

from pathlib import Path

# Paths
BASE_DIR = Path(__file__).parent.parent.parent.parent
RESOURCES_DIR = BASE_DIR / "NPLearn" / "Resources"

# Levels
LEVELS = ["beginner", "elementary", "intermediate", "advanced", "proficient"]

# Minimum items required per category
MIN_ITEMS_PER_CATEGORY = 100
MIN_GRAMMAR_PER_LEVEL = 10
MIN_PRACTICE_PER_LEVEL = 50
MIN_GAMES_PER_LEVEL = 5
MIN_READING_PER_LEVEL = 5

# JSON Files needed
JSON_FILES = {
    "level_data": [
        "nepali_learning_data_beginner.json",
        "nepali_learning_data_elementary.json", 
        "nepali_learning_data_intermediate.json",
        "nepali_learning_data_advanced.json",
        "nepali_learning_data_proficient.json",
    ],
    "standalone": [
        "games.json",
        "grammar.json",
        "practice.json",
        "reading.json",
        "speaking.json",
        "vocabulary.json",
        "writing.json",
        "manifest.json",
    ]
}

# Version
VERSION = "3.0"

