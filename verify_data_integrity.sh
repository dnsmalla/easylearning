#!/bin/bash

# 🔍 Data Integrity Verification Script
# This script checks if all necessary JSON data files exist and have valid content

set -e

echo "🔍 Verifying JLearn App Data Integrity..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check file existence and size
check_file() {
    local file_path=$1
    local min_size=$2
    local description=$3
    
    if [ -f "$file_path" ]; then
        local file_size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
        if [ "$file_size" -gt "$min_size" ]; then
            echo -e "${GREEN}✅ $description${NC}"
            echo "   Path: $file_path"
            echo "   Size: $file_size bytes"
            ((PASSED++))
        else
            echo -e "${RED}❌ $description (file too small: $file_size bytes)${NC}"
            echo "   Path: $file_path"
            ((FAILED++))
        fi
    else
        echo -e "${RED}❌ $description (file not found)${NC}"
        echo "   Path: $file_path"
        ((FAILED++))
    fi
    echo ""
}

# Function to check JSON validity
check_json_validity() {
    local file_path=$1
    local description=$2
    
    if [ -f "$file_path" ]; then
        if python3 -m json.tool "$file_path" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $description - Valid JSON${NC}"
            ((PASSED++))
        else
            echo -e "${RED}❌ $description - Invalid JSON${NC}"
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠️  $description - File not found${NC}"
        ((WARNINGS++))
    fi
}

# Function to check JSON content
check_json_content() {
    local file_path=$1
    local key=$2
    local expected_count=$3
    local description=$4
    
    if [ -f "$file_path" ]; then
        local count=$(python3 -c "import json; data=json.load(open('$file_path')); print(len(data.get('$key', [])))" 2>/dev/null || echo "0")
        if [ "$count" -ge "$expected_count" ]; then
            echo -e "${GREEN}✅ $description: $count items (expected: $expected_count+)${NC}"
            ((PASSED++))
        else
            echo -e "${RED}❌ $description: $count items (expected: $expected_count+)${NC}"
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠️  $description - File not found${NC}"
        ((WARNINGS++))
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Part 1: Checking Bundled Resources (App)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check bundled JSON files (must be present for app to work offline)
check_file "JPLearning/Resources/japanese_learning_data_n5_jisho.json" 70000 "N5 Bundled Data"
check_file "JPLearning/Resources/japanese_learning_data_n4_jisho.json" 70000 "N4 Bundled Data"
check_file "JPLearning/Resources/japanese_learning_data_n3_jisho.json" 70000 "N3 Bundled Data"
check_file "JPLearning/Resources/japanese_learning_data_n2_jisho.json" 70000 "N2 Bundled Data"
check_file "JPLearning/Resources/japanese_learning_data_n1_jisho.json" 70000 "N1 Bundled Data"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Part 2: Checking GitHub Repository Data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check GitHub JSON files (for remote updates)
check_file "jpleanrning/japanese_learning_data_n5_jisho.json" 70000 "N5 GitHub Data"
check_file "jpleanrning/japanese_learning_data_n4_jisho.json" 70000 "N4 GitHub Data"
check_file "jpleanrning/japanese_learning_data_n3_jisho.json" 70000 "N3 GitHub Data"
check_file "jpleanrning/japanese_learning_data_n2_jisho.json" 70000 "N2 GitHub Data"
check_file "jpleanrning/japanese_learning_data_n1_jisho.json" 70000 "N1 GitHub Data"
check_file "jpleanrning/manifest.json" 500 "GitHub Manifest"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Part 3: Validating JSON Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate JSON syntax
check_json_validity "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "N5 Bundled JSON"
check_json_validity "jpleanrning/japanese_learning_data_n5_jisho.json" "N5 GitHub JSON"
check_json_validity "jpleanrning/manifest.json" "Manifest JSON"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Part 4: Checking Data Content (N5 Sample)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check N5 data content (expected counts)
check_json_content "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "kanji" 30 "N5 Kanji Count"
check_json_content "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "flashcards" 101 "N5 Vocabulary Count"
check_json_content "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "grammar" 25 "N5 Grammar Count"
check_json_content "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "practice" 10 "N5 Practice Questions"
check_json_content "JPLearning/Resources/japanese_learning_data_n5_jisho.json" "games" 4 "N5 Games"

echo -e "${BLUE}ℹ️  Note: Reading comprehension uses built-in sample data (not in JSON)${NC}"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Part 5: Checking Data Synchronization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Compare bundled vs GitHub checksums
for level in n5 n4 n3 n2 n1; do
    bundled="JPLearning/Resources/japanese_learning_data_${level}_jisho.json"
    github="jpleanrning/japanese_learning_data_${level}_jisho.json"
    level_upper=$(echo "$level" | tr '[:lower:]' '[:upper:]')
    
    if [ -f "$bundled" ] && [ -f "$github" ]; then
        bundled_hash=$(md5 -q "$bundled" 2>/dev/null || echo "")
        github_hash=$(md5 -q "$github" 2>/dev/null || echo "")
        
        if [ "$bundled_hash" == "$github_hash" ]; then
            echo -e "${GREEN}✅ $level_upper data is synchronized (bundled == GitHub)${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠️  $level_upper data differs (bundled != GitHub)${NC}"
            echo "   This is OK if you recently updated GitHub but haven't rebuilt the app"
            ((WARNINGS++))
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Passed:  $PASSED${NC}"
echo -e "${RED}❌ Failed:  $FAILED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All critical checks passed! The app data is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open the Xcode project:"
    echo "   open JPLearning/JLearn.xcodeproj"
    echo ""
    echo "2. Build and run the app (⌘ + R)"
    echo ""
    echo "3. Follow the testing guide:"
    echo "   cat RUN_AND_TEST_APP.md"
    exit 0
else
    echo -e "${RED}⚠️  Some checks failed. Please review the errors above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. If bundled data is missing:"
    echo "   cp jpleanrning/*.json JPLearning/Resources/"
    echo ""
    echo "2. If JSON is invalid:"
    echo "   python3 -m json.tool FILE.json"
    echo ""
    echo "3. If GitHub data is missing:"
    echo "   git add jpleanrning/ && git commit -m 'Update data' && git push"
    exit 1
fi
