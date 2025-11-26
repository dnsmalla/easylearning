# Quick Start Guide - JLearn Data Toolkit

## Overview
This toolkit manages Japanese learning data generation, validation, and GitHub synchronization for the JLearn app.

---

## Common Commands

### 1. Validate Data Files
```bash
./toolkit --project jlearn verify
```
**What it does:**
- Validates all JSON files in `jpleanrning/` folder
- Checks manifest integrity
- Verifies file formats
- Reports any issues

**When to use:** Before uploading to GitHub or after generating new data

---

### 2. Upload Data to GitHub
```bash
./toolkit --project jlearn upload
```
**What it does:**
- Clones GitHub repository to temporary location
- Copies only `jpleanrning/` folder contents
- Excludes backup files automatically
- Commits and pushes changes
- Cleans up temporary files

**When to use:** After updating any data files

**With custom commit message:**
```bash
./toolkit --project jlearn upload --message "Added new N2 vocabulary"
```

---

### 3. View Configuration
```bash
./toolkit --project jlearn config
```
**What it does:**
- Displays current project configuration
- Shows GitHub repository details
- Lists data file patterns
- Shows source/destination paths

**When to use:** To verify settings before operations

---

### 4. Setup New GitHub Repository
```bash
./toolkit --project jlearn setup
```
**What it does:**
- Creates initial repository structure
- Generates `.gitignore` and `README.md`
- Prepares for first push

**When to use:** One-time setup for new GitHub repository

---

## Project Structure

```
auto_app_data generation/
├── toolkit                     # Main entry point
├── core/                       # Reusable components
│   ├── lib/                   # Utility libraries
│   │   ├── colors.sh          # Color output
│   │   ├── logger.sh          # Logging functions
│   │   ├── paths.sh           # Path utilities
│   │   └── validator.sh       # Validation functions
│   └── tools/                 # Core tools
│       ├── setup.sh           # GitHub setup
│       └── upload.sh          # GitHub upload
└── projects/
    └── jlearn/                # JLearn specific
        ├── config.sh          # Project config
        └── data_generators/   # Data generation scripts
```

---

## Configuration

### JLearn Project Config
Located at: `projects/jlearn/config.sh`

**Key Settings:**
```bash
PROJECT_NAME="jlearn"
GITHUB_USER="dnsmalla"
GITHUB_REPO="easylearning"
SOURCE_DATA_DIR="jpleanrning"
TARGET_DATA_DIR="jpleanrning"
```

**To modify:** Edit `projects/jlearn/config.sh`

---

## Workflow Example

### Standard Data Update Workflow

**Step 1: Generate/Update Data**
```bash
cd data_generators
python generate_vocabulary.py
# or use other generation scripts
```

**Step 2: Validate Data**
```bash
cd /Users/dinsmallade/Desktop/auto_sys/swift_apps/auto_swift_jlearn/auto_app_data\ generation
./toolkit --project jlearn verify
```

**Step 3: Upload to GitHub**
```bash
./toolkit --project jlearn upload --message "Updated vocabulary data"
```

**Step 4: Verify on GitHub**
Visit: https://github.com/dnsmalla/easylearning

---

## Troubleshooting

### Issue: "Configuration not found"
**Solution:** Ensure you're in the `auto_app_data generation` directory

### Issue: "Data files not found"
**Solution:** Check that `jpleanrning/` folder exists in project root

### Issue: "Git authentication failed"
**Solution:** Ensure GitHub credentials are configured:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Issue: "Permission denied"
**Solution:** Make toolkit executable:
```bash
chmod +x toolkit
```

---

## What Gets Uploaded to GitHub

**✅ Included:**
- All `*.json` files in `jpleanrning/`
- Manifest files
- Data files

**❌ Excluded:**
- Backup files (`*.backup*`)
- Temporary files
- App code
- Build files
- Xcode projects

---

## Adding New Projects

### To replicate this toolkit for another app:

**Step 1: Copy project template**
```bash
cp -r projects/jlearn projects/myapp
```

**Step 2: Edit configuration**
Edit `projects/myapp/config.sh`:
```bash
PROJECT_NAME="myapp"
GITHUB_USER="yourusername"
GITHUB_REPO="yourrepo"
SOURCE_DATA_DIR="myapp_data"
TARGET_DATA_DIR="myapp_data"
```

**Step 3: Use toolkit**
```bash
./toolkit --project myapp verify
./toolkit --project myapp upload
```

---

## Success Indicators

When everything works correctly, you should see:

**Validation:**
```
✅ All data files valid
Total: 12
Passed: 12
```

**Upload:**
```
✅ Copied 12 files to repository
✅ Changes committed and pushed to GitHub
```

**GitHub Repository:**
- Only contains data folder
- No app code present
- All files accessible via raw URLs

---

## Support Files

- **VALIDATION_TEST_REPORT.md** - Detailed test results
- **REFACTORING_COMPLETE.md** - Architecture documentation
- **GET_STARTED.md** - Detailed setup guide

---

## GitHub URLs

**Repository:** https://github.com/dnsmalla/easylearning  
**Raw Data Base URL:** https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/

**Example Data URLs:**
- Manifest: `https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/manifest.json`
- Vocabulary: `https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/vocabulary.json`
- N5 Data: `https://raw.githubusercontent.com/dnsmalla/easylearning/main/jpleanrning/japanese_learning_data_n5_jisho.json`

---

## Quick Reference

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `verify` | Validate data | Before upload |
| `upload` | Push to GitHub | After changes |
| `config` | View settings | Check configuration |
| `setup` | Initial setup | First time only |

---

**Last Updated:** November 25, 2024  
**Toolkit Version:** 1.0  
**Status:** ✅ Production Ready

