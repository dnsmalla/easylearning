#!/usr/bin/env bash
# DNS System - Project Type Detection
# Intelligently detects project type from input

# Dynamic keyword detection - no hardcoded patterns
detect_project_type() {
  local input="$1"
  local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]')
  
  # Web/API keywords
  if echo "$normalized" | grep -qE "(web|api|rest|http|server|client|service|endpoint)"; then
    echo "web_api"
    return
  fi
  
  # Database keywords
  if echo "$normalized" | grep -qE "(database|db|storage|crud|sql|data|model)"; then
    echo "database"
    return
  fi
  
  # File operations keywords
  if echo "$normalized" | grep -qE "(copy|file|directory|folder|backup|sync|transfer)"; then
    echo "file_ops"
    return
  fi
  
  # Processing keywords
  if echo "$normalized" | grep -qE "(process|parse|transform|convert|analyze|extract)"; then
    echo "processing"
    return
  fi
  
  # Management keywords
  if echo "$normalized" | grep -qE "(manage|control|admin|monitor|track|organize)"; then
    echo "management"
    return
  fi
  
  # Generation keywords
  if echo "$normalized" | grep -qE "(generate|build|create|make|produce|construct)"; then
    echo "generation"
    return
  fi
  
  # E-commerce keywords
  if echo "$normalized" | grep -qE "(shop|store|commerce|cart|payment|order|product)"; then
    echo "ecommerce"
    return
  fi
  
  # Social/Communication keywords
  if echo "$normalized" | grep -qE "(social|chat|message|post|user|friend|follow)"; then
    echo "social"
    return
  fi
  
  # Dashboard/Analytics keywords
  if echo "$normalized" | grep -qE "(dashboard|report|chart|analytics|metric|stats)"; then
    echo "dashboard"
    return
  fi
  
  # Mobile keywords
  if echo "$normalized" | grep -qE "(mobile|ios|android|app|phone|device)"; then
    echo "mobile"
    return
  fi
  
  # Default - suggest awesome-cursorrules for unrecognized patterns
  echo "generic"
}

# Detect complexity level
detect_complexity() {
  local title="$1"
  
  # Determine complexity based on keywords
  if echo "$title" | grep -qiE "(platform|system|framework|enterprise|full|complete)"; then
    echo "heavy"
  elif echo "$title" | grep -qiE "(service|manager|handler|processor)"; then
    echo "medium"
  else
    echo "basic"
  fi
}
