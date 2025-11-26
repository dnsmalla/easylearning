#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# GITHUB SETUP TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Initial setup for GitHub data hosting (first time only)
# Generic tool that works with any project configuration
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/validator.sh"

# ───────────────────────────────────────────────────────────────────────────
# Main setup function
# ───────────────────────────────────────────────────────────────────────────

setup_github_repo() {
    print_box "GitHub Repository - Initial Setup"
    echo ""
    
    # Display configuration
    print_section "Configuration"
    echo "Project: $PROJECT_NAME"
    echo "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    echo "Data Folder: $SOURCE_DATA_DIR → $GITHUB_DATA_DIR"
    echo ""
    
    # Validate configuration
    log_info "Validating configuration..."
    if ! validate_paths; then
        log_error "Configuration validation failed"
        return 1
    fi
    log_success "Configuration is valid"
    
    # Create setup directory
    echo ""
    print_section "Creating Setup Directory"
    
    local setup_dir="$PROJECT_ROOT/${TEMP_DIR_PREFIX}_setup"
    
    if [ -d "$setup_dir" ]; then
        log_warning "Setup directory already exists"
        read -p "Delete and recreate? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            rm -rf "$setup_dir"
        else
            log_error "Cancelled"
            return 1
        fi
    fi
    
    mkdir -p "$setup_dir"
    cd "$setup_dir"
    
    git init
    log_success "Git repository initialized"
    
    # Create data folder and copy files
    mkdir -p "$GITHUB_DATA_DIR"
    
    echo ""
    print_section "Copying Data Files"
    
    local file_count=0
    # Use default pattern if array not set
    local patterns=("*.json")
    if [ -n "${DATA_FILE_PATTERNS+x}" ] && [ ${#DATA_FILE_PATTERNS[@]} -gt 0 ]; then
        patterns=("${DATA_FILE_PATTERNS[@]}")
    fi
    
    for pattern in "${patterns[@]}"; do
        for file in "$SOURCE_DATA_PATH"/$pattern; do
            if [ ! -f "$file" ]; then
                continue
            fi
            
            local filename=$(basename "$file")
            
            if should_exclude_file "$filename"; then
                continue
            fi
            
            cp "$file" "$GITHUB_DATA_DIR/"
            print_check "$filename"
            file_count=$((file_count + 1))
        done
    done
    
    if [ $file_count -eq 0 ]; then
        log_error "No files copied"
        return 1
    fi
    
    log_success "Copied $file_count files"
    
    # Create README and .gitignore
    echo ""
    create_readme
    create_gitignore
    
    # Show summary
    echo ""
    print_section "Repository Contents"
    echo "  README.md"
    echo "  .gitignore"
    echo "  $GITHUB_DATA_DIR/"
    ls -lh "$GITHUB_DATA_DIR"/*.json 2>/dev/null | awk '{print "    " $9 " (" $5 ")"}'
    
    # Instructions
    echo ""
    print_section "Next Steps"
    echo ""
    color_highlight "1. Create GitHub repository:"
    echo "   https://github.com/new"
    echo "   Repository name: $GITHUB_REPO_NAME"
    echo "   Make it PUBLIC"
    echo "   Do NOT initialize with README"
    echo ""
    color_highlight "2. Push to GitHub:"
    echo "   cd $setup_dir"
    echo "   git remote add origin $GITHUB_REPO_URL"
    echo "   git add ."
    echo "   git commit -m \"Initial commit: $PROJECT_NAME data\""
    echo "   git branch -M $GITHUB_BRANCH"
    echo "   git push -u origin $GITHUB_BRANCH"
    echo ""
    color_highlight "3. Verify on GitHub:"
    echo "   Only $GITHUB_DATA_DIR/ folder should be visible"
    echo ""
    color_highlight "4. Test URLs:"
    echo "   $RAW_BASE_URL/$MANIFEST_FILE"
    echo ""
    
    # Ask about GitHub CLI
    echo ""
    read -p "Create repository with GitHub CLI now? (yes/no): " create_now
    
    if [ "$create_now" = "yes" ] || [ "$create_now" = "y" ]; then
        if command -v gh &> /dev/null; then
            log_info "Creating repository with GitHub CLI..."
            if gh repo create "$GITHUB_REPO_NAME" --$REPO_VISIBILITY --description "$REPO_DESCRIPTION" --source=. --push; then
                log_success "Repository created and pushed!"
                echo ""
                echo "View at: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME"
            else
                log_error "Failed to create repository"
            fi
        else
            log_error "GitHub CLI (gh) not found"
            echo "Install with: brew install gh"
        fi
    fi
    
    echo ""
    log_success "Setup complete!"
    log_info "Repository ready in: $setup_dir"
}

# ───────────────────────────────────────────────────────────────────────────
# Helper functions (same as upload.sh)
# ───────────────────────────────────────────────────────────────────────────

create_readme() {
    log_info "Creating README.md..."
    # Same implementation as upload.sh
    cat > README.md << EOF
# $GITHUB_REPO_NAME

$PROJECT_DESCRIPTION

## Contents

This repository contains learning data in the \`$GITHUB_DATA_DIR/\` folder.

## License

$LICENSE_TYPE
EOF
    log_success "README.md created"
}

create_gitignore() {
    log_info "Creating .gitignore..."
    # Same implementation as upload.sh
    cat > .gitignore << EOF
# Only track $GITHUB_DATA_DIR folder
/*
!/$GITHUB_DATA_DIR/
!/README.md
!/.gitignore

$GITHUB_DATA_DIR/*.backup
$GITHUB_DATA_DIR/*.bak
EOF
    log_success ".gitignore created"
}

# ───────────────────────────────────────────────────────────────────────────
# Execute
# ───────────────────────────────────────────────────────────────────────────

setup_github_repo

