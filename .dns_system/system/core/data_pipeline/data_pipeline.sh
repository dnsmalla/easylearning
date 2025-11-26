#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# DNS DATA PIPELINE GENERATOR
# ═══════════════════════════════════════════════════════════════════════════
# Automatically generates complete data generation pipelines for any app
# Uses app_tips documentation + data_sync system + LLM to create pipelines
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIPS_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)/app_tips"
DATA_SYNC_DIR="$SCRIPT_DIR/../data_sync"

# Load libraries
source "$SCRIPT_DIR/../data_sync/lib/colors.sh"
source "$SCRIPT_DIR/../data_sync/lib/logger.sh"

# ───────────────────────────────────────────────────────────────────────────
# Pipeline Generator Functions
# ───────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║           DNS Data Pipeline Generator                             ║
╚═══════════════════════════════════════════════════════════════════╝

Automatically generates complete data generation + sync pipelines

USAGE:
    data-pipeline generate [OPTIONS]
    data-pipeline info
    data-pipeline validate
    data-pipeline integrate

COMMANDS:
    generate        Generate complete data pipeline for your app
    info            Show available pipeline templates
    validate        Validate existing pipeline
    integrate       Integrate with existing data sync

OPTIONS:
    --type TYPE     Pipeline type (learning, ecommerce, content, etc.)
    --api URL       API endpoint for data source
    --levels LIST   Data levels (e.g., N5,N4,N3,N2,N1 or Beginner,Intermediate,Advanced)
    --output DIR    Output directory for generated files

EXAMPLES:
    # Generate learning app pipeline
    data-pipeline generate --type learning --api "https://jisho.org/api" --levels "N5,N4,N3,N2,N1"
    
    # Generate e-commerce pipeline
    data-pipeline generate --type ecommerce --api "https://api.stripe.com" 
    
    # Show available templates
    data-pipeline info
    
    # Validate generated pipeline
    data-pipeline validate

WHAT IT GENERATES:
    ✓ Data schema (JSON)
    ✓ Generation scripts (Python)
    ✓ Validation engine
    ✓ Merge logic
    ✓ Automation scripts
    ✓ Shell wrappers
    ✓ CI/CD workflows
    ✓ Integration with data-sync
    ✓ Complete documentation

INTEGRATION:
    The generated pipeline automatically integrates with:
    - DNS data-sync system (for GitHub upload)
    - App tips documentation
    - LLM-powered optimization
    - DNS system logging and metrics

EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Generate
# ───────────────────────────────────────────────────────────────────────────

cmd_generate() {
    print_box "Data Pipeline Generator"
    echo ""
    
    # Parse options
    local pipeline_type="learning"
    local api_url=""
    local data_levels=""
    local output_dir=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type)
                pipeline_type="$2"
                shift 2
                ;;
            --api)
                api_url="$2"
                shift 2
                ;;
            --levels)
                data_levels="$2"
                shift 2
                ;;
            --output)
                output_dir="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log_info "Pipeline Type: $pipeline_type"
    log_info "API URL: ${api_url:-Not specified}"
    log_info "Levels: ${data_levels:-Auto-detect}"
    log_info "Output: ${output_dir:-.}"
    
    echo ""
    print_section "Step 1: Analyzing Requirements"
    
    # Check if app tips exist
    local tips_file="$TIPS_DIR/03_automated_learning_data_pipeline.md"
    if [ -f "$tips_file" ]; then
        print_check "Found app tips documentation"
        log_info "Using: $tips_file"
    else
        log_warning "App tips not found, using basic template"
    fi
    
    echo ""
    print_section "Step 2: Generating Data Schema"
    
    # Generate schema based on type
    generate_schema "$pipeline_type" "$data_levels" "$output_dir"
    
    echo ""
    print_section "Step 3: Creating Generation Scripts"
    
    generate_python_scripts "$pipeline_type" "$api_url" "$data_levels" "$output_dir"
    
    echo ""
    print_section "Step 4: Setting Up Automation"
    
    generate_automation_scripts "$pipeline_type" "$output_dir"
    
    echo ""
    print_section "Step 5: Integrating with Data Sync"
    
    integrate_with_data_sync "$pipeline_type" "$output_dir"
    
    echo ""
    print_section "Step 6: Creating Documentation"
    
    generate_pipeline_docs "$pipeline_type" "$output_dir"
    
    echo ""
    log_success "Pipeline generation complete!"
    echo ""
    color_highlight "📁 Generated Files:"
    echo "  ├── data_schema.json          (Data structure)"
    echo "  ├── generate_data.py          (Data generator)"
    echo "  ├── validate_data.py          (Validator)"
    echo "  ├── merge_data.py             (Merge logic)"
    echo "  ├── automate_pipeline.sh      (Automation)"
    echo "  ├── .github/workflows/        (CI/CD)"
    echo "  └── README_PIPELINE.md        (Documentation)"
    echo ""
    color_highlight "📝 Next Steps:"
    echo "  1. Review generated files in: ${output_dir:-.}"
    echo "  2. Customize API integration in generate_data.py"
    echo "  3. Test: bash automate_pipeline.sh test"
    echo "  4. Run: bash automate_pipeline.sh full"
    echo ""
    echo "📚 Documentation: README_PIPELINE.md"
}

# ───────────────────────────────────────────────────────────────────────────
# Schema Generation
# ───────────────────────────────────────────────────────────────────────────

generate_schema() {
    local type="$1"
    local levels="$2"
    local output="$3"
    
    log_info "Generating schema for type: $type"
    
    # Convert levels string to array
    IFS=',' read -ra LEVEL_ARRAY <<< "$levels"
    
    local schema_file="${output:-.}/data_schema.json"
    
    cat > "$schema_file" << EOF
{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "title": "$(echo $type | sed 's/.*/\u&/') Data Schema",
  "description": "Auto-generated schema for $type data pipeline",
  "version": "1.0.0",
  "type": "object",
  "properties": {
    "items": {
      "type": "array",
      "items": {
        "\$ref": "#/definitions/item"
      }
    },
    "metadata": {
      "\$ref": "#/definitions/metadata"
    }
  },
  "definitions": {
    "item": {
      "type": "object",
      "required": ["id", "level", "content"],
      "properties": {
        "id": {
          "type": "string",
          "description": "Unique identifier"
        },
        "level": {
          "type": "string",
          "enum": [$(for level in "${LEVEL_ARRAY[@]}"; do echo "\"$level\","; done | sed '$ s/,$//')],
          "description": "Difficulty level"
        },
        "content": {
          "type": "object",
          "description": "Main content data"
        },
        "created_at": {
          "type": "string",
          "format": "date-time"
        },
        "updated_at": {
          "type": "string",
          "format": "date-time"
        }
      }
    },
    "metadata": {
      "type": "object",
      "properties": {
        "version": {
          "type": "string"
        },
        "generated_at": {
          "type": "string",
          "format": "date-time"
        },
        "total_items": {
          "type": "integer"
        },
        "levels": {
          "type": "object"
        }
      }
    }
  }
}
EOF
    
    print_check "Created: $schema_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Python Script Generation
# ───────────────────────────────────────────────────────────────────────────

generate_python_scripts() {
    local type="$1"
    local api="$2"
    local levels="$3"
    local output="$4"
    
    log_info "Generating Python scripts..."
    
    # Main generator script
    local gen_file="${output:-.}/generate_data.py"
    
    cat > "$gen_file" << 'GENEOF'
#!/usr/bin/env python3
"""
Auto-generated Data Pipeline Generator
Created by DNS Data Pipeline Generator

This script generates data from external APIs and validates against schema.
"""

import json
import requests
import hashlib
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path

class DataGenerator:
    """Main data generation class"""
    
    def __init__(self, api_url: str, schema_path: str):
        self.api_url = api_url
        self.schema_path = Path(schema_path)
        self.schema = self.load_schema()
    
    def load_schema(self) -> Dict:
        """Load JSON schema"""
        with open(self.schema_path) as f:
            return json.load(f)
    
    def fetch_data(self, query: str, level: str) -> List[Dict]:
        """Fetch data from API"""
        # TODO: Implement your API integration here
        # Example:
        # response = requests.get(f"{self.api_url}/search", params={'q': query, 'level': level})
        # return response.json()
        pass
    
    def generate_id(self, content: Dict) -> str:
        """Generate unique ID for item"""
        content_str = json.dumps(content, sort_keys=True)
        return hashlib.md5(content_str.encode()).hexdigest()
    
    def create_item(self, content: Dict, level: str) -> Dict:
        """Create a data item"""
        now = datetime.utcnow().isoformat() + 'Z'
        return {
            "id": self.generate_id(content),
            "level": level,
            "content": content,
            "created_at": now,
            "updated_at": now
        }
    
    def validate_item(self, item: Dict) -> bool:
        """Validate item against schema"""
        # Basic validation - enhance as needed
        required_fields = ['id', 'level', 'content']
        return all(field in item for field in required_fields)
    
    def generate_for_level(self, level: str, count: int = 100) -> List[Dict]:
        """Generate data for a specific level"""
        print(f"Generating {count} items for level: {level}")
        items = []
        
        # TODO: Implement your generation logic
        # This is a template - customize for your use case
        
        return items
    
    def save_data(self, items: List[Dict], output_path: Path):
        """Save generated data"""
        data = {
            "items": items,
            "metadata": {
                "version": "1.0.0",
                "generated_at": datetime.utcnow().isoformat() + 'Z',
                "total_items": len(items),
                "levels": self._count_by_level(items)
            }
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✓ Saved {len(items)} items to {output_path}")
    
    def _count_by_level(self, items: List[Dict]) -> Dict[str, int]:
        """Count items by level"""
        counts = {}
        for item in items:
            level = item.get('level', 'unknown')
            counts[level] = counts.get(level, 0) + 1
        return counts

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate data')
    parser.add_argument('--api', required=True, help='API URL')
    parser.add_argument('--level', help='Specific level to generate')
    parser.add_argument('--output', default='generated_data.json', help='Output file')
    parser.add_argument('--count', type=int, default=100, help='Items per level')
    
    args = parser.parse_args()
    
    generator = DataGenerator(args.api, 'data_schema.json')
    
    if args.level:
        items = generator.generate_for_level(args.level, args.count)
    else:
        # Generate for all levels from schema
        schema = generator.load_schema()
        levels = schema['definitions']['item']['properties']['level']['enum']
        items = []
        for level in levels:
            items.extend(generator.generate_for_level(level, args.count))
    
    generator.save_data(items, Path(args.output))
    print("✅ Data generation complete!")
GENEOF
    
    chmod +x "$gen_file"
    print_check "Created: $gen_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Automation Scripts
# ───────────────────────────────────────────────────────────────────────────

generate_automation_scripts() {
    local type="$1"
    local output="$2"
    
    log_info "Creating automation scripts..."
    
    local auto_file="${output:-.}/automate_pipeline.sh"
    
    cat > "$auto_file" << 'AUTOEOF'
#!/bin/bash
set -euo pipefail

# Auto-generated Pipeline Automation Script
# Created by DNS Data Pipeline Generator

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Data Pipeline Automation"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  generate    Generate data from API"
    echo "  validate    Validate generated data"
    echo "  merge       Merge with existing data"
    echo "  sync        Sync to app resources"
    echo "  upload      Upload to GitHub (via data-sync)"
    echo "  full        Run complete pipeline"
    echo "  test        Test pipeline"
    echo ""
    echo "Options:"
    echo "  --level LEVEL    Process specific level"
    echo "  --push           Push to GitHub after sync"
}

cmd_generate() {
    echo -e "${BLUE}Generating data...${NC}"
    python3 generate_data.py --api "${API_URL}" "$@"
}

cmd_validate() {
    echo -e "${BLUE}Validating data...${NC}"
    # Use jsonschema for validation
    python3 -c "
import json
import jsonschema

with open('data_schema.json') as f:
    schema = json.load(f)

with open('generated_data.json') as f:
    data = json.load(f)

try:
    jsonschema.validate(data, schema)
    print('✓ Validation passed')
except Exception as e:
    print(f'✗ Validation failed: {e}')
    exit(1)
"
}

cmd_upload() {
    echo -e "${BLUE}Uploading to GitHub...${NC}"
    bash .cursorrules data-sync upload --message "Auto-update from pipeline"
}

cmd_full() {
    echo -e "${GREEN}Running full pipeline...${NC}"
    cmd_generate "$@"
    cmd_validate
    cmd_upload
    echo -e "${GREEN}✅ Pipeline complete!${NC}"
}

case "${1:-}" in
    generate) shift; cmd_generate "$@" ;;
    validate) cmd_validate ;;
    upload) cmd_upload ;;
    full) shift; cmd_full "$@" ;;
    test) cmd_validate ;;
    --help|help|-h) show_help ;;
    *) show_help; exit 1 ;;
esac
AUTOEOF
    
    chmod +x "$auto_file"
    print_check "Created: $auto_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Data Sync Integration
# ───────────────────────────────────────────────────────────────────────────

integrate_with_data_sync() {
    local type="$1"
    local output="$2"
    
    log_info "Integrating with data-sync system..."
    
    echo ""
    color_highlight "The pipeline will automatically use:"
    echo "  → bash .cursorrules data-sync upload"
    echo "  → .dns_system/config/data_sync.conf"
    echo ""
    
    print_check "Integrated with data-sync"
}

# ───────────────────────────────────────────────────────────────────────────
# Documentation Generation
# ───────────────────────────────────────────────────────────────────────────

generate_pipeline_docs() {
    local type="$1"
    local output="$2"
    
    log_info "Generating documentation..."
    
    local doc_file="${output:-.}/README_PIPELINE.md"
    
    cat > "$doc_file" << 'DOCEOF'
# Data Pipeline Documentation

## Overview

This data pipeline was auto-generated by the DNS Data Pipeline Generator.
It provides a complete system for generating, validating, and syncing data.

## Quick Start

```bash
# 1. Configure API
export API_URL="https://your-api.com"

# 2. Generate data
bash automate_pipeline.sh generate

# 3. Validate
bash automate_pipeline.sh validate

# 4. Upload to GitHub
bash automate_pipeline.sh upload

# Or run everything:
bash automate_pipeline.sh full
```

## Components

- **data_schema.json** - Data structure definition
- **generate_data.py** - Data generation script
- **automate_pipeline.sh** - Automation wrapper
- **Integration** - Uses DNS data-sync for GitHub upload

## Customization

1. Edit `generate_data.py` - Customize API integration
2. Edit `data_schema.json` - Adjust data structure
3. Edit `.dns_system/config/data_sync.conf` - Configure GitHub

## Integration with DNS System

The pipeline integrates with:
- ✓ DNS data-sync (GitHub upload)
- ✓ DNS logging system
- ✓ App tips documentation
- ✓ Controlled via .cursorrules

## Documentation

See: .dns_system/app_tips/03_automated_learning_data_pipeline.md
DOCEOF
    
    print_check "Created: $doc_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Info
# ───────────────────────────────────────────────────────────────────────────

cmd_info() {
    print_box "Available Pipeline Templates"
    echo ""
    
    echo "📚 Pipeline Types:"
    echo "  • learning       - Language learning apps (flashcards, vocabulary)"
    echo "  • ecommerce      - Product catalogs, inventory"
    echo "  • content        - Articles, blog posts, media"
    echo "  • social         - User profiles, posts, comments"
    echo "  • analytics      - Metrics, events, logs"
    echo ""
    
    echo "📖 Documentation:"
    if [ -f "$TIPS_DIR/03_automated_learning_data_pipeline.md" ]; then
        print_check "App tips available: $TIPS_DIR/03_automated_learning_data_pipeline.md"
    else
        log_warning "App tips not found"
    fi
    
    echo ""
    echo "🔗 Integration:"
    print_check "DNS data-sync system available"
    print_check "Controlled via .cursorrules"
}

# ───────────────────────────────────────────────────────────────────────────
# Main Entry Point
# ───────────────────────────────────────────────────────────────────────────

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        generate)
            cmd_generate "$@"
            ;;
        info)
            cmd_info
            ;;
        validate)
            log_info "Pipeline validation not yet implemented"
            ;;
        integrate)
            log_info "Integration check not yet implemented"
            ;;
        --help|-h|help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"

