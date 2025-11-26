#!/bin/bash
# Minimal Documentation Generator
# Generates ONLY what Apple requires for app submission

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/AppStore_Required"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p "$DOCS_DIR"

# Load config
if [ -f "$SCRIPT_DIR/config/app_info.conf" ]; then
    source "$SCRIPT_DIR/config/app_info.conf"
else
    APP_NAME="VisaPro"
    APP_VERSION="1.1.0"
    BUILD_NUMBER="4"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Minimal App Store Documentation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. APP DESCRIPTION (for App Store Connect)
cat > "$DOCS_DIR/APP_DESCRIPTION.txt" << 'EOF'
VisaPro - Your Visa Application Assistant

Simplify your Japan visa application with VisaPro. Fill out official forms digitally, generate professional PDFs instantly, and print at Japanese convenience stores.

KEY FEATURES:
• Student & Dependent visa support
• Smart guided forms with auto-save
• Instant PDF generation
• Convenience store printing (7-Eleven, FamilyMart, Lawson)
• 10 languages supported
• Secure local storage only
• Face ID / Touch ID security

Perfect for students and families applying for Japanese visas.
EOF

# 2. WHAT'S NEW (for updates)
cat > "$DOCS_DIR/WHATS_NEW.txt" << EOF
Version $APP_VERSION

• Performance improvements
• Bug fixes and stability enhancements
• Enhanced user experience
• Improved reliability
EOF

# 3. KEYWORDS (for App Store Connect)
cat > "$DOCS_DIR/KEYWORDS.txt" << 'EOF'
visa,application,japan,immigration,forms,pdf,student,dependent,travel,passport,documents,convenience,store,printing
EOF

# 4. REVIEW NOTES (for Apple reviewer)
cat > "$DOCS_DIR/REVIEW_NOTES.txt" << 'EOF'
Dear App Review Team,

Thank you for reviewing VisaPro.

TEST ACCOUNT:
Email: demo@visapro.com
Password: DemoUser2025

TESTING STEPS:
1. Login with account above
2. Tap "Japan Student Visa"
3. Form has sample data (or fill new one)
4. Tap "Preview PDF" to generate
5. Tap "Print at Store" to see QR code

KEY FEATURES:
• Form filling with validation
• PDF generation (official forms)
• Convenience store printing
• Language switching
• Account deletion (Profile → Settings)

DATA: All stored locally. No analytics. No tracking.

Thank you!
EOF

# 5. PRIVACY POLICY (to publish online)
cat > "$DOCS_DIR/PRIVACY_POLICY.md" << 'EOF'
# Privacy Policy

**Last updated: November 9, 2025**

## Data Collection
VisaPro does NOT collect, store, or share your personal data. All information you enter stays on your device only.

## What We Store Locally
- Visa form data (on your device only)
- Authentication credentials (encrypted in iOS Keychain)
- User preferences

## What We DO NOT Do
- ❌ No cloud storage
- ❌ No analytics
- ❌ No tracking
- ❌ No advertisements
- ❌ No data sharing

## Firebase Authentication
We use Firebase for user authentication only. Firebase stores:
- Your email address
- Encrypted password

No other data is sent to Firebase.

## Your Rights
- Delete your account anytime in Settings
- All data is erased when you delete your account

## Contact
Email: support@visapro.com
EOF

# 6. SUPPORT PAGE (to publish online)
cat > "$DOCS_DIR/SUPPORT_PAGE.md" << 'EOF'
# VisaPro Support

## Contact
Email: support@visapro.com
Response time: 24-48 hours

## Common Questions

**Q: Is my data safe?**
A: Yes. All data is stored locally on your device only.

**Q: How do I fill a visa form?**
A: 1) Choose visa type, 2) Fill form fields, 3) Generate PDF.

**Q: How do I print at convenience stores?**
A: Tap "Print at Store", show QR code at store copier.

**Q: How do I delete my account?**
A: Profile → Settings → Delete Account

**Q: What visa types are supported?**
A: Currently Japan Student and Dependent visas.

## Technical Requirements
- iOS 16.0 or later
- iPhone or iPad
- Internet for initial login only
EOF

echo -e "${GREEN}✓${NC} APP_DESCRIPTION.txt"
echo -e "${GREEN}✓${NC} WHATS_NEW.txt"
echo -e "${GREEN}✓${NC} KEYWORDS.txt"
echo -e "${GREEN}✓${NC} REVIEW_NOTES.txt"
echo -e "${GREEN}✓${NC} PRIVACY_POLICY.md"
echo -e "${GREEN}✓${NC} SUPPORT_PAGE.md"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Complete! 6 files created${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📁 Location: $DOCS_DIR"
echo ""
echo "Next steps:"
echo "1. Publish PRIVACY_POLICY.md & SUPPORT_PAGE.md online (use Carrd.co)"
echo "2. Copy APP_DESCRIPTION.txt to App Store Connect"
echo "3. Copy KEYWORDS.txt to App Store Connect"
echo "4. Copy REVIEW_NOTES.txt to App Store Connect"
echo "5. Submit app"
echo ""

