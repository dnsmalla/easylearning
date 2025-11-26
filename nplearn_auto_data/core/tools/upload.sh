#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# Upload to GitHub
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"

print_section "Upload to GitHub"

# Check for git
if ! command -v git &> /dev/null; then
    log_error "Git not installed"
    exit 1
fi

# Create temp directory for upload
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

log_task "Cloning repository"
if git clone --depth 1 "https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME.git" "$TEMP_DIR/repo" 2>/dev/null; then
    log_task_done
else
    log_task_failed
    log_error "Failed to clone repository"
    exit 1
fi

# Create data directory
mkdir -p "$TEMP_DIR/repo/$GITHUB_DATA_DIR"

# Copy all JSON files
log_task "Copying data files"
cp "$APP_RESOURCES_PATH"/*.json "$TEMP_DIR/repo/$GITHUB_DATA_DIR/" 2>/dev/null || true
log_task_done

# Update .gitignore to allow nplearning folder
log_task "Checking .gitignore"
GITIGNORE_FILE="$TEMP_DIR/repo/.gitignore"
if [ -f "$GITIGNORE_FILE" ]; then
    if ! grep -q "!/$GITHUB_DATA_DIR/" "$GITIGNORE_FILE"; then
        # Add nplearning to allowed folders
        sed -i '' "s|!/jpleanrning/|!/jpleanrning/\n!/$GITHUB_DATA_DIR/|" "$GITIGNORE_FILE" 2>/dev/null || \
        sed -i "s|!/jpleanrning/|!/jpleanrning/\n!/$GITHUB_DATA_DIR/|" "$GITIGNORE_FILE"
        log_task_done
        log_info "Added $GITHUB_DATA_DIR to .gitignore allowlist"
    else
        log_task_skip
        log_info "$GITHUB_DATA_DIR already in .gitignore allowlist"
    fi
else
    log_task_skip
fi

# Get version from manifest
VERSION="1.0"
if [ -f "$APP_RESOURCES_PATH/manifest.json" ]; then
    VERSION=$(python3 -c "import json; print(json.load(open('$APP_RESOURCES_PATH/manifest.json'))['version'])" 2>/dev/null || echo "1.0")
fi

# Commit and push
cd "$TEMP_DIR/repo"

log_task "Staging changes"
git add -A
log_task_done

log_task "Committing changes"
if git diff --staged --quiet; then
    log_task_skip
    log_info "No changes to commit"
else
    git commit -m "Update NPLearn data v$VERSION" 2>/dev/null
    log_task_done
fi

log_task "Pushing to GitHub"
if git push origin $GITHUB_BRANCH 2>/dev/null; then
    log_task_done
else
    log_task_failed
    log_error "Failed to push. Make sure you have write access."
    exit 1
fi

echo ""
log_success "Upload complete!"
echo ""
echo "Data available at:"
echo "  $RAW_BASE_URL/manifest.json"

