#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# DATA VERIFICATION TOOL
# ═══════════════════════════════════════════════════════════════════════════
# Validates data files before upload
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/validator.sh"

# ───────────────────────────────────────────────────────────────────────────
# Main verification function
# ───────────────────────────────────────────────────────────────────────────

verify_data() {
    print_section "Validating Data Files"
    
    # Check if source directory exists
    if [ ! -d "$SOURCE_DATA_PATH" ]; then
        log_error "Source directory not found: $SOURCE_DATA_PATH"
        return 1
    fi
    
    # Validate manifest if enabled
    if [ "${VALIDATE_MANIFEST:-true}" = "true" ]; then
        local manifest_path="$SOURCE_DATA_PATH/$MANIFEST_FILE"
        if [ -f "$manifest_path" ]; then
            if validate_json_file "$manifest_path"; then
                local version=$(get_manifest_version "$manifest_path")
                log_info "Manifest version: $version"
                print_check "Manifest valid"
            else
                log_error "Manifest validation failed"
                return 1
            fi
        else
            log_warning "Manifest file not found: $MANIFEST_FILE"
        fi
    fi
    
    echo ""
    
    # Validate all data files
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
                continue
            fi
            
            echo -n "Checking $filename... "
            
            # Validate based on file extension
            if [[ "$filename" == *.json ]]; then
                if validate_json_file "$file"; then
                    color_success "Done"
                else
                    color_error "Failed"
                    ((errors++))
                fi
            else
                # Just check if file exists and is readable
                if [ -r "$file" ]; then
                    color_success "Done"
                else
                    color_error "Failed"
                    ((errors++))
                fi
            fi
            
            ((total++))
        done
    done
    
    echo ""
    echo ""
    
    # Summary
    print_section "Summary"
    echo ""
    echo "Total: $total"
    if [ $errors -eq 0 ]; then
        log_success "Passed: $total"
        echo ""
        log_success "All data files valid"
        return 0
    else
        log_error "Failed: $errors"
        echo ""
        log_error "Validation failed"
        return 1
    fi
}

# ───────────────────────────────────────────────────────────────────────────
# Execute
# ───────────────────────────────────────────────────────────────────────────

total=0
errors=0

verify_data

