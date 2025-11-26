#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# GitHub Repository Setup Script
# ═══════════════════════════════════════════════════════════════
# Initial setup for GitHub data hosting (first time only)
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   GitHub Data Repository - Initial Setup                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Display current configuration
print_config
echo ""

# Validate configuration
if ! validate_config; then
    echo ""
    echo -e "${RED}Please fix configuration errors in:${NC}"
    echo -e "  ${YELLOW}$SCRIPT_DIR/../config/project_config.sh${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Create directory structure
echo ""
echo -e "${BLUE}📁 Creating temporary setup directory...${NC}"
SETUP_DIR="$PROJECT_ROOT/temp_github_setup"

if [ -d "$SETUP_DIR" ]; then
    echo -e "${YELLOW}⚠️  Setup directory already exists: $SETUP_DIR${NC}"
    read -p "Delete and recreate? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        rm -rf "$SETUP_DIR"
    else
        echo -e "${RED}Cancelled${NC}"
        exit 1
    fi
fi

mkdir -p "$SETUP_DIR"
cd "$SETUP_DIR"

# Initialize git
git init
echo -e "${GREEN}✓ Git repository initialized${NC}"

# Create data folder
mkdir -p "$GITHUB_DATA_FOLDER"

# Copy JSON files from source
echo ""
echo -e "${BLUE}📦 Copying JSON files from $SOURCE_DATA_FOLDER...${NC}"

if [ -d "$SOURCE_DATA_PATH" ]; then
    FILE_COUNT=0
    for file in "$SOURCE_DATA_PATH"/$DATA_FILE_PATTERN; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            
            # Check if file should be excluded
            should_exclude=false
            for pattern in "${EXCLUDE_PATTERNS[@]}"; do
                if [[ "$filename" == $pattern ]]; then
                    should_exclude=true
                    break
                fi
            done
            
            if [ "$should_exclude" = false ]; then
                cp "$file" "$GITHUB_DATA_FOLDER/"
                FILE_COUNT=$((FILE_COUNT + 1))
                echo "  ✓ $filename"
            fi
        fi
    done
    
    if [ $FILE_COUNT -eq 0 ]; then
        echo -e "${RED}❌ No files copied${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Copied $FILE_COUNT JSON files${NC}"
else
    echo -e "${RED}❌ Source directory not found: $SOURCE_DATA_PATH${NC}"
    exit 1
fi

# Create README
echo ""
echo -e "${BLUE}📄 Creating README.md...${NC}"

cat > README.md << EOF
# $GITHUB_REPO_NAME

Learning data repository for the app.

## Contents

This repository contains learning data organized in the \`$GITHUB_DATA_FOLDER/\` folder.

All files are in JSON format and contain learning content for various levels (N5-N1).

## Data Structure

- **Category-based structure**: Each category (vocabulary, grammar, kanji, etc.) in separate files
- **Level-based data**: Data organized by JLPT levels (N5, N4, N3, N2, N1)
- **Versioned**: manifest.json tracks versions and checksums

## How It Works

1. The app downloads these JSON files on first launch
2. Data is cached locally on the device for offline use
3. App checks for updates periodically
4. Users only download what they need

## Files

\`\`\`
$GITHUB_DATA_FOLDER/
├── manifest.json              # Version tracking and file manifest
├── vocabulary.json            # Vocabulary for all levels
├── grammar.json               # Grammar points
├── kanji.json                 # Kanji learning data
├── practice.json              # Practice exercises
├── games.json                 # Game-based learning
├── reading.json               # Reading comprehension
└── japanese_learning_data_*.json  # Level-specific comprehensive data
\`\`\`

## Updating Content

To update the learning data:

1. Edit JSON files locally in your project's \`$SOURCE_DATA_FOLDER/\` folder
2. Update the version in \`$SOURCE_DATA_FOLDER/manifest.json\`
3. Run the upload script: \`./github_tools/upload_to_github.sh\`
4. Users will automatically receive updates

## URLs

Data is accessible via GitHub's raw content URLs:

\`\`\`
Base URL: $RAW_BASE_URL

Example files:
- $RAW_BASE_URL/manifest.json
- $RAW_BASE_URL/vocabulary.json
\`\`\`

## Current Version

Check \`$GITHUB_DATA_FOLDER/manifest.json\` for the current version and changelog.

## Repository

- **GitHub**: [$GITHUB_USERNAME/$GITHUB_REPO_NAME](https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME)
- **Owner**: $GITHUB_USERNAME

## License

Educational Use

---

**Important Note**: This repository contains ONLY learning data (JSON files).  
The app source code is maintained separately for security and intellectual property protection.

## Maintenance

This repository is automatically updated using automation scripts from the main project.
Manual editing is not recommended - use the provided tools instead.
EOF

echo -e "${GREEN}✓ README.md created${NC}"

# Create .gitignore
echo ""
echo -e "${BLUE}📝 Creating .gitignore...${NC}"
cat > .gitignore << EOF
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Backups
*.backup
*.bak
*.tmp
*.backup_*

# Temp files
*~
*.swp
*.swo

# Logs
*.log

# Only track $GITHUB_DATA_FOLDER folder
# All other directories at root should be ignored
/*
!/$GITHUB_DATA_FOLDER/
!/README.md
!/LICENSE
!/.gitignore

# Within $GITHUB_DATA_FOLDER, ignore backup files
$GITHUB_DATA_FOLDER/*.backup
$GITHUB_DATA_FOLDER/*.backup_*
$GITHUB_DATA_FOLDER/*.bak
EOF

echo -e "${GREEN}✓ .gitignore created (protects from accidentally adding app code)${NC}"

# Show file summary
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📋 Repository Contents:${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo "  README.md"
echo "  .gitignore"
echo "  $GITHUB_DATA_FOLDER/"
ls -lh "$GITHUB_DATA_FOLDER"/*.json 2>/dev/null | awk '{print "    " $9 " (" $5 ")"}'
echo ""

# Git commands
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}🚀 Next Steps:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}1. Create GitHub repository:${NC}"
echo -e "   ${BLUE}https://github.com/new${NC}"
echo "   Repository name: $GITHUB_REPO_NAME"
echo "   Make it ${GREEN}Public${NC}"
echo "   ${RED}Do NOT${NC} initialize with README (we already have one)"
echo ""
echo -e "${YELLOW}2. Add remote and push:${NC}"
echo -e "   ${GREEN}cd $SETUP_DIR${NC}"
echo -e "   ${GREEN}git remote add origin $GITHUB_REPO_URL${NC}"
echo -e "   ${GREEN}git add .${NC}"
echo -e "   ${GREEN}git commit -m \"Initial commit: Learning data ($GITHUB_DATA_FOLDER folder only)\"${NC}"
echo -e "   ${GREEN}git branch -M main${NC}"
echo -e "   ${GREEN}git push -u origin main${NC}"
echo ""
echo -e "${YELLOW}3. Verify repository content on GitHub:${NC}"
echo "   After pushing, check that you see:"
echo -e "   ${GREEN}✓${NC} $GITHUB_DATA_FOLDER/ folder with JSON files"
echo -e "   ${GREEN}✓${NC} README.md"
echo -e "   ${GREEN}✓${NC} .gitignore"
echo -e "   ${RED}✗${NC} NO app source code"
echo ""
echo -e "${YELLOW}4. Test your data URLs:${NC}"
echo -e "   ${BLUE}$RAW_BASE_URL/manifest.json${NC}"
echo ""
echo -e "${YELLOW}5. For future updates, use:${NC}"
echo -e "   ${GREEN}cd $PROJECT_ROOT/auto_app_data\\ generation${NC}"
echo -e "   ${GREEN}./github_tools/upload_to_github.sh${NC}"
echo ""
echo -e "${GREEN}✨ Setup complete! Repository ready in: $SETUP_DIR${NC}"
echo ""

# Ask if user wants to create repo now
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Would you like to create the GitHub repository now?${NC}"
echo -e "${BLUE}(requires GitHub CLI: gh)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
read -p "Type 'yes' to create, or 'no' to create manually later: " CREATE_NOW

if [ "$CREATE_NOW" = "yes" ] || [ "$CREATE_NOW" = "y" ]; then
    if command -v gh &> /dev/null; then
        echo ""
        echo -e "${BLUE}Creating GitHub repository...${NC}"
        gh repo create "$GITHUB_REPO_NAME" --public --description "Learning data for app ($GITHUB_DATA_FOLDER folder only)" --source=. --push
        echo ""
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Repository created and pushed!${NC}"
            echo ""
            echo -e "${CYAN}View it at: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME${NC}"
            echo ""
            echo -e "${YELLOW}⚠️  IMPORTANT: Verify on GitHub that only $GITHUB_DATA_FOLDER folder is present${NC}"
        else
            echo -e "${RED}❌ Failed to create repository${NC}"
        fi
    else
        echo ""
        echo -e "${RED}❌ GitHub CLI (gh) not found${NC}"
        echo ""
        echo "Install it with:"
        echo -e "  ${GREEN}brew install gh${NC}"
        echo ""
        echo "Or create the repository manually at:"
        echo -e "  ${BLUE}https://github.com/new${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}📝 Remember to create the repository manually at:${NC}"
    echo -e "   ${BLUE}https://github.com/new${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 All done!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}⚠️  IMPORTANT:${NC}"
echo "   This repository will ONLY contain the $GITHUB_DATA_FOLDER folder contents"
echo "   Your app source code stays separate in your local project"
echo ""

