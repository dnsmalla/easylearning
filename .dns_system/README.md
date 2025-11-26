# DNS App Development System

**Professional Code Generation & Automation Toolkit**  
**Version:** 2.1.0

---

## Overview

DNS (Developer Nexus System) is a comprehensive **app development automation system** that provides:

- 🚀 **Intelligent Code Generation** - Auto-detect language, platform, and complexity
- 🤖 **AI-Powered Development** - Integrated with Cursor AI for smart assistance
- 📦 **Template Library** - Production-ready iOS, Flutter, and Python templates
- ✅ **Quality Assurance** - Linting, auto-correction, and code review
- 📱 **App Store Ready** - Review package generation and pre-submission testing

---

## Architecture

```
Project Root/
├── .dns_system/                    # DNS System (AI & Code Gen)
│   ├── config/                     # Project configuration
│   │   ├── app_info.conf          # App identity (auto-detected)
│   │   └── data_sync.conf         # Points to data toolkit
│   ├── system/                     # Core DNS system
│   │   ├── cursorrules_system.sh  # Main command dispatcher
│   │   ├── config/                # System settings
│   │   ├── core/                  # Analyzers, generators, utils
│   │   └── templates/             # Code templates
│   └── app_tips/                   # Implementation patterns library
│
├── auto_app_data generation/       # Data Toolkit (Separate)
│   ├── toolkit                     # Main command interface
│   ├── automate.sh                # Automation wrapper
│   ├── config/                    # Toolkit configuration
│   ├── projects/                  # Per-project settings
│   ├── core/                      # Data libraries
│   └── github_tools/              # GitHub operations
│
└── .cursorrules                    # Entry point (calls DNS system)
```

**Key Principle:** Code generation lives in `.dns_system/`, data operations live in `auto_app_data generation/`.

---

## Quick Start

```bash
# Initialize your project
bash .cursorrules init

# Generate code with AI
bash .cursorrules auto "User Authentication Service"

# Check system health
bash .cursorrules health

# View all commands
bash .cursorrules help
```

---

## Core Commands

### Code Generation

```bash
bash .cursorrules auto "Feature Name"     # Fully automated
bash .cursorrules basic "Service Name"    # Basic class
bash .cursorrules smart "Complex Feature" # LLM-powered
```

### Quality Assurance

```bash
bash .cursorrules check <file>    # Quality check
bash .cursorrules qa <file>       # Comprehensive QA
bash .cursorrules fix <file>      # Auto-fix issues
```

### Data Toolkit

```bash
# All data commands go to: auto_app_data generation/
bash .cursorrules data projects                    # List projects
bash .cursorrules data --project jlearn config     # Show config
bash .cursorrules data --project jlearn sync       # Full sync

# Or use toolkit directly:
cd "auto_app_data generation"
./toolkit --project jlearn sync
```

### iOS/App Store

```bash
bash .cursorrules templates list          # List templates
bash .cursorrules templates install auth  # Install auth module
bash .cursorrules package                 # App Store package
bash .cursorrules review auto             # Pre-submission test
```

---

## Supported Languages

| Language | Standards | Templates |
|----------|-----------|-----------|
| **Swift** | Apple API Guidelines | iOS, macOS |
| **Python** | PEP 8 | CLI, API |
| **Dart/Flutter** | Official Guidelines | Cross-platform |
| **JavaScript** | Airbnb Style | Node, React |

---

## Configuration

### App Identity (`config/app_info.conf`)

Auto-detects from your project:
- `project.yml` (XcodeGen)
- `Package.swift` (Swift Package)
- `pubspec.yaml` (Flutter)
- `package.json` (Node)

### Data Toolkit (`auto_app_data generation/`)

Separate toolkit for data operations:
- Multi-project support
- GitHub integration
- Data validation
- Sync automation

---

## AI Integration

DNS integrates with **Cursor AI** - no API keys required:

1. **Code Analysis** - Understands your codebase
2. **Smart Generation** - Context-aware code creation
3. **Code Review** - AI-powered suggestions
4. **Refactoring** - Intelligent improvements

---

**DNS App Development System v2.1.0**  
*Professional Code Generation & Automation*
