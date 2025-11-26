#!/usr/bin/env bash
set -euo pipefail

# Determine script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if git -C "$SCRIPT_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Scaffold a new Swift iOS app from the Meic template
# - Duplicates the Meic project directory
# - Rewrites product name, bundle identifier, and Info.plist values

TEMPLATE_DIR="$REPO_ROOT/Meic"

APP_NAME=""
BUNDLE_ID=""
DEST_DIR=""

RUN_XCODEGEN=0

usage() {
  echo "Usage: $0 -n AppName -b com.example.app [-d dest_dir] [--xcodegen]" >&2
  exit 1
}

OPTS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) APP_NAME="$2"; shift 2 ;;
    -b) BUNDLE_ID="$2"; shift 2 ;;
    -d) DEST_DIR="$2"; shift 2 ;;
    --xcodegen) RUN_XCODEGEN=1; shift ;;
    -h|--help) usage ;;
    *) OPTS+=("$1"); shift ;;
  esac
done

if [[ -z "$APP_NAME" || -z "$BUNDLE_ID" ]]; then
  usage
fi

if [[ -z "${DEST_DIR}" ]]; then
  DEST_DIR="$REPO_ROOT/${APP_NAME}"
fi

if [[ -e "$DEST_DIR" ]]; then
  echo "Error: Destination already exists: $DEST_DIR" >&2
  exit 2
fi

echo "Scaffolding '$APP_NAME' at: $DEST_DIR"
rsync -a --exclude ".build" --exclude "DerivedData" --exclude "xcuserdata" --exclude "build" --exclude "*.xcarchive" "$TEMPLATE_DIR/" "$DEST_DIR/"

# Update XcodeGen project.yml
PROJECT_YML="$DEST_DIR/project.yml"
if [[ -f "$PROJECT_YML" ]]; then
  # name
  perl -0777 -pe "s/^name:\s*.*$/name: ${APP_NAME}/m" -i "$PROJECT_YML"
  # bundle id in settings
  perl -0777 -pe "s/(PRODUCT_BUNDLE_IDENTIFIER:\s*)([\w\.\-]+)/\${1}${BUNDLE_ID}/m" -i "$PROJECT_YML"
  # info properties
  perl -0777 -pe "s/(CFBundleIdentifier:\s*)([\w\.\-]+)/\${1}${BUNDLE_ID}/m" -i "$PROJECT_YML"
  perl -0777 -pe "s/(CFBundleName:\s*)([^\n]+)/\${1}${APP_NAME}/m" -i "$PROJECT_YML"
  # rename targets
  perl -0777 -pe "s/^\s{2}Meic:\n/  ${APP_NAME}:\n/m" -i "$PROJECT_YML"
  perl -0777 -pe "s/- name: MeicTests/- name: ${APP_NAME}Tests/m" -i "$PROJECT_YML"
  perl -0777 -pe "s/\n\s{2}MeicTests:/\n  ${APP_NAME}Tests:/m" -i "$PROJECT_YML"
  perl -0777 -pe "s/- name: MeicUITests/- name: ${APP_NAME}UITests/m" -i "$PROJECT_YML"
  perl -0777 -pe "s/\n\s{2}MeicUITests:/\n  ${APP_NAME}UITests:/m" -i "$PROJECT_YML"
fi

# Update Info.plist if present
INFO_PLIST="$DEST_DIR/Sources/Info.plist"
if [[ -f "$INFO_PLIST" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${BUNDLE_ID}" "$INFO_PLIST" || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleName ${APP_NAME}" "$INFO_PLIST" || true
fi

if [[ $RUN_XCODEGEN -eq 1 ]]; then
  if command -v xcodegen >/dev/null 2>&1; then
    (cd "$DEST_DIR" && xcodegen generate | cat)
  else
    echo "Warning: xcodegen not found in PATH. Skipping project generation." >&2
  fi
fi

echo "Done. Project at: ${DEST_DIR}"



