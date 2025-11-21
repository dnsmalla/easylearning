#!/bin/bash

# Upload Japanese learning data to dnsmalla/easylearning repository
# This script copies the JSON files and manifest to your GitHub repo

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Upload Data to github.com/dnsmalla/easylearning           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Repository details
REPO_URL="https://github.com/dnsmalla/easylearning.git"
REPO_NAME="easylearning"
GITHUB_USERNAME="dnsmalla"

# Source files
SOURCE_DIR="/Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn/JPLearning/Resources"
MANIFEST_FILE="/Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn/manifest.json"

echo -e "${BLUE}Repository: $REPO_URL${NC}"
echo ""

# Check if repo already exists locally
if [ -d "$REPO_NAME" ]; then
    echo -e "${YELLOW}ℹ️  Repository folder already exists${NC}"
    echo -e "${YELLOW}Would you like to:${NC}"
    echo "  1. Update existing repository (recommended)"
    echo "  2. Delete and clone fresh"
    echo "  3. Cancel"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo "✓ Using existing repository"
            cd "$REPO_NAME"
            git pull origin main || echo "⚠️  Pull failed, continuing anyway"
            ;;
        2)
            echo "🗑️  Removing old repository..."
            rm -rf "$REPO_NAME"
            echo "📥 Cloning fresh repository..."
            git clone "$REPO_URL"
            cd "$REPO_NAME"
            ;;
        3)
            echo "❌ Cancelled"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac
else
    echo "📥 Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_NAME"
    echo "✓ Repository cloned"
fi

echo ""
echo "📦 Copying JSON files..."

# Copy JSON files
if [ -d "$SOURCE_DIR" ]; then
    cp "$SOURCE_DIR"/japanese_learning_data_n*.json . 2>/dev/null && echo "✓ JSON files copied" || echo "⚠️  No JSON files found"
else
    echo -e "${RED}❌ Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Copy manifest
if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" .
    echo "✓ manifest.json copied"
else
    echo -e "${YELLOW}⚠️  manifest.json not found, creating default...${NC}"
    cat > manifest.json << 'EOF'
{
  "version": "1.0",
  "releaseDate": "2025-11-20",
  "description": "Japanese Learning Data - Initial Release",
  "files": {
    "japanese_learning_data_n5_jisho.json": {
      "url": "https://raw.githubusercontent.com/dnsmalla/easylearning/main/japanese_learning_data_n5_jisho.json",
      "checksum": "0000",
      "size": 45056
    },
    "japanese_learning_data_n4_jisho.json": {
      "url": "https://raw.githubusercontent.com/dnsmalla/easylearning/main/japanese_learning_data_n4_jisho.json",
      "checksum": "0000",
      "size": 45056
    },
    "japanese_learning_data_n3_jisho.json": {
      "url": "https://raw.githubusercontent.com/dnsmalla/easylearning/main/japanese_learning_data_n3_jisho.json",
      "checksum": "0000",
      "size": 45056
    },
    "japanese_learning_data_n2_jisho.json": {
      "url": "https://raw.githubusercontent.com/dnsmalla/easylearning/main/japanese_learning_data_n2_jisho.json",
      "checksum": "0000",
      "size": 45056
    },
    "japanese_learning_data_n1_jisho.json": {
      "url": "https://raw.githubusercontent.com/dnsmalla/easylearning/main/japanese_learning_data_n1_jisho.json",
      "checksum": "0000",
      "size": 45056
    }
  },
  "changelog": [
    {
      "version": "1.0",
      "date": "2025-11-20",
      "changes": [
        "Initial release",
        "N5-N1 vocabulary and grammar"
      ]
    }
  ]
}
EOF
    echo "✓ Default manifest.json created"
fi

# Create/update README
if [ ! -f "README.md" ]; then
    echo ""
    echo "📄 Creating README.md..."
    cat > README.md << 'EOF'
# Easy Learning - Japanese Learning Data

Learning data repository for JLearn iOS app.

## Contents

This repository contains Japanese learning data for JLPT levels N5 to N1:

- `japanese_learning_data_n5_jisho.json` - N5 Level (Beginner)
- `japanese_learning_data_n4_jisho.json` - N4 Level (Basic)
- `japanese_learning_data_n3_jisho.json` - N3 Level (Intermediate)
- `japanese_learning_data_n2_jisho.json` - N2 Level (Advanced)
- `japanese_learning_data_n1_jisho.json` - N1 Level (Expert)
- `manifest.json` - Version tracking and file information

## How It Works

1. The JLearn iOS app downloads these JSON files on first launch
2. Data is cached locally on the device for offline use
3. App checks for updates every 30 days
4. Users only download what they need (one level at a time)

## Data Structure

Each JSON file contains:
- **Flashcards**: Vocabulary with readings, meanings, and examples
- **Grammar**: Grammar points with usage and examples
- **Practice**: Practice questions for each category

## Updating Content

To update the learning data:

1. Edit the JSON files locally
2. Update the version in `manifest.json`
3. Commit and push changes to GitHub
4. Users automatically receive updates within 30 days

## Current Version

Check `manifest.json` for the current version and changelog.

## App

**JLearn** - Japanese Learning iOS App

## License

Educational Use
EOF
    echo "✓ README.md created"
fi

# Show what we have
echo ""
echo -e "${YELLOW}📋 Files ready to upload:${NC}"
ls -lh *.json 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# Git status
echo "📊 Git status:"
git add *.json README.md 2>/dev/null || true
git status --short

echo ""
echo -e "${YELLOW}Ready to commit and push!${NC}"
echo ""
read -p "Commit message (or press Enter for default): " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Add/update Japanese learning data"
fi

echo ""
echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG" || echo "ℹ️  Nothing to commit (no changes detected)"

echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SUCCESS! Files uploaded to GitHub${NC}"
    echo ""
    echo "🔗 View your repository:"
    echo -e "   ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
    echo ""
    echo "🔗 Test your files:"
    echo -e "   ${BLUE}https://raw.githubusercontent.com/$GITHUB_USERNAME/$REPO_NAME/main/manifest.json${NC}"
    echo ""
    echo "📱 Next Steps:"
    echo "  1. Verify files are visible on GitHub (check URL above)"
    echo "  2. Make sure repository is PUBLIC"
    echo "  3. Build and run your app in Xcode"
    echo "  4. App will download from GitHub automatically!"
    echo ""
    echo -e "${GREEN}🎉 All done!${NC}"
else
    echo ""
    echo -e "${RED}❌ Push failed. Please check:${NC}"
    echo "  1. You're logged in to git (git config --global user.name)"
    echo "  2. You have push access to the repository"
    echo "  3. Network connection is working"
    echo ""
    echo "Try pushing manually:"
    echo "  cd $REPO_NAME"
    echo "  git push origin main"
fi

echo ""

