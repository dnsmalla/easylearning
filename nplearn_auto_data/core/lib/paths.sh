#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Path Utilities
# ═══════════════════════════════════════════════════════════════════════════

# Validate all required paths exist
validate_paths() {
    local valid=true
    
    # Check source data path
    log_task "Source data path"
    if [ -d "$SOURCE_DATA_PATH" ]; then
        log_task_done
    else
        log_task_failed
        log_error "Source data path not found: $SOURCE_DATA_PATH"
        valid=false
    fi
    
    # Check app resources path
    log_task "App resources path"
    if [ -d "$APP_RESOURCES_PATH" ]; then
        log_task_done
    else
        log_task_failed
        log_error "App resources path not found: $APP_RESOURCES_PATH"
        valid=false
    fi
    
    # Check for required files
    for file in "${REQUIRED_FILES[@]}"; do
        log_task "File: $file"
        if [ -f "$APP_RESOURCES_PATH/$file" ]; then
            log_task_done
        else
            log_task_failed
            log_error "Required file not found: $file"
            valid=false
        fi
    done
    
    if [ "$valid" = true ]; then
        return 0
    else
        return 1
    fi
}

