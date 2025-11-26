#!/usr/bin/env bash
#
# review_text_generator.sh
# DNS System - App Store Review Text Generator
# Generates clear, specific text for App Store submissions
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ==========================================
# PROJECT ANALYSIS
# ==========================================

analyze_project() {
  local project_dir="$1"
  
  echo -e "${BLUE}🔍 Analyzing project...${NC}"
  
  # Extract project info
  PROJECT_NAME=$(basename "$project_dir")
  
  # Try to get bundle identifier
  BUNDLE_ID=""
  if [[ -f "$project_dir/project.yml" ]]; then
    BUNDLE_ID=$(grep "PRODUCT_BUNDLE_IDENTIFIER:" "$project_dir/project.yml" | head -1 | awk '{print $2}' | tr -d '"' || echo "")
  fi
  
  if [[ -z "$BUNDLE_ID" ]]; then
    local info_plist=$(find "$project_dir" -name "Info.plist" -type f | head -1)
    if [[ -n "$info_plist" ]]; then
      BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw -o - "$info_plist" 2>/dev/null || echo "")
    fi
  fi
  
  # Get version and build
  VERSION=""
  BUILD=""
  if [[ -f "$project_dir/project.yml" ]]; then
    VERSION=$(grep "MARKETING_VERSION:" "$project_dir/project.yml" | head -1 | awk '{print $2}' | tr -d "'" || echo "1.0")
    BUILD=$(grep "CURRENT_PROJECT_VERSION:" "$project_dir/project.yml" | head -1 | awk '{print $2}' | tr -d "'" || echo "1")
  fi
  
  # Analyze features from source code
  local source_dir=$(find "$project_dir" -type d -name "Sources" | head -1)
  if [[ -z "$source_dir" ]]; then
    source_dir="$project_dir"
  fi
  
  # Detect features
  HAS_AUTH=false
  HAS_PDF=false
  HAS_PRINT=false
  HAS_LOCALIZATION=false
  HAS_BIOMETRIC=false
  HAS_FIREBASE=false
  
  if grep -r "AuthService\|Firebase.*Auth\|signIn\|login" "$source_dir" --include="*.swift" -q 2>/dev/null; then
    HAS_AUTH=true
  fi
  
  if grep -r "PDFKit\|PDFDocument\|PDFFormService" "$source_dir" --include="*.swift" -q 2>/dev/null; then
    HAS_PDF=true
  fi
  
  if grep -r "print.*job\|convenience.*print\|PrintService" "$source_dir" --include="*.swift" -i -q 2>/dev/null; then
    HAS_PRINT=true
  fi
  
  if find "$project_dir" -name "*.lproj" -o -path "*/Localizations/*.json" | grep -q . 2>/dev/null; then
    HAS_LOCALIZATION=true
  fi
  
  if grep -r "LAContext\|biometric\|FaceID\|TouchID" "$source_dir" --include="*.swift" -i -q 2>/dev/null; then
    HAS_BIOMETRIC=true
  fi
  
  if find "$project_dir" -name "GoogleService-Info.plist" | grep -q . 2>/dev/null; then
    HAS_FIREBASE=true
  fi
  
  # Get supported languages
  LANGUAGES=()
  if [[ -d "$project_dir/Sources/Localizations" ]]; then
    while IFS= read -r lang; do
      lang_code=$(basename "$lang" .json)
      LANGUAGES+=("$lang_code")
    done < <(find "$project_dir/Sources/Localizations" -name "*.json" -type f)
  fi
  
  echo -e "${GREEN}✅ Analysis complete${NC}"
  echo ""
}

# ==========================================
# APP DESCRIPTION GENERATOR
# ==========================================

generate_app_description() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 📱 App Store Description

## Short Description (30 characters)
**Copy this for App Store Subtitle:**

EOF

  # Generate short description based on features
  if [[ "$HAS_PDF" == true && "$HAS_PRINT" == true ]]; then
    echo "Digital forms & printing" >> "$output_file"
  elif [[ "$HAS_AUTH" == true ]]; then
    echo "Secure digital assistant" >> "$output_file"
  else
    echo "Professional mobile app" >> "$output_file"
  fi
  
  cat >> "$output_file" <<EOF

---

## Full Description (4000 characters max)
**Copy this for App Store Description:**

EOF

  # Generate full description
  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      cat >> "$output_file" <<'VISA_DESC'
🌏 Simplify Your Visa Application Process

VisaPro is your complete digital assistant for visa applications. Say goodbye to paper forms, confusing instructions, and errors. Our app guides you through every step with intelligent form filling, multi-language support, and convenient printing options.

✨ KEY FEATURES

📝 Digital Form Filling
• Fill visa application forms directly on your device
• Smart field validation prevents errors
• Save your progress and continue anytime
• Support for multiple visa types

🖨️ Convenience Store Printing
• Print at 7-Eleven, FamilyMart, or Lawson
• Secure QR code system
• No need for a personal printer
• Professional quality output

🌍 Multi-Language Support
• Available in 10+ languages
• Seamless language switching
• Localized for your region
• Clear, easy-to-understand instructions

🔐 Secure & Private
• Bank-level encryption
• Your data stays on your device
• Optional cloud backup
• Face ID / Touch ID protection

👤 User Account
• Save multiple applications
• Track submission history
• Easy profile management
• Delete account anytime

💡 Smart Features
• Offline mode support
• Auto-save functionality
• Form templates
• Help & support built-in

🎯 PERFECT FOR

Students applying for study visas
Dependents of visa holders
Travelers needing documentation
Anyone completing visa paperwork

📱 SIMPLE TO USE

1. Create your secure account
2. Select your visa type
3. Fill in your information
4. Preview your completed forms
5. Print at a nearby convenience store
6. Submit your application

🌟 WHY CHOOSE VISAPRO?

✓ Saves time and reduces errors
✓ Available 24/7 on your phone
✓ No complicated software needed
✓ Regular updates with new features
✓ Responsive customer support

📋 SUPPORTED DOCUMENTS

• Student visa applications
• Dependent visa applications
• Extension of stay forms
• Change of status documents
• And more being added regularly

🔒 YOUR PRIVACY MATTERS

We take your privacy seriously. Your personal information is encrypted and stored securely. We never share your data with third parties. You have complete control and can delete your account anytime.

🆘 SUPPORT

Need help? Access our comprehensive help center directly in the app, or contact our support team. We're here to make your visa application process as smooth as possible.

📲 Download VisaPro today and experience the easiest way to complete your visa applications!

VISA_DESC
      ;;
    *)
      # Generic professional description
      cat >> "$output_file" <<GENERIC_DESC
Transform the way you work with ${PROJECT_NAME}.

${PROJECT_NAME} is a powerful, user-friendly mobile application designed to streamline your workflow and boost productivity. Built with modern technology and intuitive design, our app provides everything you need in one place.

✨ KEY FEATURES

GENERIC_DESC

      if [[ "$HAS_AUTH" == true ]]; then
        cat >> "$output_file" <<'AUTH_FEATURE'
🔐 Secure Authentication
• Create your personal account
• Multiple sign-in options
• Face ID / Touch ID support
• Your data, your control

AUTH_FEATURE
      fi

      if [[ "$HAS_PDF" == true ]]; then
        cat >> "$output_file" <<'PDF_FEATURE'
📄 Document Management
• Generate professional PDFs
• Fill forms digitally
• Preview before saving
• Share easily

PDF_FEATURE
      fi

      if [[ "$HAS_LOCALIZATION" == true ]]; then
        cat >> "$output_file" <<'LOCALIZATION_FEATURE'
🌍 Multi-Language Support
• Available in multiple languages
• Seamless language switching
• Localized for your region

LOCALIZATION_FEATURE
      fi

      cat >> "$output_file" <<'GENERIC_END'

🎯 DESIGNED FOR YOU

Our app is built with user experience in mind. Every feature, every screen, every interaction is designed to be intuitive and efficient. Whether you're a beginner or a power user, you'll feel at home.

💡 SMART & EFFICIENT

• Fast performance
• Offline support
• Auto-save functionality
• Regular updates
• Responsive support

🔒 PRIVACY FIRST

Your privacy and security are our top priorities. All data is encrypted and stored securely. We never share your information with third parties.

📲 Download now and experience the difference!

GENERIC_END
      ;;
  esac
  
  echo "" >> "$output_file"
  echo "---" >> "$output_file"
  echo "" >> "$output_file"
}

# ==========================================
# WHAT'S NEW GENERATOR
# ==========================================

generate_whats_new() {
  local output_file="$1"
  local version="$2"
  
  cat >> "$output_file" <<EOF
# 🆕 What's New in Version ${version}

## Version ${version} - Release Notes (4000 characters max)
**Copy this for "What's New" section:**

EOF

  # Check if this is first version
  if [[ "$version" == "1.0" || "$version" == "1.0.0" ]]; then
    cat >> "$output_file" <<'FIRST_VERSION'
🎉 Welcome to our first release!

We're excited to bring you this brand new app designed to make your life easier. Here's what you can do:

✨ NEW FEATURES

EOF
    
    if [[ "$HAS_AUTH" == true ]]; then
      echo "• Secure user authentication with multiple sign-in options" >> "$output_file"
    fi
    
    if [[ "$HAS_PDF" == true ]]; then
      echo "• Digital form filling with PDF generation" >> "$output_file"
    fi
    
    if [[ "$HAS_PRINT" == true ]]; then
      echo "• Convenient printing at major convenience stores" >> "$output_file"
    fi
    
    if [[ "$HAS_LOCALIZATION" == true ]]; then
      echo "• Multi-language support for global users" >> "$output_file"
    fi
    
    if [[ "$HAS_BIOMETRIC" == true ]]; then
      echo "• Face ID / Touch ID for quick and secure access" >> "$output_file"
    fi
    
    cat >> "$output_file" <<'FIRST_VERSION_END'
• Beautiful, intuitive user interface
• Offline mode support
• Auto-save functionality
• Comprehensive help & support

Thank you for downloading! We'd love to hear your feedback.

FIRST_VERSION_END
  else
    # Update version template
    cat >> "$output_file" <<'UPDATE_VERSION'
🚀 This update includes:

✨ NEW FEATURES
• [Describe new feature 1]
• [Describe new feature 2]
• [Describe new feature 3]

🔧 IMPROVEMENTS
• Enhanced performance and stability
• Improved user interface
• Better error handling
• Faster load times

🐛 BUG FIXES
• Fixed [specific issue]
• Resolved [specific problem]
• Improved [specific functionality]

Thank you for your continued support! Please rate us if you enjoy the app.

UPDATE_VERSION
  fi
  
  echo "" >> "$output_file"
  echo "---" >> "$output_file"
  echo "" >> "$output_file"
}

# ==========================================
# APP PREVIEW TEXT GENERATOR
# ==========================================

generate_app_preview_text() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 🎬 App Preview Text

## Preview Video Script (for App Preview videos)

### Scene 1: Opening (3 seconds)
"[App Name] - Your digital assistant"

### Scene 2: Feature 1 (5 seconds)
EOF

  if [[ "$HAS_AUTH" == true ]]; then
    echo '"Sign in securely with multiple options"' >> "$output_file"
  else
    echo '"Easy to use, powerful features"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Scene 3: Feature 2 (5 seconds)
EOF

  if [[ "$HAS_PDF" == true ]]; then
    echo '"Fill forms digitally, save time"' >> "$output_file"
  else
    echo '"Get things done faster"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Scene 4: Feature 3 (5 seconds)
EOF

  if [[ "$HAS_PRINT" == true ]]; then
    echo '"Print at your convenience"' >> "$output_file"
  elif [[ "$HAS_LOCALIZATION" == true ]]; then
    echo '"Available in your language"' >> "$output_file"
  else
    echo '"Works offline, anytime"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Scene 5: Closing (2 seconds)
"Download now!"

---

## Screenshot Captions (for App Store Screenshots)

### Screenshot 1 (Main Screen)
"Beautiful, intuitive interface designed for you"

### Screenshot 2 (Key Feature)
EOF

  if [[ "$HAS_AUTH" == true ]]; then
    echo '"Secure sign-in with Face ID / Touch ID"' >> "$output_file"
  else
    echo '"Powerful features at your fingertips"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Screenshot 3 (Feature Detail)
EOF

  if [[ "$HAS_PDF" == true ]]; then
    echo '"Fill and preview forms before saving"' >> "$output_file"
  else
    echo '"Everything you need in one place"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Screenshot 4 (Additional Feature)
EOF

  if [[ "$HAS_PRINT" == true ]]; then
    echo '"Print with QR code at convenience stores"' >> "$output_file"
  elif [[ "$HAS_LOCALIZATION" == true ]]; then
    echo '"Available in 10+ languages"' >> "$output_file"
  else
    echo '"Works offline whenever you need it"' >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

### Screenshot 5 (User Benefit)
"Save time, reduce errors, get results"

---

EOF
}

# ==========================================
# KEYWORDS GENERATOR
# ==========================================

generate_keywords() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 🔑 Keywords

## App Store Keywords (100 characters max, comma-separated)
**Copy this for Keywords field:**

EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      echo "visa,immigration,form,pdf,application,student,dependent,document,print,digital,mobile,travel" >> "$output_file"
      ;;
    *)
      local keywords="app,mobile,productivity"
      
      if [[ "$HAS_PDF" == true ]]; then
        keywords+=",pdf,form,document"
      fi
      
      if [[ "$HAS_AUTH" == true ]]; then
        keywords+=",secure,account"
      fi
      
      if [[ "$HAS_PRINT" == true ]]; then
        keywords+=",print,qr"
      fi
      
      echo "$keywords" >> "$output_file"
      ;;
  esac
  
  cat >> "$output_file" <<'EOF'

**Note:** Keywords should be:
- Relevant to your app
- What users would search for
- No spaces between words (use comma only)
- Max 100 characters total
- No app name (Apple adds it automatically)

---

EOF
}

# ==========================================
# PROMOTIONAL TEXT GENERATOR
# ==========================================

generate_promotional_text() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 📢 Promotional Text

## Promotional Text (170 characters max)
**This appears at the top of your App Store listing and can be updated anytime:**

EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      echo "🌟 New: Print at convenience stores! Fill visa forms on your phone, generate QR code, print nearby. Fast, easy, secure. Try it now!" >> "$output_file"
      ;;
    *)
      if [[ "$HAS_AUTH" == true && "$HAS_PDF" == true ]]; then
        echo "✨ New features: Enhanced security, faster performance, better user experience. Update now for the best version yet!" >> "$output_file"
      else
        echo "🚀 Now available: Experience the future of mobile productivity. Fast, secure, and easy to use. Download today!" >> "$output_file"
      fi
      ;;
  esac
  
  cat >> "$output_file" <<'EOF'

**Tips for promotional text:**
- Update regularly (seasonally, for features, holidays)
- Include emojis to catch attention
- Mention specific features or benefits
- Create urgency or excitement
- Can be changed without app update

**Examples:**
- "🎉 Spring Sale: Premium features now FREE for limited time!"
- "🆕 Just added: Dark mode and offline support. Update now!"
- "⭐ Rated 4.8/5 by 10,000+ users. Join them today!"

---

EOF
}

# ==========================================
# SUPPORT INFORMATION GENERATOR
# ==========================================

generate_support_info() {
  local output_file="$1"
  
  cat >> "$output_file" <<EOF
# 🆘 Support Information

## Support URL
**Enter this in App Store Connect:**
https://your-website.com/support

**Should include:**
- FAQ section
- Contact form
- Troubleshooting guides
- Feature documentation
- Video tutorials (optional)

---

## Marketing URL (optional)
**Enter this in App Store Connect:**
https://your-website.com

**Should include:**
- App overview
- Feature highlights
- Screenshots/videos
- Download links
- Company information

---

## Privacy Policy URL (REQUIRED)
**Enter this in App Store Connect:**
https://your-website.com/privacy

**Must include:**
- What data you collect
- How you use the data
- How you protect data
- User rights
- Contact information

**Current app settings detected:**
EOF

  if [[ "$HAS_FIREBASE" == true ]]; then
    echo "- Firebase/Google services (must disclose)" >> "$output_file"
  fi
  
  if [[ "$HAS_AUTH" == true ]]; then
    echo "- User authentication (must disclose email/credentials collection)" >> "$output_file"
  fi
  
  if [[ "$HAS_BIOMETRIC" == true ]]; then
    echo "- Biometric data (Face ID/Touch ID - explain usage)" >> "$output_file"
  fi
  
  cat >> "$output_file" <<'EOF'

---

## Copyright
**Enter this in App Store Connect:**
EOF
  
  echo "© $(date +%Y) Your Company Name. All rights reserved." >> "$output_file"
  
  echo "" >> "$output_file"
  echo "---" >> "$output_file"
  echo "" >> "$output_file"
}

# ==========================================
# REVIEW NOTES GENERATOR
# ==========================================

generate_review_notes() {
  local output_file="$1"
  
  cat >> "$output_file" <<EOF
# 📝 App Review Information

## Review Notes
**Copy this for "Notes" field in App Store Connect:**

Dear App Review Team,

Thank you for reviewing ${PROJECT_NAME} (Version ${VERSION}, Build ${BUILD}).

**App Purpose:**
EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      cat >> "$output_file" <<'VISA_PURPOSE'
This app helps users complete visa application forms digitally. Users can fill forms on their mobile device, generate PDFs, and print at convenience stores in Japan.

VISA_PURPOSE
      ;;
    *)
      cat >> "$output_file" <<'GENERIC_PURPOSE'
This app provides [describe main purpose] to help users [describe benefit].

GENERIC_PURPOSE
      ;;
  esac

  cat >> "$output_file" <<'EOF'

**Key Features:**
EOF

  if [[ "$HAS_AUTH" == true ]]; then
    echo "- User authentication (email/password and Google Sign-In)" >> "$output_file"
  fi
  
  if [[ "$HAS_PDF" == true ]]; then
    echo "- PDF form generation and filling" >> "$output_file"
  fi
  
  if [[ "$HAS_PRINT" == true ]]; then
    echo "- Convenience store printing integration" >> "$output_file"
  fi
  
  if [[ "$HAS_LOCALIZATION" == true ]]; then
    echo "- Multi-language support (${#LANGUAGES[@]} languages)" >> "$output_file"
  fi
  
  if [[ "$HAS_BIOMETRIC" == true ]]; then
    echo "- Biometric authentication (Face ID/Touch ID)" >> "$output_file"
  fi

  cat >> "$output_file" <<'EOF'

**Testing Instructions:**

1. **Test Account:**
   Email: reviewer@example.com
   Password: ReviewTest123!
   
   (Or use "Continue with Google" option)

2. **Main Flow:**
EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      cat >> "$output_file" <<'VISA_FLOW'
   - Sign in with test account
   - Select "Student Visa" from home screen
   - Fill in sample information (any data is fine)
   - Preview the generated PDF
   - Optionally test the print QR code generation
   - Test account deletion from Profile > Settings

VISA_FLOW
      ;;
    *)
      cat >> "$output_file" <<'GENERIC_FLOW'
   - Sign in with test account
   - Navigate through main features
   - Test core functionality
   - Verify all screens load correctly
   - Test account deletion (if applicable)

GENERIC_FLOW
      ;;
  esac

  cat >> "$output_file" <<'EOF'

3. **Special Notes:**
EOF

  if [[ "$HAS_PRINT" == true ]]; then
    echo "   - Print QR codes are generated locally (no actual printing needed to test)" >> "$output_file"
  fi
  
  if [[ "$HAS_FIREBASE" == true ]]; then
    echo "   - Firebase is used for authentication only" >> "$output_file"
  fi
  
  if [[ "$HAS_BIOMETRIC" == true ]]; then
    echo "   - Biometric auth can be skipped for testing" >> "$output_file"
  fi

  cat >> "$output_file" <<EOF

4. **Privacy & Data:**
   - User data is stored securely using Keychain
   - Account deletion is available in Profile > Settings
   - Privacy policy: [Your Privacy URL]
   - Terms of service: [Your Terms URL]

5. **Contact:**
   If you have any questions, please contact:
   Email: support@yourcompany.com
   Response time: Within 24 hours

Thank you for your time and consideration!

---

## Demo Account Information
**Provide this in App Store Connect Demo Account section:**

**Username:** reviewer@example.com
**Password:** ReviewTest123!

**Additional Information:**
- This is a fully functional demo account
- Feel free to test all features
- Account can be deleted and recreated
- No real user data is present

EOF

  if [[ "$HAS_AUTH" == true ]]; then
    cat >> "$output_file" <<'AUTH_DEMO'

**Alternative Sign-In:**
You can also test "Sign in with Google" option using any Google account.

AUTH_DEMO
  fi

  echo "" >> "$output_file"
  echo "---" >> "$output_file"
  echo "" >> "$output_file"
}

# ==========================================
# CATEGORY SUGGESTIONS
# ==========================================

generate_category_suggestions() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 📂 Category Suggestions

## Primary Category
**Select in App Store Connect:**

EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      echo "**Recommended:** Productivity" >> "$output_file"
      echo "**Alternative:** Travel" >> "$output_file"
      ;;
    *)
      if [[ "$HAS_PDF" == true ]]; then
        echo "**Recommended:** Productivity" >> "$output_file"
        echo "**Alternative:** Business" >> "$output_file"
      else
        echo "**Recommended:** Productivity" >> "$output_file"
        echo "**Alternative:** Utilities" >> "$output_file"
      fi
      ;;
  esac

  cat >> "$output_file" <<'EOF'

## Secondary Category (optional)
**Select in App Store Connect:**

EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*|*[Ii]mmigration*)
      echo "**Recommended:** Travel" >> "$output_file"
      echo "**Alternative:** Business" >> "$output_file"
      ;;
    *)
      echo "**Recommended:** Business" >> "$output_file"
      echo "**Alternative:** Utilities" >> "$output_file"
      ;;
  esac

  cat >> "$output_file" <<'EOF'

## Available Categories:
- Business
- Productivity
- Utilities
- Travel
- Finance
- Education
- Lifestyle
- Reference

**Note:** Choose categories that best represent your app's primary function. Most users will find your app through search, not category browsing.

---

EOF
}

# ==========================================
# AGE RATING INFORMATION
# ==========================================

generate_age_rating() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 🔞 Age Rating Information

## Recommended Age Rating: 4+

### Content Rating Questionnaire Answers:

**Cartoon or Fantasy Violence:** None
**Realistic Violence:** None
**Sexual Content or Nudity:** None
**Profanity or Crude Humor:** None
**Alcohol, Tobacco, or Drug Use:** None
**Mature/Suggestive Themes:** None
**Horror/Fear Themes:** None
**Gambling:** None
**Contests:** None
**Unrestricted Web Access:** No
**Made for Kids:** No

### Explanation:
This app provides form-filling and document management services. It contains no inappropriate content and is suitable for ages 4+.

---

EOF
}

# ==========================================
# LOCALIZATION GUIDE
# ==========================================

generate_localization_guide() {
  local output_file="$1"
  
  cat >> "$output_file" <<'EOF'
# 🌍 Localization Guide

## Supported Languages
**Add these in App Store Connect:**

EOF

  if [[ ${#LANGUAGES[@]} -gt 0 ]]; then
    echo "Detected languages in app:" >> "$output_file"
    for lang in "${LANGUAGES[@]}"; do
      case "$lang" in
        en) echo "- English (Primary)" >> "$output_file" ;;
        ja) echo "- Japanese" >> "$output_file" ;;
        ko) echo "- Korean" >> "$output_file" ;;
        zh) echo "- Chinese (Simplified)" >> "$output_file" ;;
        vi) echo "- Vietnamese" >> "$output_file" ;;
        th) echo "- Thai" >> "$output_file" ;;
        hi) echo "- Hindi" >> "$output_file" ;;
        bn) echo "- Bengali" >> "$output_file" ;;
        ne) echo "- Nepali" >> "$output_file" ;;
        fil) echo "- Filipino" >> "$output_file" ;;
        *) echo "- $lang" >> "$output_file" ;;
      esac
    done
  else
    echo "- English (Primary)" >> "$output_file"
  fi

  cat >> "$output_file" <<'EOF'

## For Each Language, Translate:

1. **App Name** (30 characters)
2. **Subtitle** (30 characters)
3. **Description** (4000 characters)
4. **Keywords** (100 characters)
5. **What's New** (4000 characters)
6. **Promotional Text** (170 characters)
7. **Screenshot captions** (optional but recommended)

**Translation Tips:**
- Use native speakers or professional translation services
- Keep cultural context in mind
- Test translations in the app
- Ensure character limits are respected in each language
- Some languages need more/less characters for same meaning

---

EOF
}

# ==========================================
# MAIN GENERATOR
# ==========================================

generate_all_review_text() {
  local project_dir="$1"
  local output_dir="$2"
  
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║                                                        ║${NC}"
  echo -e "${CYAN}║     APP STORE REVIEW TEXT GENERATOR                   ║${NC}"
  echo -e "${CYAN}║     Generate Clear, Specific Submission Text          ║${NC}"
  echo -e "${CYAN}║                                                        ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  # Analyze project
  analyze_project "$project_dir"
  
  # Create output directory
  mkdir -p "$output_dir"
  
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local output_file="$output_dir/app_store_submission_text_${timestamp}.md"
  
  echo -e "${BLUE}📝 Generating submission text...${NC}"
  echo ""
  
  # Generate header
  cat > "$output_file" <<EOF
# 📱 App Store Submission Text
# Generated: $(date +"%Y-%m-%d %H:%M:%S")

**Project:** ${PROJECT_NAME}
**Bundle ID:** ${BUNDLE_ID:-Not detected}
**Version:** ${VERSION:-1.0}
**Build:** ${BUILD:-1}

---

**🎯 QUICK COPY SECTIONS:**
Each section below is ready to copy and paste into App Store Connect.
Look for "**Copy this for...**" markers.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  # Generate all sections
  generate_app_description "$output_file"
  generate_whats_new "$output_file" "$VERSION"
  generate_keywords "$output_file"
  generate_promotional_text "$output_file"
  generate_app_preview_text "$output_file"
  generate_support_info "$output_file"
  generate_review_notes "$output_file"
  generate_category_suggestions "$output_file"
  generate_age_rating "$output_file"
  generate_localization_guide "$output_file"
  
  # Add footer
  cat >> "$output_file" <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ✅ Submission Checklist

Before submitting, ensure:

## App Store Connect
- [ ] All metadata fields filled
- [ ] Screenshots uploaded (all required sizes)
- [ ] App icon uploaded (1024x1024)
- [ ] Privacy policy URL set
- [ ] Support URL set
- [ ] Build uploaded and selected
- [ ] Test account provided
- [ ] Age rating completed
- [ ] Category selected
- [ ] Pricing set

## App Binary
- [ ] Build tested on real device
- [ ] All features working
- [ ] No crashes or major bugs
- [ ] Performance is good
- [ ] Localization tested
- [ ] Account deletion works

## Legal
- [ ] Privacy policy is live
- [ ] Terms of service is live
- [ ] Copyright year is current
- [ ] All URLs are HTTPS
- [ ] Contact information is accurate

## Testing
- [ ] TestFlight beta testing complete
- [ ] Feedback addressed
- [ ] Pre-review tests passed
- [ ] Manual testing complete

---

# 🚀 Ready to Submit!

Your App Store submission text is complete. Copy the relevant sections into App Store Connect and submit for review.

**Good luck! 🍀**

EOF

  # Also create a quick copy file with just the essentials
  local quick_file="$output_dir/quick_copy_text.txt"
  cat > "$quick_file" <<EOF
APP STORE QUICK COPY TEXT
========================

PROJECT: ${PROJECT_NAME}
VERSION: ${VERSION:-1.0}
BUILD: ${BUILD:-1}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

APP NAME:
${PROJECT_NAME}

SUBTITLE (30 chars):
EOF

  if [[ "$HAS_PDF" == true && "$HAS_PRINT" == true ]]; then
    echo "Digital forms & printing" >> "$quick_file"
  else
    echo "Professional mobile app" >> "$quick_file"
  fi

  cat >> "$quick_file" <<EOF

KEYWORDS (100 chars):
EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*)
      echo "visa,immigration,form,pdf,application,student,dependent,document,print,digital" >> "$quick_file"
      ;;
    *)
      echo "app,mobile,productivity,efficient,secure" >> "$quick_file"
      ;;
  esac

  cat >> "$quick_file" <<EOF

PRIMARY CATEGORY:
Productivity

SECONDARY CATEGORY:
EOF

  case "$PROJECT_NAME" in
    *[Vv]isa*) echo "Travel" >> "$quick_file" ;;
    *) echo "Business" >> "$quick_file" ;;
  esac

  cat >> "$quick_file" <<EOF

AGE RATING:
4+

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For full descriptions, keywords, and all submission text,
see: $(basename "$output_file")

EOF

  echo -e "${GREEN}✅ Generation complete!${NC}"
  echo ""
  echo -e "${CYAN}📄 Files created:${NC}"
  echo -e "  ${YELLOW}Full text:${NC} $output_file"
  echo -e "  ${YELLOW}Quick copy:${NC} $quick_file"
  echo ""
  echo -e "${MAGENTA}📋 To view:${NC}"
  echo -e "  cat \"$output_file\""
  echo -e "  cat \"$quick_file\""
  echo ""
  echo -e "${GREEN}🚀 Copy sections into App Store Connect and submit!${NC}"
  echo ""
}

# ==========================================
# MAIN EXECUTION
# ==========================================

main() {
  local project_dir="${1:-.}"
  local output_dir="${2:-.dns_system/app_store_texts}"
  
  generate_all_review_text "$project_dir" "$output_dir"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

