#!/usr/bin/env bash
# App Store Review Package Generator
# Generates complete submission package with all necessary materials

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ROOT_DIR="$(cd "$SYSTEM_DIR/.." && pwd)"

# Configuration
REVIEW_PACKAGE_DIR="$ROOT_DIR/AppStore_Review_Package"
TEMPLATES_DIR="$SYSTEM_DIR/templates/review_materials"
CONFIG_FILE="$SYSTEM_DIR/config/app_info.conf"

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Load app configuration
load_app_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        print_warning "No app_info.conf found. Using defaults."
        APP_NAME="MyApp"
        APP_VERSION="1.0.0"
        APP_BUNDLE_ID="com.company.myapp"
        COMPANY_NAME="My Company"
        SUPPORT_EMAIL="support@myapp.com"
        SUPPORT_URL="https://myapp.com/support"
        PRIVACY_URL="https://myapp.com/privacy"
        TERMS_URL="https://myapp.com/terms"
    fi
}

# Create directory structure
create_directory_structure() {
    print_header "📁 Creating Review Package Directory Structure"
    
    mkdir -p "$REVIEW_PACKAGE_DIR"/{metadata,screenshots,videos,documents,assets,notes}
    mkdir -p "$REVIEW_PACKAGE_DIR"/screenshots/{iphone,ipad}
    mkdir -p "$REVIEW_PACKAGE_DIR"/screenshots/iphone/{6.5-inch,5.5-inch}
    mkdir -p "$REVIEW_PACKAGE_DIR"/screenshots/ipad/{12.9-inch}
    mkdir -p "$REVIEW_PACKAGE_DIR"/videos/{preview,demo}
    mkdir -p "$REVIEW_PACKAGE_DIR"/documents/{legal,technical}
    mkdir -p "$REVIEW_PACKAGE_DIR"/assets/{icons,promotional}
    
    print_success "Directory structure created at: $REVIEW_PACKAGE_DIR"
}

# Generate metadata file
generate_metadata() {
    print_header "📝 Generating App Metadata"
    
    local metadata_file="$REVIEW_PACKAGE_DIR/metadata/app_metadata.txt"
    
    cat > "$metadata_file" << EOF
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║                    APP STORE METADATA                            ║
║                    Generated: $(date +"%B %d, %Y")                          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APP INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

App Name:           $APP_NAME
Version:            $APP_VERSION
Bundle ID:          $APP_BUNDLE_ID
Company:            $COMPANY_NAME

Primary Category:   [FILL IN: Productivity, Business, Education, etc.]
Secondary Category: [OPTIONAL]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
APP STORE LISTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUBTITLE (Max 30 characters):
[FILL IN: Brief tagline describing your app]

PROMOTIONAL TEXT (Max 170 characters):
[OPTIONAL: Updated for seasonal promotions, features, events]

DESCRIPTION (Max 4000 characters):
[FILL IN: Detailed description of your app]

Key Features:
• [Feature 1]
• [Feature 2]
• [Feature 3]
• [Feature 4]
• [Feature 5]

KEYWORDS (Max 100 characters, comma-separated):
[FILL IN: visa, forms, documents, pdf, immigration, etc.]

SUPPORT URL:        $SUPPORT_URL
MARKETING URL:      [OPTIONAL]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT'S NEW IN THIS VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[FILL IN: Max 4000 characters]

Version $APP_VERSION includes:
• [New feature or improvement 1]
• [Bug fix or enhancement 2]
• [Performance improvement 3]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONTACT INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Support Email:      $SUPPORT_EMAIL
Privacy Policy:     $PRIVACY_URL
Terms of Service:   $TERMS_URL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REVIEW NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test Account (if required):
  Email:    [FILL IN if your app requires login]
  Password: [FILL IN]

Special Instructions:
[FILL IN: Any special notes for the review team]

Demo Data:
[FILL IN: Information about test data or demo content]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

    print_success "Metadata file created: $metadata_file"
}

# Generate description templates
generate_descriptions() {
    print_header "📄 Generating Description Templates"
    
    # English description
    cat > "$REVIEW_PACKAGE_DIR/metadata/description_english.txt" << 'EOF'
# App Store Description - English
# Maximum 4000 characters

## HEADLINE (First 2-3 sentences - most important!)
[Write a compelling opening that explains what your app does and why users need it]

## KEY FEATURES
Transform your [task/workflow] with [App Name]:

✓ Feature 1: [Benefit-focused description]
✓ Feature 2: [Benefit-focused description]
✓ Feature 3: [Benefit-focused description]
✓ Feature 4: [Benefit-focused description]
✓ Feature 5: [Benefit-focused description]

## WHY CHOOSE [APP NAME]?
• Simple & Intuitive: [Explain ease of use]
• Secure & Private: [Explain security features]
• Fast & Reliable: [Explain performance]
• Professional Quality: [Explain quality standards]

## WHO IS THIS FOR?
Perfect for:
• [User type 1]
• [User type 2]
• [User type 3]

## TESTIMONIALS (if available)
"[User quote]" - [User name/credential]

## SUPPORT
We're here to help! Contact us at [support email]
Visit [support URL] for FAQs and guides

## PRIVACY
Your data stays private. We never sell your information.
Read our privacy policy: [privacy URL]

---
Download [App Name] today and [main benefit]!
EOF

    # Keywords guide
    cat > "$REVIEW_PACKAGE_DIR/metadata/keywords_guide.txt" << 'EOF'
# App Store Keywords Guide
# Maximum 100 characters (including commas)

## KEYWORD STRATEGY

### Primary Keywords (Most Important)
[main function, main category, main use case]

### Secondary Keywords
[related features, alternative terms, use cases]

### Long-tail Keywords
[specific phrases users might search]

## KEYWORD RESEARCH
Use App Store Connect's Keyword Suggestions
Check competitor apps for keyword ideas
Use Google Trends for popularity

## FORMATTING
- Comma-separated, no spaces after commas
- No plural if singular is included (app includes both)
- No category names (already in app category)
- No app name (Apple indexes it automatically)

## EXAMPLE KEYWORDS
visa,forms,pdf,documents,immigration,application,travel,embassy,consulate,generator,fill,digital,paperwork

## YOUR KEYWORDS (100 chars max)
[FILL IN]

Character count: [X/100]
EOF

    print_success "Description templates created"
}

# Generate screenshot guide
generate_screenshot_guide() {
    print_header "📸 Generating Screenshot Guide"
    
    cat > "$REVIEW_PACKAGE_DIR/screenshots/SCREENSHOT_REQUIREMENTS.md" << 'EOF'
# 📸 App Store Screenshot Requirements

## Required Sizes

### iPhone
**6.5-inch Display (Required)** - iPhone 14 Pro Max, 13 Pro Max, 12 Pro Max, 11 Pro Max, XS Max
- Resolution: 1284 x 2778 pixels (portrait) or 2778 x 1284 pixels (landscape)
- Up to 10 screenshots

**5.5-inch Display (Required)** - iPhone 8 Plus, 7 Plus, 6s Plus
- Resolution: 1242 x 2208 pixels (portrait) or 2208 x 1242 pixels (landscape)
- Up to 10 screenshots

### iPad (if supported)
**12.9-inch Display (Required)**
- Resolution: 2048 x 2732 pixels (portrait) or 2732 x 2048 pixels (landscape)
- Up to 10 screenshots

## Screenshot Best Practices

### 1. First Screenshot is Critical
- Shows the most important/unique feature
- Clear, compelling visual
- Minimal text overlay

### 2. Tell a Story (in order)
1. Main screen/welcome
2. Key feature 1
3. Key feature 2
4. Key feature 3
5. Additional features/benefits

### 3. Design Tips
✓ Use high-quality, clear images
✓ Show actual app in use
✓ Consistent design style
✓ Text should be readable
✓ Use device frames (optional but recommended)
✓ Add short captions explaining features

✗ Don't use blurry images
✗ Don't include status bar with personal info
✗ Don't use placeholder content
✗ Don't violate Apple's guidelines

### 4. Text Overlays
- Keep text minimal and large
- Highlight key benefits
- Use contrasting colors
- Ensure readability on all devices

### 5. Localization
- Create versions for each supported language
- Translate all text in screenshots
- Consider cultural differences

## Tools for Creating Screenshots

### Simulator Screenshots
```bash
# Take screenshot in Simulator
Command + S (saves to Desktop)
```

### Professional Tools
- **Figma** - Design marketing screenshots
- **Sketch** - Professional design tool
- **App Store Screenshot Generator** - Online tools
- **Screenshot Creator** - Mac App Store

### Device Frames
- Use Apple's official device frames
- https://developer.apple.com/design/resources/

## Screenshot Checklist

Before uploading:
- [ ] Correct dimensions for each required size
- [ ] PNG or JPEG format
- [ ] RGB color space
- [ ] No transparent backgrounds
- [ ] Maximum file size: 500 MB per screenshot
- [ ] Show actual app content (no mockups)
- [ ] No sensitive user data visible
- [ ] Status bar cleaned (if visible)
- [ ] All text is readable
- [ ] Professional quality

## File Naming Convention

```
iphone_6.5_01_main.png
iphone_6.5_02_feature1.png
iphone_6.5_03_feature2.png
iphone_5.5_01_main.png
ipad_12.9_01_main.png
```

## Quick Setup Script

```bash
# Create screenshot directories
mkdir -p screenshots/iphone/6.5-inch
mkdir -p screenshots/iphone/5.5-inch
mkdir -p screenshots/ipad/12.9-inch

# Run app in Simulator at correct sizes
# iPhone 14 Pro Max for 6.5-inch
# iPhone 8 Plus for 5.5-inch
# iPad Pro 12.9-inch for iPad
```

## Review Guidelines

Apple reviews screenshots for:
- Accuracy (must show actual app)
- Appropriateness (no inappropriate content)
- Quality (professional, clear)
- Compliance (follows guidelines)

Read full guidelines:
https://developer.apple.com/app-store/product-page/
EOF

    print_success "Screenshot guide created"
}

# Generate video guide
generate_video_guide() {
    print_header "🎥 Generating Video Guide"
    
    cat > "$REVIEW_PACKAGE_DIR/videos/VIDEO_REQUIREMENTS.md" << 'EOF'
# 🎥 App Store Preview Video Requirements

## App Preview Video Specifications

### Required Formats
- **File format**: .mov, .m4v, or .mp4
- **Codec**: H.264 or HEVC
- **Resolution**: Must match device display size
- **Frame rate**: 24-60 fps
- **Duration**: 15-30 seconds
- **File size**: Maximum 500 MB

### Device Sizes
Same as screenshots:
- iPhone 6.5-inch: 1284 x 2778 or 2778 x 1284
- iPhone 5.5-inch: 1242 x 2208 or 2208 x 1242
- iPad 12.9-inch: 2048 x 2732 or 2732 x 2048

## Content Guidelines

### What to Show
✓ App in actual use
✓ Key features and benefits
✓ User interface and interactions
✓ Real functionality
✓ Value proposition

### What to Avoid
✗ Prices or pricing info
✗ "Download now" or calls to action
✗ Third-party app references
✗ Apple Watch (unless app preview is for Watch)
✗ False or misleading information
✗ Inappropriate content

## Video Structure (15-30 seconds)

### Opening (2-3 seconds)
- App icon and name
- Brief tagline or value proposition

### Main Content (10-20 seconds)
- Show 2-3 key features
- Demonstrate actual app usage
- Show smooth interactions
- Highlight unique aspects

### Closing (2-3 seconds)
- App icon
- End screen with key message

## Recording Methods

### Method 1: Screen Recording
```bash
# iOS Simulator
1. Open Simulator
2. Go to Features → Record Screen
3. Perform actions in app
4. Save recording

# Real Device
1. Open Control Center
2. Tap screen recording button
3. Record app usage
4. Stop recording (video saved to Photos)
```

### Method 2: QuickTime (Mac)
```bash
1. Connect iPhone/iPad via USB
2. Open QuickTime Player
3. File → New Movie Recording
4. Click dropdown → Select device
5. Record app usage
```

### Method 3: Professional Tools
- **Final Cut Pro** - Professional editing
- **iMovie** - Free, user-friendly
- **Adobe Premiere** - Professional editing
- **ScreenFlow** - Screen recording & editing

## Editing Tips

### 1. Quality
- Use high resolution
- Smooth transitions
- Clear visuals
- No lag or stuttering

### 2. Audio
- Music (optional, must own rights)
- Voiceover (optional)
- Sound effects from app
- Or silent (also fine)

### 3. Text Overlays
- Minimal text
- Large, readable font
- Brief feature callouts
- Consistent styling

### 4. Pacing
- Fast enough to maintain interest
- Slow enough to understand features
- 15-30 seconds total
- Show 2-3 features max

## Export Settings

### Final Cut Pro / iMovie
- Format: QuickTime Movie
- Codec: H.264
- Resolution: Match device size
- Frame rate: 30 fps
- Quality: Best

### Handbrake (Compression)
```
Container: MP4
Video Codec: H.264
Quality: RF 20-23
Frame rate: Same as source
Resolution: Don't scale
```

## Testing Checklist

Before uploading:
- [ ] Correct resolution for device
- [ ] 15-30 seconds duration
- [ ] Under 500 MB file size
- [ ] Plays smoothly
- [ ] Shows actual app functionality
- [ ] No prohibited content
- [ ] Audio levels appropriate (if used)
- [ ] Professional quality
- [ ] Accurate representation of app

## Demo Video Script Template

```
[0:00-0:02] OPENING
- Show app icon
- Display app name
- Show tagline

[0:02-0:12] FEATURE SHOWCASE
- Feature 1: [2-3 seconds]
  Show [specific interaction]
  
- Feature 2: [2-3 seconds]
  Demonstrate [key benefit]
  
- Feature 3: [2-3 seconds]
  Highlight [unique aspect]

[0:12-0:15] CLOSING
- Show app icon
- Display key message
- Fade out
```

## File Naming

```
app_preview_iphone_6.5.mp4
app_preview_iphone_5.5.mp4
app_preview_ipad_12.9.mp4
```

## Optional: App Preview Poster Frame

- Frame from video shown before playback
- Choose an engaging, representative frame
- Shows what video is about
- Selected in App Store Connect

## Resources

- Apple's App Preview Guidelines:
  https://developer.apple.com/app-store/app-previews/
  
- App Preview Specifications:
  https://help.apple.com/app-store-connect/

- Stock Music (royalty-free):
  - Epidemic Sound
  - Artlist
  - AudioJungle
EOF

    print_success "Video guide created"
}

# Generate legal documents templates
generate_legal_documents() {
    print_header "⚖️  Generating Legal Document Templates"
    
    # Privacy Policy Template
    cat > "$REVIEW_PACKAGE_DIR/documents/legal/PRIVACY_POLICY_TEMPLATE.md" << 'EOF'
# Privacy Policy for [App Name]

**Last Updated:** [Date]

## Introduction

[Company Name] ("we," "our," or "us") operates the [App Name] mobile application (the "App"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our App.

## Information We Collect

### Information You Provide
- Account information (name, email address)
- Profile information
- Content you create or upload
- Communication with support

### Automatically Collected Information
- Device information (model, OS version)
- Usage data (features used, time spent)
- Log data (crashes, errors)
- Analytics data

### Information from Third Parties
- [If using OAuth] Information from Google/Facebook/Apple Sign-In
- [If applicable] Payment information from payment processors

## How We Use Your Information

We use collected information to:
- Provide and maintain the App
- Improve user experience
- Send important updates
- Provide customer support
- Ensure security and prevent fraud
- Comply with legal obligations

## Data Storage and Security

- Data stored [locally on device / on secure servers / both]
- [If cloud] We use [Firebase/AWS/other] for secure storage
- Encryption in transit and at rest
- Regular security audits
- Access controls and authentication

## Third-Party Services

We use the following third-party services:
- [Firebase] for authentication and analytics
- [Payment processor] for payments
- [Analytics service] for usage analytics

Each service has its own privacy policy.

## Your Rights

You have the right to:
- Access your personal data
- Correct inaccurate data
- Delete your account and data
- Opt-out of marketing communications
- Export your data

## Children's Privacy

Our App is not intended for children under 13. We do not knowingly collect information from children under 13.

## Changes to This Policy

We may update this Privacy Policy. We will notify you of changes by posting the new policy with an updated date.

## Contact Us

Questions about this Privacy Policy?
- Email: [support email]
- Website: [support URL]

---

[Company Name]
[Address]
[City, State, ZIP]
EOF

    # Terms of Service Template
    cat > "$REVIEW_PACKAGE_DIR/documents/legal/TERMS_OF_SERVICE_TEMPLATE.md" << 'EOF'
# Terms of Service for [App Name]

**Last Updated:** [Date]

## Agreement to Terms

By accessing or using [App Name], you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not use our App.

## License to Use

We grant you a limited, non-exclusive, non-transferable license to use the App for personal [or business] purposes, subject to these Terms.

## User Accounts

- You are responsible for maintaining account security
- You must provide accurate information
- You must be at least 13 years old (or applicable age in your jurisdiction)
- One person or entity per account
- Don't share your account credentials

## Acceptable Use

You agree NOT to:
- Violate any laws or regulations
- Infringe on intellectual property rights
- Upload malicious code or viruses
- Harass or harm other users
- Attempt to access unauthorized areas
- Use the App for illegal purposes
- Reverse engineer the App

## Content

### Your Content
- You retain ownership of content you create
- You grant us license to use, store, and display your content
- You are responsible for your content
- Don't upload illegal or infringing content

### Our Content
- All App content is our property or our licensors'
- Protected by copyright and other laws
- Don't copy, modify, or distribute without permission

## Payments and Subscriptions

[If applicable]
- Subscription terms
- Payment methods
- Refund policy
- Auto-renewal terms
- Cancellation process

## Termination

We may terminate or suspend your account for:
- Violation of these Terms
- Fraudulent activity
- Prolonged inactivity
- At our discretion with notice

## Disclaimers

THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.

We do not guarantee:
- Uninterrupted or error-free service
- Accuracy of information
- Suitability for your purposes

## Limitation of Liability

TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE ARE NOT LIABLE FOR:
- Indirect or consequential damages
- Loss of data or profits
- Service interruptions
- Third-party content or actions

## Indemnification

You agree to indemnify and hold us harmless from claims arising from your use of the App or violation of these Terms.

## Changes to Terms

We reserve the right to modify these Terms at any time. Continued use after changes constitutes acceptance.

## Governing Law

These Terms are governed by the laws of [Jurisdiction], without regard to conflict of law principles.

## Contact Us

Questions about these Terms?
- Email: [support email]
- Website: [support URL]

---

[Company Name]
[Address]
[City, State, ZIP]
EOF

    print_success "Legal document templates created"
}

# Generate review notes template
generate_review_notes() {
    print_header "📋 Generating Review Notes Template"
    
    cat > "$REVIEW_PACKAGE_DIR/notes/REVIEWER_NOTES.md" << 'EOF'
# Notes for App Store Review Team

## App Purpose and Core Functionality

[Clearly explain what your app does and its primary purpose]

## Demo Account Information

**Test Account:**
- Email: [test@example.com]
- Password: [TestPassword123]

**Account Features:**
- Pre-populated with sample data
- All features accessible
- No payment required for testing

## How to Test the App

### First Launch
1. [Step-by-step instructions]
2. [What reviewers should see]
3. [Expected behavior]

### Main Features to Test

#### Feature 1: [Name]
1. Navigate to [location]
2. Tap [button/action]
3. Expected result: [describe]

#### Feature 2: [Name]
1. [Instructions]
2. [Expected result]

#### Feature 3: [Name]
1. [Instructions]
2. [Expected result]

## Special Permissions

### [Permission Name] - Required for [Purpose]
- When requested: [When user performs X action]
- Why needed: [Explanation]
- What happens if denied: [Graceful degradation]

### [Another Permission]
- [Same format]

## Third-Party Accounts (if required)

If app requires external accounts:
- Service: [e.g., Google account]
- Purpose: [Why needed]
- Test credentials: [Provided above or available at URL]

## Payment Testing

[If app has in-app purchases]
- Sandbox test account: [Apple sandbox account]
- Test products: [List test products]
- No real charges will be made

## Known Limitations

[If any limitations specific to review version]
- [Limitation 1 and why it exists]
- [Limitation 2 and expected behavior]

## Recent Changes

Version [X.X.X] includes:
- [Change 1]
- [Change 2]
- [Bug fixes]

## Compliance Notes

### Account Deletion (Guideline 5.1.1)
- Available in: Settings → Delete Account
- Process: [Describe the deletion flow]
- Data removed: All user data permanently deleted

### Privacy Policy
- Accessible in app: Settings → Privacy Policy
- URL: [Your privacy policy URL]
- Describes all data collection and usage

### Terms of Service
- Accessible in app: Settings → Terms of Service
- URL: [Your terms URL]

## Support Contact

For any questions during review:
- Email: [support@example.com]
- Response time: Within 24 hours
- Phone: [Optional]

## Additional Notes

[Any other information that would be helpful for reviewers]
- Special testing instructions
- Device-specific behaviors
- Regional differences
- Time-sensitive features

---

Thank you for reviewing our app!
EOF

    print_success "Review notes template created"
}

# Generate icon and promotional assets guide
generate_assets_guide() {
    print_header "🎨 Generating Assets Guide"
    
    cat > "$REVIEW_PACKAGE_DIR/assets/ASSETS_REQUIREMENTS.md" << 'EOF'
# 🎨 App Store Assets Requirements

## App Icon

### Required Sizes (iOS)
All icons must be provided in the following sizes:

| Size | Usage | Pixels |
|------|-------|--------|
| 1024x1024 | App Store | 1024x1024 px |
| 180x180 | iPhone, iOS 14+ | 180x180 px (@3x) |
| 167x167 | iPad Pro | 167x167 px (@2x) |
| 152x152 | iPad, iPad mini | 152x152 px (@2x) |
| 120x120 | iPhone, iOS 12-13 | 120x120 px (@2x, @3x) |
| 87x87 | iPhone, iOS 12-13 | 87x87 px (@3x) |
| 80x80 | iPad, Spotlight | 80x80 px (@2x) |
| 76x76 | iPad | 76x76 px (@1x) |
| 60x60 | iPhone | 60x60 px (@2x, @3x) |
| 58x58 | Settings | 58x58 px (@2x) |
| 40x40 | Spotlight | 40x40 px (@2x, @3x) |
| 29x29 | Settings | 29x29 px (@2x, @3x) |
| 20x20 | Notifications | 20x20 px (@2x, @3x) |

### Icon Design Guidelines
✓ No transparency
✓ No rounded corners (iOS adds automatically)
✓ RGB color space
✓ 72 DPI minimum
✓ PNG format
✓ Simple, recognizable design
✓ Works at all sizes

✗ Don't include alpha channel
✗ Don't add iOS UI elements
✗ Don't use photos of Apple products
✗ Don't replicate Apple apps

### Icon Design Tips
1. **Simple and Clear**: Recognizable even at small sizes
2. **Consistent Branding**: Matches your brand identity
3. **Single Focus**: One clear element, not cluttered
4. **Bold Colors**: Stand out on device and App Store
5. **No Text**: Icon should be visual only (except logos)

## Promotional Images (Optional but Recommended)

### Feature Graphic
- Size: 1024x500 pixels
- Format: PNG or JPEG
- Purpose: Featured in App Store (if selected by Apple)
- Content: Eye-catching visual representing your app

### Social Media Assets
For marketing:
- Twitter: 1200x675 px
- Facebook: 1200x630 px
- Instagram: 1080x1080 px

## Tools for Creating Icons

### Professional Tools
- **Sketch** - Popular among app designers
- **Figma** - Free, web-based design tool
- **Adobe Illustrator** - Vector design
- **Adobe Photoshop** - Raster graphics
- **Affinity Designer** - Affordable alternative

### Icon Generator Tools
- **AppIconMaker** - Generate all sizes from one image
- **MakeAppIcon** - Online icon generator
- **Icon Set Creator** - Xcode tool
- **iconutil** - Command-line tool (built into macOS)

### Generate All Sizes Script

```bash
#!/bin/bash
# Generate all icon sizes from 1024x1024 master

MASTER="icon-1024.png"
SIZES=(20 29 40 58 60 76 80 87 120 152 167 180 1024)

for size in "${SIZES[@]}"; do
  sips -z $size $size $MASTER --out "icon-${size}.png"
done
```

## Asset Checklist

Before submission:
- [ ] 1024x1024 App Store icon (no transparency, no rounded corners)
- [ ] All required icon sizes generated
- [ ] Icons look good at all sizes
- [ ] No trademark/copyright violations
- [ ] RGB color space (not CMYK)
- [ ] PNG format
- [ ] Consistent branding across all sizes
- [ ] Icon follows Apple's guidelines
- [ ] Tested on actual devices

## File Organization

```
assets/
├── icons/
│   ├── master/
│   │   └── icon-1024.png (master file)
│   ├── ios/
│   │   ├── icon-20@2x.png
│   │   ├── icon-20@3x.png
│   │   ├── icon-29@2x.png
│   │   └── ... (all required sizes)
│   └── appstore/
│       └── icon-1024.png (App Store)
├── promotional/
│   ├── feature-graphic.png
│   ├── social-twitter.png
│   ├── social-facebook.png
│   └── social-instagram.png
└── screenshots/
    └── (see SCREENSHOT_REQUIREMENTS.md)
```

## Design Resources

### Free Icon Templates
- Apple Design Resources: https://developer.apple.com/design/resources/
- iOS Icon Templates: Various Figma/Sketch community resources

### Inspiration
- Dribbble: https://dribbble.com/tags/app_icon
- Behance: https://www.behance.net/search/projects?search=app%20icon

### Guidelines
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/app-icons
- App Store Product Page: https://developer.apple.com/app-store/product-page/

## Testing Your Icon

1. **On Device**: Install app and check icon on home screen
2. **In Spotlight**: Search for your app
3. **In Settings**: Check in Settings app
4. **App Store**: Preview in App Store Connect
5. **Different Backgrounds**: Test on various wallpapers
6. **Accessibility**: Check with reduced transparency
EOF

    print_success "Assets guide created"
}

# Generate localization guide
generate_localization_guide() {
    print_header "🌍 Generating Localization Guide"
    
    cat > "$REVIEW_PACKAGE_DIR/documents/LOCALIZATION_GUIDE.md" << 'EOF'
# 🌍 App Store Localization Guide

## Supported Languages

List all languages your app supports:
- [ ] English (U.S.)
- [ ] Spanish
- [ ] French
- [ ] German
- [ ] Japanese
- [ ] Chinese (Simplified)
- [ ] Chinese (Traditional)
- [ ] Korean
- [ ] Portuguese (Brazil)
- [ ] Arabic
- [ ] [Add others]

## What Needs Translation

### App Store Connect Metadata
For EACH language:
- [ ] App name (if localized)
- [ ] Subtitle (30 chars)
- [ ] Description (4000 chars)
- [ ] Keywords (100 chars)
- [ ] What's new text (4000 chars)
- [ ] Promotional text (170 chars, optional)
- [ ] Privacy Policy URL (if translated)

### Screenshots
- [ ] Create localized screenshots for each language
- [ ] Translate any text overlays
- [ ] Consider cultural differences in imagery

### In-App Content
- [ ] UI strings
- [ ] Error messages
- [ ] Button labels
- [ ] Help text
- [ ] Legal documents

## Localization Tips

### 1. Translation Quality
- Use professional translators (not just Google Translate)
- Native speakers for best results
- Cultural adaptation, not just word-for-word
- Review in context, not just spreadsheets

### 2. Text Expansion
Different languages take different space:
- German: +35% longer than English
- Spanish: +20-30% longer
- Japanese: 50% shorter
- Arabic: Right-to-left layout

Plan UI to accommodate text expansion!

### 3. Cultural Considerations
- Colors have different meanings
- Images may need adaptation
- Date/time formats vary
- Currency and measurements
- Legal requirements differ

### 4. Testing
- [ ] Test app in each language
- [ ] Check text fits in UI
- [ ] Verify right-to-left languages (Arabic, Hebrew)
- [ ] Test on actual devices
- [ ] Get native speaker feedback

## File Structure

```
Localizations/
├── en.lproj/          # English
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── es.lproj/          # Spanish
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── fr.lproj/          # French
└── ...
```

## App Store Connect Languages

When adding a language in App Store Connect:
1. Go to App Information
2. Click "+" to add language
3. Fill in all required fields
4. Upload localized screenshots
5. Save and submit for review

## Localization Checklist

Per language:
- [ ] All UI strings translated
- [ ] App Store metadata translated
- [ ] Screenshots localized
- [ ] Keywords researched for market
- [ ] Privacy Policy available (if required)
- [ ] Tested by native speaker
- [ ] Text fits in UI at all places
- [ ] Cultural appropriateness verified
- [ ] Date/time formats correct
- [ ] Currency displayed correctly

## Tools

### Translation Management
- **Phrase** (phrase.com) - Translation management platform
- **Crowdin** - Crowdsourced translations
- **Lokalise** - Localization platform
- **POEditor** - Simple translation management

### iOS Tools
- **Xcode** - Built-in localization
- **BartyCrouch** - Automated string extraction
- **SwiftGen** - Type-safe localization

## Priority Languages

Start with languages that have highest market potential:

### Tier 1 (Essential)
- English (U.S.) - Must have
- Chinese (Simplified) - Largest market
- Spanish - Wide reach
- Japanese - High value market

### Tier 2 (Important)
- German
- French
- Korean
- Portuguese (Brazil)

### Tier 3 (Expanding)
- Arabic
- Russian
- Italian
- Dutch
- Others based on your target market

## Cost Considerations

Professional translation costs:
- $0.08-$0.25 per word (average)
- App Store description: ~$50-150 per language
- Full app localization: $500-5000+ per language
- Screenshots: $50-200 per language

Budget accordingly!

## Resources

- Apple Localization Guide: https://developer.apple.com/localization/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Locale Data: https://www.apple.com/ios/feature-availability/
EOF

    print_success "Localization guide created"
}

# Generate submission checklist
generate_submission_checklist() {
    print_header "✅ Generating Submission Checklist"
    
    cat > "$REVIEW_PACKAGE_DIR/SUBMISSION_CHECKLIST.md" << 'EOF'
# ✅ App Store Submission Checklist

**App Name:** [Fill in]  
**Version:** [Fill in]  
**Submission Date:** [Fill in]

---

## Phase 1: Pre-Submission

### App Completeness
- [ ] App builds and runs without errors
- [ ] All features working correctly
- [ ] No test or debug code remaining
- [ ] No crashes or major bugs
- [ ] Performance is acceptable
- [ ] Memory usage is reasonable

### Testing
- [ ] Tested on multiple devices (if possible)
- [ ] Tested on iOS minimum version
- [ ] Tested on latest iOS version
- [ ] All user flows tested
- [ ] Error scenarios tested
- [ ] Offline behavior tested (if applicable)

---

## Phase 2: Technical Requirements

### Build Configuration
- [ ] App version number set correctly
- [ ] Build number incremented
- [ ] Bundle identifier is correct (not placeholder)
- [ ] Deployment target set appropriately
- [ ] Build configuration is Release (not Debug)
- [ ] Code signing configured correctly

### App Store Connect Setup
- [ ] App created in App Store Connect
- [ ] Bundle ID matches
- [ ] Certificates and profiles configured
- [ ] Archive uploaded successfully
- [ ] Build appears in App Store Connect

---

## Phase 3: App Store Listing

### Basic Information
- [ ] App name (max 30 characters)
- [ ] Subtitle (max 30 characters)
- [ ] Privacy Policy URL
- [ ] Primary category selected
- [ ] Secondary category (optional)
- [ ] Copyright notice

### Description & Marketing
- [ ] App description written (max 4000 chars)
- [ ] Keywords researched and entered (max 100 chars)
- [ ] What's New text written
- [ ] Promotional text (optional, max 170 chars)
- [ ] Support URL provided
- [ ] Marketing URL (optional)

### Media Assets
- [ ] 1024x1024 App Store icon uploaded
- [ ] Screenshots uploaded (6.5-inch iPhone required)
- [ ] Screenshots uploaded (5.5-inch iPhone required)
- [ ] iPad screenshots (if supporting iPad)
- [ ] App Preview video (optional but recommended)

---

## Phase 4: Legal & Compliance

### Required Documents
- [ ] Privacy Policy accessible in app
- [ ] Privacy Policy URL in App Store Connect
- [ ] Terms of Service accessible in app
- [ ] Terms of Service URL provided

### App Store Guidelines Compliance
- [ ] Account deletion feature (if app has accounts) - Guideline 5.1.1(v)
- [ ] No placeholder content
- [ ] No misleading information
- [ ] Appropriate content rating
- [ ] Proper permission descriptions
- [ ] Third-party login disclaimer (if applicable)

### Privacy & Data
- [ ] App Privacy details completed in App Store Connect
- [ ] Data collection practices documented
- [ ] Permission usage descriptions in Info.plist
- [ ] User data handling explained
- [ ] Privacy Policy covers all data usage

---

## Phase 5: App Review Information

### Contact Information
- [ ] First name
- [ ] Last name
- [ ] Phone number
- [ ] Email address

### Review Notes
- [ ] Demo account provided (if app requires login)
- [ ] Special instructions for reviewers
- [ ] Notes about any complex features
- [ ] Explanation of permissions requested

### Additional Information
- [ ] App is appropriate for age rating selected
- [ ] Content rights obtained (if applicable)
- [ ] Export compliance information provided
- [ ] Advertising identifier usage declared

---

## Phase 6: Localization (if applicable)

### Per Language
- [ ] Description translated
- [ ] Keywords translated
- [ ] Screenshots localized
- [ ] What's New translated
- [ ] In-app content translated
- [ ] Tested by native speaker

---

## Phase 7: In-App Purchases (if applicable)

### Per Purchase
- [ ] IAP created in App Store Connect
- [ ] Product ID matches code
- [ ] Display name and description set
- [ ] Price tier selected
- [ ] Screenshot uploaded
- [ ] Review notes provided
- [ ] Tested in sandbox

---

## Phase 8: Final Review

### Pre-Submit Check
- [ ] All required fields filled in App Store Connect
- [ ] Build selected for this version
- [ ] Version number is correct
- [ ] All screenshots look professional
- [ ] Description has no typos
- [ ] Privacy Policy and ToS accessible
- [ ] Test account works (if provided)

### Test Account Verification
- [ ] Demo account credentials correct
- [ ] Account has sample data
- [ ] All features accessible
- [ ] No payment required for testing

---

## Phase 9: Submission

### Submit for Review
- [ ] Clicked "Submit for Review" button
- [ ] Received confirmation email
- [ ] Status changed to "Waiting for Review"
- [ ] Submission date noted

### Post-Submission
- [ ] Monitor App Store Connect for status updates
- [ ] Check email for review feedback
- [ ] Respond to reviewer questions within 24 hours
- [ ] Prepare for potential rejection and fixes

---

## Phase 10: After Approval

### Launch Preparation
- [ ] Release strategy decided (automatic/manual)
- [ ] Marketing materials ready
- [ ] Social media posts prepared
- [ ] Website updated
- [ ] Support channels ready

### Monitoring
- [ ] Watch for crash reports
- [ ] Monitor user reviews
- [ ] Track analytics
- [ ] Respond to user feedback
- [ ] Plan next update based on feedback

---

## Common Rejection Reasons (Avoid These!)

- [ ] App crashes frequently
- [ ] Incomplete or missing information
- [ ] Placeholder content visible
- [ ] No account deletion option
- [ ] Privacy Policy missing or inadequate
- [ ] Misleading description or screenshots
- [ ] Broken features
- [ ] Poor performance
- [ ] Inappropriate content
- [ ] Guideline violations

---

## Emergency Contacts

**Technical Issues:**
- Developer: [Name, Email, Phone]

**Business Questions:**
- Manager: [Name, Email, Phone]

**Apple Developer Support:**
- https://developer.apple.com/support/
- Phone: 1-800-633-2152 (U.S.)

---

## Notes

[Use this space for any specific notes about this submission]

---

**Submitted By:** ___________________  
**Date:** ___________________  
**Expected Review Time:** 1-3 days (average)  
**Status:** [In Progress / Submitted / In Review / Approved / Rejected]

---

## Approval Received! 🎉

- [ ] App approved date: ___________________
- [ ] Released to App Store: ___________________
- [ ] Announced on social media
- [ ] Team notified
- [ ] Celebration planned! 🥳
EOF

    print_success "Submission checklist created"
}

# Generate README for the package
generate_package_readme() {
    print_header "📚 Generating Package README"
    
    cat > "$REVIEW_PACKAGE_DIR/README.md" << 'EOF'
# 📦 App Store Review Package

This package contains all materials needed for App Store submission.

## 📁 Package Structure

```
AppStore_Review_Package/
├── README.md (this file)
├── SUBMISSION_CHECKLIST.md ⭐ Start here!
│
├── metadata/
│   ├── app_metadata.txt
│   ├── description_english.txt
│   └── keywords_guide.txt
│
├── screenshots/
│   ├── SCREENSHOT_REQUIREMENTS.md
│   ├── iphone/
│   │   ├── 6.5-inch/ (iPhone 14 Pro Max, etc.)
│   │   └── 5.5-inch/ (iPhone 8 Plus, etc.)
│   └── ipad/
│       └── 12.9-inch/ (iPad Pro)
│
├── videos/
│   ├── VIDEO_REQUIREMENTS.md
│   ├── preview/ (App Preview videos)
│   └── demo/ (Demo videos for internal use)
│
├── documents/
│   ├── LOCALIZATION_GUIDE.md
│   ├── legal/
│   │   ├── PRIVACY_POLICY_TEMPLATE.md
│   │   └── TERMS_OF_SERVICE_TEMPLATE.md
│   └── technical/
│       └── (technical documentation)
│
├── assets/
│   ├── ASSETS_REQUIREMENTS.md
│   ├── icons/
│   │   └── (all required icon sizes)
│   └── promotional/
│       └── (promotional graphics)
│
└── notes/
    └── REVIEWER_NOTES.md
```

## 🚀 Quick Start

### 1. Complete the Checklist
Start with **SUBMISSION_CHECKLIST.md** - it guides you through everything.

### 2. Fill in Metadata
Edit files in `metadata/`:
- `app_metadata.txt` - App information
- `description_english.txt` - App Store description
- `keywords_guide.txt` - Keywords for search

### 3. Create Visual Assets

#### Screenshots
1. Read `screenshots/SCREENSHOT_REQUIREMENTS.md`
2. Create screenshots for required sizes
3. Place in appropriate folders
4. Recommended: 5-10 screenshots per device size

#### App Preview Video (Optional but Recommended)
1. Read `videos/VIDEO_REQUIREMENTS.md`
2. Record 15-30 second video
3. Show key features
4. Place in `videos/preview/`

#### App Icon
1. Read `assets/ASSETS_REQUIREMENTS.md`
2. Create 1024x1024 App Store icon
3. Generate all required sizes
4. Place in `assets/icons/`

### 4. Prepare Legal Documents
- Update `documents/legal/PRIVACY_POLICY_TEMPLATE.md`
- Update `documents/legal/TERMS_OF_SERVICE_TEMPLATE.md`
- Host on your website
- Add URLs to App Store Connect

### 5. Write Review Notes
Edit `notes/REVIEWER_NOTES.md` with:
- Demo account credentials
- Special instructions
- How to test features
- Any important notes

### 6. Localization (if supporting multiple languages)
1. Read `documents/LOCALIZATION_GUIDE.md`
2. Translate all text content
3. Create localized screenshots
4. Test in each language

### 7. Submit to App Store
1. Build and archive your app in Xcode
2. Upload to App Store Connect
3. Fill in all information using materials from this package
4. Upload screenshots and videos
5. Submit for review

## 📋 What You Need to Fill In

### Critical Information
- [ ] App name and version
- [ ] Bundle identifier
- [ ] App description
- [ ] Keywords
- [ ] Screenshots (all required sizes)
- [ ] App Store icon (1024x1024)
- [ ] Privacy Policy URL
- [ ] Terms of Service URL
- [ ] Support URL
- [ ] Demo account (if app requires login)
- [ ] Review notes

### Optional but Recommended
- [ ] App Preview video
- [ ] Promotional text
- [ ] Marketing URL
- [ ] Localized content
- [ ] Feature graphic

## ⏱️ Timeline

### Preparation Time
- Metadata: 2-4 hours
- Screenshots: 4-8 hours
- Video: 4-8 hours (if creating)
- Legal docs: 2-4 hours
- Testing: 4-8 hours

**Total: 1-3 days** of focused work

### Review Time
- Typical: 1-3 days
- Can be: 24 hours to 1 week
- Complex apps: May take longer

## ✅ Quality Checklist

Before submitting, verify:
- [ ] All templates filled in (no [FILL IN] markers)
- [ ] All required screenshot sizes present
- [ ] Screenshots are high quality and professional
- [ ] Icon looks good at all sizes
- [ ] Description has no typos
- [ ] Keywords are relevant and optimized
- [ ] Privacy Policy covers all data usage
- [ ] Demo account works (if provided)
- [ ] Video plays correctly (if provided)
- [ ] All URLs are accessible
- [ ] Legal documents are complete

## 🆘 Need Help?

### Resources in This Package
- Each folder has its own requirements/guide file
- SUBMISSION_CHECKLIST.md walks through everything
- Templates are ready to fill in

### External Resources
- **App Store Connect:** https://appstoreconnect.apple.com
- **Apple Developer:** https://developer.apple.com
- **Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/
- **App Store Connect Help:** https://help.apple.com/app-store-connect/

### Support
- Apple Developer Support: https://developer.apple.com/support/
- Phone: 1-800-633-2152 (U.S.)

## 📊 Success Tips

### Increase Approval Chances
1. **Test Thoroughly** - No crashes or major bugs
2. **Clear Description** - Explain what your app does
3. **Professional Assets** - High-quality screenshots and icon
4. **Complete Information** - Fill in all fields
5. **Follow Guidelines** - Read and follow Apple's rules
6. **Demo Account** - Make testing easy for reviewers
7. **Quick Response** - Respond to reviewer questions promptly

### Common Mistakes to Avoid
- Incomplete information
- Poor quality screenshots
- Missing privacy policy
- No account deletion (if app has accounts)
- Crashes during review
- Placeholder content
- Misleading information

## 🎉 After Approval

### Launch
- Decide release schedule (automatic or manual)
- Prepare marketing materials
- Update website and social media
- Email your user base
- Submit to app review sites

### Monitoring
- Watch crash reports
- Read user reviews
- Respond to feedback
- Track downloads and usage
- Plan next update

## 📝 Notes

Use this section for any project-specific notes:

[Your notes here]

---

**Good luck with your submission!** 🚀

---

**Generated by:** DNS Review Package Generator  
**Date:** $(date +"%B %d, %Y")  
**Version:** 1.0
EOF

    print_success "Package README created"
}

# Generate a sample content checklist
generate_content_checklist() {
    print_header "📝 Generating Content Checklist"
    
    cat > "$REVIEW_PACKAGE_DIR/CONTENT_CHECKLIST.md" << 'EOF'
# 📝 Content Creation Checklist

Track your progress in creating all required materials.

## ✅ Written Content

### App Store Metadata
- [ ] App name (30 chars max)
- [ ] Subtitle (30 chars max)
- [ ] Description (4000 chars max)
  - [ ] Compelling opening
  - [ ] Key features list
  - [ ] Benefits explained
  - [ ] Call to action
- [ ] Keywords (100 chars max, comma-separated)
- [ ] What's New (4000 chars max)
- [ ] Promotional text (170 chars, optional)

### Support Materials
- [ ] Privacy Policy
  - [ ] Data collection explained
  - [ ] Data usage explained
  - [ ] Security measures described
  - [ ] User rights outlined
  - [ ] Contact information
- [ ] Terms of Service
  - [ ] Usage terms
  - [ ] Account terms
  - [ ] Content policy
  - [ ] Liability disclaimers
  - [ ] Contact information

### Review Information
- [ ] Demo account credentials
- [ ] Testing instructions
- [ ] Feature explanations
- [ ] Special notes for reviewers
- [ ] Known limitations

## 📸 Visual Assets

### App Icon
- [ ] 1024x1024 App Store icon (PNG, RGB, no transparency)
- [ ] Icon looks good at small sizes
- [ ] Icon follows Apple's guidelines
- [ ] Icon is unique and recognizable

### Screenshots - iPhone 6.5"
- [ ] Screenshot 1 (Most important feature)
- [ ] Screenshot 2 (Key feature)
- [ ] Screenshot 3 (Key feature)
- [ ] Screenshot 4 (Additional feature)
- [ ] Screenshot 5 (Additional feature)
- [ ] Optional: Up to 10 total

### Screenshots - iPhone 5.5"
- [ ] Screenshot 1
- [ ] Screenshot 2
- [ ] Screenshot 3
- [ ] Screenshot 4
- [ ] Screenshot 5
- [ ] Optional: Up to 10 total

### Screenshots - iPad 12.9" (if supporting iPad)
- [ ] Screenshot 1
- [ ] Screenshot 2
- [ ] Screenshot 3
- [ ] Screenshot 4
- [ ] Screenshot 5

### Screenshot Quality Check
- [ ] All correct dimensions
- [ ] Professional quality
- [ ] Clear and readable
- [ ] Show actual app content
- [ ] No placeholder content
- [ ] Consistent style
- [ ] Device frames added (optional)
- [ ] Text overlays clear (if used)

## 🎥 Video Content

### App Preview Video (Optional but Recommended)
- [ ] iPhone 6.5" version (1284x2778)
- [ ] iPhone 5.5" version (1242x2208)
- [ ] iPad 12.9" version (if supporting iPad)
- [ ] Duration: 15-30 seconds
- [ ] Shows actual app in use
- [ ] No prohibited content
- [ ] Professional quality
- [ ] File size under 500 MB
- [ ] Format: .mov, .m4v, or .mp4

### Video Quality Check
- [ ] Smooth playback
- [ ] Clear visuals
- [ ] Audio appropriate (if used)
- [ ] Shows key features
- [ ] Fast-paced but understandable
- [ ] Professional production

### Demo Video (Internal Use)
- [ ] Longer format showing all features
- [ ] For support/training
- [ ] For marketing
- [ ] For social media

## 🌍 Localization (if applicable)

### Per Language
- [ ] Language: ________________
  - [ ] Description translated
  - [ ] Keywords translated
  - [ ] Screenshots localized
  - [ ] What's New translated
  - [ ] Tested by native speaker

- [ ] Language: ________________
  - [ ] Description translated
  - [ ] Keywords translated
  - [ ] Screenshots localized
  - [ ] What's New translated
  - [ ] Tested by native speaker

## 📊 Quality Assurance

### Content Review
- [ ] No typos or grammar errors
- [ ] Consistent branding and messaging
- [ ] Accurate feature descriptions
- [ ] No misleading claims
- [ ] Appropriate for age rating
- [ ] Follows App Store guidelines

### Visual Review
- [ ] All images high quality
- [ ] Consistent visual style
- [ ] Professional appearance
- [ ] Correct sizes and formats
- [ ] No copyright violations
- [ ] Brand guidelines followed

### Legal Review
- [ ] Privacy Policy accurate
- [ ] Terms of Service complete
- [ ] Compliant with regulations
- [ ] Contact information correct
- [ ] URLs accessible

## 📦 Delivery Preparation

### File Organization
- [ ] All files properly named
- [ ] Files in correct folders
- [ ] Backup copies made
- [ ] Version control updated

### Upload Preparation
- [ ] Screenshots ready to upload
- [ ] Videos ready to upload
- [ ] Text content ready to copy/paste
- [ ] Demo account tested
- [ ] All URLs verified working

## ⏰ Time Estimates

Task | Estimated Time | Actual Time | Status
-----|----------------|-------------|--------
App description | 2-4 hours | | [ ]
Keywords research | 1-2 hours | | [ ]
Privacy Policy | 2-3 hours | | [ ]
Terms of Service | 2-3 hours | | [ ]
App icon design | 4-8 hours | | [ ]
Screenshot creation | 4-8 hours | | [ ]
Screenshot editing | 2-4 hours | | [ ]
Video recording | 2-4 hours | | [ ]
Video editing | 2-4 hours | | [ ]
Review notes | 1-2 hours | | [ ]
Testing & QA | 4-8 hours | | [ ]
**Total** | **26-50 hours** | | [ ]

## 📝 Notes

Use this space to track progress, issues, or ideas:

---
---
---

## ✅ Final Check

Before submission:
- [ ] All items above checked off
- [ ] Everything reviewed for quality
- [ ] Backup of all files created
- [ ] Ready to submit to App Store Connect

---

**Completed by:** ___________________  
**Date:** ___________________  
**Ready for Submission:** YES / NO
EOF

    print_success "Content checklist created"
}

# Main function
main() {
    clear
    
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        📦  APP STORE REVIEW PACKAGE GENERATOR  📦             ║
║                                                                ║
║        Generate Complete Submission Materials                 ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF

    print_info "Starting package generation..."
    print_info "This will create a complete App Store submission package.\n"
    
    # Load configuration
    load_app_config
    
    # Generate all components
    create_directory_structure
    generate_metadata
    generate_descriptions
    generate_screenshot_guide
    generate_video_guide
    generate_legal_documents
    generate_review_notes
    generate_assets_guide
    generate_localization_guide
    generate_submission_checklist
    generate_package_readme
    generate_content_checklist
    
    # Final summary
    print_header "🎉 Package Generation Complete!"
    
    echo -e "${GREEN}✅ Review package created at:${NC}"
    echo -e "${CYAN}   $REVIEW_PACKAGE_DIR${NC}\n"
    
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "   1. Read: ${CYAN}$REVIEW_PACKAGE_DIR/README.md${NC}"
    echo -e "   2. Start: ${CYAN}$REVIEW_PACKAGE_DIR/SUBMISSION_CHECKLIST.md${NC}"
    echo -e "   3. Fill in all templates marked with [FILL IN]"
    echo -e "   4. Create screenshots and videos"
    echo -e "   5. Review everything for quality"
    echo -e "   6. Submit to App Store Connect\n"
    
    echo -e "${BLUE}💡 Tip:${NC} Use the CONTENT_CHECKLIST.md to track your progress!\n"
    
    # Open in Finder (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        read -p "Open package in Finder? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$REVIEW_PACKAGE_DIR"
            print_success "Package opened in Finder"
        fi
    fi
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🚀 Good luck with your App Store submission!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Run main function
main "$@"

