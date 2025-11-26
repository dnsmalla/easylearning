#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# DATA TOOLKIT GENERATOR - PROFESSIONAL EDITION
# ═══════════════════════════════════════════════════════════════════════════
# Generates a complete, production-ready auto_app_data generation interface
# Full-featured toolkit for any app's data management and GitHub sync
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DNS_SYSTEM_DIR="$(cd "$SYSTEM_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$DNS_SYSTEM_DIR/.." && pwd)"

# Fallback colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Try to load utilities
source "$SYSTEM_DIR/core/data_sync/lib/colors.sh" 2>/dev/null || true

# ───────────────────────────────────────────────────────────────────────────
# Help
# ───────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║      DNS Data Toolkit Generator - Professional Edition            ║
╚═══════════════════════════════════════════════════════════════════╝

Generate a complete, production-ready data management system for any app.

USAGE:
    data-toolkit generate [OPTIONS]
    data-toolkit info
    data-toolkit upgrade

COMMANDS:
    generate        Generate complete toolkit structure
    info            Show what will be generated
    upgrade         Upgrade existing toolkit (with --force)

OPTIONS:
    --name NAME         Project/App name (default: folder name)
    --github USER       GitHub username
    --repo NAME         GitHub repository name
    --source FOLDER     Source data folder name
    --resources FOLDER  App resources folder
    --output DIR        Output directory
    --description TEXT  Project description
    --force             Overwrite existing files

WHAT IT GENERATES:
    auto_app_data generation/
    ├── automate.sh                  Main automation script
    ├── toolkit                      Professional multi-project toolkit
    ├── README.md                    Complete documentation
    ├── config/
    │   └── project_config.sh        Full project configuration
    ├── core/
    │   ├── lib/
    │   │   ├── colors.sh            Terminal colors + styles
    │   │   ├── logger.sh            Log levels + file logging
    │   │   ├── paths.sh             Path resolution + validation
    │   │   └── validator.sh         Full data validation
    │   └── tools/
    │       ├── setup.sh             Interactive GitHub setup
    │       └── upload.sh            Full upload with reports
    ├── github_tools/
    │   ├── setup_github_repo.sh     Repository setup
    │   └── upload_to_github.sh      Upload script
    ├── projects/
    │   └── {project}/
    │       └── config.sh            Project-specific config
    ├── tests/
    │   ├── test_github_urls.sh      URL testing
    │   └── verify_data_integrity.sh Data integrity tests
    └── docs/
        └── MIGRATION_GUIDE.md       Migration documentation

FEATURES:
    ✓ Full validation (JSON, file size, manifest, structure)
    ✓ Interactive workflows with prompts
    ✓ Log levels (DEBUG, INFO, WARNING, ERROR)
    ✓ File logging support
    ✓ Upload/verification reports
    ✓ Multi-project support
    ✓ GitHub CLI integration
    ✓ Comprehensive configuration options

EXAMPLES:
    # Generate for a new app
    bash .cursorrules data-toolkit generate --name "MyApp" --github myuser --repo mydata

    # Generate with custom folders
    bash .cursorrules data-toolkit generate --source "app_data" --resources "MyApp/Resources"

    # Upgrade existing toolkit
    bash .cursorrules data-toolkit upgrade --force

EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Utilities
# ───────────────────────────────────────────────────────────────────────────

print_box() {
    local title="$1"
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}║${NC}  %-58s  ${CYAN}║${NC}\n" "$title"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_check() {
    echo -e "  ${GREEN}✓${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# ═══════════════════════════════════════════════════════════════════════════
# GENERATOR FUNCTIONS - FULL FEATURED
# ═══════════════════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────────────────
# Generate colors.sh - Full featured with styles
# ───────────────────────────────────────────────────────────────────────────
generate_colors_lib() {
    local output_dir="$1"
    
    cat > "$output_dir/core/lib/colors.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# COLORS LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides color definitions and formatting functions for terminal output
# ═══════════════════════════════════════════════════════════════════════════

# Color definitions
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_CYAN='\033[0;36m'
export COLOR_MAGENTA='\033[0;35m'
export COLOR_WHITE='\033[1;37m'
export COLOR_GRAY='\033[0;90m'
export COLOR_NC='\033[0m'  # No Color

# Style definitions
export STYLE_BOLD='\033[1m'
export STYLE_DIM='\033[2m'
export STYLE_UNDERLINE='\033[4m'
export STYLE_RESET='\033[0m'

# ───────────────────────────────────────────────────────────────────────────
# Formatted output functions
# ───────────────────────────────────────────────────────────────────────────

color_print() {
    local color="$1"
    shift
    echo -e "${color}$@${COLOR_NC}"
}

color_error() {
    color_print "$COLOR_RED" "$@"
}

color_success() {
    color_print "$COLOR_GREEN" "$@"
}

color_warning() {
    color_print "$COLOR_YELLOW" "$@"
}

color_info() {
    color_print "$COLOR_BLUE" "$@"
}

color_highlight() {
    color_print "$COLOR_CYAN" "$@"
}

color_dim() {
    color_print "$COLOR_GRAY" "$@"
}

# ───────────────────────────────────────────────────────────────────────────
# Box drawing functions
# ───────────────────────────────────────────────────────────────────────────

print_box() {
    local title="$1"
    local width=64
    
    echo -e "${COLOR_CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${COLOR_NC}"
    printf "${COLOR_CYAN}║${COLOR_NC} %-$((width-4))s ${COLOR_CYAN}║${COLOR_NC}\n" "$title"
    echo -e "${COLOR_CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${COLOR_NC}"
}

print_separator() {
    local width="${1:-64}"
    echo -e "${COLOR_CYAN}$(printf '═%.0s' $(seq 1 $width))${COLOR_NC}"
}

print_section() {
    local title="$1"
    echo ""
    print_separator
    color_highlight "  $title"
    print_separator
    echo ""
}

print_subsection() {
    local title="$1"
    echo ""
    echo -e "${COLOR_BLUE}── $title ──${COLOR_NC}"
    echo ""
}

# ───────────────────────────────────────────────────────────────────────────
# Status indicators
# ───────────────────────────────────────────────────────────────────────────

print_check() {
    echo -e "${COLOR_GREEN}✓${COLOR_NC} $@"
}

print_cross() {
    echo -e "${COLOR_RED}✗${COLOR_NC} $@"
}

print_arrow() {
    echo -e "${COLOR_BLUE}→${COLOR_NC} $@"
}

print_bullet() {
    echo -e "${COLOR_CYAN}•${COLOR_NC} $@"
}

print_warning_icon() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_NC} $@"
}

print_info_icon() {
    echo -e "${COLOR_BLUE}ℹ${COLOR_NC} $@"
}

# ───────────────────────────────────────────────────────────────────────────
# Progress indicators
# ───────────────────────────────────────────────────────────────────────────

print_progress() {
    local current="$1"
    local total="$2"
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${COLOR_CYAN}[${COLOR_NC}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${COLOR_CYAN}]${COLOR_NC} %3d%%" "$percentage"
}

# Export functions
export -f color_print color_error color_success color_warning color_info color_highlight color_dim
export -f print_box print_separator print_section print_subsection
export -f print_check print_cross print_arrow print_bullet print_warning_icon print_info_icon
export -f print_progress
EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate logger.sh - Full featured with log levels
# ───────────────────────────────────────────────────────────────────────────
generate_logger_lib() {
    local output_dir="$1"
    
    cat > "$output_dir/core/lib/logger.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# LOGGER LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides logging functionality with different log levels and file support
# ═══════════════════════════════════════════════════════════════════════════

# Source colors library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

# Log levels
export LOG_LEVEL_DEBUG=0
export LOG_LEVEL_INFO=1
export LOG_LEVEL_WARNING=2
export LOG_LEVEL_ERROR=3
export LOG_LEVEL_SUCCESS=4

# Default log level (can be overridden)
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Log file (optional - set to enable file logging)
LOG_FILE="${LOG_FILE:-}"

# Log directory
LOG_DIR="${LOG_DIR:-}"

# ───────────────────────────────────────────────────────────────────────────
# Initialize logging
# ───────────────────────────────────────────────────────────────────────────

init_logging() {
    local toolkit_root="${1:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
    
    if [ -z "$LOG_DIR" ]; then
        LOG_DIR="$toolkit_root/logs"
    fi
    
    mkdir -p "$LOG_DIR"
    
    if [ -z "$LOG_FILE" ]; then
        LOG_FILE="$LOG_DIR/toolkit_$(date +%Y%m%d).log"
    fi
    
    # Create log file with header
    if [ ! -f "$LOG_FILE" ]; then
        echo "# Toolkit Log - $(date)" > "$LOG_FILE"
        echo "# ═══════════════════════════════════════════════════════════" >> "$LOG_FILE"
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Core logging functions
# ───────────────────────────────────────────────────────────────────────────

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Write to log file if specified
    if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
    
    # Print to terminal
    echo "$message"
}

log_debug() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]; then
        log_message "DEBUG" "$(color_dim "[DEBUG] $@")"
    fi
}

log_info() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_INFO ]; then
        log_message "INFO" "$(color_info "$@")"
    fi
}

log_warning() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_WARNING ]; then
        log_message "WARNING" "$(color_warning "⚠️  $@")"
    fi
}

log_error() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_ERROR ]; then
        log_message "ERROR" "$(color_error "❌ $@")" >&2
    fi
}

log_success() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_SUCCESS ]; then
        log_message "SUCCESS" "$(color_success "✅ $@")"
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Progress indicators
# ───────────────────────────────────────────────────────────────────────────

log_step() {
    local step_num="$1"
    local total_steps="$2"
    local message="$3"
    
    color_info "[$step_num/$total_steps] $message"
}

log_task() {
    local task="$1"
    echo -n "$task... "
}

log_task_done() {
    color_success "Done"
}

log_task_failed() {
    color_error "Failed"
}

log_task_skipped() {
    color_warning "Skipped"
}

# ───────────────────────────────────────────────────────────────────────────
# Summary functions
# ───────────────────────────────────────────────────────────────────────────

log_summary() {
    local passed="$1"
    local failed="$2"
    local total=$((passed + failed))
    
    echo ""
    print_section "Summary"
    echo "  Total: $total"
    color_success "  Passed: $passed"
    if [ $failed -gt 0 ]; then
        color_error "  Failed: $failed"
    else
        echo -e "  ${COLOR_GRAY}Failed: 0${COLOR_NC}"
    fi
    echo ""
}

log_duration() {
    local start_time="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $duration -lt 60 ]; then
        echo "${duration}s"
    else
        local mins=$((duration / 60))
        local secs=$((duration % 60))
        echo "${mins}m ${secs}s"
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Log file management
# ───────────────────────────────────────────────────────────────────────────

show_log() {
    local lines="${1:-50}"
    
    if [ -f "$LOG_FILE" ]; then
        echo "Last $lines lines of: $LOG_FILE"
        print_separator
        tail -n "$lines" "$LOG_FILE"
    else
        log_warning "No log file found"
    fi
}

clear_log() {
    if [ -f "$LOG_FILE" ]; then
        echo "# Toolkit Log - Cleared $(date)" > "$LOG_FILE"
        log_info "Log file cleared"
    fi
}

# Export functions
export -f init_logging log_message log_debug log_info log_warning log_error log_success
export -f log_step log_task log_task_done log_task_failed log_task_skipped
export -f log_summary log_duration show_log clear_log
EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate paths.sh - Full featured with validation
# ───────────────────────────────────────────────────────────────────────────
generate_paths_lib() {
    local output_dir="$1"
    
    cat > "$output_dir/core/lib/paths.sh" << 'EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# PATH RESOLVER LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Resolves project paths dynamically based on configuration
# ═══════════════════════════════════════════════════════════════════════════

# Source logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

# ───────────────────────────────────────────────────────────────────────────
# Core path resolution
# ───────────────────────────────────────────────────────────────────────────

# Get toolkit root (parent of core/)
get_toolkit_root() {
    echo "$(cd "$SCRIPT_DIR/../.." && pwd)"
}

# Get project root (parent of toolkit)
get_project_root() {
    echo "$(cd "$(get_toolkit_root)/.." && pwd)"
}

# Load project configuration
load_project_config() {
    local project_name="${1:-}"
    local toolkit_root=$(get_toolkit_root)
    
    if [ -z "$project_name" ]; then
        log_error "Project name not specified"
        return 1
    fi
    
    local config_file="$toolkit_root/projects/$project_name/config.sh"
    
    if [ ! -f "$config_file" ]; then
        log_error "Project config not found: $config_file"
        echo ""
        echo "Available projects:"
        list_projects
        return 1
    fi
    
    source "$config_file"
    
    # Set derived paths
    export PROJECT_ROOT=$(get_project_root)
    export SOURCE_DATA_PATH="$PROJECT_ROOT/$SOURCE_DATA_DIR"
    export APP_RESOURCES_PATH="$PROJECT_ROOT/$APP_RESOURCES_DIR"
    export TEMP_REPO_DIR="$PROJECT_ROOT/${TEMP_DIR_PREFIX}_repo"
    export TOOLKIT_ROOT="$toolkit_root"
    
    # Initialize logging for this project
    init_logging "$toolkit_root"
    
    log_debug "Loaded config for project: $project_name"
    log_debug "Project root: $PROJECT_ROOT"
    log_debug "Source data: $SOURCE_DATA_PATH"
    
    return 0
}

# List available projects
list_projects() {
    local toolkit_root=$(get_toolkit_root)
    local projects_dir="$toolkit_root/projects"
    
    if [ ! -d "$projects_dir" ]; then
        log_warning "No projects directory found"
        return 1
    fi
    
    for project_dir in "$projects_dir"/*; do
        if [ -d "$project_dir" ] && [ -f "$project_dir/config.sh" ]; then
            local name=$(basename "$project_dir")
            # Load and show description
            (
                source "$project_dir/config.sh" 2>/dev/null
                printf "  ${COLOR_CYAN}%-15s${COLOR_NC} %s\n" "$name" "${PROJECT_DESCRIPTION:-No description}"
            )
        fi
    done
}

# ───────────────────────────────────────────────────────────────────────────
# Path validation
# ───────────────────────────────────────────────────────────────────────────

validate_paths() {
    local errors=0
    
    print_subsection "Validating Paths"
    
    # Check source data path
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        print_cross "Source data path not found: $SOURCE_DATA_PATH"
        errors=$((errors + 1))
    else
        print_check "Source data path exists: $SOURCE_DATA_PATH"
    fi
    
    # Check if there are data files
    local file_count=0
    local patterns=("*.json")
    if [ -n "${DATA_FILE_PATTERNS+x}" ] && [ ${#DATA_FILE_PATTERNS[@]} -gt 0 ]; then
        patterns=("${DATA_FILE_PATTERNS[@]}")
    fi
    
    for pattern in "${patterns[@]}"; do
        local count=$(find "$SOURCE_DATA_PATH" -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' ')
        file_count=$((file_count + count))
    done
    
    if [ $file_count -eq 0 ]; then
        print_cross "No data files found in: $SOURCE_DATA_PATH"
        errors=$((errors + 1))
    else
        print_check "Found $file_count data files"
    fi
    
    # Check app resources path (optional)
    if [ -n "$APP_RESOURCES_PATH" ]; then
        if [ ! -d "$APP_RESOURCES_PATH" ]; then
            print_warning_icon "App resources path not found: $APP_RESOURCES_PATH"
            echo "    (This is OK if you haven't created it yet)"
        else
            print_check "App resources path exists"
        fi
    fi
    
    return $errors
}

# ───────────────────────────────────────────────────────────────────────────
# Helper functions
# ───────────────────────────────────────────────────────────────────────────

get_reports_dir() {
    echo "$(get_toolkit_root)/reports"
}

get_logs_dir() {
    echo "$(get_toolkit_root)/logs"
}

get_core_dir() {
    echo "$(get_toolkit_root)/core"
}

get_projects_dir() {
    echo "$(get_toolkit_root)/projects"
}

# Create reports directory structure
ensure_reports_dir() {
    local reports_dir=$(get_reports_dir)
    mkdir -p "$reports_dir/verification"
    mkdir -p "$reports_dir/uploads"
    mkdir -p "$reports_dir/tests"
}

# Create logs directory
ensure_logs_dir() {
    local logs_dir=$(get_logs_dir)
    mkdir -p "$logs_dir"
}

# Get timestamp for filenames
get_timestamp() {
    date +%Y%m%d_%H%M%S
}

# Export functions
export -f get_toolkit_root get_project_root load_project_config list_projects validate_paths
export -f get_reports_dir get_logs_dir get_core_dir get_projects_dir
export -f ensure_reports_dir ensure_logs_dir get_timestamp
EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate validator.sh - Full featured validation
# ───────────────────────────────────────────────────────────────────────────
generate_validator_lib() {
    local output_dir="$1"
    
    cat > "$output_dir/core/lib/validator.sh" << 'VALIDATOR_EOF'
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# VALIDATOR LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides comprehensive data validation functions
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logger.sh"

# ───────────────────────────────────────────────────────────────────────────
# JSON validation
# ───────────────────────────────────────────────────────────────────────────

validate_json_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi
    
    if ! python3 -m json.tool "$file" >/dev/null 2>&1; then
        log_error "Invalid JSON: $file"
        return 1
    fi
    
    return 0
}

validate_json_structure() {
    local file="$1"
    shift
    local required_fields=("$@")
    
    if ! validate_json_file "$file"; then
        return 1
    fi
    
    for field in "${required_fields[@]}"; do
        if ! python3 -c "import json; data=json.load(open('$file')); exit(0 if '$field' in data else 1)" 2>/dev/null; then
            log_error "Missing required field '$field' in $file"
            return 1
        fi
    done
    
    return 0
}

get_json_field() {
    local file="$1"
    local field="$2"
    
    python3 -c "import json; data=json.load(open('$file')); print(data.get('$field', ''))" 2>/dev/null
}

# ───────────────────────────────────────────────────────────────────────────
# File validation
# ───────────────────────────────────────────────────────────────────────────

validate_file_size() {
    local file="$1"
    local min_size="${MIN_FILE_SIZE:-100}"
    local max_size="${MAX_FILE_SIZE:-10485760}"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Get file size (works on both macOS and Linux)
    local size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$file" 2>/dev/null)
    else
        size=$(stat -c%s "$file" 2>/dev/null)
    fi
    
    if [ -z "$size" ]; then
        log_warning "Could not determine file size: $file"
        return 0
    fi
    
    if [ "$size" -lt "$min_size" ]; then
        log_warning "File suspiciously small: $file ($size bytes < $min_size)"
        return 1
    fi
    
    if [ "$size" -gt "$max_size" ]; then
        log_warning "File very large: $file ($size bytes > $max_size)"
        # Don't fail, just warn
    fi
    
    return 0
}

get_file_size_human() {
    local file="$1"
    local size
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$file" 2>/dev/null)
    else
        size=$(stat -c%s "$file" 2>/dev/null)
    fi
    
    if [ -z "$size" ]; then
        echo "unknown"
        return
    fi
    
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    else
        echo "$((size / 1048576))MB"
    fi
}

should_exclude_file() {
    local filename="$1"
    
    # Check if EXCLUDE_PATTERNS is set and has elements
    if [ -n "${EXCLUDE_PATTERNS+x}" ] && [ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]; then
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "$filename" == $pattern ]]; then
                return 0  # Should exclude
            fi
        done
    fi
    
    return 1  # Should not exclude
}

# ───────────────────────────────────────────────────────────────────────────
# Manifest validation
# ───────────────────────────────────────────────────────────────────────────

validate_manifest() {
    local manifest_file="$1"
    
    if [ ! -f "$manifest_file" ]; then
        log_error "Manifest file not found: $manifest_file"
        return 1
    fi
    
    if ! validate_json_file "$manifest_file"; then
        return 1
    fi
    
    # Check required fields
    local errors=0
    
    # Use default if not set
    local required_fields=("version")
    if [ -n "${REQUIRED_MANIFEST_FIELDS+x}" ] && [ ${#REQUIRED_MANIFEST_FIELDS[@]} -gt 0 ]; then
        required_fields=("${REQUIRED_MANIFEST_FIELDS[@]}")
    fi
    
    for field in "${required_fields[@]}"; do
        if ! python3 -c "import json; data=json.load(open('$manifest_file')); exit(0 if '$field' in data else 1)" 2>/dev/null; then
            log_error "Missing required manifest field: $field"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -gt 0 ]; then
        return 1
    fi
    
    # Extract and display version
    local version=$(get_json_field "$manifest_file" "version")
    log_info "Manifest version: $version"
    
    return 0
}

# ───────────────────────────────────────────────────────────────────────────
# Comprehensive validation
# ───────────────────────────────────────────────────────────────────────────

validate_all_data() {
    local data_path="$SOURCE_DATA_PATH"
    local total=0
    local valid=0
    local invalid=0
    local warnings=0
    
    print_section "Validating Data Files"
    
    # Validate manifest first
    local manifest_name="${MANIFEST_FILE:-manifest.json}"
    local manifest_path="$data_path/$manifest_name"
    
    if [ -f "$manifest_path" ]; then
        log_task "Validating manifest"
        if validate_manifest "$manifest_path"; then
            log_task_done
        else
            log_task_failed
            return 1
        fi
    else
        log_warning "No manifest file found (optional)"
    fi
    
    echo ""
    print_subsection "Validating Data Files"
    
    # Validate all data files
    local patterns=("*.json")
    if [ -n "${DATA_FILE_PATTERNS+x}" ] && [ ${#DATA_FILE_PATTERNS[@]} -gt 0 ]; then
        patterns=("${DATA_FILE_PATTERNS[@]}")
    fi
    
    for pattern in "${patterns[@]}"; do
        for file in "$data_path"/$pattern; do
            if [ ! -f "$file" ]; then
                continue
            fi
            
            local filename=$(basename "$file")
            
            # Skip excluded files
            if should_exclude_file "$filename"; then
                log_debug "Skipping excluded file: $filename"
                continue
            fi
            
            total=$((total + 1))
            local file_size=$(get_file_size_human "$file")
            
            log_task "Checking $filename ($file_size)"
            
            local file_valid=true
            
            # JSON validation
            if ! validate_json_file "$file"; then
                file_valid=false
            fi
            
            # Size validation
            if ! validate_file_size "$file"; then
                warnings=$((warnings + 1))
            fi
            
            if [ "$file_valid" = true ]; then
                log_task_done
                valid=$((valid + 1))
            else
                log_task_failed
                invalid=$((invalid + 1))
            fi
        done
    done
    
    # Summary
    echo ""
    log_summary $valid $invalid
    
    if [ $warnings -gt 0 ]; then
        log_warning "$warnings file(s) had warnings"
    fi
    
    # Save validation report
    save_validation_report $valid $invalid $warnings
    
    if [ $invalid -eq 0 ]; then
        log_success "All data files are valid!"
        return 0
    else
        log_error "Some data files are invalid"
        return 1
    fi
}

save_validation_report() {
    local valid="$1"
    local invalid="$2"
    local warnings="$3"
    
    ensure_reports_dir
    local report_file="$(get_reports_dir)/verification/validation_$(get_timestamp).txt"
    
    cat > "$report_file" << REPORT_EOF
Validation Report
=================
Date: $(date)
Project: ${PROJECT_NAME:-Unknown}
Data Path: $SOURCE_DATA_PATH

Results:
  Valid:    $valid
  Invalid:  $invalid
  Warnings: $warnings

Status: $([ $invalid -eq 0 ] && echo "PASSED" || echo "FAILED")
REPORT_EOF
    
    log_debug "Validation report saved: \$report_file"
}

# Export functions
export -f validate_json_file validate_json_structure get_json_field
export -f validate_file_size get_file_size_human should_exclude_file
export -f validate_manifest validate_all_data save_validation_report
VALIDATOR_EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate setup.sh - Full featured with GitHub CLI
# ───────────────────────────────────────────────────────────────────────────
generate_setup_tool() {
    local output_dir="$1"
    
    cat > "$output_dir/core/tools/setup.sh" << 'SETUP_EOF'
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# GITHUB SETUP TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Initial setup for GitHub data hosting (first time only)
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
    echo "  Project: $PROJECT_NAME"
    echo "  Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    echo "  Branch: ${GITHUB_BRANCH:-main}"
    echo "  Data Folder: $SOURCE_DATA_DIR → $GITHUB_DATA_DIR"
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
        log_warning "Setup directory already exists: $setup_dir"
        echo ""
        echo "  1) Delete and recreate (recommended)"
        echo "  2) Use existing directory"
        echo "  3) Cancel"
        echo ""
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                rm -rf "$setup_dir"
                ;;
            2)
                log_info "Using existing directory"
                ;;
            3|*)
                log_warning "Cancelled"
                return 1
                ;;
        esac
    fi
    
    mkdir -p "$setup_dir"
    cd "$setup_dir"
    
    git init
    print_check "Git repository initialized"
    
    # Create data folder and copy files
    mkdir -p "$GITHUB_DATA_DIR"
    
    echo ""
    print_section "Copying Data Files"
    
    local file_count=0
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
            print_check "$filename ($(get_file_size_human "$file"))"
            file_count=$((file_count + 1))
        done
    done
    
    if [ $file_count -eq 0 ]; then
        log_error "No files copied!"
        return 1
    fi
    
    log_success "Copied $file_count files"
    
    # Create README and .gitignore
    echo ""
    create_readme
    create_gitignore
    
    # Instructions
    echo ""
    print_section "Next Steps"
    echo ""
    color_highlight "Option 1: Use GitHub CLI (Recommended)"
    echo "  gh repo create $GITHUB_REPO_NAME --public --source=. --push"
    echo ""
    color_highlight "Option 2: Manual Setup"
    echo "  1. Create repository at: https://github.com/new"
    echo "     Name: $GITHUB_REPO_NAME"
    echo "     Make it PUBLIC"
    echo "     Do NOT initialize with README"
    echo ""
    echo "  2. Push to GitHub:"
    echo "     cd $setup_dir"
    echo "     git remote add origin $GITHUB_REPO_URL"
    echo "     git add ."
    echo "     git commit -m \"Initial: $PROJECT_NAME data\""
    echo "     git branch -M ${GITHUB_BRANCH:-main}"
    echo "     git push -u origin ${GITHUB_BRANCH:-main}"
    echo ""
    
    # Ask about GitHub CLI
    if command -v gh &> /dev/null; then
        echo ""
        read -p "Create repository with GitHub CLI now? (y/n): " create_now
        
        if [ "$create_now" = "y" ] || [ "$create_now" = "yes" ]; then
            log_info "Creating repository with GitHub CLI..."
            
            local visibility="${REPO_VISIBILITY:-public}"
            local description="${REPO_DESCRIPTION:-Data repository for $PROJECT_NAME}"
            
            if gh repo create "$GITHUB_REPO_NAME" --"$visibility" --description "$description" --source=. --push; then
                echo ""
                log_success "Repository created and pushed!"
                echo ""
                color_highlight "View at: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME"
                color_highlight "Raw URL: $RAW_BASE_URL/"
            else
                log_error "Failed to create repository"
            fi
        fi
    else
        log_info "GitHub CLI (gh) not installed - manual setup required"
        echo "  Install with: brew install gh"
    fi
    
    echo ""
    log_success "Setup complete!"
    log_info "Setup directory: $setup_dir"
}

# ───────────────────────────────────────────────────────────────────────────
# Helper functions
# ───────────────────────────────────────────────────────────────────────────

create_readme() {
    log_task "Creating README.md"
    
    cat > README.md << EOF
# $GITHUB_REPO_NAME

${PROJECT_DESCRIPTION:-Data repository}

## Contents

This repository contains data in the \`$GITHUB_DATA_DIR/\` folder.

## Data Structure

- JSON format
- Versioned with manifest.json

## URLs

Data is accessible via:
\`\`\`
$RAW_BASE_URL/
\`\`\`

## License

${LICENSE_TYPE:-MIT}

---
*Managed by Auto App Data Toolkit*
EOF
    
    log_task_done
}

create_gitignore() {
    log_task "Creating .gitignore"
    
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

# Within data folder, ignore backups
$GITHUB_DATA_DIR/*.backup
$GITHUB_DATA_DIR/*.backup_*
$GITHUB_DATA_DIR/*.bak
EOF
    
    log_task_done
}

# Execute
setup_github_repo
SETUP_EOF

    chmod +x "$output_dir/core/tools/setup.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate upload.sh - Full featured with reports
# ───────────────────────────────────────────────────────────────────────────
generate_upload_tool() {
    local output_dir="$1"
    
    cat > "$output_dir/core/tools/upload.sh" << 'UPLOAD_EOF'
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# GITHUB UPLOAD TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Uploads ONLY the data folder to GitHub (no app source code)
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
    local start_time=$(date +%s)
    
    print_box "Upload Data to GitHub"
    echo ""
    
    log_info "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
    log_info "Data: $SOURCE_DATA_DIR → $GITHUB_DATA_DIR"
    echo ""
    
    # Verify source directory exists
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        log_error "Source directory not found: $SOURCE_DATA_PATH"
        return 1
    fi
    
    # Handle existing temp repo
    if [ -d "$TEMP_REPO_DIR" ]; then
        log_warning "Temporary repository exists: $TEMP_REPO_DIR"
        echo ""
        echo "  1) Update existing (recommended)"
        echo "  2) Delete and clone fresh"
        echo "  3) Cancel"
        echo ""
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                log_info "Using existing repository"
                cd "$TEMP_REPO_DIR"
                git pull origin ${GITHUB_BRANCH:-main} 2>/dev/null || log_warning "Pull failed, continuing"
                ;;
            2)
                log_info "Removing old repository..."
                rm -rf "$TEMP_REPO_DIR"
                clone_repository
                ;;
            3|*)
                log_warning "Cancelled"
                return 1
                ;;
        esac
    else
        clone_repository
    fi
    
    # Ensure data folder exists
    mkdir -p "$GITHUB_DATA_DIR"
    
    # Copy data files
    echo ""
    print_section "Copying Data Files"
    
    local file_count=0
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
                log_debug "Skipping: $filename"
                continue
            fi
            
            cp "$file" "$GITHUB_DATA_DIR/"
            print_check "$filename ($(get_file_size_human "$file"))"
            file_count=$((file_count + 1))
        done
    done
    
    if [ $file_count -eq 0 ]; then
        log_error "No files copied!"
        return 1
    fi
    
    log_success "Copied $file_count files"
    
    # Update README if not exists
    if [ ! -f "README.md" ]; then
        create_readme
    fi
    
    # Update .gitignore if not exists
    if [ ! -f ".gitignore" ]; then
        create_gitignore
    fi
    
    # Git operations
    echo ""
    print_section "Git Operations"
    
    git add "$GITHUB_DATA_DIR"/*.json README.md .gitignore 2>/dev/null || true
    
    echo ""
    echo "Changes:"
    git status --short
    echo ""
    
    # Commit message
    local default_msg="${DEFAULT_COMMIT_MESSAGE:-Update data files}"
    read -p "Commit message [$default_msg]: " commit_msg
    commit_msg="${commit_msg:-$default_msg}"
    
    log_info "Committing..."
    if git commit -m "$commit_msg" 2>/dev/null; then
        print_check "Changes committed"
    else
        log_info "No changes to commit"
    fi
    
    # Push
    echo ""
    log_info "Pushing to GitHub..."
    
    if git push origin ${GITHUB_BRANCH:-main}; then
        echo ""
        log_success "Upload complete!"
        echo ""
        color_highlight "Repository: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME"
        color_highlight "Raw URL: $RAW_BASE_URL/"
        
        # Save upload report
        save_upload_report $file_count "$(log_duration $start_time)"
        
        return 0
    else
        log_error "Push failed!"
        echo ""
        echo "Please check:"
        echo "  - Git credentials configured"
        echo "  - Push access to repository"
        echo "  - Network connection"
        return 1
    fi
}

clone_repository() {
    log_info "Cloning repository..."
    
    if git clone "$GITHUB_REPO_URL" "$TEMP_REPO_DIR" 2>/dev/null; then
        cd "$TEMP_REPO_DIR"
        print_check "Repository cloned"
    else
        log_warning "Clone failed, initializing new repository..."
        mkdir -p "$TEMP_REPO_DIR"
        cd "$TEMP_REPO_DIR"
        git init
        git remote add origin "$GITHUB_REPO_URL"
        print_check "Repository initialized"
    fi
}

create_readme() {
    log_task "Creating README.md"
    
    cat > README.md << EOF
# $GITHUB_REPO_NAME

${PROJECT_DESCRIPTION:-Data repository}

## Contents

Data files in \`$GITHUB_DATA_DIR/\` folder.

## URLs

\`\`\`
$RAW_BASE_URL/
\`\`\`

## License

${LICENSE_TYPE:-MIT}
EOF
    
    log_task_done
}

create_gitignore() {
    log_task "Creating .gitignore"
    
    cat > .gitignore << EOF
.DS_Store
*.backup
*.bak
*.tmp
/*
!/$GITHUB_DATA_DIR/
!/README.md
!/.gitignore
$GITHUB_DATA_DIR/*.backup*
EOF
    
    log_task_done
}

save_upload_report() {
    local files="$1"
    local duration="$2"
    
    ensure_reports_dir
    local report_file="$(get_reports_dir)/uploads/upload_$(get_timestamp).txt"
    
    cat > "$report_file" << UPLOAD_REPORT_EOF
Upload Report
=============
Date: $(date)
Project: ${PROJECT_NAME:-Unknown}
Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME
Files: $files
Duration: $duration
Commit: $(git log -1 --format="%H" 2>/dev/null || echo "N/A")

Status: SUCCESS
UPLOAD_REPORT_EOF
    
    log_debug "Report saved: $report_file"
}

# Execute
upload_to_github
UPLOAD_EOF

    chmod +x "$output_dir/core/tools/upload.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate automate.sh - Main script
# ───────────────────────────────────────────────────────────────────────────
generate_automate_sh() {
    local output_dir="$1"
    local project_name="${2:-MyApp}"
    
    cat > "$output_dir/automate.sh" << 'AUTOMATE_EOF'
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# AUTO APP DATA - Main Automation Script
# ═══════════════════════════════════════════════════════════════════════════
# Master script for all data management and GitHub operations
# ═══════════════════════════════════════════════════════════════════════════

AUTOMATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$AUTOMATE_DIR/config/project_config.sh"

show_usage() {
    cat << 'USAGE'
╔══════════════════════════════════════════════════════════════╗
║   Auto App Data Generation & GitHub Sync Toolkit             ║
╚══════════════════════════════════════════════════════════════╝

Usage: ./automate.sh <command> [options]

COMMANDS:

  Setup & Configuration:
    config              Show current configuration
    validate            Validate configuration and paths
    setup-github        Initial GitHub repository setup

  Data Operations:
    verify              Verify local data integrity
    upload              Upload data to GitHub
    full-sync           Complete workflow (verify + upload + test)

  Testing:
    test-urls           Test GitHub URLs are accessible
    test-all            Run all tests

  Utilities:
    log [lines]         Show recent log entries
    log-clear           Clear log file
    reports             List generated reports

  Information:
    help                Show this help message
    version             Show version information

EXAMPLES:

  # First time setup
  ./automate.sh setup-github

  # Regular workflow
  ./automate.sh full-sync

  # Individual steps
  ./automate.sh verify
  ./automate.sh upload

  # View logs
  ./automate.sh log 100

WORKFLOW:

  1. Edit JSON files in your data folder
  2. Update version in manifest.json (if using)
  3. Run: ./automate.sh verify
  4. Run: ./automate.sh upload
  5. Run: ./automate.sh test-urls

  Or simply: ./automate.sh full-sync

USAGE
}

show_version() {
    echo "Auto App Data Generation Toolkit"
    echo "Version: 2.0"
    echo ""
    echo "Project: ${PROJECT_NAME:-Unknown}"
    echo "Repository: ${GITHUB_USERNAME:-}/${GITHUB_REPO_NAME:-}"
}

cmd_config() {
    print_section "Project Configuration"
    echo ""
    echo "Project Information:"
    echo "  Name: ${PROJECT_NAME:-Unknown}"
    echo "  Description: ${PROJECT_DESCRIPTION:-N/A}"
    echo "  Version: ${DATA_VERSION:-N/A}"
    echo ""
    echo "GitHub:"
    echo "  Repository: ${GITHUB_USERNAME:-}/${GITHUB_REPO_NAME:-}"
    echo "  Branch: ${GITHUB_BRANCH:-main}"
    echo "  URL: ${GITHUB_REPO_URL:-N/A}"
    echo ""
    echo "Paths:"
    echo "  Project Root: ${PROJECT_ROOT:-N/A}"
    echo "  Source Data: ${SOURCE_DATA_PATH:-N/A}"
    echo "  App Resources: ${APP_RESOURCES_PATH:-N/A}"
    echo ""
    echo "URLs:"
    echo "  Raw Base: ${RAW_BASE_URL:-N/A}"
}

cmd_validate() {
    source "$AUTOMATE_DIR/core/lib/paths.sh"
    
    print_section "Validating Configuration"
    echo ""
    
    if validate_paths; then
        echo ""
        log_success "Configuration is valid"
        return 0
    else
        echo ""
        log_error "Configuration has errors"
        return 1
    fi
}

cmd_verify() {
    source "$AUTOMATE_DIR/core/lib/validator.sh"
    validate_all_data
}

cmd_setup() {
    bash "$AUTOMATE_DIR/core/tools/setup.sh"
}

cmd_upload() {
    bash "$AUTOMATE_DIR/core/tools/upload.sh"
}

cmd_test_urls() {
    bash "$AUTOMATE_DIR/tests/test_github_urls.sh"
}

cmd_full_sync() {
    print_box "Full Sync Workflow"
    echo ""
    
    local start_time=$(date +%s)
    
    # Step 1: Verify
    log_step 1 3 "Verifying data integrity..."
    if ! cmd_verify; then
        log_error "Verification failed - aborting"
        return 1
    fi
    echo ""
    
    # Step 2: Upload
    log_step 2 3 "Uploading to GitHub..."
    if ! cmd_upload; then
        log_error "Upload failed"
        return 1
    fi
    echo ""
    
    # Step 3: Test URLs
    log_step 3 3 "Testing GitHub URLs..."
    cmd_test_urls || log_warning "URL tests failed (may need a moment to propagate)"
    
    echo ""
    print_separator
    log_success "Full sync complete! ($(log_duration $start_time))"
    print_separator
}

cmd_test_all() {
    print_box "Running All Tests"
    echo ""
    
    local passed=0
    local failed=0
    
    # Test 1: Data integrity
    log_step 1 2 "Data Integrity"
    if cmd_verify; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    echo ""
    
    # Test 2: GitHub URLs
    log_step 2 2 "GitHub URLs"
    if cmd_test_urls; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    
    log_summary $passed $failed
    
    [ $failed -eq 0 ]
}

cmd_log() {
    local lines="${1:-50}"
    source "$AUTOMATE_DIR/core/lib/logger.sh"
    init_logging "$AUTOMATE_DIR"
    show_log "$lines"
}

cmd_log_clear() {
    source "$AUTOMATE_DIR/core/lib/logger.sh"
    init_logging "$AUTOMATE_DIR"
    clear_log
}

cmd_reports() {
    local reports_dir="$AUTOMATE_DIR/reports"
    
    if [ ! -d "$reports_dir" ]; then
        log_info "No reports directory yet"
        return 0
    fi
    
    print_section "Generated Reports"
    echo ""
    
    for category in verification uploads tests; do
        if [ -d "$reports_dir/$category" ]; then
            local count=$(ls -1 "$reports_dir/$category" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo "$category: $count report(s)"
                ls -1t "$reports_dir/$category" | head -3 | sed 's/^/  /'
                echo ""
            fi
        fi
    done
}

# Main command handler
COMMAND="${1:-help}"

case "$COMMAND" in
    config)
        cmd_config
        ;;
    validate)
        cmd_validate
        ;;
    setup-github|setup)
        cmd_setup
        ;;
    verify|check)
        cmd_verify
        ;;
    upload|push)
        cmd_upload
        ;;
    full-sync|sync)
        cmd_full_sync
        ;;
    test-urls)
        cmd_test_urls
        ;;
    test-all|test)
        cmd_test_all
        ;;
    log)
        cmd_log "${2:-50}"
        ;;
    log-clear)
        cmd_log_clear
        ;;
    reports)
        cmd_reports
        ;;
    version|--version|-v)
        show_version
        ;;
    help|--help|-h|*)
        show_usage
        ;;
esac
AUTOMATE_EOF

    chmod +x "$output_dir/automate.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate project config - Full featured
# ───────────────────────────────────────────────────────────────────────────
generate_project_config() {
    local output_dir="$1"
    local project_name="${2:-MyApp}"
    local github_user="${3:-yourusername}"
    local github_repo="${4:-appdata}"
    local source_folder="${5:-data}"
    local app_resources="${6:-App/Resources}"
    local description="${7:-App data repository}"
    
    cat > "$output_dir/config/project_config.sh" << EOF
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# PROJECT CONFIGURATION - $project_name
# ═══════════════════════════════════════════════════════════════════════════
# 📝 This is the ONLY file you need to edit for your project
# All paths and settings are centralized here
# ═══════════════════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────────────────────────────────
# PROJECT INFORMATION
# ──────────────────────────────────────────────────────────────────────────
PROJECT_NAME="$project_name"
PROJECT_DESCRIPTION="$description"
DATA_VERSION="1.0"

# ──────────────────────────────────────────────────────────────────────────
# GITHUB CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
GITHUB_USERNAME="$github_user"
GITHUB_REPO_NAME="$github_repo"
GITHUB_BRANCH="main"

# ──────────────────────────────────────────────────────────────────────────
# DIRECTORY STRUCTURE
# ──────────────────────────────────────────────────────────────────────────
# Source data location (relative to project root)
SOURCE_DATA_DIR="$source_folder"

# App resources location (where app reads data from)
APP_RESOURCES_DIR="$app_resources"

# GitHub data folder structure
GITHUB_DATA_DIR="$source_folder"

# ──────────────────────────────────────────────────────────────────────────
# DATA FILES CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
# File patterns to include
DATA_FILE_PATTERNS=(
    "*.json"
)

# File patterns to exclude
EXCLUDE_PATTERNS=(
    "*.backup"
    "*.backup_*"
    "*.bak"
    "*.tmp"
    "*_temp.json"
)

# Manifest file name
MANIFEST_FILE="manifest.json"

# ──────────────────────────────────────────────────────────────────────────
# DATA VALIDATION RULES
# ──────────────────────────────────────────────────────────────────────────
# Required fields in manifest
REQUIRED_MANIFEST_FIELDS=(
    "version"
)

# Minimum file size (bytes) - smaller files are suspicious
MIN_FILE_SIZE=100

# Maximum file size (bytes) - larger files trigger warning
MAX_FILE_SIZE=10485760  # 10MB

# ──────────────────────────────────────────────────────────────────────────
# REPOSITORY SETTINGS
# ──────────────────────────────────────────────────────────────────────────
# Repository visibility (public/private)
REPO_VISIBILITY="public"

# Repository description for GitHub
REPO_DESCRIPTION="Data for \$PROJECT_NAME"

# License type
LICENSE_TYPE="MIT"

# ──────────────────────────────────────────────────────────────────────────
# AUTOMATION SETTINGS
# ──────────────────────────────────────────────────────────────────────────
# Default commit message
DEFAULT_COMMIT_MESSAGE="Update \$PROJECT_NAME data"

# Temporary directory prefix
TEMP_DIR_PREFIX="temp_github"

# ──────────────────────────────────────────────────────────────────────────
# TESTING CONFIGURATION
# ──────────────────────────────────────────────────────────────────────────
# Sample files to test (will test these first)
TEST_FILES=(
    "manifest.json"
)

# HTTP timeout for URL tests (seconds)
URL_TEST_TIMEOUT=30

# ═══════════════════════════════════════════════════════════════════════════
# AUTO-COMPUTED VALUES (don't edit below)
# ═══════════════════════════════════════════════════════════════════════════

# Paths
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="\$(cd "\$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="\$(cd "\$TOOLKIT_ROOT/.." && pwd)"

SOURCE_DATA_PATH="\$PROJECT_ROOT/\$SOURCE_DATA_DIR"
APP_RESOURCES_PATH="\$PROJECT_ROOT/\$APP_RESOURCES_DIR"
TEMP_REPO_DIR="\$PROJECT_ROOT/\${TEMP_DIR_PREFIX}_repo"

# URLs
GITHUB_REPO_URL="https://github.com/\$GITHUB_USERNAME/\$GITHUB_REPO_NAME.git"
RAW_BASE_URL="https://raw.githubusercontent.com/\$GITHUB_USERNAME/\$GITHUB_REPO_NAME/\$GITHUB_BRANCH/\$GITHUB_DATA_DIR"

# Source libraries
source "\$TOOLKIT_ROOT/core/lib/colors.sh"
source "\$TOOLKIT_ROOT/core/lib/logger.sh"

# Initialize logging
init_logging "\$TOOLKIT_ROOT"

# Export all configuration
export PROJECT_NAME PROJECT_DESCRIPTION DATA_VERSION
export GITHUB_USERNAME GITHUB_REPO_NAME GITHUB_BRANCH GITHUB_REPO_URL RAW_BASE_URL
export SOURCE_DATA_DIR APP_RESOURCES_DIR GITHUB_DATA_DIR SOURCE_DATA_PATH APP_RESOURCES_PATH
export MANIFEST_FILE DEFAULT_COMMIT_MESSAGE TEMP_DIR_PREFIX TEMP_REPO_DIR
export REPO_VISIBILITY REPO_DESCRIPTION LICENSE_TYPE
export MIN_FILE_SIZE MAX_FILE_SIZE URL_TEST_TIMEOUT
export REQUIRED_MANIFEST_FIELDS DATA_FILE_PATTERNS EXCLUDE_PATTERNS TEST_FILES
export TOOLKIT_ROOT PROJECT_ROOT
EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate toolkit - Professional multi-project toolkit
# ───────────────────────────────────────────────────────────────────────────
generate_toolkit() {
    local output_dir="$1"
    
    cat > "$output_dir/toolkit" << 'TOOLKIT_EOF'
#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# PROFESSIONAL DATA TOOLKIT
# ═══════════════════════════════════════════════════════════════════════════
# Multi-project data management and GitHub operations
# ═══════════════════════════════════════════════════════════════════════════

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load core libraries
source "$TOOLKIT_ROOT/core/lib/colors.sh"
source "$TOOLKIT_ROOT/core/lib/logger.sh"
source "$TOOLKIT_ROOT/core/lib/paths.sh"

show_usage() {
    print_box "Professional Data Toolkit"
    cat << 'EOF'

Usage: ./toolkit --project PROJECT_NAME COMMAND [options]

REQUIRED:
  --project NAME          Project to use

COMMANDS:
  config                Show configuration
  validate              Validate configuration
  setup                 GitHub repository setup
  upload                Upload data to GitHub
  verify                Verify data integrity
  sync                  Full workflow
  test-urls             Test GitHub URLs
  test-all              Run all tests

OTHER:
  projects              List available projects
  help                  Show this help
  version               Show version

EXAMPLES:
  ./toolkit --project myapp setup
  ./toolkit --project myapp sync
  ./toolkit projects

ADDING NEW PROJECTS:
  1. Copy: cp -r projects/default projects/mynewapp
  2. Edit: nano projects/mynewapp/config.sh
  3. Use:  ./toolkit --project mynewapp setup

EOF
}

cmd_projects() {
    print_section "Available Projects"
    echo ""
    list_projects
    echo ""
    log_info "Use: ./toolkit --project NAME COMMAND"
}

cmd_version() {
    echo "Professional Data Toolkit v2.0"
    echo "Multi-project support enabled"
}

# Main
main() {
    local project_name=""
    local command=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project|-p)
                project_name="$2"
                shift 2
                ;;
            --help|-h|help)
                show_usage
                exit 0
                ;;
            projects)
                cmd_projects
                exit 0
                ;;
            version|--version)
                cmd_version
                exit 0
                ;;
            *)
                if [ -z "$command" ]; then
                    command="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Special commands that don't need project
    if [ "$command" = "projects" ]; then
        cmd_projects
        exit 0
    fi
    
    # Check project specified
    if [ -z "$project_name" ]; then
        color_error "Error: --project required"
        echo ""
        echo "Usage: ./toolkit --project NAME COMMAND"
        echo "Run './toolkit projects' to list available projects"
        exit 1
    fi
    
    # Load project configuration
    if ! load_project_config "$project_name"; then
        exit 1
    fi
    
    # Load validator after config
    source "$TOOLKIT_ROOT/core/lib/validator.sh"
    
    # Execute command
    case "$command" in
        config)
            print_section "Configuration: $PROJECT_NAME"
            echo ""
            echo "GitHub: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
            echo "Source: $SOURCE_DATA_PATH"
            echo "URL: $RAW_BASE_URL"
            ;;
        validate)
            validate_paths
            ;;
        setup)
            bash "$TOOLKIT_ROOT/core/tools/setup.sh"
            ;;
        upload)
            bash "$TOOLKIT_ROOT/core/tools/upload.sh"
            ;;
        verify)
            validate_all_data
            ;;
        sync)
            print_box "Full Sync: $PROJECT_NAME"
            echo ""
            log_step 1 3 "Verifying..."
            validate_all_data || exit 1
            echo ""
            log_step 2 3 "Uploading..."
            bash "$TOOLKIT_ROOT/core/tools/upload.sh" || exit 1
            echo ""
            log_step 3 3 "Testing URLs..."
            bash "$TOOLKIT_ROOT/tests/test_github_urls.sh" || true
            echo ""
            log_success "Sync complete!"
            ;;
        test-urls)
            bash "$TOOLKIT_ROOT/tests/test_github_urls.sh"
            ;;
        test-all)
            local passed=0 failed=0
            validate_all_data && passed=$((passed+1)) || failed=$((failed+1))
            bash "$TOOLKIT_ROOT/tests/test_github_urls.sh" && passed=$((passed+1)) || failed=$((failed+1))
            log_summary $passed $failed
            [ $failed -eq 0 ]
            ;;
        "")
            show_usage
            exit 1
            ;;
        *)
            color_error "Unknown command: $command"
            echo "Run './toolkit --help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
TOOLKIT_EOF

    chmod +x "$output_dir/toolkit"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate tests
# ───────────────────────────────────────────────────────────────────────────
generate_tests() {
    local output_dir="$1"
    
    # Test GitHub URLs
    cat > "$output_dir/tests/test_github_urls.sh" << 'TESTURLS_EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to load config from parent
if [ -f "$SCRIPT_DIR/../config/project_config.sh" ]; then
    source "$SCRIPT_DIR/../config/project_config.sh"
else
    source "$SCRIPT_DIR/../core/lib/colors.sh"
    source "$SCRIPT_DIR/../core/lib/logger.sh"
fi

print_section "Testing GitHub URLs"
echo ""

log_info "Base URL: $RAW_BASE_URL"
echo ""

success=0
failed=0
timeout="${URL_TEST_TIMEOUT:-30}"

# Get list of test files
test_files=("manifest.json")
if [ -n "${TEST_FILES+x}" ] && [ ${#TEST_FILES[@]} -gt 0 ]; then
    test_files=("${TEST_FILES[@]}")
fi

# Also test all JSON files in source
if [ -d "$SOURCE_DATA_PATH" ]; then
    for file in "$SOURCE_DATA_PATH"/*.json; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")
        
        # Skip backups
        [[ "$filename" == *.backup* ]] && continue
        [[ "$filename" == *.bak ]] && continue
        
        # Add if not already in list
        if [[ ! " ${test_files[*]} " =~ " ${filename} " ]]; then
            test_files+=("$filename")
        fi
    done
fi

for file in "${test_files[@]}"; do
    url="$RAW_BASE_URL/$file"
    log_task "Testing $file"
    
    if curl -s -f -o /dev/null --max-time "$timeout" "$url" 2>/dev/null; then
        log_task_done
        success=$((success + 1))
    else
        log_task_failed
        failed=$((failed + 1))
    fi
done

echo ""
log_summary $success $failed

if [ $failed -eq 0 ]; then
    log_success "All URLs accessible!"
    exit 0
else
    log_error "Some URLs not accessible"
    echo ""
    echo "Note: New files may take a few seconds to propagate."
    exit 1
fi
TESTURLS_EOF

    chmod +x "$output_dir/tests/test_github_urls.sh"
    
    # Verify data integrity
    cat > "$output_dir/tests/verify_data_integrity.sh" << 'VERIFY_EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/../config/project_config.sh" ]; then
    source "$SCRIPT_DIR/../config/project_config.sh"
fi

source "$SCRIPT_DIR/../core/lib/validator.sh"

validate_all_data
VERIFY_EOF

    chmod +x "$output_dir/tests/verify_data_integrity.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate GitHub tools (wrappers)
# ───────────────────────────────────────────────────────────────────────────
generate_github_tools() {
    local output_dir="$1"
    
    # Setup wrapper
    cat > "$output_dir/github_tools/setup_github_repo.sh" << 'GHSETUP_EOF'
#!/bin/bash
# Wrapper - calls core setup tool
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"
exec bash "$SCRIPT_DIR/../core/tools/setup.sh" "$@"
GHSETUP_EOF
    chmod +x "$output_dir/github_tools/setup_github_repo.sh"
    
    # Upload wrapper
    cat > "$output_dir/github_tools/upload_to_github.sh" << 'GHUPLOAD_EOF'
#!/bin/bash
# Wrapper - calls core upload tool
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"
exec bash "$SCRIPT_DIR/../core/tools/upload.sh" "$@"
GHUPLOAD_EOF
    chmod +x "$output_dir/github_tools/upload_to_github.sh"
}

# ───────────────────────────────────────────────────────────────────────────
# Generate default project config
# ───────────────────────────────────────────────────────────────────────────
generate_default_project() {
    local output_dir="$1"
    local project_name="${2:-default}"
    local github_user="${3:-yourusername}"
    local github_repo="${4:-appdata}"
    local source_folder="${5:-data}"
    
    mkdir -p "$output_dir/projects/$project_name"
    
    cat > "$output_dir/projects/$project_name/config.sh" << EOF
#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# PROJECT: $project_name
# ═══════════════════════════════════════════════════════════════════════════

export PROJECT_NAME="$project_name"
export PROJECT_DESCRIPTION="Data for $project_name"

# GitHub
export GITHUB_USERNAME="$github_user"
export GITHUB_REPO_NAME="$github_repo"
export GITHUB_BRANCH="main"

# Directories
export SOURCE_DATA_DIR="$source_folder"
export APP_RESOURCES_DIR="App/Resources"
export GITHUB_DATA_DIR="$source_folder"

# Files
export DATA_FILE_PATTERNS=("*.json")
export EXCLUDE_PATTERNS=("*.backup" "*.backup_*" "*.bak" "*.tmp")
export MANIFEST_FILE="manifest.json"

# Validation
export REQUIRED_MANIFEST_FIELDS=("version")
export MIN_FILE_SIZE=100
export MAX_FILE_SIZE=10485760

# Repository
export REPO_VISIBILITY="public"
export REPO_DESCRIPTION="Data for $project_name"
export LICENSE_TYPE="MIT"

# Automation
export DEFAULT_COMMIT_MESSAGE="Update $project_name data"
export TEMP_DIR_PREFIX="temp_github"

# Testing
export TEST_FILES=("manifest.json")
export URL_TEST_TIMEOUT=30

# Auto-computed
TOOLKIT_ROOT="\${TOOLKIT_ROOT:-\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/../.." && pwd)}"
PROJECT_ROOT="\$(cd "\$TOOLKIT_ROOT/.." && pwd)"

export SOURCE_DATA_PATH="\$PROJECT_ROOT/\$SOURCE_DATA_DIR"
export APP_RESOURCES_PATH="\$PROJECT_ROOT/\$APP_RESOURCES_DIR"
export TEMP_REPO_DIR="\$PROJECT_ROOT/\${TEMP_DIR_PREFIX}_repo"
export GITHUB_REPO_URL="https://github.com/\$GITHUB_USERNAME/\$GITHUB_REPO_NAME.git"
export RAW_BASE_URL="https://raw.githubusercontent.com/\$GITHUB_USERNAME/\$GITHUB_REPO_NAME/\$GITHUB_BRANCH/\$GITHUB_DATA_DIR"
EOF
}

# ───────────────────────────────────────────────────────────────────────────
# Generate README
# ───────────────────────────────────────────────────────────────────────────
generate_readme() {
    local output_dir="$1"
    local project_name="${2:-MyApp}"
    
    cat > "$output_dir/README.md" << EOF
# Auto App Data Generation Toolkit

Professional data management and GitHub synchronization for **$project_name**.

## 🚀 Quick Start

\`\`\`bash
# 1. Configure your project
nano config/project_config.sh

# 2. Setup GitHub repository
./automate.sh setup-github

# 3. Sync your data
./automate.sh full-sync
\`\`\`

## 📁 Structure

\`\`\`
auto_app_data generation/
├── automate.sh              # Simple single-project script
├── toolkit                  # Multi-project toolkit
├── config/
│   └── project_config.sh    # ⚙️ EDIT THIS
├── core/
│   ├── lib/                 # Libraries
│   │   ├── colors.sh        # Terminal colors
│   │   ├── logger.sh        # Logging (levels + file)
│   │   ├── paths.sh         # Path resolution
│   │   └── validator.sh     # Data validation
│   └── tools/               # Core tools
│       ├── setup.sh         # GitHub setup
│       └── upload.sh        # Data upload
├── github_tools/            # GitHub wrappers
├── projects/                # Multi-project configs
├── tests/                   # Test scripts
├── reports/                 # Generated reports
└── logs/                    # Log files
\`\`\`

## 🔧 Commands

### Simple Usage (automate.sh)

| Command | Description |
|---------|-------------|
| \`./automate.sh config\` | Show configuration |
| \`./automate.sh validate\` | Validate setup |
| \`./automate.sh setup-github\` | Create GitHub repo |
| \`./automate.sh verify\` | Verify data integrity |
| \`./automate.sh upload\` | Upload to GitHub |
| \`./automate.sh full-sync\` | Complete workflow |
| \`./automate.sh test-urls\` | Test GitHub URLs |
| \`./automate.sh log\` | View recent logs |

### Multi-Project Usage (toolkit)

\`\`\`bash
./toolkit --project myapp setup
./toolkit --project myapp sync
./toolkit projects
\`\`\`

## ✨ Features

- ✓ Full JSON validation
- ✓ File size validation
- ✓ Manifest validation
- ✓ Interactive workflows
- ✓ Log levels (DEBUG, INFO, WARNING, ERROR)
- ✓ File logging
- ✓ Upload reports
- ✓ Verification reports
- ✓ Multi-project support
- ✓ GitHub CLI integration

## 📊 Workflow

1. **Edit** your JSON files
2. **Verify** with \`./automate.sh verify\`
3. **Upload** with \`./automate.sh upload\`
4. **Test** with \`./automate.sh test-urls\`

Or run everything: \`./automate.sh full-sync\`

---
*Generated by DNS Data Toolkit Generator - Professional Edition*
EOF
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN COMMAND HANDLERS
# ═══════════════════════════════════════════════════════════════════════════

cmd_generate() {
    print_box "Data Toolkit Generator - Professional Edition"
    echo ""
    
    # Parse options
    local project_name=""
    local github_user=""
    local github_repo=""
    local output_dir=""
    local force=false
    local source_folder="data"
    local app_resources="App/Resources"
    local description="App data repository"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name) project_name="$2"; shift 2 ;;
            --github) github_user="$2"; shift 2 ;;
            --repo) github_repo="$2"; shift 2 ;;
            --output) output_dir="$2"; shift 2 ;;
            --source) source_folder="$2"; shift 2 ;;
            --resources) app_resources="$2"; shift 2 ;;
            --description) description="$2"; shift 2 ;;
            --force) force=true; shift ;;
            *) shift ;;
        esac
    done
    
    # Set defaults
    project_name="${project_name:-$(basename "$PROJECT_ROOT")}"
    github_user="${github_user:-yourusername}"
    github_repo="${github_repo:-${project_name,,}data}"
    output_dir="${output_dir:-$PROJECT_ROOT/auto_app_data generation}"
    
    log_info "Project: $project_name"
    log_info "GitHub: $github_user/$github_repo"
    log_info "Source: $source_folder"
    log_info "Output: $output_dir"
    echo ""
    
    # Check if exists
    if [ -d "$output_dir" ] && [ "$force" != true ]; then
        log_warning "Output directory exists: $output_dir"
        echo ""
        read -p "Overwrite? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Cancelled"
            return 1
        fi
    fi
    
    # Create structure
    print_section "Creating Directory Structure"
    mkdir -p "$output_dir"/{config,core/{lib,tools},github_tools,projects,tests,reports/{verification,uploads,tests},logs,docs}
    print_check "Created directories"
    
    # Generate all files
    print_section "Generating Core Libraries"
    generate_colors_lib "$output_dir"
    print_check "colors.sh (full featured)"
    
    generate_logger_lib "$output_dir"
    print_check "logger.sh (log levels + file logging)"
    
    generate_paths_lib "$output_dir"
    print_check "paths.sh (path resolution + validation)"
    
    generate_validator_lib "$output_dir"
    print_check "validator.sh (full validation)"
    
    print_section "Generating Tools"
    generate_setup_tool "$output_dir"
    print_check "setup.sh (interactive + GitHub CLI)"
    
    generate_upload_tool "$output_dir"
    print_check "upload.sh (with reports)"
    
    print_section "Generating Main Scripts"
    generate_automate_sh "$output_dir" "$project_name"
    print_check "automate.sh"
    
    generate_toolkit "$output_dir"
    print_check "toolkit (multi-project)"
    
    generate_project_config "$output_dir" "$project_name" "$github_user" "$github_repo" "$source_folder" "$app_resources" "$description"
    print_check "project_config.sh (full options)"
    
    print_section "Generating Additional Files"
    generate_github_tools "$output_dir"
    print_check "GitHub tool wrappers"
    
    generate_tests "$output_dir"
    print_check "Test scripts"
    
    generate_default_project "$output_dir" "$project_name" "$github_user" "$github_repo" "$source_folder"
    print_check "Default project config"
    
    generate_readme "$output_dir" "$project_name"
    print_check "README.md"
    
    echo ""
    log_success "Professional toolkit generated!"
    echo ""
    echo -e "${CYAN}📁 Generated:${NC} $output_dir/"
    echo ""
    echo -e "${CYAN}📝 Next Steps:${NC}"
    echo "  1. Configure: nano \"$output_dir/config/project_config.sh\""
    echo "  2. Setup: cd \"$output_dir\" && ./automate.sh setup-github"
    echo "  3. Sync: ./automate.sh full-sync"
    echo ""
    echo -e "${CYAN}📊 Features Included:${NC}"
    echo "  ✓ Full validation (JSON, size, manifest, structure)"
    echo "  ✓ Log levels (DEBUG, INFO, WARNING, ERROR)"
    echo "  ✓ File logging support"
    echo "  ✓ Interactive workflows"
    echo "  ✓ Upload/verification reports"
    echo "  ✓ Multi-project support"
    echo "  ✓ GitHub CLI integration"
    echo ""
}

cmd_info() {
    print_box "Data Toolkit Generator - Info"
    echo ""
    
    echo "This generator creates a FULL-FEATURED data management system:"
    echo ""
    echo "📦 Core Libraries:"
    echo "  • colors.sh   - Terminal colors + styles + progress bars"
    echo "  • logger.sh   - Log levels + file logging + duration tracking"
    echo "  • paths.sh    - Path resolution + validation + project loading"
    echo "  • validator.sh - JSON + size + manifest + structure validation"
    echo ""
    echo "🛠️ Tools:"
    echo "  • setup.sh    - Interactive GitHub setup + CLI integration"
    echo "  • upload.sh   - Full upload workflow + reports"
    echo ""
    echo "📊 Features:"
    echo "  ✓ Multi-project support via toolkit"
    echo "  ✓ Comprehensive validation"
    echo "  ✓ Interactive prompts"
    echo "  ✓ Log levels and file logging"
    echo "  ✓ Upload and verification reports"
    echo "  ✓ GitHub CLI integration"
    echo ""
    echo "Run: bash .cursorrules data-toolkit generate"
}

# Main
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        generate) cmd_generate "$@" ;;
        info) cmd_info ;;
        upgrade) cmd_generate --force "$@" ;;
        --help|-h|help) show_help ;;
        *) show_help; exit 1 ;;
    esac
}

main "$@"
