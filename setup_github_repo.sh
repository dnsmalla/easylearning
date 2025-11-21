#!/bin/bash

# GitHub Data Repository Setup Script
# This script helps you set up the GitHub repository for hosting learning data

set -e

echo "🎯 JLearn - GitHub Data Hosting Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get GitHub username
echo -e "${BLUE}Enter your GitHub username:${NC}"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ GitHub username is required"
    exit 1
fi

# Repo name
REPO_NAME="japanese-learning-data"
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
RAW_BASE_URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/$REPO_NAME/main"

echo ""
echo -e "${GREEN}✓ GitHub Username: $GITHUB_USERNAME${NC}"
echo -e "${GREEN}✓ Repository: $REPO_NAME${NC}"
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    echo "✓ Git repository initialized"
fi

# Copy JSON files
echo ""
echo "📦 Copying JSON files..."
SOURCE_DIR="../JPLearning/Resources"

if [ -d "$SOURCE_DIR" ]; then
    cp "$SOURCE_DIR"/japanese_learning_data_n*.json . 2>/dev/null || echo "⚠️  No JSON files found in Resources"
    echo "✓ JSON files copied"
else
    echo "⚠️  Resources directory not found at $SOURCE_DIR"
fi

# Calculate file sizes
echo ""
echo "📊 Calculating file sizes..."

get_file_size() {
    if [ -f "$1" ]; then
        stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

N5_SIZE=$(get_file_size "japanese_learning_data_n5_jisho.json")
N4_SIZE=$(get_file_size "japanese_learning_data_n4_jisho.json")
N3_SIZE=$(get_file_size "japanese_learning_data_n3_jisho.json")
N2_SIZE=$(get_file_size "japanese_learning_data_n2_jisho.json")
N1_SIZE=$(get_file_size "japanese_learning_data_n1_jisho.json")

# Create manifest.json
echo ""
echo "📝 Creating manifest.json..."

CURRENT_DATE=$(date +%Y-%m-%d)

cat > manifest.json << EOF
{
  "version": "1.0",
  "releaseDate": "$CURRENT_DATE",
  "description": "Japanese Learning Data - Initial Release",
  "files": {
    "japanese_learning_data_n5_jisho.json": {
      "url": "$RAW_BASE_URL/japanese_learning_data_n5_jisho.json",
      "checksum": "0000",
      "size": $N5_SIZE
    },
    "japanese_learning_data_n4_jisho.json": {
      "url": "$RAW_BASE_URL/japanese_learning_data_n4_jisho.json",
      "checksum": "0000",
      "size": $N4_SIZE
    },
    "japanese_learning_data_n3_jisho.json": {
      "url": "$RAW_BASE_URL/japanese_learning_data_n3_jisho.json",
      "checksum": "0000",
      "size": $N3_SIZE
    },
    "japanese_learning_data_n2_jisho.json": {
      "url": "$RAW_BASE_URL/japanese_learning_data_n2_jisho.json",
      "checksum": "0000",
      "size": $N2_SIZE
    },
    "japanese_learning_data_n1_jisho.json": {
      "url": "$RAW_BASE_URL/japanese_learning_data_n1_jisho.json",
      "checksum": "0000",
      "size": $N1_SIZE
    }
  },
  "changelog": [
    {
      "version": "1.0",
      "date": "$CURRENT_DATE",
      "changes": [
        "Initial release",
        "N5 vocabulary and grammar",
        "N4 vocabulary and grammar",
        "N3 vocabulary and grammar",
        "N2 vocabulary and grammar",
        "N1 vocabulary and grammar"
      ]
    }
  ]
}
EOF

echo "✓ manifest.json created"

# Create README
echo ""
echo "📄 Creating README.md..."

cat > README.md << EOF
# Japanese Learning Data

Learning data repository for JLearn iOS app.

## Contents

- \`japanese_learning_data_n5_jisho.json\` - N5 Level (Beginner)
- \`japanese_learning_data_n4_jisho.json\` - N4 Level (Basic)
- \`japanese_learning_data_n3_jisho.json\` - N3 Level (Intermediate)
- \`japanese_learning_data_n2_jisho.json\` - N2 Level (Advanced)
- \`japanese_learning_data_n1_jisho.json\` - N1 Level (Expert)

## Current Version

**v1.0** - Released $CURRENT_DATE

## How It Works

1. The JLearn app downloads these JSON files on first launch
2. Data is cached locally on the device
3. App checks for updates every 30 days
4. Users only download what they need

## Updating Content

1. Edit the JSON files
2. Update version in \`manifest.json\`
3. Push changes to GitHub
4. Users automatically receive updates

## File Structure

Each JSON file contains:
- Flashcards (vocabulary)
- Grammar points
- Practice questions

See the app code for detailed schema.

---

**App**: [JLearn - Japanese Learning](https://github.com/$GITHUB_USERNAME/jlearn-app)  
**License**: Educational Use
EOF

echo "✓ README.md created"

# Create .gitignore
cat > .gitignore << EOF
.DS_Store
*.swp
*.swo
*~
EOF

echo "✓ .gitignore created"

# Show file summary
echo ""
echo -e "${YELLOW}📋 Repository Contents:${NC}"
ls -lh *.json 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# Git commands
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo ""
echo "1. Create GitHub repository:"
echo -e "   ${BLUE}https://github.com/new${NC}"
echo "   Repository name: $REPO_NAME"
echo "   Make it Public"
echo ""
echo "2. Add remote and push:"
echo -e "   ${GREEN}git remote add origin $REPO_URL.git${NC}"
echo -e "   ${GREEN}git add .${NC}"
echo -e "   ${GREEN}git commit -m \"Initial commit: Japanese learning data\"${NC}"
echo -e "   ${GREEN}git branch -M main${NC}"
echo -e "   ${GREEN}git push -u origin main${NC}"
echo ""
echo "3. Update app configuration:"
echo "   Edit: JPLearning/Sources/Services/RemoteDataService.swift"
echo "   Replace YOUR_USERNAME with: $GITHUB_USERNAME"
echo ""
echo "4. Test in app:"
echo "   Build and run the app"
echo "   Check Settings → Data Management"
echo ""
echo -e "${GREEN}✨ Setup complete! Repository ready in: $(pwd)${NC}"
echo ""

# Ask if user wants to create repo now
echo -e "${BLUE}Would you like to create the GitHub repository now? (requires GitHub CLI)${NC}"
echo "Type 'yes' to create, or 'no' to create manually later:"
read -r CREATE_NOW

if [ "$CREATE_NOW" = "yes" ] || [ "$CREATE_NOW" = "y" ]; then
    if command -v gh &> /dev/null; then
        echo ""
        echo "Creating GitHub repository..."
        gh repo create "$REPO_NAME" --public --description "Learning data for JLearn iOS app" --source=. --push
        echo ""
        echo -e "${GREEN}✅ Repository created and pushed!${NC}"
        echo "View it at: $REPO_URL"
    else
        echo ""
        echo "❌ GitHub CLI (gh) not found. Install it with:"
        echo "   brew install gh"
        echo ""
        echo "Or create the repository manually at: https://github.com/new"
    fi
else
    echo ""
    echo "📝 Remember to create the repository manually at:"
    echo "   https://github.com/new"
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"

