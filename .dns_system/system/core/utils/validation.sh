#!/usr/bin/env bash
# DNS System - Enhanced Validation and Security
# Comprehensive input validation, sanitization, and security checks

# Input sanitization
sanitize_input() {
  local input="$1"
  local type="${2:-general}"  # general, filename, command, path
  
  case "$type" in
    "filename")
      # Allow only safe filename characters
      echo "$input" | sed 's/[^a-zA-Z0-9._-]/_/g' | sed 's/__*/_/g'
      ;;
    "command")
      # Remove potentially dangerous characters for commands
      echo "$input" | sed 's/[;&|`$(){}[\]\\]//g' | tr -d '\n\r'
      ;;
    "path")
      # Sanitize file paths
      echo "$input" | sed 's/\.\.\///g' | sed 's/[;&|`$(){}[\]\\]//g'
      ;;
    *)
      # General sanitization
      echo "$input" | sed 's/[;&|`$(){}[\]\\]//g' | tr -d '\n\r'
      ;;
  esac
}

# Validate dependencies
validate_dependencies() {
  local missing_deps=()
  local optional_deps=()
  
  # Required dependencies
  local required_tools=("bash" "python3" "git" "grep" "sed" "awk")
  
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing_deps+=("$tool")
    fi
  done
  
  # Optional dependencies (for enhanced features)
  local optional_tools=("bc" "jq" "curl" "swift" "dart")
  
  for tool in "${optional_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      optional_deps+=("$tool")
    fi
  done
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing required dependencies: ${missing_deps[*]}" "VALIDATION"
    echo "Please install the missing tools to continue."
    return 1
  fi
  
  if [[ ${#optional_deps[@]} -gt 0 ]]; then
    log_warn "Optional dependencies missing: ${optional_deps[*]}" "VALIDATION"
    log_info "Some features may be limited without these tools" "VALIDATION"
  fi
  
  log_info "All required dependencies validated" "VALIDATION"
  return 0
}

# Validate file permissions
validate_file_permissions() {
  local file_path="$1"
  local required_permission="${2:-r}"  # r, w, x, rw, rx, wx, rwx
  
  if [[ ! -e "$file_path" ]]; then
    log_error "File does not exist: $file_path" "VALIDATION"
    return 1
  fi
  
  case "$required_permission" in
    "r") [[ -r "$file_path" ]] || { log_error "No read permission: $file_path" "VALIDATION"; return 1; } ;;
    "w") [[ -w "$file_path" ]] || { log_error "No write permission: $file_path" "VALIDATION"; return 1; } ;;
    "x") [[ -x "$file_path" ]] || { log_error "No execute permission: $file_path" "VALIDATION"; return 1; } ;;
    "rw") [[ -r "$file_path" && -w "$file_path" ]] || { log_error "No read/write permission: $file_path" "VALIDATION"; return 1; } ;;
    "rx") [[ -r "$file_path" && -x "$file_path" ]] || { log_error "No read/execute permission: $file_path" "VALIDATION"; return 1; } ;;
    "wx") [[ -w "$file_path" && -x "$file_path" ]] || { log_error "No write/execute permission: $file_path" "VALIDATION"; return 1; } ;;
    "rwx") [[ -r "$file_path" && -w "$file_path" && -x "$file_path" ]] || { log_error "No full permission: $file_path" "VALIDATION"; return 1; } ;;
  esac
  
  return 0
}

# Safe command execution
safe_execute() {
  local command="$1"
  local timeout_duration="${2:-30}"
  local allowed_commands="${3:-python3,swift,dart,git,npm,pip,pip3}"
  
  # Sanitize command
  local sanitized_command="$(sanitize_input "$command" "command")"
  local base_command="$(echo "$sanitized_command" | awk '{print $1}')"
  
  # Check if command is in allowed list
  if [[ ",$allowed_commands," != *",$base_command,"* ]]; then
    log_error "Command not allowed: $base_command" "SECURITY"
    return 1
  fi
  
  # Execute with timeout
  log_debug "Executing safe command: $sanitized_command" "SECURITY"
  timeout "$timeout_duration" bash -c "$sanitized_command"
  local exit_code=$?
  
  if [[ $exit_code -eq 124 ]]; then
    log_error "Command timed out after ${timeout_duration}s: $base_command" "SECURITY"
    return 124
  fi
  
  return $exit_code
}

# Validate project title
validate_project_title() {
  local title="$1"
  
  if [[ -z "$title" ]]; then
    log_error "Project title cannot be empty" "VALIDATION"
    return 1
  fi
  
  if [[ ${#title} -lt 3 ]]; then
    log_error "Project title too short (minimum 3 characters)" "VALIDATION"
    return 1
  fi
  
  if [[ ${#title} -gt 100 ]]; then
    log_error "Project title too long (maximum 100 characters)" "VALIDATION"
    return 1
  fi
  
  # Check for potentially problematic characters
  if [[ "$title" =~ [^a-zA-Z0-9\ \-\_\.] ]]; then
    log_warn "Project title contains special characters, will be sanitized" "VALIDATION"
  fi
  
  return 0
}

# Validate directory structure
validate_directory_structure() {
  local base_dir="$1"
  
  # Check if base directory exists and is writable
  if [[ ! -d "$base_dir" ]]; then
    log_error "Base directory does not exist: $base_dir" "VALIDATION"
    return 1
  fi
  
  if ! validate_file_permissions "$base_dir" "w"; then
    return 1
  fi
  
  # Check required subdirectories
  local required_dirs=("core" "templates" "workspace" "config")
  
  for dir in "${required_dirs[@]}"; do
    local full_path="$base_dir/$dir"
    if [[ ! -d "$full_path" ]]; then
      log_warn "Creating missing directory: $full_path" "VALIDATION"
      mkdir -p "$full_path" || {
        log_error "Failed to create directory: $full_path" "VALIDATION"
        return 1
      }
    fi
  done
  
  log_info "Directory structure validated" "VALIDATION"
  return 0
}

# Validate JSON format
validate_json() {
  local json_file="$1"
  
  if [[ ! -f "$json_file" ]]; then
    log_error "JSON file not found: $json_file" "VALIDATION"
    return 1
  fi
  
  if command -v jq >/dev/null 2>&1; then
    if jq empty "$json_file" 2>/dev/null; then
      log_debug "JSON validation passed: $json_file" "VALIDATION"
      return 0
    else
      log_error "Invalid JSON format: $json_file" "VALIDATION"
      return 1
    fi
  elif command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
      log_debug "JSON validation passed: $json_file" "VALIDATION"
      return 0
    else
      log_error "Invalid JSON format: $json_file" "VALIDATION"
      return 1
    fi
  else
    log_warn "No JSON validator available, skipping validation" "VALIDATION"
    return 0
  fi
}

# System health check
system_health_check() {
  local issues=0
  
  echo "🏥 DNS System Health Check"
  echo "========================="
  
  # Check dependencies
  echo "Checking dependencies..."
  if ! validate_dependencies; then
    ((issues++))
  fi
  
  # Check directory structure
  echo "Checking directory structure..."
  if ! validate_directory_structure "$SYSTEM_DIR"; then
    ((issues++))
  fi
  
  # Check disk space
  echo "Checking disk space..."
  local available_space=$(df "$SYSTEM_DIR" | awk 'NR==2 {print $4}')
  if [[ $available_space -lt 100000 ]]; then  # Less than ~100MB
    log_warn "Low disk space available: ${available_space}KB" "HEALTH"
    ((issues++))
  fi
  
  # Check log file size
  echo "Checking log files..."
  if [[ -f "$LOG_FILE" ]]; then
    local log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    if [[ $log_size -gt $((MAX_LOG_SIZE * 2)) ]]; then
      log_warn "Log file is very large: ${log_size} bytes" "HEALTH"
      ((issues++))
    fi
  fi
  
  # Summary
  echo ""
  if [[ $issues -eq 0 ]]; then
    echo "✅ System health check passed - no issues found"
    return 0
  else
    echo "⚠️  System health check found $issues issues"
    return 1
  fi
}

# Auto-fix common issues
auto_fix_issues() {
  local fixes_applied=0
  
  echo "🔧 Auto-fixing common issues..."
  
  # Fix directory permissions
  if [[ -d "$SYSTEM_DIR" ]]; then
    find "$SYSTEM_DIR" -type d -exec chmod 755 {} \; 2>/dev/null && {
      log_info "Fixed directory permissions" "AUTO_FIX"
      ((fixes_applied++))
    }
  fi
  
  # Fix file permissions for scripts
  find "$SYSTEM_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null && {
    log_info "Fixed script permissions" "AUTO_FIX"
    ((fixes_applied++))
  }
  
  # Clean up old log files if too large
  if [[ -f "$LOG_FILE" ]]; then
    local log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    if [[ $log_size -gt $((MAX_LOG_SIZE * 3)) ]]; then
      mv "$LOG_FILE" "${LOG_FILE}.old"
      log_info "Rotated large log file" "AUTO_FIX"
      ((fixes_applied++))
    fi
  fi
  
  # Create missing directories
  local required_dirs=("$WORKSPACE_DIR/cache" "$WORKSPACE_DIR/analysis" "$WORKSPACE_DIR/todos")
  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir" && {
        log_info "Created missing directory: $dir" "AUTO_FIX"
        ((fixes_applied++))
      }
    fi
  done
  
  echo "Applied $fixes_applied automatic fixes"
  return 0
}

# Export functions
export -f sanitize_input
export -f validate_dependencies
export -f validate_file_permissions
export -f safe_execute
export -f validate_project_title
export -f validate_directory_structure
export -f validate_json
export -f system_health_check
export -f auto_fix_issues
