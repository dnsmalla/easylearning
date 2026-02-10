#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# NPLearn – Automated learning data generation (all levels, all categories)
# ═══════════════════════════════════════════════════════════════════════════
# Single source: config/data_generation/sources/vocabulary_master.json
# Commands: build-master (from existing JSON) | generate | validate
# Run from repo root: bash .dns_system_language/scripts/generate_learning_data.sh [build-master|generate|validate]
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DNS_SYSTEM="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

export DNS_SYSTEM
export WORKSPACE_ROOT
export OUTPUT_DIR="${OUTPUT_DIR:-}"
export SOURCES_DIR="${SOURCES_DIR:-}"
export LEVEL_FILE_PREFIX="${LEVEL_FILE_PREFIX:-}"

if [[ -f "$DNS_SYSTEM/config/data_generation/app_config.sh" ]]; then
  source "$DNS_SYSTEM/config/data_generation/app_config.sh"
fi

# Output under repo root
export OUTPUT_DIR="${OUTPUT_DIR:-$WORKSPACE_ROOT/$DATA_SOURCE_DIR_NAME}"
export SOURCES_DIR="${SOURCES_DIR:-$DNS_SYSTEM/config/data_generation/sources}"

CMD="${1:-generate}"
case "$CMD" in
  build-master)
    echo "Building master from existing level files in $OUTPUT_DIR..."
    python3 "$GENERATOR_SCRIPT" build-master --output-dir "$OUTPUT_DIR" --sources-dir "$SOURCES_DIR" --level-prefix "${LEVEL_FILE_PREFIX:-nepali_learning_data}"
    ;;
  generate)
    echo "Generating all level files and practice.json from master..."
    python3 "$GENERATOR_SCRIPT" generate --output-dir "$OUTPUT_DIR" --sources-dir "$SOURCES_DIR" --level-prefix "${LEVEL_FILE_PREFIX:-nepali_learning_data}"
    ;;
  validate)
    python3 "$GENERATOR_SCRIPT" validate --output-dir "$OUTPUT_DIR" --level-prefix "${LEVEL_FILE_PREFIX:-nepali_learning_data}" --schema "$SCHEMA_FILE"
    ;;
  *)
    echo "Usage: $0 {build-master|generate|validate}"
    echo "  build-master  Extract vocabulary/grammar from existing level JSONs → sources/vocabulary_master.json"
    echo "  generate      Generate all level files + practice.json from master (consistent IDs, audioText)"
    echo "  validate      Validate generated JSON against schema"
    exit 1
    ;;
esac
