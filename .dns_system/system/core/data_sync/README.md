# DNS Data Sync Module

## Overview

The DNS Data Sync module is a universal data synchronization tool that allows any project to easily sync data files with a GitHub repository. It's part of the DNS (Development Navigation System) and provides a clean separation between app code and data.

## Architecture

```
.dns_system/
└── system/
    └── core/
        └── data_sync/
            ├── data_sync.sh          # Master entry point
            ├── lib/                  # Reusable libraries
            │   ├── colors.sh        # Terminal colors
            │   ├── logger.sh        # Logging functions
            │   ├── paths.sh         # Path utilities
            │   └── validator.sh     # Data validation
            ├── tools/               # Core tools
            │   ├── setup.sh         # Initial GitHub setup
            │   ├── upload.sh        # Upload to GitHub
            │   └── verify.sh        # Data validation
            └── templates/           # Project templates
                └── project_config.template
```

## Key Features

✅ **Universal**: Works with any project, any data type  
✅ **Non-Invasive**: Project-specific config stays in project root  
✅ **Safe**: Only pushes data, never app code  
✅ **Validation**: JSON validation before upload  
✅ **Flexible**: Configurable patterns and exclusions  
✅ **Clean**: Automatic .gitignore and README generation  

## Quick Start

### 1. Initialize for Your Project

```bash
cd your_project
../.dns_system/dns-data-sync init
```

This creates `.data_sync_config.sh` in your project root.

### 2. Configure

Edit `.data_sync_config.sh` with your project details:

```bash
export PROJECT_NAME="myapp"
export GITHUB_USERNAME="yourusername"
export GITHUB_REPO_NAME="myapp-data"
export SOURCE_DATA_DIR="data"
export GITHUB_DATA_DIR="data"
```

### 3. Verify Data

```bash
../.dns_system/dns-data-sync verify
```

### 4. Setup GitHub (First Time Only)

```bash
../.dns_system/dns-data-sync setup
```

### 5. Upload to GitHub

```bash
../.dns_system/dns-data-sync upload
```

## Commands

### `init`
Initialize data sync for a new project. Creates configuration file from template.

```bash
dns-data-sync init
```

### `config`
Display current project configuration.

```bash
dns-data-sync config
```

### `status`
Check sync status, git configuration, and file counts.

```bash
dns-data-sync status
```

### `verify`
Validate data files before upload (JSON validation, file checks).

```bash
dns-data-sync verify
```

### `setup`
Initial GitHub repository setup (first time only).

```bash
dns-data-sync setup
```

### `upload`
Upload data to GitHub repository.

```bash
# With default commit message
dns-data-sync upload

# With custom message
dns-data-sync upload --message "Added new content"
```

## Configuration Options

### Required Settings

| Setting | Description | Example |
|---------|-------------|---------|
| `PROJECT_NAME` | Project identifier | `"jlearn"` |
| `GITHUB_USERNAME` | GitHub username/org | `"dnsmalla"` |
| `GITHUB_REPO_NAME` | Repository name | `"easylearning"` |
| `SOURCE_DATA_DIR` | Local data directory | `"jpleanrning"` |
| `GITHUB_DATA_DIR` | GitHub directory name | `"jpleanrning"` |

### Optional Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `DATA_FILE_PATTERNS` | File patterns to include | `("*.json")` |
| `EXCLUDE_PATTERNS` | Patterns to exclude | `("*.backup" "*.tmp")` |
| `GITHUB_BRANCH` | Branch to push to | `"main"` |
| `MANIFEST_FILE` | Manifest filename | `"manifest.json"` |
| `VALIDATE_JSON` | Enable JSON validation | `true` |

## How It Works

### Upload Process

1. **Clone**: Clones GitHub repository to temporary directory
2. **Copy**: Copies only specified data files (respecting patterns)
3. **Filter**: Excludes backup files and unwanted patterns
4. **Generate**: Creates/updates .gitignore and README
5. **Commit**: Commits changes with custom or default message
6. **Push**: Pushes to GitHub
7. **Cleanup**: Removes temporary directory (optional)

### What Gets Pushed

✅ **Included**:
- Files matching `DATA_FILE_PATTERNS`
- Manifest file
- Generated README.md
- Generated .gitignore

❌ **Excluded**:
- Backup files (*.backup, *.backup_*, etc.)
- Temporary files (*.tmp, *~)
- Files matching `EXCLUDE_PATTERNS`
- **All app code**

### Safety Features

- Explicit .gitignore ensures only data folder is tracked
- Validation before upload catches errors early
- Dry-run capability (manual git status check before push)
- Configurable exclusion patterns
- No app code ever leaves project directory

## Integration with Other Projects

### For Mobile Apps

```bash
export PROJECT_NAME="fitness_tracker"
export SOURCE_DATA_DIR="app_data"
export GITHUB_REPO_NAME="fitness-data"
```

### For Config Management

```bash
export PROJECT_NAME="config_system"
export DATA_FILE_PATTERNS=("*.json" "*.yml" "*.yaml")
export SOURCE_DATA_DIR="configs"
```

### For Content Management

```bash
export PROJECT_NAME="blog_cms"
export DATA_FILE_PATTERNS=("*.md" "*.json")
export SOURCE_DATA_DIR="content"
```

## Example: JLearn Setup

The JLearn Japanese learning app uses this system:

```bash
# Configuration: .data_sync_config.sh
export PROJECT_NAME="jlearn"
export GITHUB_USERNAME="dnsmalla"
export GITHUB_REPO_NAME="easylearning"
export SOURCE_DATA_DIR="jpleanrning"
export GITHUB_DATA_DIR="jpleanrning"

# Workflow:
../.dns_system/dns-data-sync verify    # Validate 12 JSON files
../.dns_system/dns-data-sync upload    # Push to GitHub

# Result:
# Repository: github.com/dnsmalla/easylearning
# Contains: Only jpleanrning/ folder (no app code)
# Files: 12 JSON files + manifest + README
```

## Troubleshooting

### "Configuration file not found"
Run `dns-data-sync init` to create `.data_sync_config.sh`

### "Source directory not found"
Check `SOURCE_DATA_DIR` in your config file

### "Git authentication failed"
Configure git credentials:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### "Permission denied"
Make sure dns-data-sync is executable:
```bash
chmod +x .dns_system/dns-data-sync
```

## Benefits

### For Single Projects
- Clean separation of data and code
- Easy data updates without app releases
- Version-controlled data
- Automatic backup to GitHub

### For Multiple Projects
- Reusable system across all projects
- Consistent workflow
- Central tool updates benefit all projects
- No duplication of sync logic

### For Teams
- Standard data sync process
- Clear documentation
- Easy onboarding
- Reduces errors

## Advanced Usage

### Custom Config File

```bash
dns-data-sync --config ./custom_config.sh verify
```

### Pre/Post Upload Hooks

In your config file:

```bash
export PRE_UPLOAD_HOOK="./scripts/validate_extra.sh"
export POST_UPLOAD_HOOK="./scripts/notify_team.sh"
```

### Multiple Environments

```bash
# Development
dns-data-sync --config .data_sync_dev.sh upload

# Production
dns-data-sync --config .data_sync_prod.sh upload
```

## Version History

**v1.0.0** (Current)
- Initial master tool release
- Integrated into DNS system
- Universal project support
- Full validation suite
- Comprehensive documentation

## Future Enhancements

- [ ] Support for private repositories
- [ ] Automatic versioning
- [ ] Diff view before upload
- [ ] Rollback capability
- [ ] Multi-branch support
- [ ] Compression options
- [ ] Cloud storage integration (S3, etc.)

## Contributing

This is part of the DNS (Development Navigation System). To improve or extend:

1. Edit files in `.dns_system/system/core/data_sync/`
2. Test with multiple projects
3. Update documentation
4. Share improvements

## License

Part of DNS (Development Navigation System)  
Educational and development use

---

**Master Tool Location**: `.dns_system/system/core/data_sync/`  
**Command**: `.dns_system/dns-data-sync`  
**Version**: 1.0.0  
**Status**: ✅ Production Ready

