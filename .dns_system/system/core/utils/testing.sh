#!/usr/bin/env bash
# DNS System - Comprehensive Testing Framework
# Automated testing for all system components

# Testing configuration
TEST_DIR="$SYSTEM_DIR/tests"
TEST_RESULTS_DIR="$WORKSPACE_DIR/test_results"
TEST_TIMEOUT=30

# Test result tracking (bash version compatible)
if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
  declare -A TEST_RESULTS
else
  # Fallback for older bash - use simple variables
  TEST_RESULTS_KEYS=""
  TEST_RESULTS_VALUES=""
fi
TEST_TOTAL=0
TEST_PASSED=0
TEST_FAILED=0
TEST_SKIPPED=0

# Initialize testing framework
init_testing() {
  mkdir -p "$TEST_DIR" "$TEST_RESULTS_DIR"
  
  # Clear previous results
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    TEST_RESULTS=()
  else
    TEST_RESULTS_KEYS=""
    TEST_RESULTS_VALUES=""
  fi
  TEST_TOTAL=0
  TEST_PASSED=0
  TEST_FAILED=0
  TEST_SKIPPED=0
  
  log_info "Testing framework initialized" "TEST"
}

# Run a single test
run_test() {
  local test_name="$1"
  local test_function="$2"
  local test_description="${3:-No description}"
  
  ((TEST_TOTAL++))
  
  echo "🧪 Running test: $test_name"
  echo "   Description: $test_description"
  
  local start_time=$(date +%s.%N)
  local test_output=""
  local test_result=""
  
  # Run test with timeout
  if timeout "$TEST_TIMEOUT" bash -c "$test_function" >"$TEST_RESULTS_DIR/${test_name}.log" 2>&1; then
    test_result="PASS"
    ((TEST_PASSED++))
    echo "   ✅ PASSED"
  else
    local exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
      test_result="TIMEOUT"
      echo "   ⏰ TIMEOUT (${TEST_TIMEOUT}s)"
    else
      test_result="FAIL"
      ((TEST_FAILED++))
      echo "   ❌ FAILED"
    fi
  fi
  
  local end_time=$(date +%s.%N)
  local duration
  if command -v bc >/dev/null 2>&1; then
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
  else
    duration=$(awk "BEGIN {print $end_time - $start_time}" 2>/dev/null || echo "0")
  fi
  
  # Store test result (bash version compatible)
  if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
    TEST_RESULTS["$test_name"]="$test_result:$duration:$test_description"
  else
    # Fallback for older bash - append to simple variables
    TEST_RESULTS_KEYS="$TEST_RESULTS_KEYS $test_name"
    TEST_RESULTS_VALUES="$TEST_RESULTS_VALUES $test_result:$duration:$test_description"
  fi
  
  # Log test result
  log_info "Test $test_name: $test_result (${duration}s)" "TEST"
}

# Assert functions for tests
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-Assertion failed}"
  
  if [[ "$expected" == "$actual" ]]; then
    return 0
  else
    echo "ASSERTION FAILED: $message"
    echo "  Expected: '$expected'"
    echo "  Actual: '$actual'"
    return 1
  fi
}

assert_not_empty() {
  local value="$1"
  local message="${2:-Value should not be empty}"
  
  if [[ -n "$value" ]]; then
    return 0
  else
    echo "ASSERTION FAILED: $message"
    echo "  Value is empty"
    return 1
  fi
}

assert_file_exists() {
  local file_path="$1"
  local message="${2:-File should exist}"
  
  if [[ -f "$file_path" ]]; then
    return 0
  else
    echo "ASSERTION FAILED: $message"
    echo "  File does not exist: $file_path"
    return 1
  fi
}

assert_command_success() {
  local command="$1"
  local message="${2:-Command should succeed}"
  
  if eval "$command" >/dev/null 2>&1; then
    return 0
  else
    echo "ASSERTION FAILED: $message"
    echo "  Command failed: $command"
    return 1
  fi
}

# Test system components
test_naming_utilities() {
  # Test snake_case conversion
  local result=$(to_snake "Test Project Name")
  assert_equals "test_project_name" "$result" "Snake case conversion failed"
  
  # Test PascalCase conversion
  result=$(to_pascal "test project name")
  assert_equals "TestProjectName" "$result" "Pascal case conversion failed"
  
  # Test kebab-case conversion
  result=$(to_kebab "Test Project Name")
  assert_equals "test-project-name" "$result" "Kebab case conversion failed"
  
  return 0
}

test_directory_utilities() {
  # Test output directory detection
  local temp_dir="/tmp/dns_test_$$"
  mkdir -p "$temp_dir/src"
  
  local result=$(detect_output_directory "" "$temp_dir")
  assert_equals "$temp_dir/src" "$result" "Output directory detection failed"
  
  # Test TODO directory generation
  result=$(get_todo_dir "Test Project" "$temp_dir")
  assert_not_empty "$result" "TODO directory generation failed"
  
  # Cleanup
  rm -rf "$temp_dir"
  
  return 0
}

test_validation_system() {
  # Test input sanitization
  local result=$(sanitize_input "test;rm -rf /" "command")
  assert_equals "testrm -rf /" "$result" "Command sanitization failed"
  
  # Test project title validation
  if validate_project_title "Valid Project Name"; then
    echo "Project title validation passed"
  else
    echo "ASSERTION FAILED: Valid project title rejected"
    return 1
  fi
  
  # Test invalid project title
  if ! validate_project_title ""; then
    echo "Empty project title correctly rejected"
  else
    echo "ASSERTION FAILED: Empty project title accepted"
    return 1
  fi
  
  return 0
}

test_caching_system() {
  # Initialize cache for testing
  init_cache
  
  # Test cache set/get
  set_cache "test_key" "test_value"
  local result=$(get_cache "test_key")
  assert_equals "test_value" "$result" "Cache set/get failed"
  
  # Test cache miss
  if get_cache "nonexistent_key" >/dev/null 2>&1; then
    echo "ASSERTION FAILED: Cache miss should return error"
    return 1
  else
    echo "Cache miss correctly handled"
  fi
  
  # Test cache key generation
  result=$(generate_cache_key "test input" "prefix")
  assert_not_empty "$result" "Cache key generation failed"
  
  return 0
}

test_language_detection() {
  # Test Python detection
  local result=$(detect_language "Python web API")
  assert_equals "python" "$result" "Python detection failed"
  
  # Test Swift detection
  result=$(detect_language "iOS Swift app")
  assert_equals "swift" "$result" "Swift detection failed"
  
  # Test Flutter detection
  result=$(detect_language "Flutter mobile widget")
  assert_equals "flutter" "$result" "Flutter detection failed"
  
  return 0
}

test_project_type_detection() {
  # Test web API detection
  local result=$(detect_project_type "REST API server")
  assert_equals "web_api" "$result" "Web API detection failed"
  
  # Test database detection
  result=$(detect_project_type "Database management system")
  assert_equals "database" "$result" "Database detection failed"
  
  # Test e-commerce detection
  result=$(detect_project_type "Online shopping platform")
  assert_equals "ecommerce" "$result" "E-commerce detection failed"
  
  return 0
}

test_logging_system() {
  # Test basic logging
  log_info "Test log message" "TEST"
  
  # Test performance timing
  start_timer "test_timer"
  sleep 0.1
  local duration=$(end_timer "test_timer")
  
  # Duration should be approximately 0.1 seconds
  if command -v bc >/dev/null 2>&1; then
    if (( $(echo "$duration > 0.05" | bc -l) )) && (( $(echo "$duration < 0.2" | bc -l) )); then
      echo "Performance timing test passed"
    else
      echo "ASSERTION FAILED: Performance timing inaccurate: $duration"
      return 1
    fi
  else
    # Fallback test without bc
    if awk "BEGIN {exit !($duration > 0.05 && $duration < 0.2)}" 2>/dev/null; then
      echo "Performance timing test passed"
    else
      echo "ASSERTION FAILED: Performance timing inaccurate: $duration"
      return 1
    fi
  fi
  
  return 0
}

test_error_detection() {
  # Create a test Python file with errors
  local test_file="/tmp/test_error_detection_$$.py"
  cat > "$test_file" << 'EOF'
# Test file with intentional errors
def test_function()
    print("Missing colon")
    return True

if __name__ == "__main__":
    test_function()
EOF
  
  # Test syntax error detection
  if detect_syntax_errors "$test_file" "python" 2>/dev/null; then
    echo "ASSERTION FAILED: Syntax errors not detected"
    rm -f "$test_file"
    return 1
  else
    echo "Syntax error detection passed"
  fi
  
  # Cleanup
  rm -f "$test_file"
  
  return 0
}

test_code_generation() {
  local temp_dir="/tmp/dns_codegen_test_$$"
  mkdir -p "$temp_dir"
  
  # Test basic code generation
  if generate_basic_class "Test Project" "$temp_dir"; then
    echo "Code generation completed"
    
    # Check if file was created
    local expected_file="$temp_dir/test_project.py"
    assert_file_exists "$expected_file" "Generated code file not found"
    
    # Check if file contains expected content
    if grep -q "class TestProject" "$expected_file"; then
      echo "Generated code contains expected class"
    else
      echo "ASSERTION FAILED: Generated code missing expected class"
      rm -rf "$temp_dir"
      return 1
    fi
  else
    echo "ASSERTION FAILED: Code generation failed"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Cleanup
  rm -rf "$temp_dir"
  
  return 0
}

test_system_integration() {
  # Test full workflow
  local temp_dir="/tmp/dns_integration_test_$$"
  mkdir -p "$temp_dir"
  
  # Change to temp directory for testing
  local original_dir=$(pwd)
  cd "$temp_dir"
  
  # Initialize system
  if init_system; then
    echo "System initialization passed"
  else
    echo "ASSERTION FAILED: System initialization failed"
    cd "$original_dir"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Test basic generation workflow
  local test_title="Integration Test Project"
  
  # Generate project metadata
  eval "$(generate_project_meta "$test_title")"
  assert_not_empty "$SNAKE_NAME" "Project metadata generation failed"
  
  # Test TODO generation
  if generate_fallback_todo "$test_title"; then
    echo "TODO generation passed"
  else
    echo "ASSERTION FAILED: TODO generation failed"
    cd "$original_dir"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Cleanup
  cd "$original_dir"
  rm -rf "$temp_dir"
  
  return 0
}

# Run all tests
run_all_tests() {
  echo "🧪 DNS System Comprehensive Test Suite"
  echo "======================================"
  echo ""
  
  init_testing
  start_timer "full_test_suite"
  
  # Core utility tests
  echo "📦 Testing Core Utilities..."
  run_test "naming_utilities" "test_naming_utilities" "Test naming convention functions"
  run_test "directory_utilities" "test_directory_utilities" "Test directory management functions"
  run_test "validation_system" "test_validation_system" "Test input validation and sanitization"
  run_test "caching_system" "test_caching_system" "Test intelligent caching system"
  
  echo ""
  echo "🔍 Testing Analysis Components..."
  run_test "language_detection" "test_language_detection" "Test programming language detection"
  run_test "project_type_detection" "test_project_type_detection" "Test project type classification"
  
  echo ""
  echo "📊 Testing System Components..."
  run_test "logging_system" "test_logging_system" "Test logging and performance monitoring"
  run_test "error_detection" "test_error_detection" "Test code error detection"
  
  echo ""
  echo "🏗️ Testing Code Generation..."
  run_test "code_generation" "test_code_generation" "Test basic code generation workflow"
  
  echo ""
  echo "🔗 Testing System Integration..."
  run_test "system_integration" "test_system_integration" "Test full system workflow"
  
  local duration=$(end_timer "full_test_suite")
  
  # Generate test report
  generate_test_report "$duration"
  
  # Return appropriate exit code
  if [[ $TEST_FAILED -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

# Generate comprehensive test report
generate_test_report() {
  local total_duration="$1"
  local report_file="$TEST_RESULTS_DIR/test_report.md"
  
  echo ""
  echo "📊 Test Results Summary"
  echo "======================"
  echo "Total Tests: $TEST_TOTAL"
  echo "Passed: $TEST_PASSED"
  echo "Failed: $TEST_FAILED"
  echo "Skipped: $TEST_SKIPPED"
  echo "Success Rate: $(( TEST_PASSED * 100 / TEST_TOTAL ))%"
  echo "Total Duration: ${total_duration}s"
  echo ""
  
  # Generate detailed report
  cat > "$report_file" << EOF
# DNS System Test Report
Generated on: $(date)

## Summary
- **Total Tests**: $TEST_TOTAL
- **Passed**: $TEST_PASSED ✅
- **Failed**: $TEST_FAILED ❌
- **Skipped**: $TEST_SKIPPED ⏭️
- **Success Rate**: $(( TEST_PASSED * 100 / TEST_TOTAL ))%
- **Total Duration**: ${total_duration}s

## Detailed Results

EOF

  # Add detailed results
  for test_name in "${!TEST_RESULTS[@]}"; do
    local result_data="${TEST_RESULTS[$test_name]}"
    local result=$(echo "$result_data" | cut -d: -f1)
    local duration=$(echo "$result_data" | cut -d: -f2)
    local description=$(echo "$result_data" | cut -d: -f3-)
    
    local status_icon="❌"
    case "$result" in
      "PASS") status_icon="✅" ;;
      "TIMEOUT") status_icon="⏰" ;;
      "SKIP") status_icon="⏭️" ;;
    esac
    
    echo "### $test_name $status_icon" >> "$report_file"
    echo "- **Status**: $result" >> "$report_file"
    echo "- **Duration**: ${duration}s" >> "$report_file"
    echo "- **Description**: $description" >> "$report_file"
    echo "" >> "$report_file"
  done
  
  echo "📄 Detailed report saved to: $report_file"
  
  # Log test completion
  log_info "Test suite completed: $TEST_PASSED/$TEST_TOTAL passed (${total_duration}s)" "TEST"
  track_usage "test_suite" "system_testing" "framework" true "$total_duration"
}

# Run specific test category
run_test_category() {
  local category="$1"
  
  init_testing
  
  case "$category" in
    "core")
      echo "🧪 Running Core Utility Tests..."
      run_test "naming_utilities" "test_naming_utilities" "Test naming convention functions"
      run_test "directory_utilities" "test_directory_utilities" "Test directory management functions"
      run_test "validation_system" "test_validation_system" "Test input validation and sanitization"
      ;;
    "analysis")
      echo "🧪 Running Analysis Tests..."
      run_test "language_detection" "test_language_detection" "Test programming language detection"
      run_test "project_type_detection" "test_project_type_detection" "Test project type classification"
      ;;
    "generation")
      echo "🧪 Running Code Generation Tests..."
      run_test "code_generation" "test_code_generation" "Test basic code generation workflow"
      ;;
    "integration")
      echo "🧪 Running Integration Tests..."
      run_test "system_integration" "test_system_integration" "Test full system workflow"
      ;;
    *)
      echo "❌ Unknown test category: $category"
      echo "Available categories: core, analysis, generation, integration"
      return 1
      ;;
  esac
  
  generate_test_report "0"
}

# Export functions
export -f init_testing
export -f run_test
export -f assert_equals
export -f assert_not_empty
export -f assert_file_exists
export -f assert_command_success
export -f run_all_tests
export -f run_test_category
export -f generate_test_report
