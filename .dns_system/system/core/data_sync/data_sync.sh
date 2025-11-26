#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# DNS DATA SYNC MASTER TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Universal data synchronization tool for any project
# Part of the DNS (Development Navigation System)
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
TOOLS_DIR="$SCRIPT_DIR/tools"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Load core libraries
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/logger.sh"

# ───────────────────────────────────────────────────────────────────────────
# Configuration Loading
# ───────────────────────────────────────────────────────────────────────────

load_project_config() {
    local config_file="$1"
    
    # If no config file specified, try default locations
    if [ -z "$config_file" ] || [ "$config_file" = ".data_sync_config.sh" ]; then
        # Get the DNS system directory (go up from core/data_sync to .dns_system level)
        local dns_system_dir="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
        
        # Priority order:
        # 1. .dns_system/config/data_sync.conf (preferred - keeps root clean)
        # 2. .data_sync_config.sh (backwards compatibility)
        if [ -f "$dns_system_dir/config/data_sync.conf" ]; then
            config_file="$dns_system_dir/config/data_sync.conf"
        elif [ -f ".data_sync_config.sh" ]; then
            config_file=".data_sync_config.sh"
        else
            config_file="$dns_system_dir/config/data_sync.conf"
        fi
    fi
    
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        echo ""
        echo "To set up data sync for your project:"
        echo "  1. Run: bash .cursorrules data-sync init"
        echo "  2. Edit .dns_system/config/data_sync.conf with your project details"
        echo "  3. Run this tool again"
        echo ""
        echo "Note: Config is now stored in .dns_system/config/ to keep your root folder clean"
        return 1
    fi
    
    source "$config_file"
    log_debug "Loaded configuration from: $config_file"
    
    # Load other libraries that depend on config
    source "$LIB_DIR/paths.sh"
    source "$LIB_DIR/validator.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Help System
# ───────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║               DNS Data Sync - Master Tool                         ║
╚═══════════════════════════════════════════════════════════════════╝

Universal data synchronization tool for any project.

USAGE:
    dns-data-sync [OPTIONS] COMMAND [ARGS]

OPTIONS:
    --config FILE    Path to project config file (default: .data_sync_config.sh)
    --help, -h       Show this help message
    --version        Show version information

COMMANDS:
    init             Initialize data sync for current project
    verify           Validate data files before upload
    upload           Upload data to GitHub repository
    setup            Initial GitHub repository setup
    config           Show current configuration
    status           Check sync status

EXAMPLES:
    # Initialize new project
    dns-data-sync init

    # Validate data files
    dns-data-sync verify

    # Upload to GitHub
    dns-data-sync upload

    # Upload with custom message
    dns-data-sync upload --message "Added new content"

    # Use custom config file
    dns-data-sync --config ./my_config.sh verify

CONFIGURATION:
    Projects need a .data_sync_config.sh file in their root.
    Use 'dns-data-sync init' to create one from the template.

    Required settings:
    - PROJECT_NAME            Project identifier
    - GITHUB_USERNAME         GitHub username/org
    - GITHUB_REPO_NAME        Repository name
    - SOURCE_DATA_DIR         Local data directory
    - GITHUB_DATA_DIR         GitHub directory name

INTEGRATION:
    This tool is part of the DNS (Development Navigation System).
    It works with any project that has structured data files.

    Common use cases:
    - Mobile app learning data
    - Configuration files
    - Content management
    - Asset synchronization

DOCUMENTATION:
    For more information, see: .dns_system/system/core/data_sync/README.md

EOF
}

show_version() {
    echo "DNS Data Sync v1.0.0"
    echo "Part of Development Navigation System"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Initialize
# ───────────────────────────────────────────────────────────────────────────

cmd_init() {
    print_box "Initialize Data Sync"
    echo ""
    
    # Get the DNS system directory (go up from core/data_sync to .dns_system level)
    local dns_system_dir="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
    local config_file="$dns_system_dir/config/data_sync.conf"
    
    if [ -f "$config_file" ]; then
        log_warning "Configuration file already exists: $config_file"
        read -p "Overwrite? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Cancelled"
            return 1
        fi
    fi
    
    log_info "Creating configuration file..."
    cp "$TEMPLATES_DIR/project_config.template" "$config_file"
    log_success "Created: $config_file"
    
    echo ""
    color_highlight "Next steps:"
    echo "  1. Edit .dns_system/config/data_sync.conf with your project details"
    echo "  2. Run: bash .cursorrules data-sync verify"
    echo "  3. Run: bash .cursorrules data-sync setup (first time only)"
    echo "  4. Run: bash .cursorrules data-sync upload"
    echo ""
    echo "📍 Config location: .dns_system/config/data_sync.conf (keeps root clean)"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Verify
# ───────────────────────────────────────────────────────────────────────────

cmd_verify() {
    bash "$TOOLS_DIR/verify.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Upload
# ───────────────────────────────────────────────────────────────────────────

cmd_upload() {
    # Parse upload arguments
    local commit_message=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message|-m)
                commit_message="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Set commit message if provided
    if [ -n "$commit_message" ]; then
        export DEFAULT_COMMIT_MESSAGE="$commit_message"
    fi
    
    bash "$TOOLS_DIR/upload.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Setup
# ───────────────────────────────────────────────────────────────────────────

cmd_setup() {
    bash "$TOOLS_DIR/setup.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Config
# ───────────────────────────────────────────────────────────────────────────

cmd_config() {
    print_box "Current Configuration"
    echo ""
    
    echo "Project Information:"
    print_arrow "Name: $PROJECT_NAME"
    print_arrow "Description: $PROJECT_DESCRIPTION"
    echo ""
    
    echo "GitHub Configuration:"
    print_arrow "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    print_arrow "Branch: $GITHUB_BRANCH"
    print_arrow "URL: $GITHUB_REPO_URL"
    echo ""
    
    echo "Data Directories:"
    print_arrow "Source: $SOURCE_DATA_PATH"
    print_arrow "GitHub Target: $GITHUB_DATA_DIR"
    print_arrow "Manifest: $MANIFEST_FILE"
    echo ""
    
    echo "File Patterns:"
    if [ -n "${DATA_FILE_PATTERNS+x}" ] && [ ${#DATA_FILE_PATTERNS[@]} -gt 0 ]; then
        print_arrow "Include: ${DATA_FILE_PATTERNS[*]}"
    else
        print_arrow "Include: *.json (default)"
    fi
    if [ -n "${EXCLUDE_PATTERNS+x}" ] && [ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]; then
        print_arrow "Exclude: ${EXCLUDE_PATTERNS[*]}"
    fi
    echo ""
    
    echo "URLs:"
    print_arrow "Raw Base: $RAW_BASE_URL"
}

# ───────────────────────────────────────────────────────────────────────────
# Command: Status
# ───────────────────────────────────────────────────────────────────────────

cmd_status() {
    print_box "Data Sync Status"
    echo ""
    
    # Check if source directory exists
    if [ -d "$SOURCE_DATA_PATH" ]; then
        print_check "Source directory exists: $SOURCE_DATA_PATH"
        local file_count=$(find "$SOURCE_DATA_PATH" -name "*.json" -type f | wc -l)
        print_arrow "Data files found: $file_count"
    else
        print_cross "Source directory not found: $SOURCE_DATA_PATH"
    fi
    
    echo ""
    
    # Check if temp repo exists
    if [ -d "$TEMP_REPO_DIR" ]; then
        print_arrow "Temporary repository exists"
        if [ -d "$TEMP_REPO_DIR/.git" ]; then
            cd "$TEMP_REPO_DIR"
            local branch=$(git branch --show-current)
            local commit=$(git log -1 --format="%h - %s")
            print_arrow "Current branch: $branch"
            print_arrow "Last commit: $commit"
        fi
    else
        print_arrow "No temporary repository (will clone on upload)"
    fi
    
    echo ""
    
    # Check git configuration
    if command -v git &> /dev/null; then
        print_check "Git is installed"
        local git_user=$(git config user.name 2>/dev/null || echo "Not set")
        local git_email=$(git config user.email 2>/dev/null || echo "Not set")
        print_arrow "Git user: $git_user <$git_email>"
    else
        print_cross "Git not found"
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Main Entry Point
# ───────────────────────────────────────────────────────────────────────────

main() {
    local config_file=""  # Will auto-detect
    local command=""
    
    # Parse global options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --config)
                config_file="$2"
                shift 2
                ;;
            init)
                # Init doesn't need config
                cmd_init "${@:2}"
                exit $?
                ;;
            verify|upload|setup|config|status)
                command="$1"
                shift
                break
                ;;
            *)
                log_error "Unknown option or command: $1"
                echo ""
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # If no command, show help
    if [ -z "$command" ]; then
        show_help
        exit 1
    fi
    
    # Load project configuration (auto-detects location)
    if ! load_project_config "$config_file"; then
        exit 1
    fi
    
    # Execute command
    case $command in
        verify)
            cmd_verify "$@"
            ;;
        upload)
            cmd_upload "$@"
            ;;
        setup)
            cmd_setup "$@"
            ;;
        config)
            cmd_config "$@"
            ;;
        status)
            cmd_status "$@"
            ;;
        *)
            log_error "Unknown command: $command"
            exit 1
            ;;
    esac
}

# Run main
main "$@"

