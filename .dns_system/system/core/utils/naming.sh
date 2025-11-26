#!/usr/bin/env bash
# DNS System - Naming Utilities
# Provides consistent naming convention functions

# Convert to snake_case
to_snake() { 
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g'
}

# Convert to PascalCase
to_pascal() { 
  echo "$1" | sed 's/[^a-zA-Z0-9]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | tr -d ' '
}

# Convert to kebab-case
to_kebab() { 
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g'
}

# Convert to camelCase
to_camel() {
  local pascal="$(to_pascal "$1")"
  echo "${pascal:0:1}" | tr '[:upper:]' '[:lower:]'${pascal:1}
}
