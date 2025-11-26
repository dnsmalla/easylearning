#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# VALIDATOR LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides data validation functions
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
    local required_fields=("$@")
    shift  # Remove first argument (file)
    
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
    
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    if [ "$size" -lt "$min_size" ]; then
        log_warning "File too small: $file ($size bytes)"
        return 1
    fi
    
    if [ "$size" -gt "$max_size" ]; then
        log_warning "File too large: $file ($size bytes)"
    fi
    
    return 0
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
    for field in "${REQUIRED_MANIFEST_FIELDS[@]}"; do
        if ! python3 -c "import json; data=json.load(open('$manifest_file')); exit(0 if '$field' in data else 1)" 2>/dev/null; then
            log_error "Missing required field: $field"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -gt 0 ]; then
        return 1
    fi
    
    # Extract and display version
    local version=$(python3 -c "import json; print(json.load(open('$manifest_file'))['version'])" 2>/dev/null)
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
    
    print_section "Validating Data Files"
    
    # Validate manifest first
    local manifest_path="$data_path/$MANIFEST_FILE"
    if validate_manifest "$manifest_path"; then
        print_check "Manifest valid"
    else
        print_cross "Manifest invalid"
        return 1
    fi
    
    echo ""
    
    # Validate all data files
    # Use default pattern if array not set
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
            
            log_task "Checking $filename"
            
            if validate_json_file "$file" && validate_file_size "$file"; then
                log_task_done
                valid=$((valid + 1))
            else
                log_task_failed
                invalid=$((invalid + 1))
            fi
        done
    done
    
    echo ""
    log_summary $valid $invalid
    
    if [ $invalid -eq 0 ]; then
        log_success "All data files valid"
        return 0
    else
        log_error "Some data files invalid"
        return 1
    fi
}

# Export functions
export -f validate_json_file validate_json_structure validate_file_size
export -f should_exclude_file validate_manifest validate_all_data

