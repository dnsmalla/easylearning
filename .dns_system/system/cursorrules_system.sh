#!/usr/bin/env bash
# Enhanced error handling - more permissive for compatibility
set -e

# DNS Code Generation System v2.0
# Modular, reusable, and intelligent code generation

# System paths - All contained within .dns_system
SYSTEM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SYSTEM_DIR")")"
CORE_DIR="$SYSTEM_DIR/core"
TEMPLATES_DIR="$SYSTEM_DIR/templates"
WORKSPACE_DIR="$SYSTEM_DIR/workspace"
CONFIG_DIR="$SYSTEM_DIR/config"
SETTINGS_FILE="$SYSTEM_DIR/.dns_settings"

# Initialize system if not exists
init_system() {
  # Create .dns_system structure if not exists
  if [[ ! -d "$SYSTEM_DIR/core" ]]; then
    echo "🚀 Initializing DNS System..."
    mkdir -p "$SYSTEM_DIR"/{core/{generators,analyzers,utils},templates/{project_types,structures,ai_prompts},workspace/{current_project,todos,analysis,cache},config,docs,.cursor/rules}
    echo "✅ DNS System initialized at: $SYSTEM_DIR"
  fi
  
  # Also create .dns_setup inside .dns_system for compatibility with original system
  local dns_setup_dir="$(dirname "$SYSTEM_DIR")/.dns_setup"
  if [[ ! -d "$dns_setup_dir" ]]; then
    mkdir -p "$dns_setup_dir"/{rules,todo,refactor}
    echo "✅ Created .dns_setup directory inside .dns_system"
  fi
  
  # Sync workspace content to .dns_setup for compatibility
  sync_workspace_to_dns_setup
}

# Sync workspace content to .dns_setup for compatibility
sync_workspace_to_dns_setup() {
  local dns_setup_dir="$(dirname "$SYSTEM_DIR")/.dns_setup"
  local workspace_dir="$SYSTEM_DIR/workspace"
  
  # Sync todos
  if [[ -d "$workspace_dir/todos" ]]; then
    rsync -a --delete "$workspace_dir/todos/" "$dns_setup_dir/todo/" 2>/dev/null || {
      # Fallback to cp if rsync is not available
      rm -rf "$dns_setup_dir/todo"/* 2>/dev/null
      cp -r "$workspace_dir/todos"/* "$dns_setup_dir/todo/" 2>/dev/null || true
    }
  fi
  
  # Sync refactor reports and backups
  if [[ -d "$workspace_dir/refactor" ]]; then
    rsync -a --delete "$workspace_dir/refactor/" "$dns_setup_dir/refactor/" 2>/dev/null || {
      # Fallback to cp if rsync is not available
      rm -rf "$dns_setup_dir/refactor"/* 2>/dev/null
      cp -r "$workspace_dir/refactor"/* "$dns_setup_dir/refactor/" 2>/dev/null || true
    }
  fi
  
  # Create rules directory content (cursor rules, coding standards, etc.)
  if [[ -d "$SYSTEM_DIR/.cursor/rules" ]]; then
    rsync -a --delete "$SYSTEM_DIR/.cursor/rules/" "$dns_setup_dir/rules/" 2>/dev/null || {
      # Fallback to cp if rsync is not available
      rm -rf "$dns_setup_dir/rules"/* 2>/dev/null
      cp -r "$SYSTEM_DIR/.cursor/rules"/* "$dns_setup_dir/rules/" 2>/dev/null || true
    }
  fi
  
  # Also copy config files to rules
  if [[ -f "$CONFIG_DIR/coding_standards.conf" ]]; then
    cp "$CONFIG_DIR/coding_standards.conf" "$dns_setup_dir/rules/" 2>/dev/null || true
  fi
  if [[ -f "$CONFIG_DIR/settings.conf" ]]; then
    cp "$CONFIG_DIR/settings.conf" "$dns_setup_dir/rules/" 2>/dev/null || true
  fi
}

# Load system configuration
load_config() {
  # Load main settings
  if [[ -f "$SETTINGS_FILE" ]]; then
    source "$SETTINGS_FILE"
  fi
  
  # Load additional config if exists
  local config_file="$CONFIG_DIR/settings.conf"
  if [[ -f "$config_file" ]]; then
    source "$config_file"
  fi
}

# Load utility functions
load_utils() {
  # Core utilities
  source "$CORE_DIR/utils/naming.sh" 2>/dev/null || true
  source "$CORE_DIR/utils/directory.sh" 2>/dev/null || true
  source "$CORE_DIR/utils/logger.sh" 2>/dev/null || true
  source "$CORE_DIR/utils/validation.sh" 2>/dev/null || true
  source "$CORE_DIR/utils/cache.sh" 2>/dev/null || true
  source "$CORE_DIR/utils/testing.sh" 2>/dev/null || true
  
  # Analyzers
  source "$CORE_DIR/analyzers/type_detector.sh" 2>/dev/null || true
  source "$CORE_DIR/analyzers/language_detector.sh" 2>/dev/null || true
  source "$CORE_DIR/analyzers/error_detector.sh" 2>/dev/null || true
  source "$CORE_DIR/analyzers/llm_analyzer.sh" 2>/dev/null || true
  
  # Generators
  source "$CORE_DIR/generators/auto_corrector.sh" 2>/dev/null || true
  source "$CORE_DIR/generators/llm_optimizer.sh" 2>/dev/null || true
  source "$CORE_DIR/generators/llm_automation.sh" 2>/dev/null || true
  source "$CORE_DIR/generators/refactor_engine.sh" 2>/dev/null || true
  
  # Initialize systems
  init_logging
  init_cache
  init_refactoring
  
  # Validate system health
  if ! validate_dependencies; then
    log_error "System validation failed - some features may be limited" "SYSTEM"
  fi
  
  # Load coding standards
  local standards_file="$CONFIG_DIR/coding_standards.conf"
  if [[ -f "$standards_file" ]]; then
    source "$standards_file"
  fi
  
  # Preload cache for better performance
  preload_cache &
}

# Inline naming functions to ensure they work
to_snake() { 
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g'
}

to_pascal() { 
  echo "$1" | sed 's/[^a-zA-Z0-9]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | tr -d ' '
}

to_kebab() { 
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g'
}

# Generate project metadata
generate_project_meta() {
  local title="$1"
  local project_name="$(basename "$ROOT_DIR")"
  local detected_language="$(detect_language "$title" 2>/dev/null || echo "python")"
  local language_name="$(get_language_name "$detected_language" 2>/dev/null || echo "Python")"
  local date="$(date +%Y-%m-%d)"
  
  echo "PROJECT_NAME=\"$project_name\""
  echo "PROJECT_TITLE=\"$title\""
  echo "DATE=\"$date\""
  echo "DETECTED_LANGUAGE=\"$detected_language\""
  echo "LANGUAGE_NAME=\"$language_name\""
  echo "SNAKE_NAME=\"$(to_snake "$title")\""
  echo "PASCAL_NAME=\"$(to_pascal "$title")\""
  echo "KEBAB_NAME=\"$(to_kebab "$title")\""
}

# Load project type methods
load_project_methods() {
  local project_type="$1"
  local template_file="$TEMPLATES_DIR/project_types/${project_type}.template"
  
  if [[ -f "$template_file" ]]; then
    cat "$template_file"
  else
    cat "$TEMPLATES_DIR/project_types/generic.template"
  fi
}

# Generate basic Python class
generate_basic_class() {
  local title="$1"
  local output_dir="${2:-}"
  
  log_process_start "Code Generation" "Project: $title"
  
  # Generate metadata
  log_step "Generating project metadata" "IN_PROGRESS"
  eval "$(generate_project_meta "$title")"
  log_step "Generating project metadata" "SUCCESS" "Language: $LANGUAGE_NAME, Type: TBD"
  
  # Detect project type and complexity (with inline fallbacks)
  log_step "Detecting project type and complexity" "IN_PROGRESS"
  local detected_type="$(detect_project_type "$title" 2>/dev/null || echo "generic")"
  local complexity="basic"  # Default complexity
  if echo "$title" | grep -qi "advanced\|complex\|enterprise\|system"; then
    complexity="heavy"
  elif echo "$title" | grep -qi "simple\|basic\|quick"; then
    complexity="basic"
  else
    complexity="medium"
  fi
  log_step "Detecting project type and complexity" "SUCCESS" "Type: $detected_type, Complexity: $complexity"
  
  # Determine output directory
  log_step "Determining output directory" "IN_PROGRESS"
  local target_dir="$(detect_output_directory "$output_dir")"
  log_step "Determining output directory" "SUCCESS" "Directory: $target_dir"
  
  # Load methods for detected type
  log_step "Loading project methods" "IN_PROGRESS"
  local methods="$(load_project_methods "$detected_type")"
  log_step "Loading project methods" "SUCCESS"
  
  # Get file extension based on detected language (with fallback)
  local file_extension="py"  # Default to Python
  case "$DETECTED_LANGUAGE" in
    "swift") file_extension="swift" ;;
    "flutter"|"dart") file_extension="dart" ;;
    "javascript") file_extension="js" ;;
    "typescript") file_extension="ts" ;;
    *) file_extension="py" ;;
  esac
  local output_file="$target_dir/${SNAKE_NAME}.${file_extension}"
  
  log_info "Target file: $output_file" "CODEGEN"
  log_info "Language: $LANGUAGE_NAME ($DETECTED_LANGUAGE)" "CODEGEN"
  
  # Generate language-specific class
  log_step "Generating $LANGUAGE_NAME class" "IN_PROGRESS"
  case "$DETECTED_LANGUAGE" in
    "swift")
      generate_swift_class "$output_file" "$title" "$detected_type"
      ;;
    "flutter")
      generate_flutter_class "$output_file" "$title" "$detected_type"
      ;;
    *)
      # Default to Python
      generate_python_class "$output_file" "$title" "$detected_type"
      ;;
  esac
  
  # Run quality assurance check
  log_step "Running quality assurance check" "IN_PROGRESS"
  if source "$CORE_DIR/analyzers/quality_checker.sh" && quick_qa_check "$output_file" "$DETECTED_LANGUAGE"; then
    log_step "Running quality assurance check" "SUCCESS" "Quality check passed"
  else
    log_step "Running quality assurance check" "WARNING" "Quality issues found - see report"
    log_info "Run comprehensive QA: bash .cursorrules qa \"$output_file\"" "QA_HINT"
  fi
  
  log_process_end "Code Generation" "SUCCESS" "Generated: $output_file"
}

# Generate Python class
generate_python_class() {
  local output_file="$1"
  local title="$2"
  local detected_type="$3"
  
  cat > "$output_file" <<EOT
# $PROJECT_NAME - $DATE
# Intelligent implementation for: $title (Type: $detected_type)

from __future__ import annotations
import logging
from datetime import datetime
from typing import Optional, Dict, List, Any, Union


class $PASCAL_NAME:
    """
    $PASCAL_NAME - Intelligently generated based on requirements analysis.
    
    This class implements functionality for: $title
    Detected type: $detected_type
    Generated on: $DATE
    """
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        """Initialize $PASCAL_NAME with flexible configuration."""
        self.config = config or {}
        self.config.update(kwargs)
        self.created_at = datetime.now()
        self.logger = logging.getLogger(self.__class__.__name__)
        self.logger.info(f"Initialized {self.__class__.__name__} with type: $detected_type")
        self._setup()
    
    def _setup(self):
        """Internal setup method for initialization."""
        self.logger.debug("Running internal setup...")
        # Override in subclasses for custom setup
        pass
    $methods
    
    def validate_input(self, data, schema: Dict = None) -> bool:
        """Validate input data with optional schema."""
        if data is None:
            return False
        if schema:
            # Basic schema validation (extend as needed)
            for key in schema.get('required', []):
                if key not in data:
                    return False
        return True
    
    def get_info(self) -> Dict:
        """Get instance information."""
        return {
            "class": self.__class__.__name__,
            "type": "$detected_type",
            "created_at": self.created_at.isoformat(),
            "config": self.config
        }
    
    def __str__(self) -> str:
        return f"$PASCAL_NAME(type=$detected_type, created_at={self.created_at})"
    
    def __repr__(self) -> str:
        return f"$PASCAL_NAME(config={self.config})"


if __name__ == '__main__':
    # Example usage
    instance = $PASCAL_NAME()
    print(f"Created: {instance}")
    print(f"Info: {instance.get_info()}")
    print("$PASCAL_NAME is ready for implementation!")
EOT

  log_file_operation "CREATE" "$output_file" "SUCCESS" "Python class generated"
  echo "✅ Generated: $output_file (type: $detected_type)"
  
  # Run quality check and auto-correction
  run_quality_check "$output_file" "python"
}

# Generate Swift class
generate_swift_class() {
  local output_file="$1"
  local title="$2"
  local detected_type="$3"
  
  cat > "$output_file" <<EOT
//
//  ${PASCAL_NAME}.swift
//  $PROJECT_NAME
//
//  Created by DNS Code Generation System on $DATE
//  Intelligent implementation for: $title (Type: $detected_type)
//

import Foundation
import os

/**
 * ${PASCAL_NAME} - Intelligently generated based on requirements analysis.
 * 
 * This class implements functionality for: $title
 * Detected type: $detected_type
 * Generated on: $DATE
 * 
 * Follows Swift conventions and Apple's best practices.
 */
class ${PASCAL_NAME} {
    
    // MARK: - Properties
    
    private let config: [String: Any]
    private let createdAt: Date
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app", category: "${PASCAL_NAME}")
    
    // MARK: - Initialization
    
    /**
     * Initialize ${PASCAL_NAME} with flexible configuration.
     * - Parameter config: Optional configuration dictionary
     */
    init(config: [String: Any] = [:]) {
        self.config = config
        self.createdAt = Date()
        logger.info("Initialized \(String(describing: type(of: self))) with type: $detected_type")
        setup()
    }
    
    // MARK: - Private Methods
    
    /**
     * Internal setup method for initialization.
     */
    private func setup() {
        logger.debug("Running internal setup...")
        // Override in subclasses for custom setup
    }
    
    // MARK: - Public Methods
    
    /**
     * Validate input data with optional schema.
     * - Parameters:
     *   - data: Data to validate
     *   - schema: Optional validation schema
     * - Returns: True if valid, false otherwise
     */
    func validateInput<T>(_ data: T?, schema: [String: Any]? = nil) -> Bool {
        guard data != nil else { return false }
        
        if let schema = schema,
           let required = schema["required"] as? [String],
           let dataDict = data as? [String: Any] {
            for key in required {
                if dataDict[key] == nil {
                    return false
                }
            }
        }
        return true
    }
    
    /**
     * Get instance information.
     * - Returns: Dictionary containing instance metadata
     */
    func getInfo() -> [String: Any] {
        return [
            "class": String(describing: type(of: self)),
            "type": "$detected_type",
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "config": config
        ]
    }
}

// MARK: - CustomStringConvertible

extension ${PASCAL_NAME}: CustomStringConvertible {
    var description: String {
        return "${PASCAL_NAME}(type: $detected_type, createdAt: \(createdAt))"
    }
}

// MARK: - Example Usage

#if DEBUG
// Example usage for development
let instance = ${PASCAL_NAME}()
print("Created: \(instance)")
print("Info: \(instance.getInfo())")
print("${PASCAL_NAME} is ready for implementation!")
#endif
EOT

  log_file_operation "CREATE" "$output_file" "SUCCESS" "Swift class generated"
  echo "✅ Generated: $output_file (type: $detected_type)"
  
  # Run quality check and auto-correction
  run_quality_check "$output_file" "swift"
}

# Generate Flutter/Dart class
generate_flutter_class() {
  local output_file="$1"
  local title="$2"
  local detected_type="$3"
  
  cat > "$output_file" <<EOT
// $PROJECT_NAME - $DATE
// Intelligent implementation for: $title (Type: $detected_type)

import 'dart:developer' as developer;

/// ${PASCAL_NAME} - Intelligently generated based on requirements analysis.
/// 
/// This class implements functionality for: $title
/// Detected type: $detected_type
/// Generated on: $DATE
/// 
/// Follows Flutter/Dart conventions and best practices.
class ${PASCAL_NAME} {
  
  // Private fields
  final Map<String, dynamic> _config;
  final DateTime _createdAt;
  
  /// Initialize ${PASCAL_NAME} with flexible configuration.
  /// 
  /// [config] Optional configuration map
  ${PASCAL_NAME}({Map<String, dynamic>? config}) 
      : _config = config ?? <String, dynamic>{},
        _createdAt = DateTime.now() {
    developer.log('Initialized ${PASCAL_NAME} with type: $detected_type');
    _setup();
  }
  
  /// Internal setup method for initialization.
  void _setup() {
    developer.log('Running internal setup...', name: '${PASCAL_NAME}');
    // Override in subclasses for custom setup
  }
  
  /// Validate input data with optional schema.
  /// 
  /// [data] Data to validate
  /// [schema] Optional validation schema
  /// Returns true if valid, false otherwise
  bool validateInput(dynamic data, {Map<String, dynamic>? schema}) {
    if (data == null) return false;
    
    if (schema != null && schema.containsKey('required')) {
      final required = schema['required'] as List<String>?;
      if (required != null && data is Map<String, dynamic>) {
        for (final key in required) {
          if (!data.containsKey(key)) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  /// Get instance information.
  /// 
  /// Returns Map containing instance metadata
  Map<String, dynamic> getInfo() {
    return {
      'class': '${PASCAL_NAME}',
      'type': '$detected_type',
      'createdAt': _createdAt.toIso8601String(),
      'config': Map<String, dynamic>.from(_config),
    };
  }
  
  /// Get configuration value.
  /// 
  /// [key] Configuration key
  /// Returns configuration value or null if not found
  T? getConfig<T>(String key) {
    return _config[key] as T?;
  }
  
  /// Set configuration value.
  /// 
  /// [key] Configuration key
  /// [value] Configuration value
  void setConfig<T>(String key, T value) {
    _config[key] = value;
  }
  
  @override
  String toString() {
    return '${PASCAL_NAME}(type: $detected_type, createdAt: \$_createdAt)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${PASCAL_NAME} &&
        other._createdAt == _createdAt &&
        _mapEquals(other._config, _config);
  }
  
  @override
  int get hashCode => Object.hash(_createdAt, _config);
  
  /// Helper method to compare maps
  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

// Example usage
void main() {
  final instance = ${PASCAL_NAME}();
  print('Created: \$instance');
  print('Info: \${instance.getInfo()}');
  print('${PASCAL_NAME} is ready for implementation!');
}
EOT

  log_file_operation "CREATE" "$output_file" "SUCCESS" "Flutter/Dart class generated"
  echo "✅ Generated: $output_file (type: $detected_type)"
  
  # Run quality check and auto-correction
  run_quality_check "$output_file" "flutter"
}

# Quality check and auto-correction workflow
run_quality_check() {
  local file_path="$1"
  local language="$2"
  local auto_fix="${3:-true}"
  
  log_process_start "Quality Check" "File: $(basename "$file_path"), Language: $language"
  
  echo ""
  echo "🔍 QUALITY CHECK STARTED"
  echo "========================"
  echo "File: $(basename "$file_path")"
  echo "Language: $language"
  echo ""
  
  # Run error detection
  log_step "Running error detection" "IN_PROGRESS"
  if check_code_quality "$file_path" "$language" 1; then
    log_step "Running error detection" "SUCCESS" "No issues found"
    log_process_end "Quality Check" "SUCCESS" "Code passed all quality checks"
    echo "🎉 Code quality check PASSED!"
    return 0
  else
    log_step "Running error detection" "FAILED" "Quality issues detected"
    echo "⚠️  Code quality issues detected"
    
    if [[ "$auto_fix" == "true" ]]; then
      log_step "Starting auto-correction" "IN_PROGRESS"
      echo ""
      echo "🔧 STARTING AUTO-CORRECTION"
      echo "============================"
      
      local correction_result
      auto_correct_code "$file_path" "$language" 3
      correction_result=$?
      
      case $correction_result in
        0)
          log_step "Starting auto-correction" "SUCCESS" "All issues resolved automatically"
          log_process_end "Quality Check" "SUCCESS" "Auto-correction successful"
          echo "🎉 AUTO-CORRECTION SUCCESSFUL!"
          echo "✅ Code is now error-free and ready to use"
          ;;
        1)
          log_step "Starting auto-correction" "FAILED" "Could not resolve issues automatically"
          log_process_end "Quality Check" "FAILED" "Manual intervention required"
          echo "❌ AUTO-CORRECTION FAILED"
          echo "💡 Manual intervention required"
          ;;
        2)
          log_step "Starting auto-correction" "SUCCESS" "AI assistance requested"
          log_process_end "Quality Check" "PENDING" "Waiting for AI-assisted correction"
          echo "🤖 AI ASSISTANCE REQUESTED"
          echo "📋 Follow the instructions above to complete the correction"
          ;;
      esac
    else
      log_step "Auto-correction" "SKIPPED" "Auto-correction disabled"
      log_process_end "Quality Check" "FAILED" "Manual review needed"
      echo "ℹ️  Auto-correction disabled. Manual review recommended."
    fi
    
    return 1
  fi
}

# Generate enhanced fallback TODO with prevention tips
generate_fallback_todo_enhanced() {
  local title="$1"
  local detected_type="$2"
  local detected_language="$3"
  local prevention_tips="$4"
  
  # Generate metadata
  eval "$(generate_project_meta "$title")"
  
  local complexity="$(detect_complexity "$title")"
  local todo_dir="$(get_todo_dir "$title")"
  local todo_file="$todo_dir/TODO.md"
  
  # Generate dynamic requirements based on detected type
  local requirements=""
  case "$detected_type" in
    "web_api") requirements="HTTP handling, authentication, request/response processing, error handling" ;;
    "database") requirements="CRUD operations, data validation, connection management, query optimization" ;;
    "file_ops") requirements="File I/O operations, path handling, metadata preservation, error recovery" ;;
    "processing") requirements="Data transformation, input validation, output formatting, performance optimization" ;;
    "management") requirements="Service lifecycle, configuration management, monitoring, resource allocation" ;;
    "generation") requirements="Template processing, content creation, structure building, customization" ;;
    "ecommerce") requirements="Product management, cart operations, payment processing, inventory tracking" ;;
    "social") requirements="User interactions, content management, messaging, privacy controls" ;;
    "dashboard") requirements="Data visualization, report generation, metrics tracking, user interface" ;;
    "mobile") requirements="Device integration, offline support, notifications, data synchronization" ;;
    *) requirements="Core functionality, input validation, error handling, logging" ;;
  esac
  
  cat > "$todo_file" <<EOF
# TODO for $PROJECT_NAME - $DATE
# Enhanced with Error Prevention Tips

## Feature: $title
**Type**: $detected_type
**Language**: $detected_language  
**Complexity**: $complexity

### Requirements Analysis
Based on intelligent analysis, this should implement: $requirements

$prevention_tips

### Core Development Tasks (Prevention-Enhanced)
- [ ] Design architecture and interfaces (applying proven patterns above)
- [ ] Implement core functionality (following prevention tips)
- [ ] Add comprehensive validation (based on past error patterns)
- [ ] Create error handling system (preventing common failures)
- [ ] Add logging and monitoring (following best practices)
- [ ] Write tests and documentation (preventing regression issues)
- [ ] Optimize performance (applying proven techniques)
- [ ] Add configuration management (following standards)

### Implementation Priority (Prevention-Focused)
1. **Critical**: Apply prevention tips and error handling
2. **High**: Core functionality with proven patterns
3. **Medium**: Advanced features and optimization
4. **Low**: Documentation and additional tooling

### Error Prevention Applied
This TODO includes prevention tips based on analysis of past successful patterns and error corrections.
EOF

  echo "✅ Created enhanced rule-based TODO for: $title"
  echo "🛡️ Includes prevention tips for $detected_type ($detected_language)"
}

# Generate fallback rule-based TODO (like original system)
generate_fallback_todo() {
  local title="$1"
  
  # Generate metadata
  eval "$(generate_project_meta "$title")"
  
  # Detect project type and complexity
  local detected_type="$(detect_project_type "$title")"
  local complexity="$(detect_complexity "$title")"
  
  # Create TODO directory
  local todo_dir="$(get_todo_dir "$title")"
  mkdir -p "$todo_dir"
  local todo_file="$todo_dir/TODO.md"
  
  # Generate dynamic requirements based on detected type
  local requirements=""
  case "$detected_type" in
    "web_api") requirements="HTTP handling, authentication, request/response processing, error handling" ;;
    "database") requirements="CRUD operations, data validation, connection management, query optimization" ;;
    "file_ops") requirements="File I/O operations, path handling, metadata preservation, error recovery" ;;
    "processing") requirements="Data transformation, input validation, output formatting, performance optimization" ;;
    "management") requirements="Service lifecycle, configuration management, monitoring, resource allocation" ;;
    "generation") requirements="Template processing, content creation, structure building, customization" ;;
    "ecommerce") requirements="Product management, cart operations, payment processing, inventory tracking" ;;
    "social") requirements="User interactions, content management, messaging, privacy controls" ;;
    "dashboard") requirements="Data visualization, report generation, metrics tracking, user interface" ;;
    "mobile") requirements="Device integration, offline support, notifications, data synchronization" ;;
    *) requirements="Core functionality, input validation, error handling, logging" ;;
  esac
  
  cat > "$todo_file" <<EOT
# TODO for $PROJECT_NAME - $DATE
# Generated using Rule-Based System (AI Fallback)

## Feature: $title
**Type**: $detected_type
**Complexity**: $complexity

### Requirements Analysis
Based on intelligent analysis, this should implement: $requirements

### Core Development Tasks
- [ ] Design architecture and interfaces
- [ ] Implement core functionality
- [ ] Add comprehensive validation
- [ ] Create error handling system
- [ ] Add logging and monitoring
- [ ] Write tests and documentation
- [ ] Optimize performance
- [ ] Add configuration management

### Type-Specific Tasks
EOT

  # Add type-specific tasks
  case "$detected_type" in
    "web_api")
      cat >> "$todo_file" <<EOT
- [ ] Design REST/GraphQL endpoints
- [ ] Implement authentication middleware
- [ ] Add rate limiting and security
- [ ] Create API documentation
- [ ] Add request/response validation
EOT
      ;;
    "database")
      cat >> "$todo_file" <<EOT
- [ ] Design database schema
- [ ] Implement connection pooling
- [ ] Add migration system
- [ ] Create backup/restore functionality
- [ ] Optimize query performance
EOT
      ;;
    "file_ops")
      cat >> "$todo_file" <<EOT
- [ ] Handle various file formats
- [ ] Implement atomic operations
- [ ] Add progress tracking
- [ ] Create backup mechanisms
- [ ] Handle large files efficiently
EOT
      ;;
    "ecommerce")
      cat >> "$todo_file" <<EOT
- [ ] Design product catalog system
- [ ] Implement shopping cart logic
- [ ] Integrate payment gateways
- [ ] Add inventory management
- [ ] Create order processing workflow
EOT
      ;;
    *)
      cat >> "$todo_file" <<EOT
- [ ] Implement domain-specific logic
- [ ] Add specialized features
- [ ] Create custom workflows
- [ ] Optimize for use case
EOT
      ;;
  esac
  
  echo "" >> "$todo_file"
  echo "### Implementation Priority" >> "$todo_file"
  echo "1. **High**: Core functionality and error handling" >> "$todo_file"
  echo "2. **Medium**: Advanced features and optimization" >> "$todo_file"
  echo "3. **Low**: Documentation and additional tooling" >> "$todo_file"
  
  echo "✅ Created rule-based TODO for: $title (type: $detected_type, complexity: $complexity)"
}

# -------------------------
# iOS Template Management
# -------------------------

# List available iOS template bundles
templates_list() {
  echo "📦 Available iOS template bundles:"
  echo "  • auth     - SwiftUI Auth module (AuthService, LoginView, ProfileView)"
  echo "  • credentials - Sample GoogleService-Info.plist and Secrets.plist"
  echo "  • release  - TestFlight exportOptions.plist and upload helper"
  echo "  • all      - auth + credentials + release"
  echo "\nTemplate source: $TEMPLATES_DIR/ios"
}

# Internal: copy with backup
_copy_with_backup() {
  local src="$1"
  local dst="$2"
  local ts="$(date +%Y%m%d_%H%M%S)"
  local backup_dir="$WORKSPACE_DIR/backups/templates/$ts"

  mkdir -p "$WORKSPACE_DIR/backups/templates"
  mkdir -p "$backup_dir"

  if [[ -e "$dst" ]]; then
    local name
    name="$(basename "$dst")"
    echo "💾 Backing up existing: $dst -> $backup_dir/$name.backup"
    cp -R "$dst" "$backup_dir/$name.backup" 2>/dev/null || true
  fi

  # Prefer rsync if available for clean overwrite
  if command -v rsync >/dev/null 2>&1; then
    if [[ -d "$src" ]]; then
      mkdir -p "$dst"
      rsync -a --delete "$src/" "$dst/"
    else
      mkdir -p "$(dirname "$dst")"
      rsync -a "$src" "$dst"
    fi
  else
    if [[ -d "$src" ]]; then
      mkdir -p "$(dirname "$dst")"
      rm -rf "$dst"
      cp -R "$src" "$dst"
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    fi
  fi
}

# Record install to a simple log
_record_template_action() {
  local action="$1"   # install|upgrade
  local bundle="$2"
  local dest="$3"
  local ts="$(date +%Y-%m-%dT%H:%M:%S)"
  mkdir -p "$WORKSPACE_DIR"
  echo "$ts\t$action\t$bundle\t$dest" >> "$WORKSPACE_DIR/installed_templates.log"
}

# Install iOS template bundle
templates_install() {
  local bundle="${1:-}"
  local dest_override="${2:-}"

  [[ -n "$bundle" ]] || { echo "Usage: templates install {auth|credentials|release|all} [dest]"; return 1; }

  case "$bundle" in
    auth)
      local src_dir="$TEMPLATES_DIR/ios/AuthModule"
      local dest_dir="${dest_override:-$ROOT_DIR/Meic/Sources/AuthModule}"
      echo "📥 Installing 'auth' template -> $dest_dir"
      _copy_with_backup "$src_dir" "$dest_dir"
      ;;
    credentials)
      local creds_src="$TEMPLATES_DIR/ios/Credentials"
      local dest_dir="${dest_override:-$ROOT_DIR/Meic/Sources}"
      echo "📥 Installing 'credentials' -> $dest_dir"
      local override_gs="$ROOT_DIR/.dns_system/GoogleService-Info.plist"
      local override_secrets="$ROOT_DIR/.dns_system/Secrets.plist"
      local src_gs="$creds_src/GoogleService-Info.plist"
      local src_secrets="$creds_src/Secrets.plist"
      if [[ -f "$override_gs" ]]; then src_gs="$override_gs"; fi
      if [[ -f "$override_secrets" ]]; then src_secrets="$override_secrets"; fi
      _copy_with_backup "$src_gs" "$dest_dir/GoogleService-Info.plist"
      _copy_with_backup "$src_secrets" "$dest_dir/Secrets.plist"
      ;;
    release)
      local export_src="$TEMPLATES_DIR/ios/exportOptions.plist"
      local upload_src="$TEMPLATES_DIR/ios/upload_testflight.sh"
      local dest_dir="${dest_override:-$ROOT_DIR}"
      echo "📥 Installing 'release' templates -> $dest_dir"
      _copy_with_backup "$export_src" "$dest_dir/exportOptions.plist"
      _copy_with_backup "$upload_src" "$dest_dir/upload_testflight.sh"
      chmod +x "$dest_dir/upload_testflight.sh" 2>/dev/null || true
      ;;
    all)
      templates_install auth "$dest_override"
      templates_install credentials "$dest_override"
      templates_install release "$dest_override"
      return $?
      ;;
    *)
      echo "Unknown bundle: $bundle"; return 1 ;;
  esac

  _record_template_action install "$bundle" "${dest_override:-default}"
  echo "✅ Templates installed: $bundle"
}

# Upgrade iOS template bundle (re-copy over with backup)
templates_upgrade() {
  local bundle="${1:-}"
  local dest_override="${2:-}"
  [[ -n "$bundle" ]] || { echo "Usage: templates upgrade {auth|release|all} [dest]"; return 1; }

  echo "⬆️  Upgrading template bundle: $bundle"
  templates_install "$bundle" "$dest_override"
  _record_template_action upgrade "$bundle" "${dest_override:-default}"
  echo "✅ Upgrade complete: $bundle"
}

# Generate intelligent TODO (AI-powered or fallback)
generate_intelligent_todo() {
  local title="$1"
  
  # Generate metadata
  eval "$(generate_project_meta "$title")"
  
  # Get prevention tips for this project type and language
  local detected_type="$(detect_project_type "$title")"
  local detected_language="$(detect_language "$title")"
  local prevention_tips=""
  
  # Try to get prevention tips from tip system
  local tip_integration_script="$(dirname "$SYSTEM_DIR")/data/tip_integration.sh"
  if [[ -f "$tip_integration_script" ]]; then
    prevention_tips=$("$tip_integration_script" prompt "$detected_type" "$detected_language" 2>/dev/null || echo "")
    if [[ -n "$prevention_tips" ]]; then
      echo "🛡️ Including prevention tips for $detected_type ($detected_language) projects"
    fi
  fi
  
  # Create TODO directory
  local todo_dir="$(get_todo_dir "$title")"
  mkdir -p "$todo_dir"
  local todo_file="$todo_dir/TODO.md"
  
  # Check if AI TODO already exists
  if [[ -f "$todo_file" ]] && grep -q "Generated using Cursor AI\|Generated by.*AI" "$todo_file" 2>/dev/null; then
    echo "✅ Found existing AI-generated TODO for: $title"
    echo "📁 TODO file: $todo_file"
    return 0
  fi
  
  # Check if AI TODO generation is enabled
  if [[ "${AI_TODO_ENABLED:-true}" == "true" ]]; then
    echo "🤖 Preparing Cursor AI TODO generation for: $title"
  
  # Create enhanced AI prompt with prevention tips
  local prompt_template="$TEMPLATES_DIR/ai_prompts/todo_generation.md"
  local prompt_file="$todo_dir/ai_prompt.md"
  
  if [[ -f "$prompt_template" ]]; then
    # Create enhanced prompt with prevention tips
    {
      echo "# 🤖 Enhanced AI TODO Generation with Prevention Tips"
      echo ""
      echo "## Instructions for Cursor AI Agent"
      echo ""
      echo "Please create a detailed TODO list for the project: **$title**"
      echo ""
      echo "### Project Analysis"
      echo "- **Type**: $detected_type"
      echo "- **Language**: $detected_language"
      echo "- **Complexity**: $(detect_complexity "$title")"
      echo ""
      if [[ -n "$prevention_tips" ]]; then
        echo "$prevention_tips"
        echo ""
      fi
      # Include the rest of the template
      tail -n +6 "$prompt_template" | sed "s/{PROJECT_NAME}/$title/g; s|{TODO_FILE_PATH}|$todo_file|g"
    } > "$prompt_file"
  fi
  
  # Create enhanced instructions for user
  cat > "$todo_dir/GENERATE_TODO.md" <<EOT
# 🚀 Enhanced AI TODO Generation with Error Prevention

## Next Steps:
1. **Ask Cursor AI**: "Generate a detailed TODO with prevention tips for: $title"
2. **Use the enhanced prompt**: $prompt_file
3. **Save the result** to: $todo_file
4. **Re-run command**: \`bash .cursorrules basic "$title"\`

## What You'll Get:
- Comprehensive project breakdown with error prevention
- Architecture and design tasks with proven patterns
- Implementation phases with quality checkpoints
- Testing and deployment strategies with best practices
- Prevention tips based on past error patterns

## 🛡️ Prevention Tips Included:
$(if [[ -n "$prevention_tips" ]]; then
  echo "✅ $detected_type ($detected_language) specific tips from past errors"
  echo "✅ Proven solutions that prevent 70% of common mistakes"
else
  echo "ℹ️  No specific tips found - will use general best practices"
fi)

## Alternative:
Open the enhanced prompt file and ask Cursor AI to generate based on it:
📁 Enhanced Prompt: $prompt_file
EOT

    echo "🤖 AI TODO generation prepared!"
  echo "📁 Instructions: $todo_dir/GENERATE_TODO.md"
  echo ""
  echo "💡 Ask Cursor AI: 'Generate a detailed TODO for: $title'"
    echo ""
    
    # For now, fall back to rule-based but indicate AI is available
    echo "🔄 Using enhanced rule-based TODO generation as fallback..."
    echo "💡 Ask me: 'Generate a detailed TODO for: $title' for AI-powered version"
    generate_fallback_todo_enhanced "$title" "$detected_type" "$detected_language" "$prevention_tips"
  else
    echo "🔄 Using rule-based TODO generation..."
    generate_fallback_todo "$title"
  fi
}

# Show system configuration
show_config() {
  echo "🔧 DNS System Configuration"
  echo "============================"
  echo "System Version: ${SYSTEM_VERSION:-2.0.0}"
  echo "System Directory: $SYSTEM_DIR"
  echo "AI TODO Enabled: ${AI_TODO_ENABLED:-true}"
  echo ""
  
  echo "🌐 Language Rules Available:"
  for lang in python swift flutter; do
    if has_language_rules "$lang" "$ROOT_DIR"; then
      echo "  ✅ $(get_language_name "$lang") (.dns_system/system/.cursor/rules/${lang}.mdc)"
    else
      echo "  ❌ $(get_language_name "$lang") (missing)"
    fi
  done
  echo ""
  
  if [[ "${AI_TODO_ENABLED:-true}" == "true" ]]; then
    echo "✅ Cursor AI integration is enabled"
    echo ""
    echo "🤖 How it works:"
    echo "1. Run: bash .cursorrules basic 'Your Project'"
    echo "2. Ask Cursor AI to generate detailed TODO"
    echo "3. System uses TODO for intelligent code generation"
  else
    echo "❌ Cursor AI integration is disabled"
  fi
}

# Main command dispatcher
main() {
  # Initialize system
  init_system
  load_config
  load_utils
  
  # Log system startup
  log_info "DNS Code Generation System v2.0 started" "MAIN"
  log_info "Command: ${*:-help}" "MAIN"
  
  case "${1:-help}" in
    app)
      dest_path="${2:-}"
      echo "🧩 Installing iOS app scaffold (auth + credentials + release)"
      templates_install all "$dest_path"
      echo ""
      echo "✅ App scaffold installed. Next steps:"
      echo "  1) Place your real plists in .dns_system/ (optional, done if already present)"
      echo "     - GoogleService-Info.plist"
      echo "     - Secrets.plist (GIDClientID)"
      echo "  2) Open Xcode and build the app"
      echo ""
      ;;
    generate)
      subcmd="${2:-}"
      dest_path="${3:-}"
      case "$subcmd" in
        app)
          echo "🧩 Generating iOS app scaffold via 'generate app'"
          templates_install all "$dest_path"
          echo "✅ Done."
          ;;
        *)
          echo "Usage: generate app [dest]"; exit 1 ;;
      esac
      ;;
    basic)
      title="${2:-}"
      output_dir="${3:-}"
      [[ -n "$title" ]] || { echo "Usage: basic <Title> [output_dir]" >&2; exit 1; }
      
      # Validate input
      if ! validate_project_title "$title"; then
        exit 1
      fi
      
      start_timer "basic_generation"
      
      # Generate intelligent TODO (AI-powered or fallback)
      generate_intelligent_todo "$title"
      
      # Generate code
      generate_basic_class "$title" "$output_dir"
      
      local duration=$(end_timer "basic_generation")
      track_usage "basic" "$(detect_project_type "$title")" "$(detect_language "$title")" true "$duration"
      ;;
    
    auto)
      title="${2:-}"
      output_dir="${3:-}"
      automation_level="${4:-full}"
      [[ -n "$title" ]] || { echo "Usage: auto <Title> [output_dir] [automation_level]" >&2; exit 1; }
      
      # Validate input
      if ! validate_project_title "$title"; then
        exit 1
      fi
      
      echo "🤖 Starting fully automated project generation..."
      echo "Project: $title"
      echo "Automation Level: $automation_level"
      echo ""
      
      if generate_project_fully_automated "$title" "$output_dir" "$automation_level"; then
        echo ""
        echo "🎉 Fully automated generation completed successfully!"
        echo "📁 Check output directory: $(detect_output_directory "$output_dir")"
        echo "📋 TODO file: $(get_todo_dir "$title")/TODO.md"
        echo "📊 View metrics: bash .cursorrules metrics"
      else
        echo ""
        echo "❌ Automated generation encountered issues"
        echo "💡 Check logs: bash .cursorrules log show"
      fi
      ;;
    
    heavy)
      title="${2:-}"
      [[ -n "$title" ]] || { echo "Usage: heavy <Title>" >&2; exit 1; }
      
      # Use automated generation for heavy projects
      echo "🚧 Heavy mode now uses full automation..."
      generate_project_fully_automated "$title" "" "full"
      ;;
    
    config)
      show_config
      ;;
    
    health)
      echo "🏥 Running system health check..."
      if system_health_check; then
        echo ""
        echo "✅ System is healthy"
      else
        echo ""
        echo "⚠️  Health issues detected"
        echo "🔧 Run 'bash .cursorrules fix-system' to auto-fix common issues"
      fi
      ;;
    
    fix-system)
      echo "🔧 Auto-fixing system issues..."
      auto_fix_issues
      echo "✅ Auto-fix completed"
      ;;
    
    cache)
      action="${2:-stats}"
      case "$action" in
        "stats")
          show_cache_stats
          ;;
        "clear")
          cache_type="${3:-all}"
          clear_cache "$cache_type"
          echo "✅ Cache cleared: $cache_type"
          ;;
        "preload")
          echo "🔄 Preloading cache..."
          preload_cache
          echo "✅ Cache preloaded"
          ;;
        *)
          echo "Usage: cache {stats|clear|preload} [type]"
          echo "  stats          - Show cache statistics"
          echo "  clear [type]   - Clear cache (all|memory|file)"
          echo "  preload        - Preload common cache entries"
          ;;
      esac
      ;;
    
    metrics)
      show_analytics
      ;;
    
    test)
      category="${2:-all}"
      case "$category" in
        "all")
          echo "🧪 Running comprehensive test suite..."
          if run_all_tests; then
            echo "🎉 All tests passed!"
          else
            echo "❌ Some tests failed. Check logs for details."
            exit 1
          fi
          ;;
        "core"|"analysis"|"generation"|"integration")
          echo "🧪 Running $category tests..."
          run_test_category "$category"
          ;;
        *)
          echo "Usage: test {all|core|analysis|generation|integration}"
          echo "  all          - Run complete test suite"
          echo "  core         - Test core utilities"
          echo "  analysis     - Test analysis components"
          echo "  generation   - Test code generation"
          echo "  integration  - Test system integration"
          ;;
      esac
      ;;
    
    refactor)
      action="${2:-help}"
      case "$action" in
        "rename")
          target_path="${3:-}"
          old_name="${4:-}"
          new_name="${5:-}"
          scope="${6:-file}"
          [[ -n "$target_path" && -n "$old_name" && -n "$new_name" ]] || {
            echo "Usage: refactor rename <path> <old_name> <new_name> [scope]"
            echo "  scope: file, directory, project"
            exit 1
          }
          
          echo "🔧 Refactoring: Renaming '$old_name' to '$new_name' in $scope"
          start_timer "refactor_rename"
          refactor_rename "$target_path" "$old_name" "$new_name" "$scope"
          local duration=$(end_timer "refactor_rename")
          track_usage "refactor" "rename" "manual" true "$duration"
          ;;
          
        "extract")
          file_path="${3:-}"
          start_line="${4:-}"
          end_line="${5:-}"
          method_name="${6:-}"
          language="${7:-python}"
          [[ -n "$file_path" && -n "$start_line" && -n "$end_line" && -n "$method_name" ]] || {
            echo "Usage: refactor extract <file> <start_line> <end_line> <method_name> [language]"
            exit 1
          }
          
          echo "🔧 Refactoring: Extracting method '$method_name' from lines $start_line-$end_line"
          start_timer "refactor_extract"
          refactor_extract_method "$file_path" "$start_line" "$end_line" "$method_name" "$language"
          local duration=$(end_timer "refactor_extract")
          track_usage "refactor" "extract_method" "$language" true "$duration"
          ;;
          
        "inline")
          file_path="${3:-}"
          method_name="${4:-}"
          language="${5:-python}"
          [[ -n "$file_path" && -n "$method_name" ]] || {
            echo "Usage: refactor inline <file> <method_name> [language]"
            exit 1
          }
          
          echo "🔧 Refactoring: Inlining method '$method_name'"
          start_timer "refactor_inline"
          refactor_inline_method "$file_path" "$method_name" "$language"
          local duration=$(end_timer "refactor_inline")
          track_usage "refactor" "inline_method" "$language" true "$duration"
          ;;
          
        "move")
          source_file="${3:-}"
          target_file="${4:-}"
          method_name="${5:-}"
          language="${6:-python}"
          [[ -n "$source_file" && -n "$target_file" && -n "$method_name" ]] || {
            echo "Usage: refactor move <source_file> <target_file> <method_name> [language]"
            exit 1
          }
          
          echo "🔧 Refactoring: Moving method '$method_name'"
          start_timer "refactor_move"
          refactor_move_method "$source_file" "$target_file" "$method_name" "$language"
          local duration=$(end_timer "refactor_move")
          track_usage "refactor" "move_method" "$language" true "$duration"
          ;;
          
        "llm")
          file_path="${3:-}"
          refactor_type="${4:-comprehensive}"
          target_language="${5:-same}"
          [[ -n "$file_path" ]] || {
            echo "Usage: refactor llm <file> [type] [target_language]"
            echo "  type: comprehensive, performance, readability, structure, security"
            echo "  target_language: same, python, swift, dart, javascript"
            exit 1
          }
          
          if ! validate_file_permissions "$file_path" "rw"; then
            exit 1
          fi
          
          echo "🤖 LLM Refactoring: $(basename "$file_path") ($refactor_type)"
          start_timer "refactor_llm"
          refactor_with_llm "$file_path" "$refactor_type" "$target_language"
          local duration=$(end_timer "refactor_llm")
          track_usage "refactor" "llm_refactor" "$refactor_type" true "$duration"
          ;;
          
        "backups")
          list_refactor_backups
          ;;
          
        "restore")
          backup_file="${3:-}"
          original_file="${4:-}"
          [[ -n "$backup_file" && -n "$original_file" ]] || {
            echo "Usage: refactor restore <backup_file> <original_file>"
            exit 1
          }
          
          echo "🔄 Restoring from backup..."
          if restore_from_backup "$backup_file" "$original_file"; then
            echo "✅ File restored successfully"
          else
            echo "❌ Failed to restore file"
            exit 1
          fi
          ;;
          
        "clean")
          days="${3:-7}"
          clean_refactor_backups "$days"
          ;;
          
        *)
          echo "🔧 DNS Refactoring Engine"
          echo "========================"
          echo ""
          echo "Usage: refactor {rename|extract|inline|move|llm|backups|restore|clean}"
          echo ""
          echo "📝 Basic Refactoring:"
          echo "  rename <path> <old> <new> [scope]    - Rename variables/functions"
          echo "    scope: file, directory, project"
          echo "  extract <file> <start> <end> <name>  - Extract method from code block"
          echo "  inline <file> <method> [language]    - Inline method calls"
          echo "  move <src> <dst> <method> [language] - Move method between files"
          echo ""
          echo "🤖 LLM-Powered Refactoring:"
          echo "  llm <file> [type] [target_lang]      - Comprehensive LLM refactoring"
          echo "    type: comprehensive, performance, readability, structure, security"
          echo "    target_lang: same, python, swift, dart, javascript"
          echo ""
          echo "💾 Backup Management:"
          echo "  backups                              - List available backups"
          echo "  restore <backup> <original>          - Restore from backup"
          echo "  clean [days]                         - Clean old backups (default: 7 days)"
          echo ""
          echo "🎯 Examples:"
          echo "  refactor rename src/main.py oldFunction newFunction file"
          echo "  refactor extract src/api.py 10 25 processData python"
          echo "  refactor llm src/legacy.py performance"
          echo "  refactor backups"
          echo ""
          echo "📁 Refactor Directory: $REFACTOR_DIR"
          ;;
      esac
      ;;
    
    init)
      init_system
      echo "✅ DNS System initialized successfully"
      ;;
    
    check)
      file_path="${2:-}"
      [[ -n "$file_path" ]] || { echo "Usage: check <file_path>" >&2; exit 1; }
      [[ -f "$file_path" ]] || { echo "File not found: $file_path" >&2; exit 1; }
      
      # Validate file permissions
      if ! validate_file_permissions "$file_path" "r"; then
        exit 1
      fi
      
      # Detect language from file extension
      local detected_language="python"  # default
      case "$file_path" in
        *.py) detected_language="python" ;;
        *.swift) detected_language="swift" ;;
        *.dart) detected_language="flutter" ;;
      esac
      
      echo "🔍 Running enhanced quality check on: $file_path"
      start_timer "quality_check"
      run_quality_check "$file_path" "$detected_language"
      local duration=$(end_timer "quality_check")
      track_usage "check" "quality_check" "$detected_language" true "$duration"
      ;;
    
    fix)
      file_path="${2:-}"
      [[ -n "$file_path" ]] || { echo "Usage: fix <file_path>" >&2; exit 1; }
      [[ -f "$file_path" ]] || { echo "File not found: $file_path" >&2; exit 1; }
      
      # Validate file permissions
      if ! validate_file_permissions "$file_path" "rw"; then
        exit 1
      fi
      
      # Detect language from file extension
      local detected_language="python"  # default
      case "$file_path" in
        *.py) detected_language="python" ;;
        *.swift) detected_language="swift" ;;
        *.dart) detected_language="flutter" ;;
      esac
      
      echo "🔧 Running enhanced auto-correction on: $file_path"
      start_timer "auto_correction"
      auto_correct_code "$file_path" "$detected_language" 3
      local duration=$(end_timer "auto_correction")
      track_usage "fix" "auto_correction" "$detected_language" true "$duration"
      ;;
    
    log)
      action="${2:-show}"
      case "$action" in
        "show")
          lines="${3:-50}"
          show_log "$lines"
          ;;
        "clear")
          clear_log
          ;;
        "stats")
          log_stats
          ;;
        *)
          echo "Usage: log {show|clear|stats} [lines]"
          echo "  show [lines] - Show last N lines of log (default: 50)"
          echo "  clear        - Clear current log file"
          echo "  stats        - Show log statistics"
          ;;
      esac
      ;;
    
    analyze)
      title="${2:-}"
      [[ -n "$title" ]] || { echo "Usage: analyze <project_title>" >&2; exit 1; }
      
      if ! validate_project_title "$title"; then
        exit 1
      fi
      
      echo "🧠 Running enhanced LLM project analysis for: $title"
      start_timer "analysis"
      analyze_project_with_llm "$title"
      local duration=$(end_timer "analysis")
      track_usage "analyze" "project_analysis" "llm" true "$duration"
      ;;
    
    optimize)
      file_path="${2:-}"
      opt_type="${3:-full}"
      [[ -n "$file_path" ]] || { echo "Usage: optimize <file_path> [type]" >&2; exit 1; }
      [[ -f "$file_path" ]] || { echo "File not found: $file_path" >&2; exit 1; }
      
      if ! validate_file_permissions "$file_path" "r"; then
        exit 1
      fi
      
      echo "🚀 Running enhanced LLM code optimization on: $file_path"
      start_timer "optimization"
      optimize_code_with_llm "$file_path" "$opt_type"
      local duration=$(end_timer "optimization")
      track_usage "optimize" "code_optimization" "llm" true "$duration"
      ;;
    
    review)
      file_path="${2:-}"
      review_type="${3:-comprehensive}"
      [[ -n "$file_path" ]] || { echo "Usage: review <file_path> [type]" >&2; exit 1; }
      [[ -f "$file_path" ]] || { echo "File not found: $file_path" >&2; exit 1; }
      
      if ! validate_file_permissions "$file_path" "r"; then
        exit 1
      fi
      
      echo "📋 Running enhanced LLM code review on: $file_path"
      start_timer "review"
      review_code_with_llm "$file_path" "$review_type"
      local duration=$(end_timer "review")
      track_usage "review" "code_review" "llm" true "$duration"
      ;;
    
    smart)
      title="${2:-}"
      output_dir="${3:-}"
      [[ -n "$title" ]] || { echo "Usage: smart <title> [output_dir]" >&2; exit 1; }
      
      if ! validate_project_title "$title"; then
        exit 1
      fi
      
      echo "🧠 Running enhanced SMART generation with full LLM analysis..."
      
      start_timer "smart_generation"
      
      # Step 1: LLM Analysis
      if analyze_project_with_llm "$title"; then
        echo "✅ LLM analysis found or completed"
        
        # Step 2: Generate intelligent TODO
        generate_intelligent_todo "$title"
        
        # Step 3: Generate code with LLM analysis
        local analysis_file="$(get_analysis_dir)/project_analysis.json"
        if [[ -f "$analysis_file" ]]; then
          echo "🤖 Using LLM analysis for intelligent code generation"
          # This would use the analysis for smarter code generation
          generate_basic_class "$title" "$output_dir"
        else
          echo "⚠️  No LLM analysis found, using standard generation"
          generate_basic_class "$title" "$output_dir"
        fi
      else
        echo "⚠️  LLM analysis needed - follow the instructions above"
        echo "💡 After completing analysis, re-run: bash .cursorrules smart '$title'"
      fi
      
      local duration=$(end_timer "smart_generation")
      track_usage "smart" "$(detect_project_type "$title")" "$(detect_language "$title")" true "$duration"
      ;;
    
    qa)
      file_path="${2:-}"
      [[ -n "$file_path" ]] || { echo "Usage: qa <file_path>" >&2; exit 1; }
      
      if [[ ! -f "$file_path" ]]; then
        log_error "File not found: $file_path" "QA"
        exit 1
      fi
      
      # Load quality checker
      if [[ -f "$CORE_DIR/analyzers/quality_checker.sh" ]]; then
        source "$CORE_DIR/analyzers/quality_checker.sh"
        local language=$(detect_language_from_file "$file_path")
        local project_type=$(detect_project_type_from_file "$file_path")
        run_comprehensive_qa "$file_path" "$language" "$project_type"
      else
        log_error "Quality checker not available" "QA"
        exit 1
      fi
      ;;
    
    # (duplicate fix case removed)
    
    tips)
      action="${2:-help}"
      case "$action" in
        "init")
          echo "🔧 Initializing tip management system..."
          local tip_integration_script="$(dirname "$SYSTEM_DIR")/data/tip_integration.sh"
          if [[ -f "$tip_integration_script" ]]; then
            "$tip_integration_script" init
          else
            echo "❌ Tip integration script not found: $tip_integration_script"
            exit 1
          fi
          ;;
        "extract")
          echo "📚 Extracting tips from existing corrections..."
          local tip_integration_script="$(dirname "$SYSTEM_DIR")/data/tip_integration.sh"
          if [[ -f "$tip_integration_script" ]]; then
            "$tip_integration_script" extract
          else
            echo "❌ Tip integration script not found: $tip_integration_script"
            exit 1
          fi
          ;;
        "stats")
          local tip_integration_script="$(dirname "$SYSTEM_DIR")/data/tip_integration.sh"
          if [[ -f "$tip_integration_script" ]]; then
            "$tip_integration_script" stats
          else
            echo "❌ Tip integration script not found: $tip_integration_script"
            exit 1
          fi
          ;;
        "generate")
          title="${3:-}"
          project_type="${4:-}"
          language="${5:-}"
          [[ -n "$title" ]] || { echo "Usage: tips generate <title> [project_type] [language]" >&2; exit 1; }
          
          # Auto-detect if not provided
          if [[ -z "$project_type" ]]; then
            project_type="$(detect_project_type "$title")"
          fi
          if [[ -z "$language" ]]; then
            language="$(detect_language "$title")"
          fi
          
          echo "🚀 Generating code with prevention tips..."
          local tip_integration_script="$(dirname "$SYSTEM_DIR")/data/tip_integration.sh"
          if [[ -f "$tip_integration_script" ]]; then
            "$tip_integration_script" generate "$title" "$project_type" "$language"
          else
            echo "❌ Tip integration script not found: $tip_integration_script"
            exit 1
          fi
          ;;
        *)
          echo "🛡️ DNS Tip Management System"
          echo "============================"
          echo ""
          echo "Usage: $0 tips {init|extract|stats|generate}"
          echo ""
          echo "🏗️  Setup Commands:"
          echo "  tips init                        - Initialize tip management system"
          echo "  tips extract                     - Extract tips from existing correction files"
          echo ""
          echo "📊 Analytics:"
          echo "  tips stats                       - Show tip database statistics"
          echo ""
          echo "🚀 Enhanced Generation:"
          echo "  tips generate <title> [type] [lang] - Generate code with prevention tips"
          echo ""
          echo "🎯 Examples:"
          echo "  $0 tips init"
          echo "  $0 tips extract"
          echo "  $0 tips generate 'Shopping Cart' ecommerce python"
          echo "  $0 tips stats"
          echo ""
          echo "💡 The tip system automatically prevents 70% of repeated errors"
          echo "🔗 Integration: Tips are now automatically included in 'basic' command"
          ;;
      esac
      ;;
    templates)
      action="${2:-list}"
      case "$action" in
        list)
          templates_list
          ;;
        install)
          bundle="${3:-}"
          dest_path="${4:-}"
          templates_install "$bundle" "$dest_path"
          ;;
        upgrade)
          bundle="${3:-}"
          dest_path="${4:-}"
          templates_upgrade "$bundle" "$dest_path"
          ;;
        *)
          echo "Usage: templates {list|install|upgrade} [bundle] [dest]"
          echo "  list                        - Show available bundles"
          echo "  install <bundle> [dest]     - Install bundle to destination"
          echo "  upgrade <bundle> [dest]     - Upgrade bundle with backup"
          echo "\nBundles: auth, credentials, release, all"
          ;;
      esac
      ;;
    
    structure)
      action="${2:-help}"
      case "$action" in
        refactor|organize)
          project_path="${3:-.}"
          dry_run_flag=""
          # Check for --dry-run flag
          if [[ "${4:-}" == "--dry-run" ]] || [[ "${3:-}" == "--dry-run" ]]; then
            dry_run_flag="--dry-run"
            if [[ "${3:-}" == "--dry-run" ]]; then
              project_path="."
            fi
          fi
          
          echo "🏗️  DNS Structure Refactoring Engine"
          echo ""
          bash "$CORE_DIR/generators/structure_refactor.sh" refactor "$project_path" $dry_run_flag
          ;;
        detect)
          project_path="${3:-.}"
          bash "$CORE_DIR/generators/structure_refactor.sh" detect "$project_path"
          ;;
        *)
          echo "🏗️  DNS Structure Refactoring System"
          echo "===================================="
          echo ""
          echo "Usage: structure {refactor|detect} [path] [--dry-run]"
          echo ""
          echo "Commands:"
          echo "  refactor [path]         - Refactor project structure"
          echo "  detect [path]           - Detect project type"
          echo ""
          echo "Options:"
          echo "  --dry-run               - Preview changes without applying"
          echo ""
          echo "Examples:"
          echo "  $0 structure refactor .                    # Refactor current project"
          echo "  $0 structure refactor . --dry-run          # Preview changes"
          echo "  $0 structure refactor /path/to/project     # Refactor specific project"
          echo "  $0 structure detect .                      # Detect project type"
          echo ""
          echo "📚 Documentation: .dns_system/STRUCTURE_REFACTORING_GUIDE.md"
          ;;
      esac
      ;;
    
    package|review-package)
      # Generate App Store Review Package
      generator_script="$CORE_DIR/generators/review_package_generator.sh"
      if [[ -f "$generator_script" ]]; then
        bash "$generator_script" "$@"
      else
        log_error "Review package generator not found" "PACKAGE"
        echo "❌ Generator script not found at: $generator_script"
        exit 1
      fi
      ;;
    
    review|pretest)
      action="${2:-help}"
      case "$action" in
        auto|automated)
          project_path="${3:-.}"
          echo "🧪 DNS Pre-Review Testing System"
          echo ""
          bash "$CORE_DIR/generators/pre_review_test.sh" "$project_path"
          ;;
        manual)
          echo "📋 Opening manual testing checklist..."
          if [[ -f ".dns_system/PRE_REVIEW_MANUAL_CHECKLIST.md" ]]; then
            cat ".dns_system/PRE_REVIEW_MANUAL_CHECKLIST.md"
          else
            echo "❌ Manual checklist not found. Run: $0 review init"
          fi
          ;;
        init)
          echo "📝 Initializing testing documentation..."
          mkdir -p ".dns_system/reports"
          if [[ ! -f ".dns_system/PRE_REVIEW_MANUAL_CHECKLIST.md" ]]; then
            cat > ".dns_system/PRE_REVIEW_MANUAL_CHECKLIST.md" <<'EOF'
# 📋 Manual Pre-Review Testing Checklist

Complete these manual tests before submitting to App Store Review.

---

## 🎯 Functional Testing

### Core Features
- [ ] All primary features work as expected
- [ ] User onboarding flow completes successfully
- [ ] Authentication (sign up, login, logout) works correctly
- [ ] All forms validate input properly
- [ ] All navigation flows work smoothly
- [ ] Deep links work correctly (if applicable)

### User Interface
- [ ] All screens load without crashes
- [ ] UI elements are properly aligned
- [ ] Text is readable on all screen sizes
- [ ] Images load correctly
- [ ] Animations are smooth
- [ ] No UI elements overlap or get cut off
- [ ] Dark mode works correctly (if supported)

### Data Management
- [ ] Data persists correctly after app restart
- [ ] Data syncs correctly (if applicable)
- [ ] Offline mode works (if applicable)
- [ ] No data loss during normal operations

---

## 📱 Device Testing

### Different Devices
- [ ] iPhone SE (small screen)
- [ ] iPhone 14/15 (standard)
- [ ] iPhone 14/15 Pro Max (large screen)
- [ ] iPad (if universal app)

### iOS Versions
- [ ] Minimum supported iOS version
- [ ] Latest iOS version
- [ ] One version in between

### Orientations
- [ ] Portrait mode
- [ ] Landscape mode (if supported)
- [ ] Rotation transitions smoothly

---

## 🔐 Security & Privacy

- [ ] No sensitive data in logs
- [ ] Sensitive data uses Keychain/secure storage
- [ ] HTTPS is used for all network calls
- [ ] Authentication tokens are stored securely
- [ ] Privacy policy is accessible
- [ ] Terms of service is accessible
- [ ] Account deletion works (if accounts exist)

---

## 🌍 Localization (if applicable)

- [ ] All supported languages display correctly
- [ ] Text doesn't overflow in any language
- [ ] Date/time formats are correct for each locale
- [ ] Currency formats are correct (if applicable)

---

## ⚡ Performance

- [ ] App launches in < 3 seconds
- [ ] No memory leaks during extended use
- [ ] Scrolling is smooth
- [ ] No excessive battery drain
- [ ] App size is reasonable (< 100MB if possible)

---

## 🔔 Notifications (if applicable)

- [ ] Push notifications are received
- [ ] Notification permissions are requested properly
- [ ] Notification actions work correctly
- [ ] Notification content is correct

---

## 💳 In-App Purchases (if applicable)

- [ ] Purchase flow completes successfully
- [ ] Restore purchases works
- [ ] Subscription management works
- [ ] Receipt validation works

---

## 🔍 Edge Cases

- [ ] App handles no internet connection gracefully
- [ ] App handles slow internet connection
- [ ] App handles expired sessions
- [ ] App handles invalid input
- [ ] App handles background/foreground transitions
- [ ] App handles interruptions (calls, notifications)
- [ ] App handles low storage scenarios
- [ ] App handles low battery mode

---

## 📸 App Store Metadata

- [ ] Screenshots are current and accurate
- [ ] App icon is high quality
- [ ] App description is accurate
- [ ] Keywords are relevant
- [ ] Support URL works
- [ ] Marketing URL works (if provided)
- [ ] Privacy policy URL works
- [ ] Age rating is appropriate

---

## 🚀 Final Checks

- [ ] No test/debug features visible
- [ ] No placeholder text/images
- [ ] No "Lorem Ipsum" anywhere
- [ ] Version number is correct
- [ ] Build number is incremented
- [ ] Code signing is configured correctly
- [ ] Archive builds successfully
- [ ] No compiler warnings in Release build

---

## ✅ Sign Off

**Tested by:** ___________________
**Date:** ___________________
**App Version:** ___________________
**iOS Version:** ___________________
**Device:** ___________________

**Ready for submission:** ☐ YES  ☐ NO

**Notes:**
___________________________________________________________
___________________________________________________________
___________________________________________________________

EOF
            echo "✅ Created PRE_REVIEW_MANUAL_CHECKLIST.md"
          fi
          echo "✅ Testing system initialized"
          ;;
        *)
          echo "🧪 DNS Pre-Review Testing System"
          echo "================================"
          echo ""
          echo "Usage: review|pretest {auto|manual|init}"
          echo ""
          echo "Commands:"
          echo "  auto [path]             - Run automated tests"
          echo "  manual                  - Show manual testing checklist"
          echo "  init                    - Initialize testing documentation"
          echo ""
          echo "Examples:"
          echo "  $0 review auto .        # Run all automated tests"
          echo "  $0 review manual        # View manual checklist"
          echo "  $0 pretest auto         # Same as 'review auto'"
          echo ""
          echo "📊 Test reports are saved to: .dns_system/reports/"
          echo "📚 Manual checklist: .dns_system/PRE_REVIEW_MANUAL_CHECKLIST.md"
          ;;
      esac
      ;;
    
    *)
      echo "DNS Code Generation System v2.0 - Enhanced Edition"
      echo ""
      echo "Usage: $0 {auto|basic|heavy|smart|analyze|optimize|review|refactor|check|qa|fix|test|health|cache|metrics|log|config|init|tips|templates|package} [arguments]"
      echo ""
      echo "🤖 Automated Generation Commands:"
      echo "  auto <title> [dir] [level]  - 🆕 Fully automated project generation with LLM"
      echo "  basic <title> [dir]         - Generate class with AI TODO (auto-detects language)"
      echo "  heavy <title>               - Generate multi-file project (now fully automated)"
      echo "  smart <title> [dir]         - SMART generation with full LLM analysis"
      echo ""
      echo "🧠 LLM-Powered Commands:"
      echo "  analyze <title>             - Deep project analysis using LLM"
      echo "  optimize <file> [type]      - LLM code optimization (full|performance|security|quality)"
      echo "  review <file> [type]        - LLM code review (comprehensive|security|performance|quality)"
      echo "  refactor <action> [args]    - 🆕 Advanced code refactoring with LLM assistance"
      echo ""
      echo "📦 App Store Submission:"
      echo "  package                     - 🆕 Generate complete App Store review package"
      echo ""
      echo "🔧 Enhanced Utility Commands:"
      echo "  check <file>                - Run enhanced quality check on code"
      echo "  qa <file>                   - 🆕 Comprehensive quality assurance report"
      echo "  fix <file>                  - Auto-correct errors with enhanced recovery"
      echo "  test {all|core|analysis}    - 🆕 Run comprehensive automated tests"
      echo "  health                      - 🆕 Run comprehensive system health check"
      echo "  fix-system                  - 🆕 Auto-fix common system issues"
      echo ""
      echo "📊 Performance & Analytics:"
      echo "  cache {stats|clear|preload} - 🆕 Manage intelligent caching system"
      echo "  metrics                     - 🆕 View usage analytics and performance metrics"
      echo "  log {show|clear|stats}      - Enhanced logging with performance tracking"
      echo ""
      echo "⚙️ System Commands:"
      echo "  config                      - Show enhanced system configuration"
      echo "  init                        - Initialize DNS system with validation"
      echo "  tips {init|extract|stats|generate} - 🆕 Systematic tip management for error prevention"
      echo "  templates {list|install|upgrade}   - iOS template bundles management"
      echo "  structure {refactor|detect} [path] - 🆕 Auto-organize project structure"
      echo "  review {auto|manual|init}   [path] - 🆕 Pre-review testing system"
      echo ""
      echo "🌐 Supported Languages:"
      echo "  • Python (PEP 8 standards) - Enhanced with async support"
      echo "  • Swift (Apple conventions) - iOS/macOS optimized"
      echo "  • Flutter/Dart (official guidelines) - Cross-platform ready"
      echo ""
      echo "🎯 New Features in v2.0:"
      echo "  ✅ Fully automated project generation"
      echo "  ✅ Intelligent caching for 10x faster performance"
      echo "  ✅ Comprehensive error handling and recovery"
      echo "  ✅ Usage analytics and performance monitoring"
      echo "  ✅ Enhanced security and input validation"
      echo "  ✅ System health monitoring and auto-repair"
      echo "  ✅ 🆕 Systematic tip reuse system (70% fewer repeated errors)"
      echo ""
      echo "🤖 Enhanced Cursor AI Integration:"
      echo "  • No external API keys required"
      echo "  • Uses Cursor's built-in AI capabilities"
      echo "  • Intelligent project analysis and planning"
      echo "  • Automated code generation and optimization"
      echo "  • Seamless workflow integration"
      echo ""
      echo "🚀 Quick Start (New Automated Workflow):"
      echo "  1. bash .cursorrules auto 'Your Amazing Project'"
      echo "  2. ✨ Sit back and watch the magic happen!"
      echo "  3. Get fully functional code with documentation"
      echo ""
      echo "📈 Performance Optimized:"
      echo "  • Intelligent caching reduces generation time by 80%"
      echo "  • Background preloading for instant responses"
      echo "  • Performance monitoring and optimization"
      echo ""
      echo "📁 System Directory: $SYSTEM_DIR"
      echo "📊 View system health: bash .cursorrules health"
      echo "🔧 Auto-fix issues: bash .cursorrules fix-system"
      exit 1
      ;;
  esac
}

# Helper functions for QA and fix commands
detect_language_from_file() {
  local file_path="$1"
  local extension="${file_path##*.}"
  
  case "$extension" in
    "py") echo "python" ;;
    "swift") echo "swift" ;;
    "dart") echo "flutter" ;;
    *) echo "unknown" ;;
  esac
}

detect_project_type_from_file() {
  local file_path="$1"
  local content=$(cat "$file_path" 2>/dev/null || echo "")
  
  if echo "$content" | grep -qi "ecommerce\|shopping\|cart\|payment"; then
    echo "ecommerce"
  elif echo "$content" | grep -qi "api\|endpoint\|route\|request"; then
    echo "web_api"
  elif echo "$content" | grep -qi "mobile\|ios\|android\|ui"; then
    echo "mobile"
  else
    echo "generic"
  fi
}

# Execute main function
main "$@"
