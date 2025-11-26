#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# GitHub Repository Setup
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"

print_section "GitHub Repository Setup"

echo "This script will help you set up your GitHub repository for hosting NPLearn data."
echo ""
echo "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
echo "Branch: $GITHUB_BRANCH"
echo "Data Directory: $GITHUB_DATA_DIR"
echo ""

# Check if repository exists
log_task "Checking repository access"
if curl -s -o /dev/null -w "%{http_code}" "https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_REPO_NAME" | grep -q "200"; then
    log_task_done
    log_info "Repository exists and is accessible"
else
    log_task_failed
    log_warning "Repository not found or not accessible"
    echo ""
    echo "Please create the repository manually:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Create repository: $GITHUB_REPO_NAME"
    echo "  3. Make it public (for raw file access)"
    echo ""
fi

# Create data directory structure
log_task "Creating local data structure"
mkdir -p "$SOURCE_DATA_PATH"
log_task_done

# Check for required files
echo ""
log_info "Required files for NPLearn:"
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$APP_RESOURCES_PATH/$file" ]; then
        echo -e "  ${COLOR_GREEN}✓${COLOR_NC} $file"
    else
        echo -e "  ${COLOR_RED}✗${COLOR_NC} $file (missing)"
    fi
done

echo ""
log_success "Setup check complete!"
echo ""
echo "Next steps:"
echo "  1. Ensure all required JSON files are in: $APP_RESOURCES_PATH"
echo "  2. Run: ./toolkit verify"
echo "  3. Run: ./toolkit upload"

