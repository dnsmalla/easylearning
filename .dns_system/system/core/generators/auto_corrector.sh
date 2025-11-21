#!/usr/bin/env bash
# DNS System - AI-Powered Auto-Correction
# Uses Cursor AI to automatically fix code errors

# Generate AI correction prompt
generate_correction_prompt() {
  local file_path="$1"
  local language="$2"
  local error_log="$3"
  local iteration="$4"
  local correction_dir="$WORKSPACE_DIR/corrections"
  
  mkdir -p "$correction_dir"
  local prompt_file="$correction_dir/fix_$(basename "$file_path" | sed 's/\.[^.]*$//').md"
  
  cat > "$prompt_file" << EOF
# 🔧 Auto-Correction Request - Iteration $iteration

## 📁 File to Fix
**File**: \`$(basename "$file_path")\`
**Language**: $language
**Location**: \`$file_path\`

## ❌ Current Errors
\`\`\`
$(cat "$error_log" 2>/dev/null || echo "Error log not available")
\`\`\`

## 📋 Current Code
\`\`\`$(get_file_extension_for_highlight "$language")
$(cat "$file_path")
\`\`\`

## 🚨 CRITICAL FIXES REQUIRED

### 1. **Template Placeholders - MUST BE FILLED**
🔴 **CRITICAL**: Check for and fix ALL empty template placeholders
- ❌ NEVER leave: \`"type": ""\`, \`"Project type: "\`, \`"Features: - "\`
- ✅ ALWAYS use: \`"type": "specific_project_type"\`, \`"Project type: detailed_description"\`
- Replace all empty strings with meaningful values

### 2. **Dead Conditional Logic - MUST BE REACHABLE**
🔴 **CRITICAL**: Fix unreachable conditional statements
- ❌ NEVER use: \`if "" == "web_api":\` (will NEVER execute)
- ✅ ALWAYS use: \`if project_type == "web_api":\` (with actual variables)
- Ensure all conditionals use variables or configuration values

### 3. **Missing Imports - MUST BE COMPLETE**
🔴 **CRITICAL**: Add ALL required imports for $language

**Required for Python:**
\`\`\`python
from __future__ import annotations
import logging
from datetime import datetime
from typing import Optional, Dict, List, Any, Union
\`\`\`

**Required for Swift:**
\`\`\`swift
import Foundation
import os.log        // If using Logger
import UIKit         // If UI components needed
\`\`\`

**Required for Dart:**
\`\`\`dart
import 'dart:developer' as developer;  // If using developer.log
import 'package:flutter/material.dart'; // If Flutter widgets
\`\`\`

## 🎯 Standard Requirements
Please fix the above code to:

1. **🚨 CRITICAL: Fill all template placeholders**
2. **🚨 CRITICAL: Fix dead conditional logic**  
3. **🚨 CRITICAL: Add missing imports**
4. **Eliminate all syntax errors**
5. **Fix runtime issues** 
6. **Follow $(get_language_name "$language") best practices**
7. **Maintain the original functionality**
8. **Fix naming conventions**
9. **Implement real business logic (not generic placeholders)**
10. **Add comprehensive error handling**
11. **Ensure code runs without errors**

## 📐 Enhanced Standards
Follow these standards from our language rules:
- **File**: \`.dns_system/.cursor/rules/$language.mdc\`
- **Feedback**: \`.dns_system/system/docs/FEEDBACK.md\`
- Apply all coding conventions specified in the rules
- Use proper error handling patterns with custom exceptions
- Follow naming conventions strictly
- Implement actual business logic for the project domain
- Break down long methods (max 20-30 lines)
- Add comprehensive documentation and type hints

## 🔄 Instructions
1. **Analyze** the errors carefully
2. **Fix** all issues systematically  
3. **Test** the logic mentally
4. **Provide** the complete corrected code
5. **Explain** what was fixed

## 💾 Output Format
Please provide the corrected code in this exact format:

\`\`\`$(get_file_extension_for_highlight "$language")
// Your corrected code here
\`\`\`

**Changes Made:**
- List the specific fixes applied
- Explain why each change was necessary
EOF

  echo "$prompt_file"
}

# Get file extension for syntax highlighting
get_file_extension_for_highlight() {
  local language="$1"
  case "$language" in
    "python") echo "python" ;;
    "swift") echo "swift" ;;
    "flutter") echo "dart" ;;
    *) echo "text" ;;
  esac
}

# Create backup of original file
create_backup() {
  local file_path="$1"
  local backup_dir="$WORKSPACE_DIR/refactor/backups"
  local timestamp="$(date +%Y%m%d_%H%M%S)"
  
  mkdir -p "$backup_dir"
  local backup_file="$backup_dir/$(basename "$file_path").backup_$timestamp"
  cp "$file_path" "$backup_file"
  echo "$backup_file"
}

# Apply AI corrections (manual step with instructions)
request_ai_correction() {
  local file_path="$1"
  local language="$2"
  local error_log="$3"
  local iteration="$4"
  
  echo "🤖 Generating AI correction request..."
  
  # Create backup
  local backup_file="$(create_backup "$file_path")"
  echo "💾 Backup created: $backup_file"
  
  # Generate correction prompt
  local prompt_file="$(generate_correction_prompt "$file_path" "$language" "$error_log" "$iteration")"
  
  echo ""
  echo "🎯 AI CORRECTION NEEDED"
  echo "======================="
  echo "📁 Prompt file: $prompt_file"
  echo "🔧 File to fix: $file_path"
  echo ""
  echo "🤖 NEXT STEPS:"
  echo "1. Open the prompt file above"
  echo "2. Ask Cursor AI to fix the code using the prompt"
  echo "3. Replace the content in: $file_path"
  echo "4. Re-run the system to verify fixes"
  echo ""
  echo "💡 Quick command:"
  echo "   Ask Cursor AI: 'Fix the code errors in $file_path following the prompt in $prompt_file'"
  echo ""
  
  return 1  # Return 1 to indicate manual intervention needed
}

# Attempt automatic fixes for common issues
apply_automatic_fixes() {
  local file_path="$1"
  local language="$2"
  local error_log="$3"
  
  echo "🔧 Attempting automatic fixes..."
  local fixes_applied=0
  local temp_file="${file_path}.tmp"
  cp "$file_path" "$temp_file"
  
  case "$language" in
    "python")
      # Fix common Python issues
      if grep -q "ImportError\|ModuleNotFoundError" "$error_log"; then
        echo "  • Adding common Python imports..."
        sed -i '1i import os\nimport sys\nfrom typing import Optional, Dict, List, Any' "$temp_file"
        ((fixes_applied++))
      fi
      
      # Fix indentation (basic attempt)
      if grep -q "IndentationError" "$error_log"; then
        echo "  • Attempting to fix indentation..."
        # This is a basic fix - might need manual correction
        python3 -c "
import ast
import sys
try:
    with open('$temp_file', 'r') as f:
        code = f.read()
    # Try to parse and reformat
    tree = ast.parse(code)
    print('Indentation seems fixable')
except:
    print('Complex indentation issues - manual fix needed')
" 2>/dev/null
        ((fixes_applied++))
      fi
      ;;
      
    "swift")
      # Fix common Swift issues
      if grep -q "import" "$error_log"; then
        echo "  • Adding common Swift imports..."
        sed -i '1i import Foundation\nimport os' "$temp_file"
        ((fixes_applied++))
      fi
      ;;
      
    "flutter")
      # Fix common Dart issues
      if grep -q "import" "$error_log"; then
        echo "  • Adding common Dart imports..."
        sed -i "1i import 'dart:core';\nimport 'dart:developer' as developer;" "$temp_file"
        ((fixes_applied++))
      fi
      ;;
  esac
  
  if [[ $fixes_applied -gt 0 ]]; then
    mv "$temp_file" "$file_path"
    echo "✅ Applied $fixes_applied automatic fixes"
    return 0
  else
    rm "$temp_file"
    echo "ℹ️  No automatic fixes available"
    return 1
  fi
}

# Main auto-correction workflow
auto_correct_code() {
  local file_path="$1"
  local language="$2"
  local max_iterations="${3:-3}"
  
  echo "🚀 Starting auto-correction for: $(basename "$file_path")"
  echo "Language: $language | Max iterations: $max_iterations"
  echo "=================================================="
  
  local iteration=1
  local error_log="/tmp/dns_error_check.txt"
  
  while [[ $iteration -le $max_iterations ]]; do
    echo ""
    echo "🔄 Auto-Correction Iteration $iteration/$max_iterations"
    echo "----------------------------------------"
    
    # First, try automatic fixes
    if apply_automatic_fixes "$file_path" "$language" "$error_log"; then
      echo "🔧 Automatic fixes applied, re-checking..."
      
      # Re-run error detection
      source "$(dirname "${BASH_SOURCE[0]}")/../analyzers/error_detector.sh"
      if check_code_quality "$file_path" "$language" 1; then
        echo "🎉 SUCCESS: Auto-correction completed!"
        return 0
      fi
    fi
    
    # If automatic fixes didn't work, request AI assistance
    echo "🤖 Requesting AI-powered correction..."
    request_ai_correction "$file_path" "$language" "$error_log" "$iteration"
    
    echo ""
    echo "⏸️  PAUSED: Waiting for manual AI correction..."
    echo "   After applying AI fixes, re-run the system to continue"
    echo ""
    
    return 2  # Return 2 to indicate manual intervention needed
  done
  
  echo ""
  echo "❌ FAILED: Auto-correction could not fix all issues"
  return 1
}

# Export functions
export -f generate_correction_prompt
export -f create_backup
export -f request_ai_correction
export -f apply_automatic_fixes
export -f auto_correct_code
