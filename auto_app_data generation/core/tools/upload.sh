#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# GITHUB UPLOAD TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Uploads ONLY the data folder to GitHub (no app source code)
# Generic tool that works with any project configuration
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/validator.sh"

# ───────────────────────────────────────────────────────────────────────────
# Main upload function
# ───────────────────────────────────────────────────────────────────────────

upload_to_github() {
    print_box "Upload Data to GitHub"
    echo ""
    
    log_info "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    log_info "Data Folder: $SOURCE_DATA_DIR → $GITHUB_DATA_DIR"
    echo ""
    
    # Verify source directory exists
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        log_error "Source directory not found: $SOURCE_DATA_PATH"
        return 1
    fi
    
    # Handle existing temp repo
    if [ -d "$TEMP_REPO_DIR" ]; then
        log_warning "Temporary repository already exists"
        echo "  1. Update existing repository (recommended)"
        echo "  2. Delete and clone fresh"
        echo "  3. Cancel"
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                log_info "Using existing repository"
                cd "$TEMP_REPO_DIR"
                git pull origin $GITHUB_BRANCH || log_warning "Pull failed, continuing anyway"
                ;;
            2)
                log_info "Removing old repository..."
                rm -rf "$TEMP_REPO_DIR"
                log_info "Cloning fresh repository..."
                git clone "$GITHUB_REPO_URL" "$TEMP_REPO_DIR"
                cd "$TEMP_REPO_DIR"
                ;;
            3)
                log_warning "Cancelled"
                return 1
                ;;
            *)
                log_error "Invalid choice"
                return 1
                ;;
        esac
    else
        log_info "Cloning repository..."
        git clone "$GITHUB_REPO_URL" "$TEMP_REPO_DIR"
        cd "$TEMP_REPO_DIR"
        log_success "Repository cloned"
    fi
    
    echo ""
    log_info "Ensuring $GITHUB_DATA_DIR folder structure..."
    mkdir -p "$GITHUB_DATA_DIR"
    
    # Copy data files
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
            
            # Skip excluded files
            if should_exclude_file "$filename"; then
                log_debug "Skipping excluded file: $filename"
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
    
    log_success "Copied $file_count files to repository"
    
    # Create/update README if needed
    if [ ! -f "README.md" ]; then
        create_readme
    fi
    
    # Create/update .gitignore if needed
    if [ ! -f ".gitignore" ]; then
        create_gitignore
    fi
    
    # Show files ready to upload
    echo ""
    print_section "Files Ready to Upload"
    ls -lh "$GITHUB_DATA_DIR"/*.json 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    
    # Git operations
    echo ""
    print_section "Git Operations"
    
    git add "$GITHUB_DATA_DIR"/*.json README.md .gitignore 2>/dev/null || true
    git status --short
    
    echo ""
    read -p "Commit message (or press Enter for default): " commit_msg
    
    if [ -z "$commit_msg" ]; then
        commit_msg="$DEFAULT_COMMIT_MESSAGE"
    fi
    
    log_info "Committing changes..."
    git commit -m "$commit_msg" || log_info "Nothing to commit (no changes detected)"
    
    echo ""
    log_info "Pushing to GitHub..."
    
    if git push origin $GITHUB_BRANCH; then
        echo ""
        log_success "SUCCESS! Files uploaded to GitHub"
        echo ""
        color_highlight "🔗 View your repository:"
        echo "   $GITHUB_REPO_URL"
        echo ""
        color_highlight "🔗 Test your files:"
        echo "   $RAW_BASE_URL/manifest.json"
        echo ""
        
        # Save upload report
        save_upload_report
        
        return 0
    else
        log_error "Push failed"
        echo ""
        echo "Please check:"
        echo "  1. Git credentials configured"
        echo "  2. Push access to repository"
        echo "  3. Network connection"
        return 1
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Helper functions
# ───────────────────────────────────────────────────────────────────────────

create_readme() {
    log_info "Creating README.md..."
    
    cat > README.md << EOF
# $GITHUB_REPO_NAME

$PROJECT_DESCRIPTION

## Contents

This repository contains learning data in the \`$GITHUB_DATA_DIR/\` folder.

## Data Structure

- Category-based structure
- JSON format
- Versioned with manifest.json

## How It Works

1. The app downloads these JSON files on first launch
2. Data is cached locally on the device for offline use
3. App checks for updates periodically
4. Users only download what they need

## Updating Content

To update the learning data:

1. Edit JSON files locally in your project's \`$SOURCE_DATA_DIR/\` folder
2. Update the version in \`$SOURCE_DATA_DIR/$MANIFEST_FILE\`
3. Run the upload tool from your project
4. Users automatically receive updates

## URLs

Data is accessible via:
\`\`\`
$RAW_BASE_URL/
\`\`\`

## License

$LICENSE_TYPE

---

**Note**: This repository contains ONLY data files.
The app source code is maintained separately.
EOF
    
    log_success "README.md created"
}

create_gitignore() {
    log_info "Creating .gitignore..."
    
    cat > .gitignore << EOF
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Backups
*.backup
*.bak
*.tmp
*.backup_*

# Temp files
*~
*.swp
*.swo

# Only track $GITHUB_DATA_DIR folder
/*
!/$GITHUB_DATA_DIR/
!/README.md
!/LICENSE
!/.gitignore

# Within $GITHUB_DATA_DIR, ignore backup files
$GITHUB_DATA_DIR/*.backup
$GITHUB_DATA_DIR/*.backup_*
$GITHUB_DATA_DIR/*.bak
EOF
    
    log_success ".gitignore created"
}

save_upload_report() {
    ensure_reports_dir
    local report_file="$(get_reports_dir)/uploads/upload_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
Upload Report
=============
Date: $(date)
Project: $PROJECT_NAME
Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME
Files Uploaded: $(ls -1 "$TEMP_REPO_DIR/$GITHUB_DATA_DIR"/*.json 2>/dev/null | wc -l)
Commit: $(cd "$TEMP_REPO_DIR" && git log -1 --format="%H")

Status: SUCCESS
EOF
    
    log_debug "Upload report saved: $report_file"
}

# ───────────────────────────────────────────────────────────────────────────
# Execute
# ───────────────────────────────────────────────────────────────────────────

upload_to_github

