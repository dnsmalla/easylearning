#!/usr/bin/env bash
# DNS System - Advanced Refactoring Engine
# Comprehensive code refactoring with LLM assistance

# Refactoring configuration
REFACTOR_DIR="$WORKSPACE_DIR/refactor"
REFACTOR_BACKUP_DIR="$REFACTOR_DIR/backups"
REFACTOR_REPORTS_DIR="$REFACTOR_DIR/reports"

# Initialize refactoring system
init_refactoring() {
  mkdir -p "$REFACTOR_DIR" "$REFACTOR_BACKUP_DIR" "$REFACTOR_REPORTS_DIR"
  log_info "Refactoring system initialized" "REFACTOR"
}

# Create backup before refactoring
create_refactor_backup() {
  local file_path="$1"
  local backup_name="$(basename "$file_path")_$(date +%Y%m%d_%H%M%S).backup"
  local backup_path="$REFACTOR_BACKUP_DIR/$backup_name"
  
  cp "$file_path" "$backup_path"
  log_info "Created refactor backup: $backup_path" "REFACTOR"
  echo "$backup_path"
}

# Restore from backup
restore_from_backup() {
  local backup_path="$1"
  local original_path="$2"
  
  if [[ -f "$backup_path" ]]; then
    cp "$backup_path" "$original_path"
    log_info "Restored from backup: $backup_path" "REFACTOR"
    return 0
  else
    log_error "Backup not found: $backup_path" "REFACTOR"
    return 1
  fi
}

# Rename variables/functions across files
refactor_rename() {
  local target_path="$1"
  local old_name="$2"
  local new_name="$3"
  local scope="${4:-file}"  # file, directory, project
  
  log_process_start "Refactor Rename" "Renaming '$old_name' to '$new_name' in $scope"
  
  # Validate inputs
  if ! validate_project_title "$old_name" || ! validate_project_title "$new_name"; then
    log_error "Invalid names for refactoring" "REFACTOR"
    return 1
  fi
  
  local files_to_process=()
  
  case "$scope" in
    "file")
      if [[ -f "$target_path" ]]; then
        files_to_process=("$target_path")
      else
        log_error "File not found: $target_path" "REFACTOR"
        return 1
      fi
      ;;
    "directory")
      if [[ -d "$target_path" ]]; then
        mapfile -t files_to_process < <(find "$target_path" -type f \( -name "*.py" -o -name "*.swift" -o -name "*.dart" -o -name "*.js" -o -name "*.ts" \))
      else
        log_error "Directory not found: $target_path" "REFACTOR"
        return 1
      fi
      ;;
    "project")
      mapfile -t files_to_process < <(find "$(pwd)" -type f \( -name "*.py" -o -name "*.swift" -o -name "*.dart" -o -name "*.js" -o -name "*.ts" \) -not -path "*/.dns_system/*" -not -path "*/node_modules/*" -not -path "*/.git/*")
      ;;
  esac
  
  local files_changed=0
  local total_replacements=0
  
  for file in "${files_to_process[@]}"; do
    if [[ -f "$file" ]]; then
      # Create backup
      local backup_path=$(create_refactor_backup "$file")
      
      # Count occurrences before replacement
      local before_count=$(grep -c "$old_name" "$file" 2>/dev/null || echo "0")
      
      if [[ $before_count -gt 0 ]]; then
        # Perform replacement with word boundaries to avoid partial matches
        if sed -i '' "s/\b$old_name\b/$new_name/g" "$file" 2>/dev/null; then
          echo "Replacement completed"
          
          # Count after replacement - simplified approach
          local replacements=$before_count
          
          if [[ $replacements -gt 0 ]]; then
            ((files_changed++))
            total_replacements=$((total_replacements + replacements))
            log_info "Renamed $replacements occurrences in $(basename "$file")" "REFACTOR"
          fi
        else
          log_error "Failed to process file: $file" "REFACTOR"
          restore_from_backup "$backup_path" "$file"
        fi
      fi
    fi
  done
  
  log_process_end "Refactor Rename" "SUCCESS" "Changed $files_changed files, $total_replacements replacements"
  
  # Generate refactor report
  generate_refactor_report "rename" "$old_name -> $new_name" "$files_changed" "$total_replacements" "${files_to_process[@]}"
  
  return 0
}

# Extract method/function refactoring
refactor_extract_method() {
  local file_path="$1"
  local start_line="$2"
  local end_line="$3"
  local method_name="$4"
  local language="${5:-python}"
  
  log_process_start "Extract Method" "Extracting lines $start_line-$end_line as '$method_name'"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "File not found: $file_path" "REFACTOR"
    return 1
  fi
  
  # Create backup
  local backup_path=$(create_refactor_backup "$file_path")
  
  # Extract the code block
  local extracted_code=$(sed -n "${start_line},${end_line}p" "$file_path")
  
  if [[ -z "$extracted_code" ]]; then
    log_error "No code found in specified lines" "REFACTOR"
    return 1
  fi
  
  # Generate method based on language
  local method_definition=""
  case "$language" in
    "python")
      method_definition="    def $method_name(self):
        \"\"\"Extracted method: $method_name\"\"\"
$extracted_code
        pass"
      ;;
    "swift")
      method_definition="    func $method_name() {
        // Extracted method: $method_name
$extracted_code
    }"
      ;;
    "dart")
      method_definition="  void $method_name() {
    // Extracted method: $method_name
$extracted_code
  }"
      ;;
    *)
      method_definition="    function $method_name() {
        // Extracted method: $method_name
$extracted_code
    }"
      ;;
  esac
  
  # Create temporary file with the refactored code
  local temp_file="${file_path}.refactor.tmp"
  
  # Add the new method before the class closing
  if [[ "$language" == "python" ]]; then
    # Find the last method in the class and add after it
    awk -v method="$method_definition" -v start="$start_line" -v end="$end_line" -v call="        self.$method_name()" '
    NR < start || NR > end {
      if (NR == start) print call
      else print
    }
    END {
      print ""
      print method
    }' "$file_path" > "$temp_file"
  else
    # Similar logic for other languages
    awk -v method="$method_definition" -v start="$start_line" -v end="$end_line" -v call="        $method_name();" '
    NR < start || NR > end {
      if (NR == start) print call
      else print
    }
    END {
      print ""
      print method
    }' "$file_path" > "$temp_file"
  fi
  
  # Replace original file
  mv "$temp_file" "$file_path"
  
  log_process_end "Extract Method" "SUCCESS" "Extracted method '$method_name'"
  
  # Generate refactor report
  generate_refactor_report "extract_method" "$method_name" "1" "1" "$file_path"
  
  return 0
}

# Inline method/function refactoring
refactor_inline_method() {
  local file_path="$1"
  local method_name="$2"
  local language="${3:-python}"
  
  log_process_start "Inline Method" "Inlining method '$method_name'"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "File not found: $file_path" "REFACTOR"
    return 1
  fi
  
  # Create backup
  local backup_path=$(create_refactor_backup "$file_path")
  
  # Find method definition and calls
  local method_start_line method_end_line
  case "$language" in
    "python")
      method_start_line=$(grep -n "def $method_name(" "$file_path" | cut -d: -f1)
      ;;
    "swift")
      method_start_line=$(grep -n "func $method_name(" "$file_path" | cut -d: -f1)
      ;;
    "dart")
      method_start_line=$(grep -n "void $method_name(" "$file_path" | cut -d: -f1)
      ;;
  esac
  
  if [[ -z "$method_start_line" ]]; then
    log_error "Method '$method_name' not found" "REFACTOR"
    return 1
  fi
  
  log_info "Found method at line $method_start_line, inlining..." "REFACTOR"
  
  # This is a simplified implementation - in practice, you'd need more sophisticated parsing
  log_warn "Inline method refactoring requires manual review" "REFACTOR"
  
  log_process_end "Inline Method" "PARTIAL" "Method found, manual review needed"
  
  return 0
}

# Move method between classes
refactor_move_method() {
  local source_file="$1"
  local target_file="$2"
  local method_name="$3"
  local language="${4:-python}"
  
  log_process_start "Move Method" "Moving '$method_name' from $(basename "$source_file") to $(basename "$target_file")"
  
  if [[ ! -f "$source_file" ]] || [[ ! -f "$target_file" ]]; then
    log_error "Source or target file not found" "REFACTOR"
    return 1
  fi
  
  # Create backups
  local source_backup=$(create_refactor_backup "$source_file")
  local target_backup=$(create_refactor_backup "$target_file")
  
  # Extract method from source
  local method_definition
  case "$language" in
    "python")
      method_definition=$(awk "/def $method_name\(/,/^    def |^class |^$/" "$source_file")
      ;;
    "swift")
      method_definition=$(awk "/func $method_name\(/,/^    func |^class |^}$/" "$source_file")
      ;;
  esac
  
  if [[ -z "$method_definition" ]]; then
    log_error "Method '$method_name' not found in source file" "REFACTOR"
    return 1
  fi
  
  # Add to target file (simplified - would need proper class detection)
  echo "" >> "$target_file"
  echo "$method_definition" >> "$target_file"
  
  # Remove from source file (simplified)
  case "$language" in
    "python")
      sed -i "/def $method_name(/,/^    def \|^class \|^$/d" "$source_file"
      ;;
  esac
  
  log_process_end "Move Method" "SUCCESS" "Method moved successfully"
  
  # Generate refactor report
  generate_refactor_report "move_method" "$method_name" "2" "1" "$source_file" "$target_file"
  
  return 0
}

# Generate comprehensive refactoring with LLM
refactor_with_llm() {
  local file_path="$1"
  local refactor_type="${2:-comprehensive}"  # comprehensive, performance, readability, structure
  local target_language="${3:-same}"
  
  log_process_start "LLM Refactoring" "File: $(basename "$file_path"), Type: $refactor_type"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "File not found: $file_path" "REFACTOR"
    return 1
  fi
  
  # Create backup
  local backup_path=$(create_refactor_backup "$file_path")
  
  # Detect current language
  local current_language="python"
  case "$file_path" in
    *.py) current_language="python" ;;
    *.swift) current_language="swift" ;;
    *.dart) current_language="flutter" ;;
    *.js|*.ts) current_language="javascript" ;;
  esac
  
  local refactor_prompt="$REFACTOR_REPORTS_DIR/refactor_prompt_$(basename "$file_path" | sed 's/\.[^.]*$//').md"
  local refactor_result="$REFACTOR_REPORTS_DIR/refactored_$(basename "$file_path")"
  
  # Generate refactoring prompt
  cat > "$refactor_prompt" << EOF
# 🔧 Advanced Code Refactoring Request

## File to Refactor
**File**: \`$(basename "$file_path")\`
**Language**: $current_language
**Target Language**: $target_language
**Refactoring Type**: $refactor_type

## Current Code
\`\`\`$(get_file_extension_for_highlight "$current_language")
$(cat "$file_path")
\`\`\`

## Refactoring Requirements

### 1. **Code Analysis**
Analyze the current code for:
- Code smells and anti-patterns
- Performance bottlenecks
- Readability issues
- Structural problems
- Maintainability concerns
- Security vulnerabilities

### 2. **Refactoring Focus**
$(get_refactoring_focus "$refactor_type")

### 3. **Language-Specific Improvements**
Apply standards from: \`.dns_system/.cursor/rules/$current_language.mdc\`
- Follow naming conventions
- Use proper code structure
- Apply language-specific best practices
- Implement proper error handling
- Add appropriate documentation

### 4. **Output Requirements**

#### A. Refactored Code
Provide the complete refactored code with:
- All improvements implemented
- Comprehensive comments explaining changes
- Proper documentation
- Enhanced error handling
- Performance optimizations
- Modern language features

#### B. Refactoring Report
Create a detailed report including:
- **Issues Found**: List all problems identified
- **Refactoring Applied**: Detailed explanation of each change
- **Performance Impact**: Expected performance improvements
- **Readability Improvements**: How code clarity was enhanced
- **Structural Changes**: Architecture and design improvements
- **Best Practices Applied**: Standards and practices implemented
- **Testing Recommendations**: How to test the refactored code
- **Migration Guide**: Steps to safely apply changes

## Refactoring Categories

### Performance Refactoring
- Algorithm optimization
- Memory usage improvements
- Caching strategies
- Lazy loading implementation
- Resource management

### Readability Refactoring
- Variable and function naming
- Code organization
- Comment improvements
- Documentation enhancement
- Complexity reduction

### Structural Refactoring
- Design pattern implementation
- Class and method extraction
- Interface segregation
- Dependency injection
- Modular architecture

### Security Refactoring
- Input validation
- Error handling
- Data sanitization
- Authentication improvements
- Authorization enhancements

## Output Files
1. **Refactored Code**: Save to \`$refactor_result\`
2. **Refactoring Report**: Save to \`${refactor_result%.py}_report.md\`

## Quality Assurance
- Ensure all functionality is preserved
- Add comprehensive error handling
- Include proper logging
- Maintain backward compatibility where possible
- Follow SOLID principles
EOF

  log_ai_interaction "REFACTOR_PROMPT_GENERATED" "Prompt: $refactor_prompt"
  
  echo ""
  echo "🔧 LLM CODE REFACTORING NEEDED"
  echo "==============================="
  echo "📁 Prompt file: $refactor_prompt"
  echo "💾 Refactored code: $refactor_result"
  echo "📊 Report file: ${refactor_result%.py}_report.md"
  echo ""
  echo "🤖 NEXT STEPS:"
  echo "1. Open the prompt file above"
  echo "2. Ask Cursor AI to refactor the code"
  echo "3. Save refactored code to: $refactor_result"
  echo "4. Save refactoring report to: ${refactor_result%.py}_report.md"
  echo "5. Review and apply the refactoring"
  echo ""
  echo "💡 Quick command:"
  echo "   Ask Cursor AI: 'Refactor the code following the prompt in $refactor_prompt'"
  echo ""
  
  log_process_end "LLM Refactoring" "PENDING" "Waiting for LLM refactoring"
  return 2  # Indicates manual LLM interaction needed
}

# Get refactoring focus description
get_refactoring_focus() {
  local refactor_type="$1"
  
  case "$refactor_type" in
    "performance")
      echo "Focus on PERFORMANCE refactoring:
- Algorithm efficiency improvements
- Memory usage optimization
- Execution speed enhancements
- Resource utilization improvements
- Caching and lazy loading strategies
- Database query optimization
- Asynchronous processing implementation"
      ;;
    "readability")
      echo "Focus on READABILITY refactoring:
- Variable and function naming improvements
- Code organization and structure
- Comment and documentation enhancement
- Complexity reduction and simplification
- Consistent coding style application
- Dead code removal
- Magic number elimination"
      ;;
    "structure")
      echo "Focus on STRUCTURAL refactoring:
- Design pattern implementation
- Class and method extraction/inline
- Interface segregation
- Dependency injection
- Modular architecture improvements
- Separation of concerns
- Single responsibility principle"
      ;;
    "security")
      echo "Focus on SECURITY refactoring:
- Input validation and sanitization
- Error handling without information leakage
- Authentication and authorization improvements
- Data encryption and protection
- SQL injection prevention
- XSS protection
- Secure coding practices"
      ;;
    *)
      echo "Provide COMPREHENSIVE refactoring covering:
- Performance improvements
- Readability enhancements
- Structural optimizations
- Security hardening
- Best practice implementations
- Maintainability improvements
- Modern language feature adoption"
      ;;
  esac
}

# Generate refactoring report
generate_refactor_report() {
  local refactor_type="$1"
  local details="$2"
  local files_changed="$3"
  local total_changes="$4"
  shift 4
  local affected_files=("$@")
  
  local report_file="$REFACTOR_REPORTS_DIR/refactor_report_$(date +%Y%m%d_%H%M%S).md"
  
  cat > "$report_file" << EOF
# Refactoring Report
Generated on: $(date)

## Summary
- **Refactoring Type**: $refactor_type
- **Details**: $details
- **Files Changed**: $files_changed
- **Total Changes**: $total_changes
- **Duration**: $(date)

## Affected Files
$(printf '%s\n' "${affected_files[@]}" | sed 's/^/- /')

## Backup Information
All original files have been backed up to:
\`$REFACTOR_BACKUP_DIR\`

## Restoration
To restore any file from backup:
\`bash .cursorrules refactor restore <backup_file> <original_file>\`

## Validation
Run quality checks on refactored files:
\`bash .cursorrules check <file>\`

## Next Steps
1. Test the refactored code thoroughly
2. Run the test suite to ensure functionality
3. Review the changes for correctness
4. Update documentation if needed
5. Commit the changes to version control
EOF

  log_info "Generated refactoring report: $report_file" "REFACTOR"
  echo "📊 Refactoring report: $report_file"
}

# List available backups
list_refactor_backups() {
  echo "📦 Available Refactor Backups"
  echo "============================="
  
  if [[ -d "$REFACTOR_BACKUP_DIR" ]]; then
    local backups=($(ls -t "$REFACTOR_BACKUP_DIR"/*.backup 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
      echo "No backups found"
      return 1
    fi
    
    for backup in "${backups[@]}"; do
      local backup_name=$(basename "$backup")
      local backup_date=$(stat -f%Sm -t%Y-%m-%d\ %H:%M "$backup" 2>/dev/null || stat -c%y "$backup" 2>/dev/null | cut -d' ' -f1-2)
      local backup_size=$(stat -f%z "$backup" 2>/dev/null || stat -c%s "$backup" 2>/dev/null)
      
      echo "  📄 $backup_name"
      echo "     Date: $backup_date"
      echo "     Size: $backup_size bytes"
      echo "     Path: $backup"
      echo ""
    done
  else
    echo "No backup directory found"
    return 1
  fi
}

# Clean old backups
clean_refactor_backups() {
  local days_to_keep="${1:-7}"  # Keep backups for 7 days by default
  
  echo "🧹 Cleaning refactor backups older than $days_to_keep days..."
  
  if [[ -d "$REFACTOR_BACKUP_DIR" ]]; then
    local deleted_count=0
    
    # Find and delete old backups
    while IFS= read -r -d '' backup_file; do
      rm -f "$backup_file"
      ((deleted_count++))
      log_info "Deleted old backup: $(basename "$backup_file")" "REFACTOR"
    done < <(find "$REFACTOR_BACKUP_DIR" -name "*.backup" -mtime +$days_to_keep -print0 2>/dev/null)
    
    echo "🗑️  Deleted $deleted_count old backup files"
    log_info "Cleaned $deleted_count old refactor backups" "REFACTOR"
  else
    echo "No backup directory found"
  fi
}

# Export functions
export -f init_refactoring
export -f create_refactor_backup
export -f restore_from_backup
export -f refactor_rename
export -f refactor_extract_method
export -f refactor_inline_method
export -f refactor_move_method
export -f refactor_with_llm
export -f get_refactoring_focus
export -f generate_refactor_report
export -f list_refactor_backups
export -f clean_refactor_backups
