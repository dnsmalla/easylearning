#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# Data Integrity Verification Script
# ═══════════════════════════════════════════════════════════════
# Validates JSON files before uploading to GitHub
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Data Integrity Verification                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DATA_PATH" ]; then
    echo -e "${RED}❌ Source directory not found: $SOURCE_DATA_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}Checking: $SOURCE_DATA_PATH${NC}"
echo ""

total_files=0
valid_files=0
invalid_files=0
total_size=0

# Function to check JSON validity
check_json() {
    local file="$1"
    local filename=$(basename "$file")
    
    echo -n "Checking $filename... "
    
    # Check if file is valid JSON
    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        local size_kb=$((size / 1024))
        total_size=$((total_size + size))
        valid_files=$((valid_files + 1))
        echo -e "${GREEN}✓ Valid${NC} (${size_kb} KB)"
        return 0
    else
        invalid_files=$((invalid_files + 1))
        echo -e "${RED}✗ Invalid JSON${NC}"
        return 1
    fi
}

# Check all JSON files
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Validating JSON Files:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

for file in "$SOURCE_DATA_PATH"/$DATA_FILE_PATTERN; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        
        # Skip backup files
        should_skip=false
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$filename" == $pattern ]]; then
                should_skip=true
                break
            fi
        done
        
        if [ "$should_skip" = false ]; then
            total_files=$((total_files + 1))
            check_json "$file"
        else
            echo "Skipping $filename (backup)"
        fi
    fi
done

# Check for manifest.json specifically
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Checking Manifest:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

MANIFEST_FILE="$SOURCE_DATA_PATH/manifest.json"
if [ -f "$MANIFEST_FILE" ]; then
    if python3 -c "
import json
import sys

try:
    with open('$MANIFEST_FILE', 'r') as f:
        data = json.load(f)
    
    # Check required fields
    required_fields = ['version', 'releaseDate']
    missing = [field for field in required_fields if field not in data]
    
    if missing:
        print('❌ Missing required fields:', ', '.join(missing))
        sys.exit(1)
    
    print('✓ Version:', data.get('version'))
    print('✓ Release Date:', data.get('releaseDate'))
    
    if 'categories' in data:
        print('✓ Structure: category-based')
        print('✓ Categories:', len(data['categories']))
    
    sys.exit(0)
except Exception as e:
    print(f'❌ Error: {e}')
    sys.exit(1)
" 2>&1; then
        echo -e "${GREEN}✓ Manifest is valid${NC}"
    else
        echo -e "${RED}✗ Manifest has issues${NC}"
        invalid_files=$((invalid_files + 1))
    fi
else
    echo -e "${YELLOW}⚠️  manifest.json not found${NC}"
fi

# Summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Summary:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo "Total files checked: $total_files"
echo -e "${GREEN}Valid: $valid_files${NC}"

if [ $invalid_files -gt 0 ]; then
    echo -e "${RED}Invalid: $invalid_files${NC}"
fi

total_size_mb=$(echo "scale=2; $total_size / 1024 / 1024" | bc)
echo "Total size: ${total_size_mb} MB"
echo ""

if [ $invalid_files -eq 0 ]; then
    echo -e "${GREEN}✅ All files are valid!${NC}"
    echo ""
    echo "Safe to upload to GitHub."
    exit 0
else
    echo -e "${RED}❌ Some files have errors${NC}"
    echo ""
    echo "Please fix errors before uploading to GitHub."
    exit 1
fi

