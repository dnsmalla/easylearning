#!/usr/bin/env bash
# DNS System - Error Detection and Auto-Correction
# Detects syntax errors, runtime issues, and suggests fixes

# Check if required tools are available
check_language_tools() {
  local language="$1"
  
  case "$language" in
    "python")
      if command -v python3 >/dev/null 2>&1; then
        echo "python3"
        return 0
      elif command -v python >/dev/null 2>&1; then
        echo "python"
        return 0
      else
        echo "❌ Python not found. Please install Python 3.x"
        return 1
      fi
      ;;
    "swift")
      if command -v swift >/dev/null 2>&1; then
        echo "swift"
        return 0
      else
        echo "❌ Swift not found. Please install Swift toolchain"
        return 1
      fi
      ;;
    "flutter")
      if command -v dart >/dev/null 2>&1; then
        echo "dart"
        return 0
      else
        echo "❌ Dart not found. Please install Flutter/Dart SDK"
        return 1
      fi
      ;;
    *)
      echo "❌ Unsupported language: $language"
      return 1
      ;;
  esac
}

# Detect syntax errors in generated code
detect_syntax_errors() {
  local file_path="$1"
  local language="$2"
  local temp_error_file="/tmp/dns_error_check.txt"
  
  echo "🔍 Checking syntax for $language file: $(basename "$file_path")"
  
  case "$language" in
    "python")
      local python_cmd="$(check_language_tools python)"
      [[ $? -ne 0 ]] && return 1
      
      # Check syntax using Python's compile
      if $python_cmd -m py_compile "$file_path" 2>"$temp_error_file"; then
        echo "✅ Python syntax is valid"
        return 0
      else
        echo "❌ Python syntax errors found:"
        cat "$temp_error_file"
        return 1
      fi
      ;;
      
    "swift")
      # Check Swift syntax
      if swift -frontend -parse "$file_path" 2>"$temp_error_file" >/dev/null; then
        echo "✅ Swift syntax is valid"
        return 0
      else
        echo "❌ Swift syntax errors found:"
        cat "$temp_error_file"
        return 1
      fi
      ;;
      
    "flutter")
      # Check Dart syntax
      if dart analyze "$file_path" 2>"$temp_error_file" >/dev/null; then
        echo "✅ Dart syntax is valid"
        return 0
      else
        echo "❌ Dart syntax errors found:"
        cat "$temp_error_file"
        return 1
      fi
      ;;
      
    *)
      echo "❌ Cannot check syntax for unsupported language: $language"
      return 1
      ;;
  esac
}

# Try to run the generated code and detect runtime errors
detect_runtime_errors() {
  local file_path="$1"
  local language="$2"
  local temp_output_file="/tmp/dns_runtime_check.txt"
  local timeout_duration=10
  
  echo "🏃 Testing runtime execution for: $(basename "$file_path")"
  
  case "$language" in
    "python")
      local python_cmd="$(check_language_tools python)"
      [[ $? -ne 0 ]] && return 1
      
      # Run with timeout to prevent infinite loops
      if timeout "$timeout_duration" $python_cmd "$file_path" >"$temp_output_file" 2>&1; then
        echo "✅ Python code executed successfully"
        echo "📄 Output:"
        head -10 "$temp_output_file"
        return 0
      else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
          echo "⏰ Python execution timed out (${timeout_duration}s)"
        else
          echo "❌ Python runtime errors found:"
          cat "$temp_output_file"
        fi
        return 1
      fi
      ;;
      
    "swift")
      # Compile and run Swift code
      local swift_binary="/tmp/dns_swift_test"
      if swift build -Xswiftc "$file_path" -o "$swift_binary" 2>"$temp_output_file" >/dev/null; then
        if timeout "$timeout_duration" "$swift_binary" >>"$temp_output_file" 2>&1; then
          echo "✅ Swift code executed successfully"
          echo "📄 Output:"
          head -10 "$temp_output_file"
          rm -f "$swift_binary"
          return 0
        else
          echo "❌ Swift runtime errors found:"
          cat "$temp_output_file"
          rm -f "$swift_binary"
          return 1
        fi
      else
        echo "❌ Swift compilation failed:"
        cat "$temp_output_file"
        return 1
      fi
      ;;
      
    "flutter")
      # For Dart, we can run it directly
      if timeout "$timeout_duration" dart run "$file_path" >"$temp_output_file" 2>&1; then
        echo "✅ Dart code executed successfully"
        echo "📄 Output:"
        head -10 "$temp_output_file"
        return 0
      else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
          echo "⏰ Dart execution timed out (${timeout_duration}s)"
        else
          echo "❌ Dart runtime errors found:"
          cat "$temp_output_file"
        fi
        return 1
      fi
      ;;
      
    *)
      echo "❌ Cannot run code for unsupported language: $language"
      return 1
      ;;
  esac
}

# Generate error analysis and suggestions
analyze_errors() {
  local file_path="$1"
  local language="$2"
  local error_log="$3"
  
  echo "🔬 Analyzing errors in: $(basename "$file_path")"
  
  # Common error patterns and fixes
  local suggestions=""
  
  # Python-specific error analysis
  if [[ "$language" == "python" ]]; then
    if grep -q "ImportError\|ModuleNotFoundError" "$error_log"; then
      suggestions+="• Missing imports detected. Add required import statements.\n"
    fi
    if grep -q "IndentationError" "$error_log"; then
      suggestions+="• Indentation errors found. Fix spacing and tabs.\n"
    fi
    if grep -q "SyntaxError" "$error_log"; then
      suggestions+="• Syntax errors detected. Check parentheses, quotes, and colons.\n"
    fi
    if grep -q "NameError" "$error_log"; then
      suggestions+="• Undefined variables found. Check variable names and scope.\n"
    fi
  fi
  
  # Swift-specific error analysis
  if [[ "$language" == "swift" ]]; then
    if grep -q "import" "$error_log"; then
      suggestions+="• Missing import statements. Add required framework imports.\n"
    fi
    if grep -q "undeclared" "$error_log"; then
      suggestions+="• Undeclared identifiers found. Check variable and function names.\n"
    fi
  fi
  
  # Dart-specific error analysis
  if [[ "$language" == "flutter" ]]; then
    if grep -q "import" "$error_log"; then
      suggestions+="• Missing import statements. Add required package imports.\n"
    fi
    if grep -q "undefined" "$error_log"; then
      suggestions+="• Undefined references found. Check class and method names.\n"
    fi
  fi
  
  if [[ -n "$suggestions" ]]; then
    echo "💡 Suggested fixes:"
    echo -e "$suggestions"
  else
    echo "🤔 No specific suggestions available. Manual review needed."
  fi
}

# Main error detection function
check_code_quality() {
  local file_path="$1"
  local language="$2"
  local max_iterations="${3:-3}"
  
  echo "🚀 Starting code quality check for: $(basename "$file_path")"
  echo "Language: $language | Max iterations: $max_iterations"
  echo "=================================================="
  
  local iteration=1
  local syntax_ok=false
  local runtime_ok=false
  
  while [[ $iteration -le $max_iterations ]]; do
    echo ""
    echo "🔄 Iteration $iteration/$max_iterations"
    echo "------------------------"
    
    # Check syntax first
    if detect_syntax_errors "$file_path" "$language"; then
      syntax_ok=true
      
      # If syntax is OK, check runtime
      if detect_runtime_errors "$file_path" "$language"; then
        runtime_ok=true
        echo ""
        echo "🎉 SUCCESS: Code passes all checks!"
        echo "✅ Syntax: Valid"
        echo "✅ Runtime: Working"
        return 0
      else
        echo "⚠️  Syntax OK, but runtime issues detected"
        runtime_ok=false
      fi
    else
      echo "⚠️  Syntax errors detected"
      syntax_ok=false
      runtime_ok=false
    fi
    
    # Generate improvement suggestions
    local error_file="/tmp/dns_error_check.txt"
    if [[ -f "$error_file" ]]; then
      analyze_errors "$file_path" "$language" "$error_file"
    fi
    
    ((iteration++))
    
    if [[ $iteration -le $max_iterations ]]; then
      echo ""
      echo "🔧 Preparing for next iteration..."
      echo "💡 Manual fixes needed, or use AI-assisted correction"
    fi
  done
  
  echo ""
  echo "❌ FAILED: Code still has issues after $max_iterations iterations"
  echo "Status: Syntax=$syntax_ok | Runtime=$runtime_ok"
  return 1
}

# Export functions for use in other scripts
export -f check_language_tools
export -f detect_syntax_errors  
export -f detect_runtime_errors
export -f analyze_errors
export -f check_code_quality
