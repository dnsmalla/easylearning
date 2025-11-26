#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# NPLearn Project Configuration
# ═══════════════════════════════════════════════════════════════════════════

# Project Info
export PROJECT_NAME="nplearn"
export PROJECT_DESCRIPTION="Nepali Learning App Data"

# GitHub Configuration
export GITHUB_USERNAME="dnsmalla"
export GITHUB_REPO_NAME="easylearning"
export GITHUB_BRANCH="main"
export GITHUB_DATA_DIR="nplearning"
export GITHUB_REPO_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME"
export RAW_BASE_URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME/$GITHUB_BRANCH/$GITHUB_DATA_DIR"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../NPLearn" && pwd)"
export SOURCE_DATA_PATH="$PROJECT_ROOT/Resources"
export APP_RESOURCES_PATH="$PROJECT_ROOT/Resources"

# Required files
export REQUIRED_FILES=(
    "manifest.json"
    "vocabulary.json"
    "grammar.json"
    "practice.json"
    "reading.json"
    "games.json"
)

# Test files for URL testing
TEST_FILES=(
    "manifest.json"
    "vocabulary.json"
    "grammar.json"
    "nepali_learning_data_beginner.json"
)
export TEST_FILES

# Settings
export URL_TEST_TIMEOUT=10

