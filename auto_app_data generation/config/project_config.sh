#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Project Configuration
# ═══════════════════════════════════════════════════════════════
# 📝 EDIT THIS FILE for each new project
# This file contains all project-specific settings
# ═══════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────
# GitHub Configuration
# ───────────────────────────────────────────────────────────────
GITHUB_USERNAME="dnsmalla"
GITHUB_REPO_NAME="easylearning"
GITHUB_REPO_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME.git"

# ───────────────────────────────────────────────────────────────
# Project Paths (relative to project root)
# ───────────────────────────────────────────────────────────────
# Where is your project root? (parent of auto_app_data generation)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source data folder (where JSON files are located)
SOURCE_DATA_FOLDER="jpleanrning"
SOURCE_DATA_PATH="$PROJECT_ROOT/$SOURCE_DATA_FOLDER"

# App resources folder (where app reads data from)
APP_RESOURCES_FOLDER="JPLearning/Resources"
APP_RESOURCES_PATH="$PROJECT_ROOT/$APP_RESOURCES_FOLDER"

# ───────────────────────────────────────────────────────────────
# GitHub Repository Structure
# ───────────────────────────────────────────────────────────────
# Where should data be placed in the GitHub repo?
GITHUB_DATA_FOLDER="jpleanrning"

# ───────────────────────────────────────────────────────────────
# Data Files Configuration
# ───────────────────────────────────────────────────────────────
# Data files to sync (pattern match)
DATA_FILE_PATTERN="*.json"

# Exclude patterns (backup files, etc.)
EXCLUDE_PATTERNS=(
    "*.backup"
    "*.backup_*"
    "*.bak"
    "*.tmp"
)

# ───────────────────────────────────────────────────────────────
# Raw GitHub URLs
# ───────────────────────────────────────────────────────────────
RAW_BASE_URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME/main/$GITHUB_DATA_FOLDER"

# ───────────────────────────────────────────────────────────────
# Temporary Directories
# ───────────────────────────────────────────────────────────────
TEMP_REPO_DIR="$PROJECT_ROOT/temp_github_repo"

# ───────────────────────────────────────────────────────────────
# Colors for Output
# ───────────────────────────────────────────────────────────────
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export NC='\033[0m' # No Color

# ───────────────────────────────────────────────────────────────
# Helper Functions
# ───────────────────────────────────────────────────────────────

print_config() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Project Configuration${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}GitHub:${NC}"
    echo "  Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    echo "  URL: $GITHUB_REPO_URL"
    echo ""
    echo -e "${BLUE}Paths:${NC}"
    echo "  Project Root: $PROJECT_ROOT"
    echo "  Source Data: $SOURCE_DATA_PATH"
    echo "  App Resources: $APP_RESOURCES_PATH"
    echo ""
    echo -e "${BLUE}GitHub Structure:${NC}"
    echo "  Data Folder: $GITHUB_DATA_FOLDER"
    echo "  Raw Base URL: $RAW_BASE_URL"
    echo ""
}

validate_config() {
    local errors=0
    
    echo -e "${BLUE}Validating configuration...${NC}"
    echo ""
    
    # Check source data path
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        echo -e "${RED}❌ Source data path not found: $SOURCE_DATA_PATH${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✓ Source data path exists${NC}"
    fi
    
    # Check app resources path
    if [ ! -d "$APP_RESOURCES_PATH" ]; then
        echo -e "${YELLOW}⚠️  App resources path not found: $APP_RESOURCES_PATH${NC}"
        echo "   (This is OK if you don't have app resources yet)"
    else
        echo -e "${GREEN}✓ App resources path exists${NC}"
    fi
    
    # Check for data files
    local file_count=$(find "$SOURCE_DATA_PATH" -name "$DATA_FILE_PATTERN" -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        echo -e "${RED}❌ No data files found matching pattern: $DATA_FILE_PATTERN${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✓ Found $file_count data files${NC}"
    fi
    
    echo ""
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}Configuration has $errors error(s)${NC}"
        return 1
    else
        echo -e "${GREEN}Configuration is valid!${NC}"
        return 0
    fi
}

# ───────────────────────────────────────────────────────────────
# Auto-export all variables
# ───────────────────────────────────────────────────────────────
export GITHUB_USERNAME
export GITHUB_REPO_NAME
export GITHUB_REPO_URL
export PROJECT_ROOT
export SOURCE_DATA_FOLDER
export SOURCE_DATA_PATH
export APP_RESOURCES_FOLDER
export APP_RESOURCES_PATH
export GITHUB_DATA_FOLDER
export DATA_FILE_PATTERN
export RAW_BASE_URL
export TEMP_REPO_DIR

# ───────────────────────────────────────────────────────────────
# Usage as standalone script
# ───────────────────────────────────────────────────────────────
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        show|print)
            print_config
            ;;
        validate|check)
            print_config
            echo ""
            validate_config
            ;;
        *)
            echo "Usage: $0 {show|validate}"
            echo ""
            echo "Commands:"
            echo "  show      - Display configuration"
            echo "  validate  - Validate configuration"
            echo ""
            echo "This file is typically sourced by other scripts."
            exit 1
            ;;
    esac
fi

