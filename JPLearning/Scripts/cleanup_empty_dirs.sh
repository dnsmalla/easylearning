#!/bin/bash
#
# cleanup_empty_dirs.sh
# Safely remove empty directories from NPLearn project
#
# Usage: bash cleanup_empty_dirs.sh
#

set -e

echo "🧹 NPLearn - Empty Directory Cleanup Script"
echo "=========================================="
echo ""

# Navigate to project root
cd "$(dirname "$0")"

# List of empty directories to remove
EMPTY_DIRS=(
    "Sources/Protocols"
    "Sources/Repositories"
    "Sources/ViewModels"
    "Sources/Resources"
    "Sources/Views/Achievements"
    "Sources/Views/Animations"
    "Sources/Views/Challenges"
    "Sources/Views/Progress"
    "Sources/Views/WebSearch"
)

echo "📋 Found ${#EMPTY_DIRS[@]} empty directories to remove:"
echo ""

for dir in "${EMPTY_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir (exists)"
    else
        echo "  ✗ $dir (not found)"
    fi
done

echo ""
echo "⚠️  This will permanently delete these directories."
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled."
    exit 1
fi

echo ""
echo "🗑️  Removing empty directories..."
echo ""

REMOVED_COUNT=0
for dir in "${EMPTY_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Check if directory is really empty
        if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
            rm -rf "$dir"
            echo "  ✅ Removed: $dir"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        else
            echo "  ⚠️  Skipped: $dir (not empty)"
        fi
    else
        echo "  ⏭️  Skipped: $dir (not found)"
    fi
done

echo ""
echo "=========================================="
echo "✨ Cleanup Complete!"
echo "   Removed: $REMOVED_COUNT directories"
echo ""
echo "🔧 Next steps:"
echo "   1. Build project: Cmd+B"
echo "   2. Run tests: Cmd+U"
echo "   3. Commit changes if all tests pass"
echo ""

