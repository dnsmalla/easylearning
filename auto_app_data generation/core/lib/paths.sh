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
        return 1
    fi
    
    source "$config_file"
    
    # Set derived paths
    export PROJECT_ROOT=$(get_project_root)
    export SOURCE_DATA_PATH="$PROJECT_ROOT/$SOURCE_DATA_DIR"
    export APP_RESOURCES_PATH="$PROJECT_ROOT/$APP_RESOURCES_DIR"
    export TEMP_REPO_DIR="$PROJECT_ROOT/${TEMP_DIR_PREFIX}_repo"
    export TOOLKIT_ROOT="$toolkit_root"
    
    log_debug "Loaded config for project: $project_name"
    log_debug "Project root: $PROJECT_ROOT"
    log_debug "Source data: $SOURCE_DATA_PATH"
    
    return 0
}

# ───────────────────────────────────────────────────────────────────────────
# Path validation
# ───────────────────────────────────────────────────────────────────────────

validate_paths() {
    local errors=0
    
    # Check source data path
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        log_error "Source data path not found: $SOURCE_DATA_PATH"
        errors=$((errors + 1))
    else
        log_debug "Source data path exists: $SOURCE_DATA_PATH"
    fi
    
    # Check if there are data files
    local file_count=0
    # Use default pattern if array not set
    local patterns=("*.json")
    if [ -n "${DATA_FILE_PATTERNS+x}" ] && [ ${#DATA_FILE_PATTERNS[@]} -gt 0 ]; then
        patterns=("${DATA_FILE_PATTERNS[@]}")
    fi
    
    for pattern in "${patterns[@]}"; do
        file_count=$((file_count + $(find "$SOURCE_DATA_PATH" -name "$pattern" -type f 2>/dev/null | wc -l)))
    done
    
    if [ $file_count -eq 0 ]; then
        log_error "No data files found in: $SOURCE_DATA_PATH"
        errors=$((errors + 1))
    else
        log_debug "Found $file_count data files"
    fi
    
    return $errors
}

# ───────────────────────────────────────────────────────────────────────────
# Helper functions
# ───────────────────────────────────────────────────────────────────────────

get_reports_dir() {
    echo "$(get_toolkit_root)/reports"
}

get_core_dir() {
    echo "$(get_toolkit_root)/core"
}

get_projects_dir() {
    echo "$(get_toolkit_root)/projects"
}

# Create reports directory if it doesn't exist
ensure_reports_dir() {
    local reports_dir=$(get_reports_dir)
    mkdir -p "$reports_dir/verification"
    mkdir -p "$reports_dir/uploads"
    mkdir -p "$reports_dir/tests"
}

# Export functions
export -f get_toolkit_root get_project_root load_project_config validate_paths
export -f get_reports_dir get_core_dir get_projects_dir ensure_reports_dir

