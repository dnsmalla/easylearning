#!/usr/bin/env bash
# DNS System - Enhanced Centralized Logging System
# Tracks all processes from start to end with log rotation and analytics

# Global logging configuration
LOG_DIR="$(dirname "$SYSTEM_DIR")/logs"
LOG_FILE="$LOG_DIR/dns_process.log"
ANALYTICS_FILE="$LOG_DIR/analytics.json"
LOG_LEVEL="${DNS_LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR
MAX_LOG_SIZE=1048576  # 1MB in bytes

# Performance tracking (using bash 3.x compatible syntax)
if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
  declare -A PERF_TIMERS
else
  # Fallback for older bash versions
  PERF_TIMERS_KEYS=""
  PERF_TIMERS_VALUES=""
fi

# Ensure log directory exists
init_logging() {
  mkdir -p "$LOG_DIR"
  
  # Create new log file (replace old one)
  cat > "$LOG_FILE" << EOF
================================================================================
DNS Code Generation System v2.0 - Process Log
================================================================================
Session Started: $(date '+%Y-%m-%d %H:%M:%S')
System Directory: $SYSTEM_DIR
Root Directory: $ROOT_DIR
Log Level: $LOG_LEVEL
================================================================================

EOF
  
  log_info "Logging system initialized"
  log_info "Log file: $LOG_FILE"
}

# Get timestamp for log entries
get_timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Get log level number for comparison
get_log_level_num() {
  case "$1" in
    "DEBUG") echo 1 ;;
    "INFO")  echo 2 ;;
    "WARN")  echo 3 ;;
    "ERROR") echo 4 ;;
    *) echo 2 ;;  # Default to INFO
  esac
}

# Check if we should log this level
should_log() {
  local level="$1"
  local current_level_num=$(get_log_level_num "$LOG_LEVEL")
  local message_level_num=$(get_log_level_num "$level")
  
  [[ $message_level_num -ge $current_level_num ]]
}

# Generic logging function
write_log() {
  local level="$1"
  local message="$2"
  local component="${3:-SYSTEM}"
  
  # Check if we should log this level
  if ! should_log "$level"; then
    return 0
  fi
  
  # Check log file size and rotate if needed
  if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt $MAX_LOG_SIZE ]]; then
    # Archive old log and start fresh
    mv "$LOG_FILE" "${LOG_FILE}.old"
    init_logging
  fi
  
  # Format: [TIMESTAMP] [LEVEL] [COMPONENT] MESSAGE
  local log_entry="[$(get_timestamp)] [$level] [$component] $message"
  
  # Write to log file
  echo "$log_entry" >> "$LOG_FILE"
  
  # Also output to console with color coding
  case "$level" in
    "DEBUG") echo -e "\033[36m$log_entry\033[0m" ;;  # Cyan
    "INFO")  echo -e "\033[32m$log_entry\033[0m" ;;  # Green
    "WARN")  echo -e "\033[33m$log_entry\033[0m" ;;  # Yellow
    "ERROR") echo -e "\033[31m$log_entry\033[0m" ;;  # Red
    *) echo "$log_entry" ;;
  esac
}

# Convenience logging functions
log_debug() {
  write_log "DEBUG" "$1" "${2:-SYSTEM}"
}

log_info() {
  write_log "INFO" "$1" "${2:-SYSTEM}"
}

log_warn() {
  write_log "WARN" "$1" "${2:-SYSTEM}"
}

log_error() {
  write_log "ERROR" "$1" "${2:-SYSTEM}"
}

# Log process start
log_process_start() {
  local process_name="$1"
  local details="${2:-}"
  
  echo "" >> "$LOG_FILE"
  echo "┌─────────────────────────────────────────────────────────────────────────────┐" >> "$LOG_FILE"
  echo "│ PROCESS START: $process_name" >> "$LOG_FILE"
  if [[ -n "$details" ]]; then
    echo "│ Details: $details" >> "$LOG_FILE"
  fi
  echo "│ Started at: $(get_timestamp)" >> "$LOG_FILE"
  echo "└─────────────────────────────────────────────────────────────────────────────┘" >> "$LOG_FILE"
  
  log_info "🚀 Starting process: $process_name" "PROCESS"
  [[ -n "$details" ]] && log_debug "Process details: $details" "PROCESS"
}

# Log process end
log_process_end() {
  local process_name="$1"
  local status="${2:-SUCCESS}"
  local details="${3:-}"
  
  local status_icon="✅"
  [[ "$status" != "SUCCESS" ]] && status_icon="❌"
  
  echo "" >> "$LOG_FILE"
  echo "┌─────────────────────────────────────────────────────────────────────────────┐" >> "$LOG_FILE"
  echo "│ PROCESS END: $process_name" >> "$LOG_FILE"
  echo "│ Status: $status" >> "$LOG_FILE"
  if [[ -n "$details" ]]; then
    echo "│ Details: $details" >> "$LOG_FILE"
  fi
  echo "│ Ended at: $(get_timestamp)" >> "$LOG_FILE"
  echo "└─────────────────────────────────────────────────────────────────────────────┘" >> "$LOG_FILE"
  
  if [[ "$status" == "SUCCESS" ]]; then
    log_info "$status_icon Process completed: $process_name" "PROCESS"
  else
    log_error "$status_icon Process failed: $process_name - $status" "PROCESS"
  fi
  [[ -n "$details" ]] && log_debug "Process end details: $details" "PROCESS"
}

# Log step within a process
log_step() {
  local step_name="$1"
  local status="${2:-IN_PROGRESS}"
  local details="${3:-}"
  
  case "$status" in
    "IN_PROGRESS") 
      log_info "🔄 Step: $step_name" "STEP"
      ;;
    "SUCCESS")
      log_info "✅ Step completed: $step_name" "STEP"
      ;;
    "FAILED")
      log_error "❌ Step failed: $step_name" "STEP"
      ;;
    "SKIPPED")
      log_warn "⏭️  Step skipped: $step_name" "STEP"
      ;;
  esac
  
  [[ -n "$details" ]] && log_debug "Step details: $details" "STEP"
}

# Log command execution
log_command() {
  local command="$1"
  local exit_code="${2:-0}"
  local output="${3:-}"
  
  log_debug "Executing command: $command" "CMD"
  
  if [[ $exit_code -eq 0 ]]; then
    log_debug "Command successful (exit code: $exit_code)" "CMD"
  else
    log_error "Command failed (exit code: $exit_code): $command" "CMD"
  fi
  
  if [[ -n "$output" ]]; then
    log_debug "Command output: $output" "CMD"
  fi
}

# Log file operations
log_file_operation() {
  local operation="$1"  # CREATE, READ, WRITE, DELETE, MOVE
  local file_path="$2"
  local status="${3:-SUCCESS}"
  local details="${4:-}"
  
  case "$operation" in
    "CREATE") log_info "📄 Created file: $file_path" "FILE" ;;
    "READ")   log_debug "📖 Reading file: $file_path" "FILE" ;;
    "WRITE")  log_info "✏️  Writing to file: $file_path" "FILE" ;;
    "DELETE") log_info "🗑️  Deleted file: $file_path" "FILE" ;;
    "MOVE")   log_info "📦 Moved file: $file_path" "FILE" ;;
  esac
  
  if [[ "$status" != "SUCCESS" ]]; then
    log_error "File operation failed: $operation on $file_path - $status" "FILE"
  fi
  
  [[ -n "$details" ]] && log_debug "File operation details: $details" "FILE"
}

# Log error detection results
log_error_detection() {
  local file_path="$1"
  local language="$2"
  local syntax_status="$3"
  local runtime_status="$4"
  local error_details="${5:-}"
  
  log_info "🔍 Error detection for: $(basename "$file_path") ($language)" "ERROR_CHECK"
  log_info "Syntax check: $syntax_status" "ERROR_CHECK"
  log_info "Runtime check: $runtime_status" "ERROR_CHECK"
  
  if [[ -n "$error_details" ]]; then
    log_debug "Error details: $error_details" "ERROR_CHECK"
  fi
}

# Log AI interaction
log_ai_interaction() {
  local action="$1"  # PROMPT_GENERATED, CORRECTION_REQUESTED, etc.
  local details="$2"
  
  log_info "🤖 AI Interaction: $action" "AI"
  [[ -n "$details" ]] && log_debug "AI details: $details" "AI"
}

# Show current log
show_log() {
  local lines="${1:-50}"  # Default to last 50 lines
  
  if [[ -f "$LOG_FILE" ]]; then
    echo "📋 DNS System Log (last $lines lines):"
    echo "========================================"
    tail -n "$lines" "$LOG_FILE"
  else
    echo "❌ No log file found at: $LOG_FILE"
  fi
}

# Clear current log
clear_log() {
  if [[ -f "$LOG_FILE" ]]; then
    log_info "🧹 Clearing log file" "SYSTEM"
    init_logging
    log_info "Log file cleared and reinitialized" "SYSTEM"
  else
    echo "ℹ️  No log file to clear"
  fi
}

# Get log statistics
log_stats() {
  if [[ ! -f "$LOG_FILE" ]]; then
    echo "❌ No log file found"
    return 1
  fi
  
  local total_lines=$(wc -l < "$LOG_FILE")
  local debug_count=$(grep -c "\[DEBUG\]" "$LOG_FILE" || echo 0)
  local info_count=$(grep -c "\[INFO\]" "$LOG_FILE" || echo 0)
  local warn_count=$(grep -c "\[WARN\]" "$LOG_FILE" || echo 0)
  local error_count=$(grep -c "\[ERROR\]" "$LOG_FILE" || echo 0)
  local file_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  
  echo "📊 Log Statistics:"
  echo "=================="
  echo "Total lines: $total_lines"
  echo "File size: $file_size bytes"
  echo "Log levels:"
  echo "  DEBUG: $debug_count"
  echo "  INFO:  $info_count"
  echo "  WARN:  $warn_count"
  echo "  ERROR: $error_count"
}

# Performance monitoring functions
start_timer() {
  local timer_name="$1"
  local current_time="$(date +%s.%N)"
  
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    PERF_TIMERS["${timer_name}_start"]="$current_time"
  else
    # Fallback for older bash - use simple variables
    eval "PERF_TIMER_${timer_name}_start=\"$current_time\""
  fi
}

end_timer() {
  local timer_name="$1"
  local start_time
  local end_time="$(date +%s.%N)"
  
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    start_time="${PERF_TIMERS[${timer_name}_start]}"
    PERF_TIMERS["${timer_name}_duration"]="$duration"
  else
    # Fallback for older bash
    eval "start_time=\"\$PERF_TIMER_${timer_name}_start\""
  fi
  
  local duration
  if [[ -n "$start_time" ]]; then
    if command -v bc >/dev/null 2>&1; then
      duration="$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")"
    else
      # Fallback to basic arithmetic if bc is not available
      duration="$(awk "BEGIN {print $end_time - $start_time}" 2>/dev/null || echo "0")"
    fi
  else
    duration="0"
  fi
  
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    PERF_TIMERS["${timer_name}_duration"]="$duration"
  fi
  
  log_info "Performance: $timer_name took ${duration}s" "PERF"
  echo "$duration"
}

# Analytics tracking
track_usage() {
  local command="$1"
  local project_type="$2"
  local language="$3"
  local success="$4"
  local duration="${5:-0}"
  
  local timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  
  # Create analytics entry
  local entry="{
    \"timestamp\": \"$timestamp\",
    \"command\": \"$command\",
    \"project_type\": \"$project_type\",
    \"language\": \"$language\",
    \"success\": $success,
    \"duration\": $duration,
    \"system_version\": \"${SYSTEM_VERSION:-2.0.0}\"
  }"
  
  # Append to analytics file
  echo "$entry" >> "$ANALYTICS_FILE"
  log_debug "Usage tracked: $command ($project_type, $language)" "ANALYTICS"
}

# Show analytics summary
show_analytics() {
  if [[ ! -f "$ANALYTICS_FILE" ]]; then
    echo "📊 No analytics data available"
    return 1
  fi
  
  echo "📊 DNS System Analytics"
  echo "======================"
  
  local total_uses=$(wc -l < "$ANALYTICS_FILE")
  local successful_uses=$(grep '"success": true' "$ANALYTICS_FILE" | wc -l)
  local success_rate=$((successful_uses * 100 / total_uses))
  
  echo "Total uses: $total_uses"
  echo "Successful: $successful_uses"
  echo "Success rate: $success_rate%"
  echo ""
  
  echo "Most used commands:"
  grep -o '"command": "[^"]*"' "$ANALYTICS_FILE" | sort | uniq -c | sort -nr | head -5
  echo ""
  
  echo "Most used languages:"
  grep -o '"language": "[^"]*"' "$ANALYTICS_FILE" | sort | uniq -c | sort -nr | head -5
}

# Enhanced error detection with auto-recovery
log_error_with_recovery() {
  local error_msg="$1"
  local component="${2:-SYSTEM}"
  local recovery_action="${3:-}"
  
  log_error "$error_msg" "$component"
  
  if [[ -n "$recovery_action" ]]; then
    log_info "Attempting recovery: $recovery_action" "$component"
    if eval "$recovery_action"; then
      log_info "Recovery successful" "$component"
      return 0
    else
      log_error "Recovery failed" "$component"
      return 1
    fi
  fi
  
  return 1
}

# Export functions for use in other scripts
export -f init_logging
export -f write_log
export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f log_process_start
export -f log_process_end
export -f log_step
export -f log_command
export -f log_file_operation
export -f log_error_detection
export -f log_ai_interaction
export -f show_log
export -f clear_log
export -f log_stats
export -f start_timer
export -f end_timer
export -f track_usage
export -f show_analytics
export -f log_error_with_recovery
