# auto_swift

**Multi-App iOS Development Workspace**

A centralized workspace for managing multiple iOS applications with professional development infrastructure.

---

## 📱 Apps

### 1. OneNoteClone
**Status**: ✅ Complete  
**Description**: Comprehensive note-taking app similar to Microsoft OneNote  
**Location**: `OneNoteClone_App/`  

**Features**:
- Rich text editing with formatting
- Professional drawing canvas (color picker, line width control)
- Voice and video recording
- Equation editor
- Image support
- Checklists
- Hierarchical organization

**Quick Start**:
```bash
cd OneNoteClone_App
open OneNoteClone.xcodeproj
```

### 2. HelpAGI
**Status**: ✅ Complete  
**Description**: AGI/AI News iOS App with GitHub-powered content  
**Location**: `HelpAGI/`  

**Features**:
- 4-tab interface (Home, Browse, Saved, Profile)
- Remote content from GitHub Pages
- Apple News-style design
- Offline support

**Quick Start**:
```bash
cd HelpAGI
open HelpAGI.xcodeproj
```

---

## 🏗 Workspace Structure

```
auto_swift/                          ← Multi-app workspace
│
├── OneNoteClone_App/               ← Self-contained app
│   ├── OneNoteClone.xcodeproj/
│   ├── OneNoteClone/               ← Source code
│   ├── .onenote_system/            ← Build system
│   ├── README.md
│   ├── QUICKSTART.md
│   └── docs...
│
├── HelpAGI/                        ← Self-contained app
│   ├── HelpAGI.xcodeproj/
│   ├── HelpAGI/                    ← Source code
│   ├── ContentManager.swift
│   └── README.md
│
├── .dns_system/                    ← Shared system tools
│   ├── system/
│   ├── config/
│   ├── data/
│   └── scripts/
│
└── README.md                       ← This file
```

---

## 🚀 Quick Commands

### For OneNoteClone
```bash
cd OneNoteClone_App
./.onenote_system/onenote_system help
./.onenote_system/onenote_system open
```

### For HelpAGI
```bash
cd HelpAGI
open HelpAGI.xcodeproj
```

---

## 📋 Adding New Apps

When adding a new app to this workspace:

1. **Create app folder**:
   ```bash
   mkdir MyNewApp
   ```

2. **Create Xcode project inside**:
   ```bash
   cd MyNewApp
   # Create project in Xcode, save in current directory
   ```

3. **Add build system** (optional):
   ```bash
   mkdir .mynewapp_system
   # Add config, scripts, docs
   ```

4. **Update this README**:
   - Add to Apps section
   - Document features
   - Add quick start commands

---

## 🛠 Shared Tools

### .dns_system
Shared development system providing:
- Code generation
- Quality checking
- Testing utilities
- Documentation templates
- iOS templates

Located at: `.dns_system/`

---

## 📚 Documentation

### Workspace Level
- `README.md` - This file (workspace overview)

### App Level
Each app has its own documentation:
- `AppName/README.md` - App-specific readme
- `AppName/docs/` - Detailed documentation
- `AppName/.system/` - Build system docs

---

## 🎯 Best Practices

### Structure
- ✅ Each app is **self-contained** in its own folder
- ✅ App folder contains `.xcodeproj` + source folder
- ✅ App-specific build systems stay with the app
- ✅ Shared tools in `.dns_system/`

### Naming
- App folders: `AppName_App/` or `AppName/`
- Xcode projects: `AppName.xcodeproj/`
- Source folders: `AppName/`

### Organization
```
AppName_App/
├── AppName.xcodeproj/     ← Xcode project
├── AppName/               ← Source code
├── .appname_system/       ← Build system (optional)
├── README.md              ← App documentation
└── docs/                  ← Additional docs
```

---

## 📊 Workspace Stats

| App | Status | Lines of Code | Features |
|-----|--------|---------------|----------|
| OneNoteClone | ✅ Complete | ~2,500+ | 10+ major features |
| HelpAGI | ✅ Complete | ~1,500+ | News reader with remote content |

---

## 🔧 Development

### Prerequisites
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+
- iOS 16.0+ (deployment target)

### Setup New Development Environment
```bash
# 1. Clone/navigate to workspace
cd /Users/dinsmallade/Desktop/auto_sys/auto_swift

# 2. Choose an app
cd OneNoteClone_App

# 3. Open in Xcode
open OneNoteClone.xcodeproj

# 4. Build and run (⌘+R)
```

---

## 📦 Build & Deploy

Each app has its own build system:

### OneNoteClone
```bash
cd OneNoteClone_App
./.onenote_system/onenote_system build
./.onenote_system/onenote_system archive
```

### HelpAGI
```bash
cd HelpAGI
# Build in Xcode or use xcodebuild
```

---

## 🆘 Support

### For specific apps
See the app's README:
- `OneNoteClone_App/README.md`
- `HelpAGI/README.md`

### For workspace issues
Check shared system:
- `.dns_system/README.md`

---

## 📝 License

Each app may have its own license. See individual app directories.

---

## 🎉 Summary

This workspace provides:
- ✅ Clean organization for multiple iOS apps
- ✅ Each app is self-contained
- ✅ Shared development tools
- ✅ Professional structure
- ✅ Easy to add new apps

---

**Current Apps**: 2 (OneNoteClone, HelpAGI)  
**Status**: Clean, organized, production-ready  
**Last Updated**: 2025-11-10

---

For app-specific documentation, navigate to the app folder and read its README.
