#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# DNS DATA GENERATION SYSTEM - CORE
# ═══════════════════════════════════════════════════════════════════════════
# Universal data generation system that works with app-specific modules
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DNS_SYSTEM="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Load libraries
source "$SCRIPT_DIR/../data_sync/lib/colors.sh"
source "$SCRIPT_DIR/../data_sync/lib/logger.sh"

# ───────────────────────────────────────────────────────────────────────────
# Configuration
# ───────────────────────────────────────────────────────────────────────────

load_app_config() {
    local config_file="$DNS_SYSTEM/config/data_generation/app_config.sh"
    
    if [ ! -f "$config_file" ]; then
        log_error "App configuration not found: $config_file"
        echo ""
        echo "Initialize with: bash .cursorrules data-gen init"
        return 1
    fi
    
    source "$config_file"
    log_debug "Loaded app config: $config_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Help
# ───────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║           DNS Data Generation System                              ║
╚═══════════════════════════════════════════════════════════════════╝

Universal data generation system with app-specific modules

USAGE:
    data-gen [COMMAND] [OPTIONS]

COMMANDS:
    init            Initialize data generation for your app
    generate        Generate data using app-specific module
    validate        Validate generated data
    schema          Show/update schema
    config          Show configuration
    module          Manage app-specific module

OPTIONS:
    --level LEVEL   Generate for specific level
    --count N       Number of items to generate
    --output FILE   Output file path

EXAMPLES:
    # Initialize for your app
    bash .cursorrules data-gen init

    # Generate data
    bash .cursorrules data-gen generate --level N5 --count 100

    # Validate generated data
    bash .cursorrules data-gen validate

    # View configuration
    bash .cursorrules data-gen config

ARCHITECTURE:
    Core System (Generic):
      .dns_system/system/core/data_generation/    ← Universal logic
    
    App Module (Your Code):
      .dns_system/config/data_generation/         ← JLearn specific
        ├── app_config.sh                         ← Configuration
        ├── generator.py                          ← Your generator
        └── schema.json                           ← Your schema

You only need to update files in config/data_generation/ for your app!

EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Init
# ───────────────────────────────────────────────────────────────────────────

cmd_init() {
    print_box "Initialize Data Generation Module"
    echo ""
    
    local config_dir="$DNS_SYSTEM/config/data_generation"
    local config_file="$config_dir/app_config.sh"
    local generator_file="$config_dir/generator.py"
    local schema_file="$config_dir/schema.json"
    
    if [ -f "$config_file" ]; then
        log_warning "Module already initialized"
        read -p "Overwrite? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && return 1
    fi
    
    log_info "Creating app-specific module..."
    
    # Ensure directory exists
    mkdir -p "$config_dir"
    
    # Create config
    cat > "$config_file" << EOF
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# APP-SPECIFIC DATA GENERATION CONFIG
# ═══════════════════════════════════════════════════════════════════════════
# Customize this for your app's needs
# ═══════════════════════════════════════════════════════════════════════════

# App information
export APP_NAME="JLearn"
export APP_TYPE="learning"  # learning, ecommerce, content, etc.

# Data levels (customize for your app)
export DATA_LEVELS=("N5" "N4" "N3" "N2" "N1")

# API configuration
export API_BASE_URL="https://jisho.org/api"
export API_TIMEOUT=30

# Generation settings
export DEFAULT_COUNT=100
export BATCH_SIZE=20

# Output configuration
export OUTPUT_DIR="jpleanrning"
export OUTPUT_FORMAT="json"

# Schema file
export SCHEMA_FILE="$DNS_SYSTEM/config/data_generation/schema.json"

# Generator script
export GENERATOR_SCRIPT="$DNS_SYSTEM/config/data_generation/generator.py"
EOF
    
    print_check "Created: app_config.sh"
    
    # Create schema template
    cat > "$schema_file" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "JLearn Data Schema",
  "description": "Japanese learning data structure",
  "type": "object",
  "properties": {
    "flashcards": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/flashcard"
      }
    }
  },
  "definitions": {
    "flashcard": {
      "type": "object",
      "required": ["word", "reading", "meaning", "level"],
      "properties": {
        "word": {"type": "string"},
        "reading": {"type": "string"},
        "meaning": {"type": "string"},
        "level": {
          "type": "string",
          "enum": ["N5", "N4", "N3", "N2", "N1"]
        },
        "examples": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    }
  }
}
EOF
    
    print_check "Created: schema.json"
    
    # Create generator template
    cat > "$generator_file" << 'EOF'
#!/usr/bin/env python3
"""
APP-SPECIFIC DATA GENERATOR
Customize this file for your app's data generation needs
"""

import json
import requests
import sys
from typing import List, Dict, Optional
from datetime import datetime

class AppDataGenerator:
    """
    JLearn-specific data generator
    Customize this class for your app
    """
    
    def __init__(self, api_url: str, schema_path: str):
        self.api_url = api_url
        self.schema_path = schema_path
    
    def fetch_from_api(self, query: str, level: str) -> List[Dict]:
        """
        Fetch data from your API
        CUSTOMIZE THIS METHOD for your data source
        """
        # Example for Jisho API
        try:
            response = requests.get(
                f"{self.api_url}/v1/search/words",
                params={'keyword': query},
                timeout=30
            )
            response.raise_for_status()
            data = response.json()
            
            # Transform API response to your format
            items = []
            for item in data.get('data', []):
                if self._matches_level(item, level):
                    items.append(self._transform_item(item, level))
            
            return items
        except Exception as e:
            print(f"Error fetching data: {e}")
            return []
    
    def _matches_level(self, item: Dict, level: str) -> bool:
        """
        Check if item matches the target level
        CUSTOMIZE THIS for your level logic
        """
        # Example: check JLPT tags
        jlpt_tags = item.get('jlpt', [])
        return f'jlpt-{level.lower()}' in jlpt_tags
    
    def _transform_item(self, api_item: Dict, level: str) -> Dict:
        """
        Transform API response to your data format
        CUSTOMIZE THIS for your schema
        """
        japanese = api_item.get('japanese', [{}])[0]
        senses = api_item.get('senses', [{}])[0]
        
        return {
            'word': japanese.get('word', ''),
            'reading': japanese.get('reading', ''),
            'meaning': '; '.join(senses.get('english_definitions', [])),
            'level': level,
            'examples': senses.get('sentences', [])[:3]
        }
    
    def generate_for_level(self, level: str, count: int = 100) -> List[Dict]:
        """
        Generate data for a specific level
        """
        print(f"Generating {count} items for level {level}...")
        
        # Common words for each JLPT level
        queries = self._get_queries_for_level(level)
        
        all_items = []
        for query in queries:
            items = self.fetch_from_api(query, level)
            all_items.extend(items)
            if len(all_items) >= count:
                break
        
        return all_items[:count]
    
    def _get_queries_for_level(self, level: str) -> List[str]:
        """
        Get search queries for each level
        CUSTOMIZE THIS for your data sources
        """
        # Example queries for Japanese
        queries_by_level = {
            'N5': ['basic', 'common', 'everyday'],
            'N4': ['intermediate', 'conversation'],
            'N3': ['advanced', 'business'],
            'N2': ['formal', 'technical'],
            'N1': ['academic', 'specialized']
        }
        return queries_by_level.get(level, ['common'])
    
    def validate_data(self, data: List[Dict]) -> bool:
        """
        Validate generated data against schema
        """
        # Basic validation
        for item in data:
            if not all(k in item for k in ['word', 'reading', 'meaning', 'level']):
                return False
        return True
    
    def save_data(self, data: List[Dict], output_path: str):
        """
        Save generated data
        """
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump({
                'flashcards': data,
                'metadata': {
                    'generated_at': datetime.utcnow().isoformat(),
                    'total_count': len(data)
                }
            }, f, indent=2, ensure_ascii=False)
        
        print(f"✓ Saved {len(data)} items to {output_path}")


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate app data')
    parser.add_argument('--api', required=True, help='API URL')
    parser.add_argument('--level', required=True, help='Data level')
    parser.add_argument('--count', type=int, default=100, help='Item count')
    parser.add_argument('--output', required=True, help='Output file')
    parser.add_argument('--schema', required=True, help='Schema file')
    
    args = parser.parse_args()
    
    generator = AppDataGenerator(args.api, args.schema)
    data = generator.generate_for_level(args.level, args.count)
    
    if generator.validate_data(data):
        generator.save_data(data, args.output)
        print("✅ Generation complete!")
    else:
        print("❌ Validation failed!")
        sys.exit(1)


if __name__ == '__main__':
    main()
EOF
    
    chmod +x "$generator_file"
    print_check "Created: generator.py"
    
    echo ""
    log_success "Data generation module initialized!"
    echo ""
    color_highlight "📁 App-specific files (customize these):"
    echo "  .dns_system/config/data_generation/"
    echo "    ├── app_config.sh    ← Your settings"
    echo "    ├── generator.py     ← Your generation logic"
    echo "    └── schema.json      ← Your data structure"
    echo ""
    color_highlight "📝 Next steps:"
    echo "  1. Edit generator.py to customize data generation"
    echo "  2. Update schema.json for your data structure"
    echo "  3. Run: bash .cursorrules data-gen generate --level N5"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Generate
# ───────────────────────────────────────────────────────────────────────────

cmd_generate() {
    print_box "Generate Data"
    echo ""
    
    load_app_config || return 1
    
    # Parse options
    local level=""
    local count="${DEFAULT_COUNT:-100}"
    local output=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --level) level="$2"; shift 2 ;;
            --count) count="$2"; shift 2 ;;
            --output) output="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    if [ -z "$level" ]; then
        log_error "Level required. Use: --level N5"
        return 1
    fi
    
    if [ -z "$output" ]; then
        output="${OUTPUT_DIR}/generated_${level}_$(date +%Y%m%d).json"
    fi
    
    log_info "Level: $level"
    log_info "Count: $count"
    log_info "Output: $output"
    echo ""
    
    # Run app-specific generator
    log_info "Running app-specific generator..."
    python3 "$GENERATOR_SCRIPT" \
        --api "$API_BASE_URL" \
        --level "$level" \
        --count "$count" \
        --output "$output" \
        --schema "$SCHEMA_FILE"
    
    if [ $? -eq 0 ]; then
        echo ""
        log_success "Data generation complete!"
        echo ""
        echo "📁 Output: $output"
        echo "📊 Use: bash .cursorrules data-sync upload"
    else
        log_error "Generation failed"
        return 1
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Config
# ───────────────────────────────────────────────────────────────────────────

cmd_config() {
    print_box "Data Generation Configuration"
    echo ""
    
    load_app_config || return 1
    
    echo "App Information:"
    print_arrow "Name: $APP_NAME"
    print_arrow "Type: $APP_TYPE"
    echo ""
    
    echo "Levels:"
    if [ -n "${DATA_LEVELS+x}" ] && [ ${#DATA_LEVELS[@]} -gt 0 ]; then
        for level in "${DATA_LEVELS[@]}"; do
            print_arrow "$level"
        done
    else
        print_arrow "Not configured"
    fi
    echo ""
    
    echo "API:"
    print_arrow "Base URL: $API_BASE_URL"
    echo ""
    
    echo "Output:"
    print_arrow "Directory: $OUTPUT_DIR"
    print_arrow "Format: $OUTPUT_FORMAT"
    echo ""
    
    echo "Files:"
    print_arrow "Config: .dns_system/config/data_generation/app_config.sh"
    print_arrow "Generator: .dns_system/config/data_generation/generator.py"
    print_arrow "Schema: .dns_system/config/data_generation/schema.json"
}

# ───────────────────────────────────────────────────────────────────────────
# Main
# ───────────────────────────────────────────────────────────────────────────

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        init) cmd_init ;;
        generate) cmd_generate "$@" ;;
        config) cmd_config ;;
        validate|schema|module) log_info "Command '$command' not yet implemented" ;;
        --help|-h|help) show_help ;;
        *) show_help; exit 1 ;;
    esac
}

main "$@"

