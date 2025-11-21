#!/usr/bin/env bash
#
# pre_review_test.sh
# DNS System - Comprehensive Pre-Review Testing System
# Tests all requirements before App Store submission
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0
SKIPPED_TESTS=0

# Test report file
REPORT_FILE=""
TEST_START_TIME=""

# Initialize test system
init_test_system() {
  TEST_START_TIME=$(date +%s)
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  REPORT_FILE="/tmp/dns_pre_review_test_${timestamp}.md"
  
  cat > "$REPORT_FILE" <<EOF
# 📋 Pre-Review Test Report

**Date:** $(date +"%Y-%m-%d %H:%M:%S")
**Project:** $(basename "$(pwd)")

---

## Test Results Summary

EOF
}

# Print section header
print_section() {
  local title="$1"
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                                                        ║${NC}"
  printf "${BLUE}║${NC}  %-52s${BLUE}║${NC}\n" "$title"
  echo -e "${BLUE}║                                                        ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  echo "### $title" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
}

# Test result logging
log_test() {
  local test_name="$1"
  local status="$2"
  local message="${3:-}"
  
  ((TOTAL_TESTS++))
  
  case "$status" in
    "PASS")
      ((PASSED_TESTS++))
      echo -e "  ${GREEN}✅ PASS${NC} - $test_name"
      echo "- ✅ **PASS** - $test_name" >> "$REPORT_FILE"
      ;;
    "FAIL")
      ((FAILED_TESTS++))
      echo -e "  ${RED}❌ FAIL${NC} - $test_name"
      [[ -n "$message" ]] && echo -e "    ${RED}↳${NC} $message"
      echo "- ❌ **FAIL** - $test_name" >> "$REPORT_FILE"
      [[ -n "$message" ]] && echo "  - Error: $message" >> "$REPORT_FILE"
      ;;
    "WARN")
      ((WARNING_TESTS++))
      echo -e "  ${YELLOW}⚠️  WARN${NC} - $test_name"
      [[ -n "$message" ]] && echo -e "    ${YELLOW}↳${NC} $message"
      echo "- ⚠️  **WARN** - $test_name" >> "$REPORT_FILE"
      [[ -n "$message" ]] && echo "  - Warning: $message" >> "$REPORT_FILE"
      ;;
    "SKIP")
      ((SKIPPED_TESTS++))
      echo -e "  ${BLUE}⏭️  SKIP${NC} - $test_name"
      [[ -n "$message" ]] && echo -e "    ${BLUE}↳${NC} $message"
      echo "- ⏭️  **SKIP** - $test_name" >> "$REPORT_FILE"
      [[ -n "$message" ]] && echo "  - Reason: $message" >> "$REPORT_FILE"
      ;;
  esac
  
  echo "" >> "$REPORT_FILE"
}

# ==========================================
# PROJECT STRUCTURE TESTS
# ==========================================

test_project_structure() {
  print_section "1. PROJECT STRUCTURE VERIFICATION"
  
  local project_dir="$1"
  
  # Test: Xcode project exists
  if ls "$project_dir"/*.xcodeproj >/dev/null 2>&1; then
    log_test "Xcode project file exists" "PASS"
  else
    log_test "Xcode project file exists" "FAIL" "No .xcodeproj found"
  fi
  
  # Test: project.yml exists (for XcodeGen)
  if [[ -f "$project_dir/project.yml" ]]; then
    log_test "project.yml configuration exists" "PASS"
  else
    log_test "project.yml configuration exists" "SKIP" "Not using XcodeGen"
  fi
  
  # Test: Info.plist exists
  if find "$project_dir" -name "Info.plist" -type f | grep -q .; then
    log_test "Info.plist exists" "PASS"
  else
    log_test "Info.plist exists" "FAIL" "Info.plist not found"
  fi
  
  # Test: GoogleService-Info.plist exists (if using Firebase)
  if find "$project_dir" -name "GoogleService-Info.plist" -type f | grep -q .; then
    log_test "GoogleService-Info.plist exists" "PASS"
  else
    log_test "GoogleService-Info.plist exists" "WARN" "Not found - skip if not using Firebase"
  fi
  
  # Test: Assets.xcassets exists
  if find "$project_dir" -name "Assets.xcassets" -type d | grep -q .; then
    log_test "Assets.xcassets exists" "PASS"
  else
    log_test "Assets.xcassets exists" "FAIL" "Asset catalog not found"
  fi
}

# ==========================================
# BUILD TESTS
# ==========================================

test_build_configuration() {
  print_section "2. BUILD CONFIGURATION TESTS"
  
  local project_dir="$1"
  local project_file=$(find "$project_dir" -name "*.xcodeproj" -type d | head -1)
  
  if [[ -z "$project_file" ]]; then
    log_test "Project file available for testing" "FAIL" "No .xcodeproj found"
    return 1
  fi
  
  local project_name=$(basename "$project_file" .xcodeproj)
  
  # Test: Clean build succeeds
  echo "  🔨 Building project (this may take a minute)..."
  if xcodebuild -project "$project_file" \
                -scheme "$project_name" \
                -configuration Debug \
                clean build \
                CODE_SIGNING_ALLOWED=NO \
                >/tmp/build_test.log 2>&1; then
    log_test "Clean build succeeds (Debug)" "PASS"
  else
    log_test "Clean build succeeds (Debug)" "FAIL" "Build failed - check /tmp/build_test.log"
  fi
  
  # Test: Release build succeeds
  echo "  🔨 Testing Release build..."
  if xcodebuild -project "$project_file" \
                -scheme "$project_name" \
                -configuration Release \
                build \
                CODE_SIGNING_ALLOWED=NO \
                >/tmp/build_release_test.log 2>&1; then
    log_test "Release build succeeds" "PASS"
  else
    log_test "Release build succeeds" "FAIL" "Release build failed"
  fi
  
  # Test: No build warnings (critical ones)
  local warning_count=$(grep "warning:" /tmp/build_test.log 2>/dev/null | wc -l | tr -d ' ')
  if [[ -z "$warning_count" ]] || [[ "$warning_count" == "0" ]]; then
    log_test "No build warnings" "PASS"
  elif [[ $warning_count -lt 5 ]]; then
    log_test "No build warnings" "WARN" "$warning_count warnings found"
  else
    log_test "No build warnings" "FAIL" "$warning_count warnings found"
  fi
  
  # Test: No deprecated API usage
  if grep -q "deprecated" /tmp/build_test.log 2>/dev/null; then
    log_test "No deprecated API usage" "WARN" "Deprecated APIs detected"
  else
    log_test "No deprecated API usage" "PASS"
  fi
}

# ==========================================
# CODE QUALITY TESTS
# ==========================================

test_code_quality() {
  print_section "3. CODE QUALITY TESTS"
  
  local project_dir="$1"
  local source_dir=$(find "$project_dir" -type d -name "Sources" | head -1)
  
  if [[ -z "$source_dir" ]]; then
    source_dir="$project_dir"
  fi
  
  # Test: No force unwraps (!)
  local force_unwrap_count=$(find "$source_dir" -name "*.swift" -type f -exec grep -c "!" {} \; 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")
  if [[ $force_unwrap_count -eq 0 ]]; then
    log_test "No force unwraps (!)" "PASS"
  elif [[ $force_unwrap_count -lt 10 ]]; then
    log_test "No force unwraps (!)" "WARN" "$force_unwrap_count found - review for safety"
  else
    log_test "No force unwraps (!)" "FAIL" "$force_unwrap_count found - high crash risk"
  fi
  
  # Test: No print statements in production code
  local print_count=$(find "$source_dir" -name "*.swift" -type f -exec grep -c "print(" {} \; 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")
  if [[ $print_count -eq 0 ]]; then
    log_test "No debug print statements" "PASS"
  elif [[ $print_count -lt 5 ]]; then
    log_test "No debug print statements" "WARN" "$print_count print() calls found"
  else
    log_test "No debug print statements" "FAIL" "$print_count print() calls - remove for production"
  fi
  
  # Test: Proper error handling
  local throw_count=$(find "$source_dir" -name "*.swift" -type f -exec grep -c "throw\|throws" {} \; 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")
  local catch_count=$(find "$source_dir" -name "*.swift" -type f -exec grep -c "catch\|try" {} \; 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")
  if [[ $catch_count -gt 0 ]]; then
    log_test "Error handling implemented" "PASS"
  else
    log_test "Error handling implemented" "WARN" "Consider adding error handling"
  fi
  
  # Test: Code file organization
  local swift_file_count=$(find "$source_dir" -name "*.swift" -type f | wc -l | xargs)
  if [[ $swift_file_count -gt 50 ]]; then
    log_test "Code organization" "WARN" "$swift_file_count Swift files - consider refactoring"
  else
    log_test "Code organization" "PASS" "$swift_file_count Swift files"
  fi
}

# ==========================================
# APP STORE COMPLIANCE TESTS
# ==========================================

test_app_store_compliance() {
  print_section "4. APP STORE COMPLIANCE TESTS"
  
  local project_dir="$1"
  
  # Test: Bundle identifier is not placeholder
  local bundle_id=$(find "$project_dir" -name "Info.plist" -type f -exec plutil -extract CFBundleIdentifier raw -o - {} \; 2>/dev/null | head -1)
  if [[ -n "$bundle_id" && "$bundle_id" != *"company"* && "$bundle_id" != *"example"* ]]; then
    log_test "Valid bundle identifier" "PASS" "$bundle_id"
  else
    log_test "Valid bundle identifier" "FAIL" "Placeholder bundle ID detected: $bundle_id"
  fi
  
  # Test: App icon exists
  if find "$project_dir" -path "*/Assets.xcassets/AppIcon.appiconset/Contents.json" -type f | grep -q .; then
    log_test "App icon configured" "PASS"
  else
    log_test "App icon configured" "FAIL" "AppIcon asset not found"
  fi
  
  # Test: Version and build number set
  local version=$(find "$project_dir" -name "Info.plist" -type f -exec plutil -extract CFBundleShortVersionString raw -o - {} \; 2>/dev/null | head -1)
  local build=$(find "$project_dir" -name "Info.plist" -type f -exec plutil -extract CFBundleVersion raw -o - {} \; 2>/dev/null | head -1)
  if [[ -n "$version" && -n "$build" ]]; then
    log_test "Version numbers set" "PASS" "Version: $version, Build: $build"
  else
    log_test "Version numbers set" "FAIL" "Version or build number missing"
  fi
  
  # Test: Privacy policy URL configured
  if grep -r "privacyPolicyURL\|PRIVACY_URL" "$project_dir" --include="*.swift" --include="*.plist" | grep -v "example.com" | grep -q .; then
    log_test "Privacy policy URL configured" "PASS"
  else
    log_test "Privacy policy URL configured" "WARN" "Privacy policy URL may not be set"
  fi
  
  # Test: Terms of service URL configured
  if grep -r "termsOfServiceURL\|TERMS_URL" "$project_dir" --include="*.swift" --include="*.plist" | grep -v "example.com" | grep -q .; then
    log_test "Terms of service URL configured" "PASS"
  else
    log_test "Terms of service URL configured" "WARN" "Terms URL may not be set"
  fi
  
  # Test: Account deletion implemented (if using authentication)
  if grep -r "deleteAccount\|account.*delete" "$project_dir" --include="*.swift" -i | grep -q .; then
    log_test "Account deletion implemented (5.1.1v)" "PASS"
  else
    log_test "Account deletion implemented (5.1.1v)" "WARN" "Required if app has accounts"
  fi
}

# ==========================================
# SECURITY TESTS
# ==========================================

test_security() {
  print_section "5. SECURITY TESTS"
  
  local project_dir="$1"
  
  # Test: No hardcoded API keys or secrets
  if grep -r "sk_live_\|pk_live_\|api_key.*=.*\"[A-Za-z0-9]" "$project_dir" --include="*.swift" | grep -v "example\|placeholder\|YOUR_" | grep -q .; then
    log_test "No hardcoded API keys" "FAIL" "Potential API keys found in code"
  else
    log_test "No hardcoded API keys" "PASS"
  fi
  
  # Test: Keychain usage for sensitive data
  if grep -r "Keychain\|SecItemAdd\|SecItemCopyMatching" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Secure storage (Keychain) used" "PASS"
  else
    log_test "Secure storage (Keychain) used" "WARN" "Consider using Keychain for sensitive data"
  fi
  
  # Test: HTTPS usage (not HTTP)
  if grep -r "http://" "$project_dir" --include="*.swift" --include="*.plist" | grep -v "localhost\|127.0.0.1\|example.com" | grep -q .; then
    log_test "HTTPS enforced (no HTTP)" "WARN" "HTTP URLs detected - use HTTPS in production"
  else
    log_test "HTTPS enforced (no HTTP)" "PASS"
  fi
  
  # Test: App Transport Security configured
  if grep -r "NSAllowsArbitraryLoads.*true" "$project_dir" --include="*.plist" | grep -q .; then
    log_test "App Transport Security" "FAIL" "ATS is disabled - security risk"
  else
    log_test "App Transport Security" "PASS"
  fi
}

# ==========================================
# PERMISSIONS & PRIVACY TESTS
# ==========================================

test_permissions() {
  print_section "6. PERMISSIONS & PRIVACY TESTS"
  
  local project_dir="$1"
  local info_plist=$(find "$project_dir" -name "Info.plist" -type f | head -1)
  
  if [[ -z "$info_plist" ]]; then
    log_test "Info.plist accessible" "FAIL" "Cannot find Info.plist"
    return 1
  fi
  
  # Test: Camera usage description (if using camera)
  if plutil -extract NSCameraUsageDescription raw -o - "$info_plist" >/dev/null 2>&1; then
    log_test "Camera usage description present" "PASS"
  elif grep -r "AVCaptureDevice\|UIImagePickerController.*camera" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Camera usage description present" "FAIL" "Camera used but description missing"
  else
    log_test "Camera usage description present" "SKIP" "Camera not used"
  fi
  
  # Test: Photo library usage description (if using photos)
  if plutil -extract NSPhotoLibraryUsageDescription raw -o - "$info_plist" >/dev/null 2>&1; then
    log_test "Photo library usage description present" "PASS"
  elif grep -r "PHPhotoLibrary\|UIImagePickerController.*photoLibrary" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Photo library usage description present" "FAIL" "Photo library used but description missing"
  else
    log_test "Photo library usage description present" "SKIP" "Photo library not used"
  fi
  
  # Test: Face ID usage description (if using biometrics)
  if plutil -extract NSFaceIDUsageDescription raw -o - "$info_plist" >/dev/null 2>&1; then
    log_test "Face ID usage description present" "PASS"
  elif grep -r "LAContext\|biometric" "$project_dir" --include="*.swift" -i | grep -q .; then
    log_test "Face ID usage description present" "WARN" "Biometrics used - description recommended"
  else
    log_test "Face ID usage description present" "SKIP" "Biometrics not used"
  fi
  
  # Test: Location usage description (if using location)
  if plutil -extract NSLocationWhenInUseUsageDescription raw -o - "$info_plist" >/dev/null 2>&1; then
    log_test "Location usage description present" "PASS"
  elif grep -r "CLLocationManager\|CoreLocation" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Location usage description present" "FAIL" "Location used but description missing"
  else
    log_test "Location usage description present" "SKIP" "Location not used"
  fi
}

# ==========================================
# PERFORMANCE TESTS
# ==========================================

test_performance() {
  print_section "7. PERFORMANCE TESTS"
  
  local project_dir="$1"
  
  # Test: Asset optimization
  local large_images=$(find "$project_dir" -name "*.png" -o -name "*.jpg" -type f -size +1M 2>/dev/null | wc -l | xargs)
  if [[ $large_images -eq 0 ]]; then
    log_test "Image assets optimized" "PASS"
  else
    log_test "Image assets optimized" "WARN" "$large_images images >1MB - consider optimization"
  fi
  
  # Test: No retain cycles (basic check)
  if grep -r "\[weak self\]\|\[unowned self\]" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Memory management (weak/unowned)" "PASS"
  else
    log_test "Memory management (weak/unowned)" "WARN" "Consider using [weak self] in closures"
  fi
  
  # Test: Async/await usage (modern concurrency)
  if grep -r "async\|await\|Task\|@MainActor" "$project_dir" --include="*.swift" | grep -q .; then
    log_test "Modern concurrency (async/await)" "PASS"
  else
    log_test "Modern concurrency (async/await)" "SKIP" "Not using Swift concurrency"
  fi
}

# ==========================================
# LOCALIZATION TESTS
# ==========================================

test_localization() {
  print_section "8. LOCALIZATION TESTS"
  
  local project_dir="$1"
  
  # Test: Localization files exist
  local localization_count=$(find "$project_dir" -name "*.lproj" -type d 2>/dev/null | wc -l | xargs)
  if [[ $localization_count -gt 0 ]]; then
    log_test "Localization files present" "PASS" "$localization_count language(s)"
  else
    log_test "Localization files present" "SKIP" "No .lproj directories found"
  fi
  
  # Test: Custom localization (JSON or similar)
  local json_localization=$(find "$project_dir" -path "*/Localizations/*.json" -type f 2>/dev/null | wc -l | xargs)
  if [[ $json_localization -gt 0 ]]; then
    log_test "Custom localization files" "PASS" "$json_localization JSON file(s)"
  else
    log_test "Custom localization files" "SKIP" "No custom localization"
  fi
}

# ==========================================
# DOCUMENTATION TESTS
# ==========================================

test_documentation() {
  print_section "9. DOCUMENTATION TESTS"
  
  local project_dir="$1"
  
  # Test: README exists
  if [[ -f "$project_dir/README.md" ]]; then
    log_test "README.md exists" "PASS"
  else
    log_test "README.md exists" "WARN" "Consider adding README.md"
  fi
  
  # Test: App Store metadata
  if [[ -d "$project_dir/AppStore_Submission_Package" ]] || [[ -d "$project_dir/metadata" ]]; then
    log_test "App Store metadata prepared" "PASS"
  else
    log_test "App Store metadata prepared" "WARN" "No App Store metadata folder found"
  fi
  
  # Test: Privacy policy document
  if find "$project_dir" -name "*PRIVACY*" -o -name "*privacy*" -type f | grep -i "\.md\|\.txt" | grep -q .; then
    log_test "Privacy policy document exists" "PASS"
  else
    log_test "Privacy policy document exists" "WARN" "Privacy policy document not found"
  fi
}

# ==========================================
# FINAL REPORT GENERATION
# ==========================================

generate_final_report() {
  local test_end_time=$(date +%s)
  local duration=$((test_end_time - TEST_START_TIME))
  
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                                                        ║${NC}"
  echo -e "${BLUE}║              FINAL TEST RESULTS                        ║${NC}"
  echo -e "${BLUE}║                                                        ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  echo "  📊 Total Tests: $TOTAL_TESTS"
  echo -e "  ${GREEN}✅ Passed: $PASSED_TESTS${NC}"
  echo -e "  ${RED}❌ Failed: $FAILED_TESTS${NC}"
  echo -e "  ${YELLOW}⚠️  Warnings: $WARNING_TESTS${NC}"
  echo -e "  ${BLUE}⏭️  Skipped: $SKIPPED_TESTS${NC}"
  echo "  ⏱️  Duration: ${duration}s"
  echo ""
  
  # Calculate pass rate
  local pass_rate=0
  if [[ $TOTAL_TESTS -gt 0 ]]; then
    pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
  fi
  
  # Add to report
  cat >> "$REPORT_FILE" <<EOF

---

## Summary

| Metric | Count |
|--------|-------|
| **Total Tests** | $TOTAL_TESTS |
| **✅ Passed** | $PASSED_TESTS |
| **❌ Failed** | $FAILED_TESTS |
| **⚠️ Warnings** | $WARNING_TESTS |
| **⏭️ Skipped** | $SKIPPED_TESTS |
| **Pass Rate** | ${pass_rate}% |
| **Duration** | ${duration}s |

---

## Recommendation

EOF

  # Determine recommendation
  if [[ $FAILED_TESTS -eq 0 && $WARNING_TESTS -le 3 ]]; then
    echo -e "  ${GREEN}✅ READY FOR REVIEW${NC}"
    echo -e "  Your app passed all critical tests!"
    echo "✅ **READY FOR APP STORE SUBMISSION**" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Your app passed all critical tests and is ready for submission." >> "$REPORT_FILE"
  elif [[ $FAILED_TESTS -le 2 && $WARNING_TESTS -le 5 ]]; then
    echo -e "  ${YELLOW}⚠️  NEEDS MINOR FIXES${NC}"
    echo -e "  Fix $FAILED_TESTS critical issue(s) before submission"
    echo "⚠️ **NEEDS MINOR FIXES**" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Address $FAILED_TESTS failed test(s) before submitting to App Store." >> "$REPORT_FILE"
  else
    echo -e "  ${RED}❌ NOT READY${NC}"
    echo -e "  Fix $FAILED_TESTS failed test(s) and review $WARNING_TESTS warning(s)"
    echo "❌ **NOT READY FOR SUBMISSION**" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Multiple critical issues detected. Address all failed tests before submission." >> "$REPORT_FILE"
  fi
  
  echo ""
  echo "📄 Full report saved to: $REPORT_FILE"
  echo ""
  
  # Copy report to project directory
  local project_report_dir="$(pwd)/.dns_system/reports"
  mkdir -p "$project_report_dir"
  cp "$REPORT_FILE" "$project_report_dir/pre_review_test_latest.md"
  echo "📋 Report also saved to: $project_report_dir/pre_review_test_latest.md"
  echo ""
}

# ==========================================
# MAIN EXECUTION
# ==========================================

main() {
  local project_dir="${1:-.}"
  
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║                                                        ║${NC}"
  echo -e "${BLUE}║     DNS PRE-REVIEW TESTING SYSTEM                      ║${NC}"
  echo -e "${BLUE}║     Comprehensive App Store Readiness Check           ║${NC}"
  echo -e "${BLUE}║                                                        ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "  📱 Testing project: $(basename "$project_dir")"
  echo "  📍 Directory: $project_dir"
  echo ""
  
  # Initialize
  init_test_system
  
  # Run all test suites
  test_project_structure "$project_dir"
  test_build_configuration "$project_dir"
  test_code_quality "$project_dir"
  test_app_store_compliance "$project_dir"
  test_security "$project_dir"
  test_permissions "$project_dir"
  test_performance "$project_dir"
  test_localization "$project_dir"
  test_documentation "$project_dir"
  
  # Generate final report
  generate_final_report
  
  # Return exit code based on results
  if [[ $FAILED_TESTS -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

