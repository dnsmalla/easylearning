#!/usr/bin/env bash
#
# App Store Review Checker - Convenience Wrapper
# Checks your app against known App Store review requirements
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKER="$SCRIPT_DIR/../system/core/utils/review_checker.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is required but not found${NC}"
    exit 1
fi

# Check if PyYAML is installed
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${YELLOW}Installing required dependency (pyyaml)...${NC}"
    pip3 install pyyaml --quiet || {
        echo -e "${RED}Failed to install pyyaml. Install manually: pip3 install pyyaml${NC}"
        exit 1
    }
fi

# Default to current directory if no argument
APP_DIR="${1:-.}"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         App Store Review Requirements Checker                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Run the checker
python3 "$CHECKER" "$APP_DIR" "$@"
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Your app is ready for submission.${NC}"
else
    echo -e "${RED}❌ Some checks failed. Please fix the issues above before submission.${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo "  • Update bundle identifier in Info.plist and project.yml"
    echo "  • Verify privacy policy and terms URLs are valid"
    echo "  • Ensure all features are implemented"
    echo "  • Run tests on a real device"
fi

exit $EXIT_CODE

