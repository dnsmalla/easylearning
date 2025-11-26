#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# LOGGER LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides logging functionality with different log levels
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

# Default log level
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Log file (optional)
LOG_FILE="${LOG_FILE:-}"

# ───────────────────────────────────────────────────────────────────────────
# Core logging functions
# ───────────────────────────────────────────────────────────────────────────

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Write to log file if specified
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
    
    # Print to terminal
    echo "$message"
}

log_debug() {
    if [ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]; then
        log_message "DEBUG" "$(color_print $COLOR_GRAY "[DEBUG] $@")"
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

# ───────────────────────────────────────────────────────────────────────────
# Summary functions
# ───────────────────────────────────────────────────────────────────────────

log_summary() {
    local passed="$1"
    local failed="$2"
    local total=$((passed + failed))
    
    echo ""
    print_section "Summary"
    echo "Total: $total"
    color_success "Passed: $passed"
    if [ $failed -gt 0 ]; then
        color_error "Failed: $failed"
    fi
    echo ""
}

# Export functions
export -f log_message log_debug log_info log_warning log_error log_success
export -f log_step log_task log_task_done log_task_failed log_summary

