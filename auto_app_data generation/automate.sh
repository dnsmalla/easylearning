#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# Main Automation Script
# ═══════════════════════════════════════════════════════════════
# Master script for all data management and GitHub operations
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/project_config.sh"

# Function to show usage
show_usage() {
    cat << EOF
╔══════════════════════════════════════════════════════════════╗
║   Auto App Data Generation & GitHub Sync Toolkit            ║
╚══════════════════════════════════════════════════════════════╝

Usage: $0 <command> [options]

COMMANDS:

  Setup & Configuration:
    config              Show current configuration
    validate            Validate configuration
    setup-github        Initial GitHub repository setup (first time)

  Data Operations:
    verify              Verify local data integrity
    upload              Upload data to GitHub
    full-sync           Verify + Upload (complete workflow)

  Testing:
    test-urls           Test GitHub URLs are accessible
    test-download       Test Swift download from GitHub
    test-all            Run all tests

  Information:
    help                Show this help message
    version             Show version information

EXAMPLES:

  # First time setup
  $0 setup-github

  # Regular workflow
  $0 full-sync

  # Verify then upload
  $0 verify
  $0 upload

  # Test everything
  $0 test-all

WORKFLOW:

  1. Edit JSON files in your data folder
  2. Update version in manifest.json
  3. Run: $0 verify
  4. Run: $0 upload
  5. Run: $0 test-urls
  
  Or just: $0 full-sync

EOF
}

# Function to show version
show_version() {
    echo "Auto App Data Generation & GitHub Sync Toolkit"
    echo "Version: 1.0"
    echo "Last Updated: 2025-11-25"
    echo ""
    echo "Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
}

# Parse command
COMMAND="${1:-help}"

case "$COMMAND" in
    config)
        print_config
        ;;
    
    validate)
        echo -e "${BLUE}Validating configuration...${NC}"
        echo ""
        print_config
        echo ""
        if validate_config; then
            exit 0
        else
            exit 1
        fi
        ;;
    
    setup-github|setup)
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Initial GitHub Setup${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        "$SCRIPT_DIR/github_tools/setup_github_repo.sh"
        ;;
    
    verify|check)
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Verifying Data Integrity${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        "$SCRIPT_DIR/tests/verify_data_integrity.sh"
        ;;
    
    upload|push)
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Uploading to GitHub${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        "$SCRIPT_DIR/github_tools/upload_to_github.sh"
        ;;
    
    full-sync|sync)
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║   Full Sync Workflow${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Step 1: Verify
        echo -e "${BLUE}[1/3] Verifying data integrity...${NC}"
        if ! "$SCRIPT_DIR/tests/verify_data_integrity.sh"; then
            echo ""
            echo -e "${RED}❌ Data verification failed. Please fix errors.${NC}"
            exit 1
        fi
        echo ""
        
        # Step 2: Upload
        echo -e "${BLUE}[2/3] Uploading to GitHub...${NC}"
        if ! "$SCRIPT_DIR/github_tools/upload_to_github.sh"; then
            echo ""
            echo -e "${RED}❌ Upload failed. Please check errors.${NC}"
            exit 1
        fi
        echo ""
        
        # Step 3: Test
        echo -e "${BLUE}[3/3] Testing GitHub URLs...${NC}"
        if ! "$SCRIPT_DIR/tests/test_github_urls.sh"; then
            echo ""
            echo -e "${YELLOW}⚠️  URL tests failed. Data may not be accessible yet.${NC}"
            echo "    Wait a few seconds and try: $0 test-urls"
        fi
        echo ""
        
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅ Full sync complete!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
        ;;
    
    test-urls)
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Testing GitHub URLs${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        "$SCRIPT_DIR/tests/test_github_urls.sh"
        ;;
    
    test-download|test-swift)
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Testing Swift Download${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        swift "$SCRIPT_DIR/tests/test_github_download.swift"
        ;;
    
    test-all|test)
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║   Running All Tests${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        TESTS_PASSED=0
        TESTS_FAILED=0
        
        # Test 1: Data integrity
        echo -e "${BLUE}[Test 1/3] Data Integrity${NC}"
        if "$SCRIPT_DIR/tests/verify_data_integrity.sh"; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        echo ""
        
        # Test 2: GitHub URLs
        echo -e "${BLUE}[Test 2/3] GitHub URLs${NC}"
        if "$SCRIPT_DIR/tests/test_github_urls.sh"; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        echo ""
        
        # Test 3: Swift download
        echo -e "${BLUE}[Test 3/3] Swift Download${NC}"
        if swift "$SCRIPT_DIR/tests/test_github_download.swift"; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        echo ""
        
        # Summary
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}Test Summary:${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "Total tests: 3"
        echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        echo ""
        
        if [ $TESTS_FAILED -eq 0 ]; then
            echo -e "${GREEN}✅ All tests passed!${NC}"
            exit 0
        else
            echo -e "${RED}❌ Some tests failed${NC}"
            exit 1
        fi
        ;;
    
    version|--version|-v)
        show_version
        ;;
    
    help|--help|-h|*)
        show_usage
        ;;
esac

