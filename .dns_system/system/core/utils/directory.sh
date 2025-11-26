#!/usr/bin/env bash
# DNS System - Directory Management
# Smart directory detection and management

# Smart directory detection
detect_output_directory() {
  local custom_dir="${1:-}"
  local root_dir="${2:-$(pwd)}"
  
  # If custom directory is specified, use it
  if [[ -n "$custom_dir" ]]; then
    mkdir -p "$custom_dir"
    echo "$custom_dir"
    return
  fi
  
  # Check for common Python project directories in order of preference
  local common_dirs=("src" "lib" "modules" "code" "python" "app")
  
  for dir in "${common_dirs[@]}"; do
    if [[ -d "$root_dir/$dir" ]]; then
      echo "$root_dir/$dir"
      return
    fi
  done
  
  # Check for any existing directory with Python files
  local existing_py_dirs=$(find "$root_dir" -maxdepth 2 -name "*.py" -type f | head -5 | xargs -I {} dirname {} | sort | uniq | grep -v "^\\.$" | head -1)
  if [[ -n "$existing_py_dirs" && "$existing_py_dirs" != "$root_dir" ]]; then
    echo "$existing_py_dirs"
    return
  fi
  
  # Default: create and use src directory
  mkdir -p "$root_dir/src"
  echo "$root_dir/src"
}

# Get project workspace directory
get_workspace_dir() {
  local project_name="$1"
  local root_dir="${2:-$(pwd)}"
  
  echo "$root_dir/.dns_system/system/workspace/current_project"
}

# Get TODO directory for project
get_todo_dir() {
  local project_name="$1"
  local root_dir="${2:-$(pwd)}"
  
  # Convert to snake_case (inline implementation to avoid sourcing issues)
  local snake_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
  
  # Use .dns_setup/todo for compatibility (as requested by user)
  echo "$root_dir/.dns_system/.dns_setup/todo/$snake_name"
}

# Get analysis directory
get_analysis_dir() {
  local root_dir="${1:-$(pwd)}"
  
  echo "$root_dir/.dns_system/system/workspace/analysis"
}
