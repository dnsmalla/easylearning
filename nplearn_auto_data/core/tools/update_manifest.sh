#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# Update Manifest
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/colors.sh"
source "$SCRIPT_DIR/../lib/logger.sh"

print_section "Updating Manifest"

MANIFEST_FILE="$APP_RESOURCES_PATH/manifest.json"

if [ ! -f "$MANIFEST_FILE" ]; then
    log_error "Manifest file not found: $MANIFEST_FILE"
    exit 1
fi

# Update file sizes
log_task "Calculating file sizes"

python3 << EOF
import json
import os

manifest_path = "$MANIFEST_FILE"
resources_path = "$APP_RESOURCES_PATH"

with open(manifest_path, 'r') as f:
    manifest = json.load(f)

# Update file info
for filename, info in manifest.get('files', {}).items():
    filepath = os.path.join(resources_path, filename)
    if os.path.exists(filepath):
        info['size'] = os.path.getsize(filepath)
    else:
        # Try in same directory as manifest
        alt_path = os.path.join(os.path.dirname(manifest_path), filename)
        if os.path.exists(alt_path):
            info['size'] = os.path.getsize(alt_path)

# Update release date
from datetime import datetime
manifest['releaseDate'] = datetime.now().strftime('%Y-%m-%d')

# Write updated manifest
with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)

print(f"Updated {len(manifest.get('files', {}))} file entries")
EOF

log_task_done

log_success "Manifest updated!"

