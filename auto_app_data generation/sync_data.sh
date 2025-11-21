#!/bin/bash
set -euo pipefail

# Automated Data Sync Script for JLearn
# This script provides a simple interface to the Python automation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/automate_data_sync.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  schema       Display schema information"
    echo "  generate     Generate data for all levels"
    echo "  validate     Validate existing data"
    echo "  sync         Sync data to app resources"
    echo "  full         Generate, validate, sync, and commit (full pipeline)"
    echo "  N5           Process only N5 level"
    echo "  N4           Process only N4 level"
    echo "  N3           Process only N3 level"
    echo "  N2           Process only N2 level"
    echo "  N1           Process only N1 level"
    echo ""
    echo "Examples:"
    echo "  $0 schema                  # Show schema info"
    echo "  $0 full                    # Full automation pipeline"
    echo "  $0 generate sync           # Generate and sync without commit"
    echo "  $0 N5 sync                 # Sync only N5 level"
    echo "  $0 validate                # Validate all existing data"
}

check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 is not installed${NC}"
        exit 1
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

check_python

# Build python command
CMD="python3 $PYTHON_SCRIPT"
LEVEL=""
OPERATIONS=()

for arg in "$@"; do
    case $arg in
        schema)
            # Special case: just show schema info and exit
            python3 "$PYTHON_SCRIPT" --schema-info
            exit 0
            ;;
        generate)
            OPERATIONS+=("--generate")
            ;;
        validate)
            OPERATIONS+=("--validate")
            ;;
        sync)
            OPERATIONS+=("--sync")
            ;;
        commit)
            OPERATIONS+=("--commit")
            ;;
        full)
            OPERATIONS+=("--generate" "--validate" "--sync" "--commit")
            ;;
        N5|N4|N3|N2|N1)
            LEVEL="--level $arg"
            ;;
        all)
            LEVEL="--all-levels"
            ;;
        help|-h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Set default to all levels if no level specified
if [ -z "$LEVEL" ]; then
    LEVEL="--all-levels"
fi

# Build final command
FINAL_CMD="$CMD $LEVEL ${OPERATIONS[*]}"

echo -e "${BLUE}🚀 Running: $FINAL_CMD${NC}"
echo ""

# Execute
eval "$FINAL_CMD"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Operation completed successfully!${NC}"
else
    echo ""
    echo -e "${RED}❌ Operation failed with exit code $EXIT_CODE${NC}"
fi

exit $EXIT_CODE

