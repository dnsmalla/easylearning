#!/usr/bin/env bash
set -euo pipefail

# Determine script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if git -C "$SCRIPT_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi
cd "$REPO_ROOT"

if [[ -f ./.asc_env ]]; then
  # shellcheck disable=SC1091
  source ./.asc_env
fi

SCHEME="Meic"
PROJECT_PATH="Meic/Meic.xcodeproj"
ARCHIVE_PATH="build/Meic.xcarchive"
EXPORT_PATH="build/meic_export"
EXPORT_PLIST="exportOptions.plist"

usage() {
  echo "Usage: $0 [-s scheme] [-p project_path] [-o export_plist]" >&2
  exit 1
}

while getopts ":s:p:o:h" opt; do
  case "$opt" in
    s) SCHEME="$OPTARG" ;;
    p) PROJECT_PATH="$OPTARG" ;;
    o) EXPORT_PLIST="$OPTARG" ;;
    h) usage ;;
    :) echo "Error: Option -$OPTARG requires an argument" >&2; usage ;;
    \?) echo "Error: Invalid option -$OPTARG" >&2; usage ;;
  esac
done

echo "[1/3] Archiving ($SCHEME)"
xcodebuild -project "$PROJECT_PATH" \
  -scheme "$SCHEME" -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="${ASC_TEAM_ID:-}" CODE_SIGN_STYLE=Automatic \
  clean archive | cat

echo "[2/3] Exporting IPA"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -exportPath "$EXPORT_PATH" \
  -allowProvisioningUpdates | cat

IPA_CANDIDATES=("${EXPORT_PATH}"/*.ipa)
if [[ ${#IPA_CANDIDATES[@]} -eq 0 || ! -e "${IPA_CANDIDATES[0]}" ]]; then
  echo "Error: No .ipa found in ${EXPORT_PATH}" >&2
  exit 1
fi
if [[ ${#IPA_CANDIDATES[@]} -gt 1 ]]; then
  echo "Error: Multiple .ipa files found in ${EXPORT_PATH}. Specify with -o custom plist to control product name or clean the folder." >&2
  printf '%s\n' "${IPA_CANDIDATES[@]}" >&2
  exit 1
fi
IPA="${IPA_CANDIDATES[0]}"

echo "[3/3] Uploading to TestFlight"
"$SCRIPT_DIR/upload_testflight.sh" -f "$IPA"

echo "✅ Done. Check App Store Connect > TestFlight."



