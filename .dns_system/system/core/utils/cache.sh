#!/usr/bin/env bash
# DNS System - Intelligent Caching System
# High-performance caching for expensive operations

# Cache configuration
CACHE_DIR="$WORKSPACE_DIR/cache"
CACHE_TTL="${DNS_CACHE_TTL:-3600}"  # 1 hour default
MAX_CACHE_SIZE="${DNS_MAX_CACHE_SIZE:-50}"  # Max 50MB

# Bash version compatibility for associative arrays
if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
  declare -A MEMORY_CACHE
  declare -A CACHE_TIMESTAMPS
else
  # Fallback for older bash versions - disable memory cache
  MEMORY_CACHE_ENABLED=false
fi

# Initialize cache system
init_cache() {
  mkdir -p "$CACHE_DIR"
  
  # Clean up old cache files on startup
  cleanup_expired_cache
  
  log_info "Cache system initialized at: $CACHE_DIR" "CACHE"
}

# Generate cache key from input
generate_cache_key() {
  local input="$1"
  local prefix="${2:-general}"
  
  # Create a hash of the input for the cache key
  local hash=$(echo -n "$input" | shasum -a 256 | cut -d' ' -f1)
  echo "${prefix}_${hash:0:16}"
}

# Check if cache entry is valid
is_cache_valid() {
  local cache_key="$1"
  local cache_file="$CACHE_DIR/$cache_key"
  local current_time=$(date +%s)
  
  if [[ ! -f "$cache_file" ]]; then
    return 1
  fi
  
  # Check file timestamp
  local file_time=$(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0)
  local age=$((current_time - file_time))
  
  if [[ $age -gt $CACHE_TTL ]]; then
    log_debug "Cache expired for key: $cache_key (age: ${age}s)" "CACHE"
    return 1
  fi
  
  return 0
}

# Get cached value
get_cache() {
  local cache_key="$1"
  local use_memory="${2:-true}"
  
  # Try memory cache first (only if bash 4+ and enabled)
  if [[ "$use_memory" == "true" && ${BASH_VERSION%%.*} -ge 4 && -n "${MEMORY_CACHE[$cache_key]:-}" ]]; then
    local cached_time="${CACHE_TIMESTAMPS[$cache_key]}"
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    if [[ $age -le $CACHE_TTL ]]; then
      log_debug "Memory cache hit for key: $cache_key" "CACHE"
      echo "${MEMORY_CACHE[$cache_key]}"
      return 0
    else
      # Remove expired memory cache
      unset MEMORY_CACHE[$cache_key]
      unset CACHE_TIMESTAMPS[$cache_key]
    fi
  fi
  
  # Try file cache
  local cache_file="$CACHE_DIR/$cache_key"
  if is_cache_valid "$cache_key"; then
    log_debug "File cache hit for key: $cache_key" "CACHE"
    cat "$cache_file"
    
    # Also store in memory cache for faster access (if bash 4+)
    if [[ "$use_memory" == "true" && ${BASH_VERSION%%.*} -ge 4 ]]; then
      MEMORY_CACHE[$cache_key]="$(cat "$cache_file")"
      CACHE_TIMESTAMPS[$cache_key]=$(date +%s)
    fi
    
    return 0
  fi
  
  log_debug "Cache miss for key: $cache_key" "CACHE"
  return 1
}

# Set cache value
set_cache() {
  local cache_key="$1"
  local value="$2"
  local use_memory="${3:-true}"
  
  # Store in file cache
  local cache_file="$CACHE_DIR/$cache_key"
  echo "$value" > "$cache_file"
  
  # Store in memory cache (if bash 4+)
  if [[ "$use_memory" == "true" && ${BASH_VERSION%%.*} -ge 4 ]]; then
    MEMORY_CACHE[$cache_key]="$value"
    CACHE_TIMESTAMPS[$cache_key]=$(date +%s)
  fi
  
  log_debug "Cached value for key: $cache_key" "CACHE"
  
  # Check cache size and cleanup if needed
  check_cache_size
}

# Get cached or compute value
get_cached_or_compute() {
  local cache_key="$1"
  local compute_function="$2"
  shift 2
  local compute_args=("$@")
  
  # Try to get from cache first
  local cached_value
  if cached_value=$(get_cache "$cache_key"); then
    echo "$cached_value"
    return 0
  fi
  
  # Cache miss - compute the value
  log_debug "Computing value for cache key: $cache_key" "CACHE"
  start_timer "cache_compute_$cache_key"
  
  local computed_value
  if computed_value=$("$compute_function" "${compute_args[@]}"); then
    local duration=$(end_timer "cache_compute_$cache_key")
    log_debug "Computed and cached value in ${duration}s" "CACHE"
    
    # Store in cache
    set_cache "$cache_key" "$computed_value"
    echo "$computed_value"
    return 0
  else
    log_error "Failed to compute value for cache key: $cache_key" "CACHE"
    return 1
  fi
}

# Cache project analysis
cache_project_analysis() {
  local project_title="$1"
  local analysis_result="$2"
  
  local cache_key=$(generate_cache_key "$project_title" "analysis")
  set_cache "$cache_key" "$analysis_result"
  
  log_info "Cached project analysis for: $project_title" "CACHE"
}

# Get cached project analysis
get_cached_project_analysis() {
  local project_title="$1"
  
  local cache_key=$(generate_cache_key "$project_title" "analysis")
  if get_cache "$cache_key"; then
    log_info "Using cached project analysis for: $project_title" "CACHE"
    return 0
  fi
  
  return 1
}

# Cache language detection
cache_language_detection() {
  local input="$1"
  local detected_language="$2"
  
  local cache_key=$(generate_cache_key "$input" "language")
  set_cache "$cache_key" "$detected_language"
}

# Get cached language detection
get_cached_language_detection() {
  local input="$1"
  
  local cache_key=$(generate_cache_key "$input" "language")
  get_cache "$cache_key"
}

# Cache project type detection
cache_project_type() {
  local input="$1"
  local project_type="$2"
  
  local cache_key=$(generate_cache_key "$input" "project_type")
  set_cache "$cache_key" "$project_type"
}

# Get cached project type
get_cached_project_type() {
  local input="$1"
  
  local cache_key=$(generate_cache_key "$input" "project_type")
  get_cache "$cache_key"
}

# Check cache size and cleanup if needed
check_cache_size() {
  local cache_size=$(du -sm "$CACHE_DIR" 2>/dev/null | cut -f1)
  
  if [[ $cache_size -gt $MAX_CACHE_SIZE ]]; then
    log_warn "Cache size ($cache_size MB) exceeds limit ($MAX_CACHE_SIZE MB)" "CACHE"
    cleanup_old_cache
  fi
}

# Cleanup expired cache entries
cleanup_expired_cache() {
  local cleaned=0
  local current_time=$(date +%s)
  
  if [[ ! -d "$CACHE_DIR" ]]; then
    return 0
  fi
  
  for cache_file in "$CACHE_DIR"/*; do
    if [[ -f "$cache_file" ]]; then
      local file_time=$(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0)
      local age=$((current_time - file_time))
      
      if [[ $age -gt $CACHE_TTL ]]; then
        rm -f "$cache_file"
        ((cleaned++))
      fi
    fi
  done
  
  if [[ $cleaned -gt 0 ]]; then
    log_info "Cleaned up $cleaned expired cache entries" "CACHE"
  fi
}

# Cleanup old cache entries (LRU style)
cleanup_old_cache() {
  local target_files=$(($(ls -1 "$CACHE_DIR" | wc -l) / 2))  # Remove half
  
  # Remove oldest files first
  ls -t "$CACHE_DIR"/* | tail -n "$target_files" | xargs rm -f
  
  log_info "Cleaned up $target_files old cache entries" "CACHE"
}

# Clear all cache
clear_cache() {
  local cache_type="${1:-all}"  # all, memory, file
  
  case "$cache_type" in
    "memory")
      if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
        unset MEMORY_CACHE
        unset CACHE_TIMESTAMPS
        declare -A MEMORY_CACHE
        declare -A CACHE_TIMESTAMPS
        log_info "Cleared memory cache" "CACHE"
      else
        log_info "Memory cache not available (bash 3.x)" "CACHE"
      fi
      ;;
    "file")
      rm -rf "$CACHE_DIR"/*
      log_info "Cleared file cache" "CACHE"
      ;;
    "all")
      if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
        unset MEMORY_CACHE
        unset CACHE_TIMESTAMPS
        declare -A MEMORY_CACHE
        declare -A CACHE_TIMESTAMPS
      fi
      rm -rf "$CACHE_DIR"/*
      log_info "Cleared all cache" "CACHE"
      ;;
  esac
}

# Show cache statistics
show_cache_stats() {
  echo "📊 DNS Cache Statistics"
  echo "======================"
  
  # Memory cache stats
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    local memory_entries=${#MEMORY_CACHE[@]}
    echo "Memory cache entries: $memory_entries"
  else
    echo "Memory cache entries: N/A (bash 3.x)"
  fi
  
  # File cache stats
  if [[ -d "$CACHE_DIR" ]]; then
    local file_entries=$(ls -1 "$CACHE_DIR" 2>/dev/null | wc -l)
    local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    echo "File cache entries: $file_entries"
    echo "File cache size: $cache_size"
  else
    echo "File cache: Not initialized"
  fi
  
  echo "Cache TTL: ${CACHE_TTL}s"
  echo "Max cache size: ${MAX_CACHE_SIZE}MB"
}

# Preload common cache entries
preload_cache() {
  log_info "Preloading common cache entries..." "CACHE"
  
  # Preload common project types
  local common_projects=("web api" "database" "mobile app" "e-commerce" "dashboard")
  
  for project in "${common_projects[@]}"; do
    # Cache language detection
    local lang=$(detect_language "$project")
    cache_language_detection "$project" "$lang"
    
    # Cache project type detection
    local type=$(detect_project_type "$project")
    cache_project_type "$project" "$type"
  done
  
  log_info "Preloaded cache for common project types" "CACHE"
}

# Export functions
export -f init_cache
export -f generate_cache_key
export -f is_cache_valid
export -f get_cache
export -f set_cache
export -f get_cached_or_compute
export -f cache_project_analysis
export -f get_cached_project_analysis
export -f cache_language_detection
export -f get_cached_language_detection
export -f cache_project_type
export -f get_cached_project_type
export -f check_cache_size
export -f cleanup_expired_cache
export -f cleanup_old_cache
export -f clear_cache
export -f show_cache_stats
export -f preload_cache
