#!/usr/bin/env bash
#
# upgrade_app_help_support.sh
# DNS System - Automated Help & Support Migration for Old Apps
#
# Usage:
#   ./upgrade_app_help_support.sh /path/to/OldApp "App Name" "support@email.com"
#
# This script will:
# 1. Copy Help & Support template
# 2. Create legal document templates
# 3. Set up configuration
# 4. Provide next steps
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DNS_SYSTEM_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEMPLATES_DIR="$DNS_SYSTEM_DIR/system/templates/ios"

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 /path/to/OldApp [AppName] [support@email.com]"
    echo ""
    echo "Examples:"
    echo "  $0 ~/MyApps/OldApp"
    echo "  $0 ~/MyApps/OldApp \"My App\" \"support@myapp.com\""
    exit 1
fi

APP_PATH="$1"
APP_NAME="${2:-YourApp}"
SUPPORT_EMAIL="${3:-support@yourapp.com}"

# Validate app path
if [ ! -d "$APP_PATH" ]; then
    print_error "App directory not found: $APP_PATH"
    exit 1
fi

print_header "DNS System - Help & Support Migration"
echo "App Path: $APP_PATH"
echo "App Name: $APP_NAME"
echo "Support Email: $SUPPORT_EMAIL"
echo ""

# Step 1: Create directory structure
print_info "Step 1: Creating directory structure..."

mkdir -p "$APP_PATH/Sources/Features/Profile"
mkdir -p "$APP_PATH/Sources/Shared"
mkdir -p "$APP_PATH/Legal"

print_success "Directories created"

# Step 2: Copy Help & Support template
print_info "Step 2: Copying Help & Support template..."

HELP_SUPPORT_TEMPLATE="$TEMPLATES_DIR/HelpSupportTemplate/HelpSupportView_Template.swift"
HELP_SUPPORT_DEST="$APP_PATH/Sources/Features/Profile/HelpSupportView.swift"

if [ -f "$HELP_SUPPORT_TEMPLATE" ]; then
    cp "$HELP_SUPPORT_TEMPLATE" "$HELP_SUPPORT_DEST"
    
    # Replace placeholders
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\[APP_NAME\]/$APP_NAME/g" "$HELP_SUPPORT_DEST"
    else
        # Linux
        sed -i "s/\[APP_NAME\]/$APP_NAME/g" "$HELP_SUPPORT_DEST"
    fi
    
    print_success "Help & Support view created: $HELP_SUPPORT_DEST"
else
    print_warning "Template not found, creating basic version..."
    # Create a minimal version if template missing
    cat > "$HELP_SUPPORT_DEST" << 'EOF'
import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Help & Support")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("TODO: Customize this view with your app's help content")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
EOF
    print_success "Basic Help & Support view created (needs customization)"
fi

# Step 3: Create Privacy Policy template
print_info "Step 3: Creating Privacy Policy template..."

PRIVACY_DEST="$APP_PATH/Legal/PRIVACY_POLICY.md"

cat > "$PRIVACY_DEST" << EOF
# Privacy Policy for $APP_NAME

**Last Updated: $(date +"%B %d, %Y")**

## Introduction

Welcome to $APP_NAME. We are committed to protecting your privacy.

## What We Collect

TODO: List what data you collect:
- ✅ Email and password (for authentication)
- ✅ [Add other data]

## What We DON'T Collect

TODO: List what you DON'T collect (important for protection):
- ❌ Analytics or usage data
- ❌ Location data
- ❌ [Add more]

## How We Store Data

TODO: Describe storage:
- Local storage on device
- OR Cloud storage via [service]

## Third-Party Services

TODO: List all third-party services:
- **Firebase Authentication** - for login
  - Privacy Policy: https://firebase.google.com/support/privacy

## Your Rights

- **Access:** Your data is accessible in the app
- **Deletion:** You can delete your account in Settings
- **Portability:** Data is stored locally on your device

## Contact Us

Email: $SUPPORT_EMAIL

---

**TODO: Copy VisaPro's PRIVACY_POLICY.md for a complete, production-ready template**
**Location: VisaPro/AppStore_Submission_Package/PRIVACY_POLICY.md**
EOF

print_success "Privacy Policy template created: $PRIVACY_DEST"
print_warning "⚠️  CUSTOMIZE THIS! Copy from VisaPro for best protection."

# Step 4: Create Terms of Service template
print_info "Step 4: Creating Terms of Service template..."

TERMS_DEST="$APP_PATH/Legal/TERMS_OF_SERVICE.md"

cat > "$TERMS_DEST" << EOF
# Terms of Service for $APP_NAME

**Last Updated: $(date +"%B %d, %Y")**

## 1. Acceptance of Terms

By using $APP_NAME, you agree to these Terms.

## 2. Description of Service

$APP_NAME is a [DESCRIBE YOUR APP].

**IMPORTANT DISCLAIMER:**
$APP_NAME does NOT provide professional advice.

## 3. Disclaimers and Limitations of Liability

**$APP_NAME IS PROVIDED "AS IS" WITHOUT WARRANTIES.**

TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE ARE NOT LIABLE FOR:
- Any damages or losses
- Direct, indirect, or consequential damages
- Lost profits or opportunities

**YOUR SOLE REMEDY:** Stop using the app.

**MAXIMUM LIABILITY:** \$0 (if free app).

## 4. User Responsibilities

YOU ARE RESPONSIBLE FOR:
- Accuracy of information you enter
- Verifying all information independently
- Complying with applicable laws

## 5. Indemnification

You agree to indemnify $APP_NAME and its developers from all claims
arising from your use of the app.

## 6. Contact

Email: $SUPPORT_EMAIL

---

**TODO: Copy VisaPro's TERMS_OF_SERVICE.md for complete, strong protection**
**Location: VisaPro/AppStore_Submission_Package/TERMS_OF_SERVICE.md**
EOF

print_success "Terms of Service template created: $TERMS_DEST"
print_warning "⚠️  CUSTOMIZE THIS! Copy from VisaPro for strongest disclaimers."

# Step 5: Create/Update AppConfiguration
print_info "Step 5: Creating AppConfiguration snippet..."

CONFIG_SNIPPET="$APP_PATH/Legal/AppConfiguration_Snippet.swift"

cat > "$CONFIG_SNIPPET" << EOF
//
// Add this to your AppConfiguration.swift or create it
//

import Foundation

enum AppConfiguration {
    // Legal document URLs
    // TODO: Upload legal docs to your website and update these URLs
    static let privacyPolicyURL = URL(string: "https://yourapp.com/privacy")!
    static let termsOfServiceURL = URL(string: "https://yourapp.com/terms")!
    static let supportEmail = "$SUPPORT_EMAIL"
    
    // App version for Help footer
    static var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
EOF

print_success "AppConfiguration snippet created: $CONFIG_SNIPPET"

# Step 6: Create DocumentViewer
print_info "Step 6: Creating DocumentViewer..."

DOC_VIEWER_DEST="$APP_PATH/Sources/Shared/DocumentViewer.swift"

cat > "$DOC_VIEWER_DEST" << 'EOF'
//
//  DocumentViewer.swift
//  Simple web view for Privacy Policy and Terms of Service
//

import SwiftUI
import WebKit

enum DocumentType {
    case privacyPolicy
    case termsOfService
    
    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        }
    }
    
    var url: URL {
        switch self {
        case .privacyPolicy: return AppConfiguration.privacyPolicyURL
        case .termsOfService: return AppConfiguration.termsOfServiceURL
        }
    }
}

struct DocumentViewer: View {
    let documentType: DocumentType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(url: documentType.url)
                .navigationTitle(documentType.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
EOF

print_success "DocumentViewer created: $DOC_VIEWER_DEST"

# Step 7: Create integration instructions
print_info "Step 7: Creating integration instructions..."

INSTRUCTIONS="$APP_PATH/Legal/INTEGRATION_INSTRUCTIONS.md"

cat > "$INSTRUCTIONS" << EOF
# Help & Support Integration Instructions

**Generated:** $(date)
**App:** $APP_NAME

## ✅ Files Created

1. **HelpSupportView.swift**
   - Location: \`Sources/Features/Profile/HelpSupportView.swift\`
   - Status: ⚠️ Needs customization (add your app's help content)

2. **Privacy Policy**
   - Location: \`Legal/PRIVACY_POLICY.md\`
   - Status: ⚠️ MUST customize before use!
   - Better: Copy from VisaPro for complete protection

3. **Terms of Service**
   - Location: \`Legal/TERMS_OF_SERVICE.md\`
   - Status: ⚠️ MUST customize before use!
   - Better: Copy from VisaPro for strongest disclaimers

4. **DocumentViewer.swift**
   - Location: \`Sources/Shared/DocumentViewer.swift\`
   - Status: ✅ Ready to use

5. **AppConfiguration snippet**
   - Location: \`Legal/AppConfiguration_Snippet.swift\`
   - Status: ⚠️ Copy to your AppConfiguration.swift

## 📋 Next Steps (Required)

### 1. Customize Help Content (1-2 hours)

Edit \`HelpSupportView.swift\`:
- Replace placeholder help sections with your app's content
- Add Getting Started guide
- Add FAQ based on user questions
- Add Troubleshooting for common issues

### 2. Customize Privacy Policy (30 min)

**RECOMMENDED:** Copy from VisaPro for production-ready version:
\`\`\`bash
cp VisaPro/AppStore_Submission_Package/PRIVACY_POLICY.md Legal/PRIVACY_POLICY.md
\`\`\`

Then customize:
- Replace "VisaPro" with "$APP_NAME"
- Update support email to "$SUPPORT_EMAIL"
- List what data YOU actually collect
- List third-party services YOU use
- Update date

### 3. Customize Terms of Service (30 min)

**RECOMMENDED:** Copy from VisaPro for strongest protection:
\`\`\`bash
cp VisaPro/AppStore_Submission_Package/TERMS_OF_SERVICE.md Legal/TERMS_OF_SERVICE.md
\`\`\`

Then customize:
- Replace "VisaPro" with "$APP_NAME"
- Update support email to "$SUPPORT_EMAIL"
- Add domain-specific disclaimers (medical, legal, financial, etc.)
- Update date

### 4. Upload Legal Docs to Website (15 min)

Upload to your website:
- Privacy Policy: \`https://yourapp.com/privacy\`
- Terms of Service: \`https://yourapp.com/terms\`

⚠️ Don't use \`example.com\` - App Store will reject!

### 5. Update AppConfiguration (5 min)

Copy contents of \`Legal/AppConfiguration_Snippet.swift\` to your \`AppConfiguration.swift\`.

Update URLs to match where you uploaded the legal docs.

### 6. Add to Profile/Settings (10 min)

In your ProfileView.swift or SettingsView.swift, add:

\`\`\`swift
NavigationLink {
    HelpSupportView()
} label: {
    HStack {
        Image(systemName: "questionmark.circle.fill")
        Text("Help & Support")
        Spacer()
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
\`\`\`

Place it in the top 3-5 items for easy access.

### 7. Test Everything (15 min)

- [ ] Can open Help & Support from Profile
- [ ] Search works in Help view
- [ ] Privacy Policy link works
- [ ] Terms of Service link works
- [ ] Documents load correctly
- [ ] Looks good on all screen sizes

## 🎯 Pre-Submission Checklist

Before submitting to App Store:

- [ ] Help content customized (no TODOs remaining)
- [ ] Privacy Policy customized for your app
- [ ] Terms customized with strong disclaimers
- [ ] Legal docs uploaded to website (not example.com)
- [ ] URLs updated in AppConfiguration
- [ ] Help & Support accessible from Profile
- [ ] All links tested and working
- [ ] Tested on real device
- [ ] No typos in legal documents

## 📚 Resources

- **Full Guide:** \`.dns_system/docs/HELP_SUPPORT_UPGRADE_GUIDE.md\`
- **Requirements:** \`.dns_system/data/help_support_requirement.yml\`
- **VisaPro Privacy:** \`VisaPro/AppStore_Submission_Package/PRIVACY_POLICY.md\`
- **VisaPro Terms:** \`VisaPro/AppStore_Submission_Package/TERMS_OF_SERVICE.md\`

## 💡 Pro Tips

1. **Copy from VisaPro** - It's production-tested and comprehensive
2. **Be specific in disclaimers** - "AS IS", "NOT LIABLE", "NOT [professional type]"
3. **List what you DON'T collect** - This protects you legally
4. **Test on device** - Simulator may not open email links
5. **Update regularly** - Review help content every 6 months

## ❓ Questions?

Check \`.dns_system/docs/HELP_SUPPORT_UPGRADE_GUIDE.md\` for detailed instructions.

---

**Next:** Follow steps 1-7 above to complete the integration.

**Time Required:** 2-4 hours total

Good luck! 🚀
EOF

print_success "Integration instructions created: $INSTRUCTIONS"

# Final summary
print_header "Migration Complete! 🎉"

echo -e "${GREEN}Files Created:${NC}"
echo "  ✅ $HELP_SUPPORT_DEST"
echo "  ✅ $PRIVACY_DEST"
echo "  ✅ $TERMS_DEST"
echo "  ✅ $DOC_VIEWER_DEST"
echo "  ✅ $CONFIG_SNIPPET"
echo "  ✅ $INSTRUCTIONS"
echo ""

print_warning "IMPORTANT: These are TEMPLATES that need customization!"
echo ""
echo "📋 Next Steps:"
echo "  1. Read: $INSTRUCTIONS"
echo "  2. Customize Help content in HelpSupportView.swift"
echo "  3. Copy VisaPro's Privacy Policy for best protection"
echo "  4. Copy VisaPro's Terms for strongest disclaimers"
echo "  5. Upload legal docs to your website"
echo "  6. Update URLs in AppConfiguration"
echo "  7. Add Help & Support link to Profile"
echo "  8. Test everything"
echo ""

print_info "Full upgrade guide: .dns_system/docs/HELP_SUPPORT_UPGRADE_GUIDE.md"
echo ""

print_success "Setup complete! Now customize for your app. 🚀"

