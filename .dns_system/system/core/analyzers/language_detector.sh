#!/usr/bin/env bash
# DNS System - Programming Language Detection
# Detects target programming language from project title and context

# Detect programming language from input
detect_language() {
  local input="$1"
  local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]')
  
  # Flutter/Dart keywords (check first as it's more specific)
  if echo "$normalized" | grep -qE "(flutter|dart|widget|stateless|stateful|pubspec|material|cupertino)"; then
    echo "flutter"
    return
  fi
  
  # Swift keywords
  if echo "$normalized" | grep -qE "(swift|ios|xcode|cocoa|swiftui|uikit|foundation)"; then
    echo "swift"
    return
  fi
  
  # Python keywords
  if echo "$normalized" | grep -qE "(python|django|flask|fastapi|pandas|numpy|ml|ai|data science|machine learning|pip|conda)"; then
    echo "python"
    return
  fi
  
  # Default to Python if no specific language detected
  echo "python"
}

# Get file extension for language
get_file_extension() {
  local language="$1"
  
  case "$language" in
    "python") echo "py" ;;
    "swift") echo "swift" ;;
    "flutter") echo "dart" ;;
    *) echo "py" ;;  # Default to Python
  esac
}

# Get language display name
get_language_name() {
  local language="$1"
  
  case "$language" in
    "python") echo "Python" ;;
    "swift") echo "Swift" ;;
    "flutter") echo "Flutter/Dart" ;;
    *) echo "Python" ;;
  esac
}

# Check if language rules exist in .dns_system/.cursor/rules
has_language_rules() {
  local language="$1"
  local root_dir="${2:-$(pwd)}"
  local rules_file="$root_dir/.dns_system/system/.cursor/rules/${language}.mdc"
  
  [[ -f "$rules_file" ]]
}

# Get language rules file path
get_language_rules_path() {
  local language="$1"
  local root_dir="${2:-$(pwd)}"
  
  echo "$root_dir/.dns_system/system/.cursor/rules/${language}.mdc"
}
