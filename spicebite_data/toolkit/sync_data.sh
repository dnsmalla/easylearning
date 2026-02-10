#!/bin/bash
# SpiceBite Data Sync Toolkit
# Manages JSON data validation, versioning, and GitHub sync

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
MANIFEST="$SCRIPT_DIR/../manifest.json"
SCHEMA="$SCRIPT_DIR/../data_schema.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  🍛 SpiceBite Data Toolkit${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Validate JSON files
validate() {
    echo -e "${YELLOW}📋 Validating JSON files...${NC}"
    local errors=0
    
    for file in "$DATA_DIR"/*.json; do
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $(basename "$file")"
        else
            echo -e "  ${RED}✗${NC} $(basename "$file") - Invalid JSON"
            ((errors++))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ All JSON files are valid${NC}"
    else
        echo -e "${RED}❌ Found $errors invalid file(s)${NC}"
        exit 1
    fi
}

# Count items in data files
count() {
    echo -e "${YELLOW}📊 Counting items...${NC}"
    
    for file in "$DATA_DIR"/*.json; do
        local name=$(basename "$file" .json)
        local count=$(python3 -c "
import json
with open('$file') as f:
    data = json.load(f)
    if 'restaurants' in data:
        print(len(data['restaurants']))
    elif 'regions' in data:
        print(len(data['regions']))
    elif 'reviews' in data:
        print(len(data['reviews']))
    else:
        print('N/A')
" 2>/dev/null || echo "Error")
        echo -e "  ${BLUE}$name:${NC} $count items"
    done
}

# Update version in manifest
version() {
    local new_version="$1"
    if [ -z "$new_version" ]; then
        echo -e "${RED}❌ Please specify version (e.g., 1.0.1)${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}📝 Updating version to $new_version...${NC}"
    
    # Update manifest version
    python3 -c "
import json
with open('$MANIFEST', 'r') as f:
    manifest = json.load(f)
manifest['version'] = '$new_version'
manifest['last_updated'] = '$(date +%Y-%m-%d)'
for key in manifest['files']:
    manifest['files'][key]['version'] = '$new_version'
with open('$MANIFEST', 'w') as f:
    json.dump(manifest, f, indent=2)
print('✅ Manifest updated')
"
    echo -e "${GREEN}✅ Version updated to $new_version${NC}"
}

# Git commit changes
commit() {
    local message="${1:-Update DineMate data}"
    echo -e "${YELLOW}📤 Committing changes...${NC}"
    
    cd "$SCRIPT_DIR/.."
    git add .
    git commit -m "📝 $message"
    echo -e "${GREEN}✅ Changes committed${NC}"
}

# Push to GitHub
push() {
    echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
    cd "$SCRIPT_DIR/.."
    git push origin main
    echo -e "${GREEN}✅ Pushed to GitHub${NC}"
}

# Full pipeline
full() {
    print_header
    validate
    echo ""
    count
    echo ""
    
    if [ "$1" == "--push" ]; then
        commit "Update restaurant data"
        push
    fi
    
    echo -e "\n${GREEN}✅ Pipeline complete!${NC}"
}

# Show help
help() {
    print_header
    echo ""
    echo "Usage: ./sync_data.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  validate     - Validate all JSON files"
    echo "  count        - Count items in each data file"
    echo "  version X.Y.Z - Update version number"
    echo "  commit \"msg\" - Git commit changes"
    echo "  push         - Push to GitHub"
    echo "  build_osm --country X | --bbox a,b,c,d - Build OSM dataset"
    echo "  full [--push] - Run full pipeline"
    echo "  help         - Show this help"
    echo ""
    echo "Examples:"
    echo "  ./sync_data.sh validate"
    echo "  ./sync_data.sh version 1.1.0"
    echo "  ./sync_data.sh build_osm --country Japan"
    echo "  ./sync_data.sh full --push"
}

# Main
case "${1:-help}" in
    validate) validate ;;
    count) count ;;
    version) version "$2" ;;
    commit) commit "$2" ;;
    push) push ;;
    build_osm) shift; python3 "$SCRIPT_DIR/build_osm.py" "$@" ;;
    full) full "$2" ;;
    help|*) help ;;
esac
