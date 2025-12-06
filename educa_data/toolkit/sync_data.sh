#!/bin/bash
#
# Educa Data Pipeline - Sync & Management Script
# Following DNS System patterns for data management
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(dirname "$SCRIPT_DIR")"
SCHEMA_FILE="$DATA_DIR/data_schema.json"
MANIFEST_FILE="$DATA_DIR/manifest.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Validate JSON syntax
validate_json() {
    local file="$1"
    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Validate all data files
validate_all() {
    print_header "Validating Data Files"
    
    local all_valid=true
    local files=(
        "universities.json"
        "countries.json"
        "courses.json"
        "guides.json"
        "remittance.json"
        "jobs.json"
        "services.json"
        "scholarships.json"
        "updates.json"
    )
    
    for file in "${files[@]}"; do
        local filepath="$DATA_DIR/data/$file"
        if [ -f "$filepath" ]; then
            if validate_json "$filepath"; then
                print_success "$file - Valid JSON"
            else
                print_error "$file - Invalid JSON"
                all_valid=false
            fi
        else
            print_warning "$file - Not found"
        fi
    done
    
    # Validate manifest
    if [ -f "$MANIFEST_FILE" ]; then
        if validate_json "$MANIFEST_FILE"; then
            print_success "manifest.json - Valid JSON"
        else
            print_error "manifest.json - Invalid JSON"
            all_valid=false
        fi
    fi
    
    echo ""
    if [ "$all_valid" = true ]; then
        print_success "All files validated successfully!"
        return 0
    else
        print_error "Some files have errors. Please fix before pushing."
        return 1
    fi
}

# Count items in each data file
count_items() {
    print_header "Data Statistics"
    
    echo ""
    printf "%-20s %s\n" "File" "Items"
    echo "----------------------------------------"
    
    local total=0
    
    for file in "$DATA_DIR/data/"*.json; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local key=$(echo "$filename" | sed 's/.json//')
            
            # Try to count items from the array in the JSON
            local count=$(python3 -c "
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    for key in data:
        if isinstance(data[key], list):
            print(len(data[key]))
            break
    else:
        print(0)
except:
    print(0)
" 2>/dev/null | head -1 || echo "0")
            
            printf "%-20s %s\n" "$filename" "$count"
            if [[ "$count" =~ ^[0-9]+$ ]]; then
                total=$((total + count))
            fi
        fi
    done
    
    echo "----------------------------------------"
    printf "%-20s %s\n" "TOTAL" "$total"
}

# Update manifest version
update_version() {
    local new_version="$1"
    
    print_header "Updating Version to $new_version"
    
    # Update manifest.json
    python3 << EOF
import json
from datetime import datetime

manifest_path = "$MANIFEST_FILE"

with open(manifest_path, 'r') as f:
    manifest = json.load(f)

manifest['version'] = "$new_version"
manifest['last_updated'] = datetime.now().strftime('%Y-%m-%d')

# Update all file versions
for key in manifest.get('files', {}):
    manifest['files'][key]['version'] = "$new_version"

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f"Updated manifest to version $new_version")
EOF
    
    # Update each data file's version
    for file in "$DATA_DIR/data/"*.json; do
        if [ -f "$file" ]; then
            python3 << EOF
import json
from datetime import datetime

with open('$file', 'r') as f:
    data = json.load(f)

data['version'] = "$new_version"
data['last_updated'] = datetime.now().strftime('%Y-%m-%d')

with open('$file', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Updated $(basename $file)")
EOF
        fi
    done
    
    print_success "Version updated to $new_version"
}

# Git commit and push
git_sync() {
    local message="${1:-Update Educa data}"
    local should_push="${2:-false}"
    
    print_header "Git Sync"
    
    cd "$DATA_DIR"
    
    # Check if in git repo
    if [ ! -d ".git" ]; then
        print_warning "Not a git repository. Initialize with: git init"
        return 1
    fi
    
    # Stage data files only
    git add data/ manifest.json data_schema.json README.md
    
    # Check for changes
    if git diff --cached --quiet; then
        print_info "No changes to commit"
        return 0
    fi
    
    # Commit
    git commit -m "📝 $message"
    print_success "Changes committed"
    
    # Push if requested
    if [ "$should_push" = "true" ] || [ "$should_push" = "--push" ]; then
        git push
        print_success "Changes pushed to remote"
    fi
}

# Full pipeline
full_pipeline() {
    local should_push="false"
    
    # Check for --push flag
    for arg in "$@"; do
        if [ "$arg" = "--push" ]; then
            should_push="true"
        fi
    done
    
    print_header "Running Full Data Pipeline"
    
    echo ""
    print_info "Step 1: Validating data files..."
    if ! validate_all; then
        print_error "Validation failed. Stopping pipeline."
        return 1
    fi
    
    echo ""
    print_info "Step 2: Counting items..."
    count_items
    
    echo ""
    print_info "Step 3: Git sync..."
    git_sync "Update Educa data" "$should_push"
    
    echo ""
    print_success "Pipeline completed successfully!"
}

# Show help
show_help() {
    cat << EOF
Educa Data Pipeline - Management Script

Usage:
  ./sync_data.sh [command] [options]

Commands:
  validate        Validate all JSON files
  count           Count items in each data file
  version <ver>   Update version number (e.g., 1.1.0)
  commit <msg>    Commit changes to git
  push            Commit and push to remote
  full            Run full pipeline (validate → count → commit)
  full --push     Run full pipeline with push
  help            Show this help message

Examples:
  # Validate all data files
  ./sync_data.sh validate

  # Update version to 1.1.0
  ./sync_data.sh version 1.1.0

  # Commit changes
  ./sync_data.sh commit "Add new universities"

  # Full pipeline with push
  ./sync_data.sh full --push

Data Files Location:
  $DATA_DIR/data/

EOF
}

# Main
case "${1:-}" in
    validate)
        validate_all
        ;;
    count)
        count_items
        ;;
    version)
        if [ -z "${2:-}" ]; then
            print_error "Please provide version number (e.g., 1.1.0)"
            exit 1
        fi
        update_version "$2"
        ;;
    commit)
        git_sync "${2:-Update Educa data}" "false"
        ;;
    push)
        git_sync "${2:-Update Educa data}" "true"
        ;;
    full)
        shift
        full_pipeline "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

