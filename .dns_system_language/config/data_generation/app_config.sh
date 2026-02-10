#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# NPLearn – Automated data generation config
# ═══════════════════════════════════════════════════════════════════════════
# Single source of truth: config/data_generation/sources/vocabulary_master.json
# Run: build-master (from existing level files) then generate (all levels/categories)
# ═══════════════════════════════════════════════════════════════════════════

DNS_SYSTEM="${DNS_SYSTEM:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# Load project config (DATA_SOURCE_DIR_NAME, LEVEL_FILE_PREFIX, etc.)
if [[ -f "$DNS_SYSTEM/config/project.conf" ]]; then
  source "$DNS_SYSTEM/config/project.conf"
fi

# App
export APP_NAME="${APP_NAME:-NPLearn}"
export APP_TYPE="learning"

# Levels (must match level file names: beginner, elementary, intermediate, advanced, proficient)
export DATA_LEVELS=("Beginner" "Elementary" "Intermediate" "Advanced" "Proficient")

# Master source: add/edit entries here or run build-master from existing JSON
export SOURCES_DIR="${DNS_SYSTEM}/config/data_generation/sources"
export VOCABULARY_MASTER="${SOURCES_DIR}/vocabulary_master.json"
export GRAMMAR_MASTER="${SOURCES_DIR}/grammar_master.json"

# Output: written under workspace root (run scripts from repo root)
export DATA_SOURCE_DIR_NAME="${DATA_SOURCE_DIR_NAME:-nplearning}"
export LEVEL_FILE_PREFIX="${LEVEL_FILE_PREFIX:-nepali_learning_data}"
if [[ -n "${WORKSPACE_ROOT:-}" ]]; then
  export OUTPUT_DIR="${OUTPUT_DIR:-$WORKSPACE_ROOT/$DATA_SOURCE_DIR_NAME}"
else
  export OUTPUT_DIR="${OUTPUT_DIR:-${DATA_SOURCE_DIR_NAME}}"
fi

# Generator
export SCHEMA_FILE="${DNS_SYSTEM}/config/data_generation/schema.json"
export GENERATOR_SCRIPT="${DNS_SYSTEM}/config/data_generation/generator.py"

# Use master source (no external API)
export USE_MASTER_SOURCE="${USE_MASTER_SOURCE:-true}"
