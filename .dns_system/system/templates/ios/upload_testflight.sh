#!/usr/bin/env bash
set -euo pipefail

# TestFlight upload helper using Apple's Transporter (iTMSTransporter)
# Template version - copy to project root when needed
#
# Prereqs:
# - Xcode installed (iTMSTransporter available via `xcrun iTMSTransporter`)
# - Apple ID with 2FA and an app-specific password
#
# Auth via Apple ID (default):
#   export ASC_USERNAME="you@example.com"
#   export ASC_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"   # app-specific password
#   Optional provider short name (if multiple teams):
#   export ASC_PROVIDER="YOURPROVIDER"
#
# Usage:
#   ./upload_testflight.sh [-f /path/to/app.ipa] [-u username] [-p env_var_for_password] [-P provider]
#
# Examples:
#   ./upload_testflight.sh
#   ./upload_testflight.sh -f build/meic_export/Meic.ipa
#   ./upload_testflight.sh -u "$ASC_USERNAME" -p ASC_APP_PASSWORD -P "$ASC_PROVIDER"

IPA_PATH_DEFAULT="build/meic_export/Meic.ipa"
USERNAME="${ASC_USERNAME:-}"
PASSWORD_ENV_VAR="ASC_APP_PASSWORD"
PROVIDER="${ASC_PROVIDER:-}"
IPA_PATH="$IPA_PATH_DEFAULT"

usage() {
  echo "Usage: $0 [-f ipa_path] [-u username] [-p password_env_var] [-P provider]" >&2
  echo "  -f ipa_path            Path to .ipa (default: $IPA_PATH_DEFAULT)" >&2
  echo "  -u username            Apple ID username (default: from ASC_USERNAME)" >&2
  echo "  -p password_env_var    Name of env var holding app-specific password (default: ASC_APP_PASSWORD)" >&2
  echo "  -P provider            Provider short name (default: from ASC_PROVIDER, optional)" >&2
  exit 1
}

while getopts ":f:u:p:P:h" opt; do
  case "$opt" in
    f) IPA_PATH="$OPTARG" ;;
    u) USERNAME="$OPTARG" ;;
    p) PASSWORD_ENV_VAR="$OPTARG" ;;
    P) PROVIDER="$OPTARG" ;;
    h) usage ;;
    :) echo "Error: Option -$OPTARG requires an argument" >&2; usage ;;
    \?) echo "Error: Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Resolve and validate
if [[ -z "${USERNAME}" ]]; then
  echo "Error: ASC_USERNAME not set and -u not provided." >&2
  echo "Set ASC_USERNAME env var or pass -u <username>." >&2
  exit 2
fi

if [[ -z "${!PASSWORD_ENV_VAR:-}" ]]; then
  echo "Error: ${PASSWORD_ENV_VAR} env var is not set (holds app-specific password)." >&2
  echo "Example: export ASC_APP_PASSWORD=xxxx-xxxx-xxxx-xxxx" >&2
  exit 3
fi

if [[ ! -f "$IPA_PATH" ]]; then
  echo "Error: IPA not found at: $IPA_PATH" >&2
  exit 4
fi

# Check transporter availability
if ! xcrun iTMSTransporter -version >/dev/null 2>&1; then
  echo "Error: iTMSTransporter not found. Ensure Xcode command line tools are installed." >&2
  echo "Open Xcode once or run: xcode-select --install" >&2
  exit 5
fi

echo "Uploading to TestFlight via Transporter..."
echo "  IPA:       $IPA_PATH"
echo "  Username:  $USERNAME"
if [[ -n "$PROVIDER" ]]; then
  echo "  Provider:  $PROVIDER"
fi

set -x
ARGS=(
  -m upload
  -assetFile "$IPA_PATH"
  -u "$USERNAME"
  -p "@env:${PASSWORD_ENV_VAR}"
  -v informational
)

# Add provider if supplied
if [[ -n "$PROVIDER" ]]; then
  ARGS+=( -provider "$PROVIDER" )
fi

xcrun iTMSTransporter "${ARGS[@]}"
set +x

echo "✅ Upload initiated. Check App Store Connect > TestFlight for processing status."


