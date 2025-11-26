#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# PROJECT CONFIGURATION - JLearn App
# ═══════════════════════════════════════════════════════════════════════════
# 📝 This is the ONLY file you need to edit for a new project
# All paths and settings are centralized here
# ═══════════════════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────────────────────────────────
# PROJECT INFORMATION
# ──────────────────────────────────────────────────────────────────────────
PROJECT_NAME="JLearn"
PROJECT_DESCRIPTION="Japanese Learning App - JLPT N5-N1"
DATA_VERSION="4.0"

# ──────────────────────────────────────────────────────────────────────────
# GITHUB CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
GITHUB_USERNAME="dnsmalla"
GITHUB_REPO_NAME="easylearning"
GITHUB_BRANCH="main"

# ──────────────────────────────────────────────────────────────────────────
# DIRECTORY STRUCTURE
# ──────────────────────────────────────────────────────────────────────────
# Source data location (relative to project root)
SOURCE_DATA_DIR="jpleanrning"

# App resources location (optional - where app reads data from)
APP_RESOURCES_DIR="JPLearning/Resources"

# GitHub data folder structure (folder name in GitHub repo)
GITHUB_DATA_DIR="jpleanrning"

# ──────────────────────────────────────────────────────────────────────────
# DATA FILES CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
# File patterns to include
DATA_FILE_PATTERNS=(
    "*.json"
)

# File patterns to exclude
EXCLUDE_PATTERNS=(
    "*.backup"
    "*.backup_*"
    "*.bak"
    "*.tmp"
    "*_temp.json"
)

# Manifest file name
MANIFEST_FILE="manifest.json"

# ──────────────────────────────────────────────────────────────────────────
# DATA VALIDATION RULES
# ──────────────────────────────────────────────────────────────────────────
# Required fields in manifest
REQUIRED_MANIFEST_FIELDS=(
    "version"
    "releaseDate"
)

# Minimum file size (bytes) - files smaller than this are suspicious
MIN_FILE_SIZE=100

# Maximum file size (bytes) - files larger than this trigger a warning
MAX_FILE_SIZE=10485760  # 10MB

# ──────────────────────────────────────────────────────────────────────────
# REPOSITORY SETTINGS
# ──────────────────────────────────────────────────────────────────────────
# Repository visibility (public/private)
REPO_VISIBILITY="public"

# Repository description for GitHub
REPO_DESCRIPTION="Learning data for $PROJECT_NAME ($GITHUB_DATA_DIR folder only)"

# License type
LICENSE_TYPE="Educational Use"

# ──────────────────────────────────────────────────────────────────────────
# AUTOMATION SETTINGS
# ──────────────────────────────────────────────────────────────────────────
# Default commit message
DEFAULT_COMMIT_MESSAGE="Update learning data from $SOURCE_DATA_DIR"

# Temporary directory prefix
TEMP_DIR_PREFIX="temp_github"

# ──────────────────────────────────────────────────────────────────────────
# TESTING CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
# Sample files to test (will test these first)
TEST_FILES=(
    "manifest.json"
    "vocabulary.json"
)

# HTTP timeout for URL tests (seconds)
URL_TEST_TIMEOUT=30

# ═══════════════════════════════════════════════════════════════════════════
# END OF USER CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════
# Everything below is auto-computed - don't edit unless you know what you're doing
# ═══════════════════════════════════════════════════════════════════════════

# Auto-compute derived values
GITHUB_REPO_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME.git"
RAW_BASE_URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME/$GITHUB_BRANCH/$GITHUB_DATA_DIR"

# Export all configuration
export PROJECT_NAME PROJECT_DESCRIPTION DATA_VERSION
export GITHUB_USERNAME GITHUB_REPO_NAME GITHUB_BRANCH GITHUB_REPO_URL RAW_BASE_URL
export SOURCE_DATA_DIR APP_RESOURCES_DIR GITHUB_DATA_DIR
export MANIFEST_FILE DEFAULT_COMMIT_MESSAGE TEMP_DIR_PREFIX
export REPO_VISIBILITY REPO_DESCRIPTION LICENSE_TYPE
export MIN_FILE_SIZE MAX_FILE_SIZE URL_TEST_TIMEOUT
export REQUIRED_MANIFEST_FIELDS DATA_FILE_PATTERNS EXCLUDE_PATTERNS TEST_FILES

