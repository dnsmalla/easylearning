#!/usr/bin/env bash
# DNS System - LLM-Powered Intelligent Analysis
# Uses Cursor AI for deep project analysis and intelligent decision making

# Generate comprehensive project analysis using LLM
analyze_project_with_llm() {
  local title="$1"
  local analysis_dir="$(get_analysis_dir)"
  mkdir -p "$analysis_dir"
  
  local analysis_prompt="$analysis_dir/project_analysis_prompt.md"
  local analysis_result="$analysis_dir/project_analysis.json"
  
  log_info "Generating LLM project analysis for: $title" "LLM_ANALYZER"
  
  # Create comprehensive analysis prompt
  cat > "$analysis_prompt" << EOF
# 🧠 Intelligent Project Analysis Request

## Project to Analyze
**Project Title**: $title

## Analysis Requirements

Please provide a comprehensive analysis of this project in JSON format:

\`\`\`json
{
  "project_analysis": {
    "title": "$title",
    "primary_language": "python|swift|flutter|javascript|java|go|rust",
    "language_confidence": 0.95,
    "language_reasoning": "Explanation of why this language was chosen",
    
    "project_type": "web_api|database|mobile|ecommerce|social|dashboard|file_ops|processing|management|generation",
    "type_confidence": 0.90,
    "type_reasoning": "Explanation of project type classification",
    
    "complexity": "basic|medium|heavy",
    "complexity_reasoning": "Why this complexity level",
    
    "architecture": {
      "pattern": "mvc|mvvm|clean|microservices|monolith",
      "components": ["component1", "component2"],
      "data_flow": "description of data flow"
    },
    
    "technologies": {
      "frameworks": ["framework1", "framework2"],
      "databases": ["database1", "database2"],
      "external_apis": ["api1", "api2"],
      "tools": ["tool1", "tool2"]
    },
    
    "core_features": [
      {
        "feature": "feature_name",
        "priority": "high|medium|low",
        "complexity": "simple|moderate|complex",
        "description": "detailed description"
      }
    ],
    
    "required_methods": [
      {
        "method_name": "method_name",
        "purpose": "what it does",
        "parameters": ["param1", "param2"],
        "return_type": "return type",
        "complexity": "simple|moderate|complex"
      }
    ],
    
    "challenges": [
      {
        "challenge": "challenge description",
        "impact": "high|medium|low",
        "solution_approach": "how to address it"
      }
    ],
    
    "recommendations": {
      "development_approach": "recommendation",
      "testing_strategy": "testing approach",
      "deployment_strategy": "deployment approach",
      "security_considerations": ["security1", "security2"]
    }
  }
}
\`\`\`

## Instructions
1. Analyze the project title and infer the requirements
2. Consider modern best practices and industry standards
3. Be specific and actionable in your recommendations
4. Focus on practical implementation details
5. Consider scalability and maintainability

## Output
Save your analysis as valid JSON to: $analysis_result
EOF

  log_ai_interaction "ANALYSIS_PROMPT_GENERATED" "Prompt file: $analysis_prompt"
  
  echo ""
  echo "🧠 LLM PROJECT ANALYSIS NEEDED"
  echo "==============================="
  echo "📁 Prompt file: $analysis_prompt"
  echo "💾 Save result to: $analysis_result"
  echo ""
  echo "🤖 NEXT STEPS:"
  echo "1. Open the prompt file above"
  echo "2. Ask Cursor AI to analyze the project"
  echo "3. Save the JSON response to the result file"
  echo "4. Re-run the system to use the analysis"
  echo ""
  echo "💡 Quick command:"
  echo "   Ask Cursor AI: 'Analyze the project following the prompt in $analysis_prompt'"
  echo ""
  
  # Check if analysis already exists
  if [[ -f "$analysis_result" ]]; then
    log_info "Found existing LLM analysis: $analysis_result" "LLM_ANALYZER"
    return 0
  else
    log_info "Waiting for LLM analysis to be generated" "LLM_ANALYZER"
    return 1
  fi
}

# Load and parse LLM project analysis
load_llm_analysis() {
  local analysis_file="$1"
  
  if [[ ! -f "$analysis_file" ]]; then
    log_error "Analysis file not found: $analysis_file" "LLM_ANALYZER"
    return 1
  fi
  
  # Validate JSON format
  if ! python3 -m json.tool "$analysis_file" >/dev/null 2>&1; then
    log_error "Invalid JSON format in analysis file" "LLM_ANALYZER"
    return 1
  fi
  
  log_info "Successfully loaded LLM analysis" "LLM_ANALYZER"
  return 0
}

# Extract specific values from LLM analysis
get_analysis_value() {
  local analysis_file="$1"
  local json_path="$2"
  
  # Use python to extract JSON values
  python3 -c "
import json
import sys

try:
    with open('$analysis_file', 'r') as f:
        data = json.load(f)
    
    # Navigate JSON path (e.g., 'project_analysis.primary_language')
    keys = '$json_path'.split('.')
    value = data
    for key in keys:
        value = value[key]
    
    print(value)
except Exception as e:
    sys.exit(1)
" 2>/dev/null
}

# Generate intelligent code based on LLM analysis
generate_code_with_llm() {
  local analysis_file="$1"
  local output_file="$2"
  local code_prompt_file="$WORKSPACE_DIR/corrections/intelligent_code_prompt.md"
  
  mkdir -p "$(dirname "$code_prompt_file")"
  
  log_info "Generating intelligent code prompt" "LLM_CODEGEN"
  
  cat > "$code_prompt_file" << EOF
# 🤖 Intelligent Code Generation Request

## Project Analysis
\`\`\`json
$(cat "$analysis_file")
\`\`\`

## 🚨 CRITICAL REQUIREMENTS (Must Fix)

### 1. **Template Placeholders - NEVER LEAVE EMPTY**
🔴 **CRITICAL**: Fill ALL template placeholders with meaningful values
- ❌ NEVER use: \`"type": ""\`, \`"Project type: "\`, \`"Features: - "\`
- ✅ ALWAYS use: \`"type": "specific_project_type"\`, \`"Project type: detailed_description"\`
- Validate all variables before substitution
- Use meaningful defaults when type cannot be determined

### 2. **Conditional Logic - MUST BE REACHABLE**
🔴 **CRITICAL**: Ensure all conditional statements can execute
- ❌ NEVER use: \`if "" == "web_api":\` (will NEVER be true)
- ✅ ALWAYS use: \`if project_type == "web_api":\` (with actual variables)
- Use configuration values or variables in conditionals
- Implement proper type checking logic

### 3. **Required Imports - MUST BE COMPLETE**
🔴 **CRITICAL**: Include ALL necessary imports for the target language

**Python Requirements:**
\`\`\`python
from __future__ import annotations
import logging
from datetime import datetime
from typing import Optional, Dict, List, Any, Union
# Add other imports based on functionality
\`\`\`

**Swift Requirements:**
\`\`\`swift
import Foundation
import os.log        // For Logger class
import UIKit         // For UI components (if needed)
\`\`\`

**Dart/Flutter Requirements:**
\`\`\`dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
\`\`\`

## Code Generation Requirements

Based on the above analysis, generate production-ready code that includes:

### 1. **Language-Specific Implementation**
- Use the detected primary language and follow its conventions
- Apply the appropriate coding standards from: \`.dns_system/.cursor/rules/[language].mdc\`
- Include proper imports and dependencies
- **CRITICAL**: Validate all template variables are filled

### 2. **Architecture Implementation**
- Follow the recommended architecture pattern
- Implement the suggested components
- Use appropriate design patterns
- **CRITICAL**: Ensure conditional logic uses actual variables

### 3. **Core Features - REAL IMPLEMENTATION**
- Implement all high-priority features from the analysis
- Create methods for each required functionality with ACTUAL business logic
- ❌ AVOID generic placeholders like: \`return {"executed": True}\`
- ✅ PROVIDE specific implementations for the project domain
- Include proper error handling and validation

### 4. **Best Practices**
- Add comprehensive documentation with examples
- Include type hints/annotations for all methods
- Implement structured logging with meaningful messages
- Add robust configuration management
- Include unit test structure and examples

### 5. **Error Handling - COMPREHENSIVE**
- Use custom exception classes where appropriate
- Provide meaningful error messages
- Implement proper error propagation
- Add logging for debugging and monitoring
- Handle edge cases and validation failures

### 6. **Code Quality Standards**
- Break down long methods (max 20-30 lines)
- Follow single responsibility principle
- Avoid nested try-catch blocks
- Use descriptive variable and method names
- Add comprehensive docstrings

## 🔍 Quality Validation Checklist

Before submitting code, verify:
- [ ] All template placeholders filled with meaningful values
- [ ] All conditional statements use variables (not empty strings)
- [ ] All required imports included for target language
- [ ] Business logic implemented (not just generic templates)
- [ ] Error handling comprehensive and meaningful
- [ ] Documentation complete with examples
- [ ] Code follows language-specific conventions
- [ ] No syntax errors or missing dependencies
- [ ] Methods have single responsibility
- [ ] Configuration properly structured

## Output Requirements
- Generate complete, runnable code with ZERO placeholders
- Include all necessary imports and dependencies
- Add comprehensive comments and documentation
- Follow the exact file structure needed
- Make it production-ready with real business logic
- **CRITICAL**: Ensure code can run immediately without errors

## Target File
Save the generated code to: $output_file
EOF

  log_ai_interaction "CODE_GENERATION_PROMPT" "Prompt: $code_prompt_file"
  
  echo ""
  echo "🤖 INTELLIGENT CODE GENERATION NEEDED"
  echo "====================================="
  echo "📁 Prompt file: $code_prompt_file"
  echo "💾 Target file: $output_file"
  echo ""
  echo "🤖 NEXT STEPS:"
  echo "1. Open the prompt file above"
  echo "2. Ask Cursor AI to generate the code"
  echo "3. Save the result to the target file"
  echo "4. System will automatically validate the code"
  echo ""
  echo "💡 Quick command:"
  echo "   Ask Cursor AI: 'Generate intelligent code following the prompt in $code_prompt_file'"
  echo ""
}

# Validate LLM-generated code
validate_llm_code() {
  local file_path="$1"
  local analysis_file="$2"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Generated code file not found: $file_path" "LLM_VALIDATOR"
    return 1
  fi
  
  log_info "Validating LLM-generated code" "LLM_VALIDATOR"
  
  # Get expected language from analysis
  local expected_language=$(get_analysis_value "$analysis_file" "project_analysis.primary_language")
  
  # Validate file extension matches expected language
  local file_ext="${file_path##*.}"
  local expected_ext=$(get_file_extension "$expected_language")
  
  if [[ "$file_ext" != "$expected_ext" ]]; then
    log_warn "File extension mismatch: expected .$expected_ext, got .$file_ext" "LLM_VALIDATOR"
  fi
  
  # Run syntax and quality checks
  run_quality_check "$file_path" "$expected_language"
  
  return $?
}

# Export functions
export -f analyze_project_with_llm
export -f load_llm_analysis
export -f get_analysis_value
export -f generate_code_with_llm
export -f validate_llm_code
