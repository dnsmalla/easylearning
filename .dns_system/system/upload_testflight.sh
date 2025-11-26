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

# TestFlight upload helper using Apple's Transporter (iTMSTransporter)

# Load project-local env if present (no secrets inside)
if [[ -f ./.asc_env ]]; then
  # shellcheck disable=SC1091
  source ./.asc_env
fi

IPA_PATH_DEFAULT="build/meic_export/Meic.ipa"
USERNAME="${ASC_USERNAME:-}"
PASSWORD_ENV_VAR="ASC_APP_PASSWORD"
PROVIDER="${ASC_PROVIDER:-}"
IPA_PATH="$IPA_PATH_DEFAULT"

usage() {
  echo "Usage: $0 [-f ipa_path] [-u username] [-p password_env_var] [-P provider]" >&2
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

if [[ -z "${USERNAME}" ]]; then
  echo "Error: ASC_USERNAME not set and -u not provided." >&2
  exit 2
fi

# If password env is not set, try Keychain
if [[ -z "${!PASSWORD_ENV_VAR:-}" ]]; then
  if command -v security >/dev/null 2>&1 && [[ -n "$USERNAME" ]]; then
    set +e
    KEYCHAIN_PW=$(security find-generic-password -s ASC_APP_PASSWORD -a "$USERNAME" -w 2>/dev/null)
    STATUS=$?
    set -e
    if [[ $STATUS -eq 0 && -n "$KEYCHAIN_PW" ]]; then
      export ${PASSWORD_ENV_VAR}="$KEYCHAIN_PW"
    fi
  fi
fi

if [[ -z "${!PASSWORD_ENV_VAR:-}" ]]; then
  echo "Error: ${PASSWORD_ENV_VAR} not set and no Keychain item found." >&2
  echo "Create an app-specific password at appleid.apple.com and store it:" >&2
  echo "  security add-generic-password -a '$USERNAME' -s ASC_APP_PASSWORD -w 'xxxx-xxxx-xxxx-xxxx' -U" >&2
  exit 3
fi

if [[ ! -f "$IPA_PATH" ]]; then
  echo "Error: IPA not found at: $IPA_PATH" >&2
  exit 4
fi

# Check transporter availability (path-based)
if ! xcrun --find iTMSTransporter >/dev/null 2>&1; then
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

if [[ -n "$PROVIDER" ]]; then
  ARGS+=( -provider "$PROVIDER" )
fi

# Prefer Transporter app if installed
if [[ -d "/Applications/Transporter.app" ]]; then
  ARGS+=( -TransporterAppPath "/Applications/Transporter.app" )
fi

xcrun iTMSTransporter "${ARGS[@]}"
set +x
echo "✅ Upload initiated. Check App Store Connect > TestFlight for processing status."



