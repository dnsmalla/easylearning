#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# GitHub Data Upload Script
# ═══════════════════════════════════════════════════════════════
# Uploads ONLY the data folder to GitHub (no app source code)
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/project_config.sh"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Upload Data to GitHub                                      ║"
echo "║   Repository: $GITHUB_USERNAME/$GITHUB_REPO_NAME"
echo "║   Data Folder: $SOURCE_DATA_FOLDER → $GITHUB_DATA_FOLDER     "
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verify source directory exists
if [ ! -d "$SOURCE_DATA_PATH" ]; then
    echo -e "${RED}❌ Source directory not found: $SOURCE_DATA_PATH${NC}"
    exit 1
fi

# Check if repo already exists
if [ -d "$TEMP_REPO_DIR" ]; then
    echo -e "${YELLOW}ℹ️  Temporary repository folder already exists${NC}"
    echo -e "${YELLOW}Would you like to:${NC}"
    echo "  1. Update existing repository (recommended)"
    echo "  2. Delete and clone fresh"
    echo "  3. Cancel"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo -e "${GREEN}✓ Using existing repository${NC}"
            cd "$TEMP_REPO_DIR"
            git pull origin main || echo -e "${YELLOW}⚠️  Pull failed, continuing anyway${NC}"
            ;;
        2)
            echo -e "${YELLOW}🗑️  Removing old repository...${NC}"
            rm -rf "$TEMP_REPO_DIR"
            echo -e "${BLUE}📥 Cloning fresh repository...${NC}"
            git clone "$GITHUB_REPO_URL" "$TEMP_REPO_DIR"
            cd "$TEMP_REPO_DIR"
            ;;
        3)
            echo -e "${YELLOW}❌ Cancelled${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            exit 1
            ;;
    esac
else
    echo -e "${BLUE}📥 Cloning repository...${NC}"
    git clone "$GITHUB_REPO_URL" "$TEMP_REPO_DIR"
    cd "$TEMP_REPO_DIR"
    echo -e "${GREEN}✓ Repository cloned${NC}"
fi

echo ""
echo -e "${BLUE}📁 Ensuring $GITHUB_DATA_FOLDER folder structure in repository...${NC}"

# Create data directory if it doesn't exist
mkdir -p "$GITHUB_DATA_FOLDER"

echo ""
echo -e "${BLUE}📦 Copying JSON files from $SOURCE_DATA_FOLDER folder...${NC}"

# Copy all JSON files, excluding backups
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
        else
            echo "  ⊘ $filename (excluded)"
        fi
    fi
done

if [ $FILE_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No files copied${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Copied $FILE_COUNT files to repository${NC}"

# Create/update README if it doesn't exist
if [ ! -f "README.md" ]; then
    echo ""
    echo -e "${BLUE}📄 Creating README.md...${NC}"
    cat > README.md << EOF
# $GITHUB_REPO_NAME

Learning data repository for the app.

## Contents

This repository contains learning data in the \`$GITHUB_DATA_FOLDER/\` folder.

## Data Structure

- Category-based structure
- All JLPT levels (N5-N1)
- JSON format

## How It Works

1. The app downloads these JSON files on first launch
2. Data is cached locally on the device for offline use
3. App checks for updates periodically
4. Users only download what they need

## Updating Content

To update the learning data:

1. Edit the JSON files locally in your project's \`$SOURCE_DATA_FOLDER/\` folder
2. Update the version in \`$SOURCE_DATA_FOLDER/manifest.json\`
3. Run the upload script from your project
4. Users automatically receive updates

## Current Version

Check \`$GITHUB_DATA_FOLDER/manifest.json\` for the current version.

## Repository

**GitHub**: [$GITHUB_USERNAME/$GITHUB_REPO_NAME](https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME)

## License

Educational Use

---

**Note**: This repository contains ONLY learning data (JSON files).  
The app source code is maintained separately.
EOF
    echo -e "${GREEN}✓ README.md created${NC}"
fi

# Create/update .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
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
    echo -e "${GREEN}✓ .gitignore created${NC}"
fi

# Show what we have
echo ""
echo -e "${YELLOW}📋 Files ready to upload:${NC}"
ls -lh "$GITHUB_DATA_FOLDER"/*.json 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""

# Git status
echo -e "${BLUE}📊 Git status:${NC}"
git add "$GITHUB_DATA_FOLDER"/*.json README.md .gitignore 2>/dev/null || true
git status --short

echo ""
echo -e "${YELLOW}Ready to commit and push!${NC}"
echo ""
read -p "Commit message (or press Enter for default): " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Update learning data from $SOURCE_DATA_FOLDER folder"
fi

echo ""
echo -e "${BLUE}💾 Committing changes...${NC}"
git commit -m "$COMMIT_MSG" || echo -e "${CYAN}ℹ️  Nothing to commit (no changes detected)${NC}"

echo ""
echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SUCCESS! Files uploaded to GitHub${NC}"
    echo ""
    echo -e "${CYAN}🔗 View your repository:${NC}"
    echo -e "   ${BLUE}https://github.com/$GITHUB_USERNAME/$GITHUB_REPO_NAME${NC}"
    echo ""
    echo -e "${CYAN}🔗 Test your files:${NC}"
    echo -e "   ${BLUE}$RAW_BASE_URL/manifest.json${NC}"
    echo ""
    echo -e "${CYAN}📱 Next Steps:${NC}"
    echo "  1. Verify files are visible on GitHub (check URL above)"
    echo "  2. Make sure repository is PUBLIC"
    echo "  3. Build and run your app"
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
    echo "  cd $TEMP_REPO_DIR"
    echo "  git push origin main"
    exit 1
fi

echo ""
echo -e "${CYAN}🗑️  Temporary repository at: $TEMP_REPO_DIR${NC}"
echo "    (You can delete this manually if you want)"
echo ""

