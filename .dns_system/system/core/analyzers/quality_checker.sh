#!/usr/bin/env bash
# DNS System - Quality Assurance Checker
# Comprehensive quality validation for generated code

# Quality check configuration
QA_STRICT_MODE="${DNS_QA_STRICT:-true}"
QA_AUTO_FIX="${DNS_QA_AUTO_FIX:-false}"
QA_REPORT_DIR="${WORKSPACE_DIR}/qa_reports"

# Main quality assurance function
run_comprehensive_qa() {
  local file_path="$1"
  local language="$2"
  local project_type="$3"
  
  log_process_start "Quality Assurance Check" "File: $(basename "$file_path")"
  
  mkdir -p "$QA_REPORT_DIR"
  local report_file="$QA_REPORT_DIR/qa_report_$(basename "$file_path" | sed 's/\.[^.]*$//').md"
  
  # Initialize QA report
  init_qa_report "$report_file" "$file_path" "$language" "$project_type"
  
  local total_issues=0
  local critical_issues=0
  
  # Run all quality checks
  log_step "Running critical issue checks" "IN_PROGRESS"
  critical_issues=$(check_critical_issues "$file_path" "$language" "$report_file")
  log_step "Running critical issue checks" "SUCCESS" "Found: $critical_issues critical issues"
  
  log_step "Running code quality checks" "IN_PROGRESS"
  local quality_issues=$(check_code_quality "$file_path" "$language" "$report_file")
  log_step "Running code quality checks" "SUCCESS" "Found: $quality_issues quality issues"
  
  log_step "Running language-specific checks" "IN_PROGRESS"
  local language_issues=$(check_language_specific "$file_path" "$language" "$report_file")
  log_step "Running language-specific checks" "SUCCESS" "Found: $language_issues language issues"
  
  log_step "Running business logic validation" "IN_PROGRESS"
  local logic_issues=$(check_business_logic "$file_path" "$project_type" "$report_file")
  log_step "Running business logic validation" "SUCCESS" "Found: $logic_issues logic issues"
  
  total_issues=$((critical_issues + quality_issues + language_issues + logic_issues))
  
  # Generate final report
  finalize_qa_report "$report_file" "$total_issues" "$critical_issues"
  
  log_process_end "Quality Assurance Check" "SUCCESS" "Report: $report_file"
  
  # Return status based on issues found
  if [[ $critical_issues -gt 0 ]]; then
    log_error "Critical issues found - code needs immediate fixes" "QA_CHECKER"
    return 2  # Critical issues
  elif [[ $total_issues -gt 0 ]]; then
    log_warning "Quality issues found - improvements recommended" "QA_CHECKER"
    return 1  # Non-critical issues
  else
    log_info "Quality check passed - no issues found" "QA_CHECKER"
    return 0  # All good
  fi
}

# Initialize QA report
init_qa_report() {
  local report_file="$1"
  local file_path="$2"
  local language="$3"
  local project_type="$4"
  
  cat > "$report_file" << EOF
# 🔍 Quality Assurance Report

**File**: \`$(basename "$file_path")\`  
**Language**: $language  
**Project Type**: $project_type  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')  
**Location**: \`$file_path\`

---

## 📊 Summary

| Category | Status | Issues Found |
|----------|--------|--------------|
| Critical Issues | 🔄 | Checking... |
| Code Quality | 🔄 | Checking... |
| Language Specific | 🔄 | Checking... |
| Business Logic | 🔄 | Checking... |

---

## 🚨 Critical Issues

EOF
}

# Check for critical issues
check_critical_issues() {
  local file_path="$1"
  local language="$2"
  local report_file="$3"
  local issues_found=0
  
  echo "### Template Placeholders" >> "$report_file"
  
  # Check for empty template placeholders
  if grep -q '"type": ""' "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Empty type placeholder found" >> "$report_file"
    echo "- Line: \`$(grep -n '"type": ""' "$file_path" | head -1)\`" >> "$report_file"
    echo "- Fix: Replace with specific project type" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  if grep -q '"Project type: "' "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Empty project type placeholder found" >> "$report_file"
    echo "- Fix: Provide detailed project description" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  if grep -q '"Features: - "' "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Empty features placeholder found" >> "$report_file"
    echo "- Fix: List specific project features" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  echo "### Dead Conditional Logic" >> "$report_file"
  
  # Check for unreachable conditionals
  if grep -q 'if.*"".*==' "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Unreachable conditional logic found" >> "$report_file"
    local dead_lines=$(grep -n 'if.*"".*==' "$file_path" | head -3)
    echo "\`\`\`" >> "$report_file"
    echo "$dead_lines" >> "$report_file"
    echo "\`\`\`" >> "$report_file"
    echo "- Fix: Use variables instead of empty strings in conditionals" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  echo "### Missing Imports" >> "$report_file"
  
  # Language-specific import checks
  case "$language" in
    "python")
      check_python_imports "$file_path" "$report_file" && ((issues_found++))
      ;;
    "swift")
      check_swift_imports "$file_path" "$report_file" && ((issues_found++))
      ;;
    "dart")
      check_dart_imports "$file_path" "$report_file" && ((issues_found++))
      ;;
  esac
  
  if [[ $issues_found -eq 0 ]]; then
    echo "✅ No critical issues found" >> "$report_file"
  fi
  
  echo "" >> "$report_file"
  echo "---" >> "$report_file"
  echo "" >> "$report_file"
  
  echo $issues_found
}

# Check Python imports
check_python_imports() {
  local file_path="$1"
  local report_file="$2"
  local issues=0
  
  if ! grep -q "from __future__ import annotations" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Missing \`from __future__ import annotations\`" >> "$report_file"
    ((issues++))
  fi
  
  if ! grep -q "import logging" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Missing \`import logging\`" >> "$report_file"
    ((issues++))
  fi
  
  if grep -q "datetime" "$file_path" && ! grep -q "from datetime import" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Using datetime without import" >> "$report_file"
    ((issues++))
  fi
  
  if grep -q ": Optional\|: Dict\|: List" "$file_path" && ! grep -q "from typing import" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Using typing without import" >> "$report_file"
    ((issues++))
  fi
  
  return $issues
}

# Check Swift imports
check_swift_imports() {
  local file_path="$1"
  local report_file="$2"
  local issues=0
  
  if ! grep -q "import Foundation" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Missing \`import Foundation\`" >> "$report_file"
    ((issues++))
  fi
  
  if grep -q "Logger" "$file_path" && ! grep -q "import os.log" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Using Logger without \`import os.log\`" >> "$report_file"
    ((issues++))
  fi
  
  return $issues
}

# Check Dart imports
check_dart_imports() {
  local file_path="$1"
  local report_file="$2"
  local issues=0
  
  if grep -q "developer.log" "$file_path" && ! grep -q "import 'dart:developer'" "$file_path" 2>/dev/null; then
    echo "🔴 **CRITICAL**: Using developer.log without import" >> "$report_file"
    ((issues++))
  fi
  
  return $issues
}

# Check code quality
check_code_quality() {
  local file_path="$1"
  local language="$2"
  local report_file="$3"
  local issues_found=0
  
  echo "## 🟡 Code Quality Issues" >> "$report_file"
  echo "" >> "$report_file"
  
  # Check for long methods
  case "$language" in
    "python")
      local long_methods=$(grep -n "def " "$file_path" | while read -r line; do
        local line_num=$(echo "$line" | cut -d: -f1)
        local method_name=$(echo "$line" | cut -d: -f2- | sed 's/def \([^(]*\).*/\1/')
        local next_def=$(tail -n +$((line_num + 1)) "$file_path" | grep -n "^def \|^class " | head -1 | cut -d: -f1)
        local method_length
        if [[ -n "$next_def" ]]; then
          method_length=$((next_def - 1))
        else
          method_length=$(tail -n +$line_num "$file_path" | wc -l)
        fi
        if [[ $method_length -gt 30 ]]; then
          echo "Method '$method_name' at line $line_num: $method_length lines"
        fi
      done)
      
      if [[ -n "$long_methods" ]]; then
        echo "### Long Methods (>30 lines)" >> "$report_file"
        echo "🟡 **WARNING**: Methods should be broken down for maintainability" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        echo "$long_methods" >> "$report_file"
        echo "\`\`\`" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
  esac
  
  # Check for generic placeholder methods
  if grep -q 'return {"executed": True}' "$file_path" 2>/dev/null; then
    echo "### Generic Placeholder Methods" >> "$report_file"
    echo "🟡 **WARNING**: Generic placeholder methods found" >> "$report_file"
    echo "- Replace with actual business logic implementation" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  # Check for proper error handling
  case "$language" in
    "python")
      if grep -q "except:" "$file_path" 2>/dev/null; then
        echo "### Bare Exception Handling" >> "$report_file"
        echo "🟡 **WARNING**: Bare except clauses found" >> "$report_file"
        echo "- Specify exception types for better error handling" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
  esac
  
  if [[ $issues_found -eq 0 ]]; then
    echo "✅ No significant code quality issues found" >> "$report_file"
    echo "" >> "$report_file"
  fi
  
  echo "---" >> "$report_file"
  echo "" >> "$report_file"
  
  echo $issues_found
}

# Check language-specific issues
check_language_specific() {
  local file_path="$1"
  local language="$2"
  local report_file="$3"
  local issues_found=0
  
  echo "## 🔧 Language-Specific Issues" >> "$report_file"
  echo "" >> "$report_file"
  
  case "$language" in
    "python")
      # Check for type hints
      if grep -q "def " "$file_path" && ! grep -q " -> " "$file_path" 2>/dev/null; then
        echo "### Missing Type Hints" >> "$report_file"
        echo "🟡 **WARNING**: Methods missing return type hints" >> "$report_file"
        echo "- Add return type annotations for better code clarity" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      
      # Check for print statements instead of logging
      if grep -q "print(" "$file_path" 2>/dev/null; then
        echo "### Print Statements" >> "$report_file"
        echo "🟡 **WARNING**: Using print() instead of logging" >> "$report_file"
        echo "- Replace print() with appropriate logging calls" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
      
    "swift")
      # Check for access control
      if grep -q "class " "$file_path" && ! grep -q "private \|public \|internal " "$file_path" 2>/dev/null; then
        echo "### Missing Access Control" >> "$report_file"
        echo "🟡 **WARNING**: Consider adding access control modifiers" >> "$report_file"
        echo "- Add appropriate access levels (private, public, internal)" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
      
    "dart")
      # Check for null safety
      if ! grep -q "?" "$file_path" && ! grep -q "late " "$file_path" 2>/dev/null; then
        echo "### Null Safety" >> "$report_file"
        echo "🟡 **INFO**: Consider null safety patterns" >> "$report_file"
        echo "- Use nullable types (?) where appropriate" >> "$report_file"
        echo "" >> "$report_file"
      fi
      ;;
  esac
  
  if [[ $issues_found -eq 0 ]]; then
    echo "✅ No language-specific issues found" >> "$report_file"
    echo "" >> "$report_file"
  fi
  
  echo "---" >> "$report_file"
  echo "" >> "$report_file"
  
  echo $issues_found
}

# Check business logic implementation
check_business_logic() {
  local file_path="$1"
  local project_type="$2"
  local report_file="$3"
  local issues_found=0
  
  echo "## 💼 Business Logic Validation" >> "$report_file"
  echo "" >> "$report_file"
  
  # Check for empty method bodies
  if grep -A 5 "def.*:$" "$file_path" 2>/dev/null | grep -q "pass$"; then
    echo "### Empty Method Bodies" >> "$report_file"
    echo "🟡 **WARNING**: Methods with 'pass' found" >> "$report_file"
    echo "- Implement actual functionality for these methods" >> "$report_file"
    echo "" >> "$report_file"
    ((issues_found++))
  fi
  
  # Project-type specific validations
  case "$project_type" in
    "ecommerce")
      if ! grep -q "payment\|cart\|order\|product" "$file_path" 2>/dev/null; then
        echo "### E-commerce Logic Missing" >> "$report_file"
        echo "🟡 **WARNING**: No e-commerce specific logic found" >> "$report_file"
        echo "- Consider adding payment, cart, or product management logic" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
      
    "web_api")
      if ! grep -q "endpoint\|route\|request\|response" "$file_path" 2>/dev/null; then
        echo "### API Logic Missing" >> "$report_file"
        echo "🟡 **WARNING**: No API specific logic found" >> "$report_file"
        echo "- Consider adding endpoint, routing, or request handling logic" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
      
    "mobile")
      if ! grep -q "view\|controller\|ui\|screen" "$file_path" 2>/dev/null; then
        echo "### Mobile Logic Missing" >> "$report_file"
        echo "🟡 **WARNING**: No mobile specific logic found" >> "$report_file"
        echo "- Consider adding UI, view, or screen management logic" >> "$report_file"
        echo "" >> "$report_file"
        ((issues_found++))
      fi
      ;;
  esac
  
  if [[ $issues_found -eq 0 ]]; then
    echo "✅ Business logic appears appropriate for project type" >> "$report_file"
    echo "" >> "$report_file"
  fi
  
  echo "---" >> "$report_file"
  echo "" >> "$report_file"
  
  echo $issues_found
}

# Finalize QA report
finalize_qa_report() {
  local report_file="$1"
  local total_issues="$2"
  local critical_issues="$3"
  
  # Update summary table
  sed -i.bak 's/| Critical Issues | 🔄 | Checking... |/| Critical Issues | '"$(get_status_icon "$critical_issues")"' | '"$critical_issues"' |/' "$report_file"
  
  # Add final recommendations
  cat >> "$report_file" << EOF

## 📋 Final Assessment

**Total Issues Found**: $total_issues  
**Critical Issues**: $critical_issues  
**Overall Status**: $(get_overall_status "$total_issues" "$critical_issues")

### Recommendations

$(generate_recommendations "$total_issues" "$critical_issues")

### Next Steps

$(generate_next_steps "$total_issues" "$critical_issues")

---

*Generated by DNS Quality Assurance System*  
*Report Location*: \`$report_file\`
EOF

  # Clean up backup file
  rm -f "${report_file}.bak" 2>/dev/null
}

# Helper functions
get_status_icon() {
  local count="$1"
  if [[ $count -eq 0 ]]; then
    echo "✅"
  elif [[ $count -lt 3 ]]; then
    echo "🟡"
  else
    echo "🔴"
  fi
}

get_overall_status() {
  local total="$1"
  local critical="$2"
  
  if [[ $critical -gt 0 ]]; then
    echo "🔴 **CRITICAL** - Immediate fixes required"
  elif [[ $total -gt 5 ]]; then
    echo "🟡 **NEEDS IMPROVEMENT** - Multiple issues found"
  elif [[ $total -gt 0 ]]; then
    echo "🟡 **GOOD** - Minor improvements recommended"
  else
    echo "✅ **EXCELLENT** - No issues found"
  fi
}

generate_recommendations() {
  local total="$1"
  local critical="$2"
  
  if [[ $critical -gt 0 ]]; then
    echo "1. **Fix critical issues immediately** - Code may not function properly"
    echo "2. Use the auto-corrector: \`.dns_system/system/core/generators/auto_corrector.sh\`"
    echo "3. Review feedback guidelines: \`.dns_system/system/docs/FEEDBACK.md\`"
  elif [[ $total -gt 0 ]]; then
    echo "1. Address quality issues for better maintainability"
    echo "2. Follow language-specific best practices"
    echo "3. Consider implementing suggested improvements"
  else
    echo "1. Code quality is excellent - ready for production"
    echo "2. Consider adding unit tests if not present"
    echo "3. Document any complex business logic"
  fi
}

generate_next_steps() {
  local total="$1"
  local critical="$2"
  
  if [[ $critical -gt 0 ]]; then
    echo "1. **IMMEDIATE**: Fix all critical issues before proceeding"
    echo "2. Re-run quality check after fixes"
    echo "3. Test the corrected code thoroughly"
  elif [[ $total -gt 0 ]]; then
    echo "1. Review and address quality issues"
    echo "2. Optional: Re-run quality check after improvements"
    echo "3. Proceed with testing and deployment"
  else
    echo "1. Code is ready for testing"
    echo "2. Proceed with integration and deployment"
    echo "3. Monitor for any runtime issues"
  fi
}

# Quick quality check function
quick_qa_check() {
  local file_path="$1"
  local language="$2"
  
  log_info "Running quick quality check" "QA_QUICK"
  
  local critical_count=0
  
  # Quick critical checks
  if grep -q '"type": ""' "$file_path" 2>/dev/null; then
    log_error "Empty type placeholder found" "QA_QUICK"
    ((critical_count++))
  fi
  
  if grep -q 'if.*"".*==' "$file_path" 2>/dev/null; then
    log_error "Dead conditional logic found" "QA_QUICK"
    ((critical_count++))
  fi
  
  case "$language" in
    "python")
      if ! grep -q "from __future__ import annotations" "$file_path" 2>/dev/null; then
        log_error "Missing future annotations import" "QA_QUICK"
        ((critical_count++))
      fi
      ;;
    "swift")
      if ! grep -q "import Foundation" "$file_path" 2>/dev/null; then
        log_error "Missing Foundation import" "QA_QUICK"
        ((critical_count++))
      fi
      ;;
  esac
  
  if [[ $critical_count -eq 0 ]]; then
    log_info "Quick quality check passed" "QA_QUICK"
    return 0
  else
    log_error "Quick quality check failed - $critical_count critical issues" "QA_QUICK"
    return 1
  fi
}

# Export functions for use in other scripts
export -f run_comprehensive_qa
export -f quick_qa_check
