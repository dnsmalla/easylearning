#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# GitHub Data URL Test Script
# ═══════════════════════════════════════════════════════════════
# Tests that all URLs are accessible from GitHub
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Testing GitHub Data URLs                                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME${NC}"
echo -e "${BLUE}Base URL: $RAW_BASE_URL${NC}"
echo ""

# Function to test URL
test_url() {
    local url="$1"
    local name="$2"
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        # Get file size
        size=$(curl -s "$url" 2>/dev/null | wc -c)
        echo -e "${GREEN}✓ OK${NC} (HTTP $response, $size bytes)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $response)"
        return 1
    fi
}

# Test manifest first
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Testing Manifest:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
test_url "$RAW_BASE_URL/manifest.json" "manifest.json"

# Get list of files from local directory
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Testing Data Files:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

success_count=0
fail_count=0
total_count=0

if [ -d "$SOURCE_DATA_PATH" ]; then
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
                total_count=$((total_count + 1))
                if test_url "$RAW_BASE_URL/$filename" "$filename"; then
                    success_count=$((success_count + 1))
                else
                    fail_count=$((fail_count + 1))
                fi
            fi
        fi
    done
fi

# Summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Summary:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "Total files tested: $total_count"
echo -e "${GREEN}Successful: $success_count${NC}"
if [ $fail_count -gt 0 ]; then
    echo -e "${RED}Failed: $fail_count${NC}"
fi
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "Your data is accessible from:"
    echo -e "  ${BLUE}https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "Possible issues:"
    echo "  1. Repository is not public"
    echo "  2. Files haven't been pushed to GitHub yet"
    echo "  3. File names don't match"
    echo "  4. Network connectivity issues"
    echo ""
    echo "Check your repository at:"
    echo -e "  ${BLUE}https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME${NC}"
    exit 1
fi

