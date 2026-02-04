#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# NPLearn – Data consistency check for app use
# ═══════════════════════════════════════════════════════════════════════════
# Verifies: level files exist, required keys, correctAnswer in options,
# listening has audioText. Updates manifest.json with file sizes.
# Run from repo root: bash .dns_system_language/scripts/check_data_consistency.sh
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DNS_SYSTEM="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -f "$DNS_SYSTEM/config/project.conf" ]]; then
  source "$DNS_SYSTEM/config/project.conf"
fi

DATA_DIR="${DATA_SOURCE_DIR_NAME:-nplearning}"
PREFIX="${LEVEL_FILE_PREFIX:-nepali_learning_data}"
LEVELS=(beginner elementary intermediate advanced proficient)
DATA_PATH="$WORKSPACE_ROOT/$DATA_DIR"
MANIFEST_PATH="$DATA_PATH/manifest.json"

echo "═══ Data consistency check (app use) ═══"
echo "Data dir: $DATA_PATH"
echo ""

FAIL=0

# 1. Level files exist and have required keys
for lev in "${LEVELS[@]}"; do
  file="$DATA_PATH/${PREFIX}_${lev}.json"
  if [[ ! -f "$file" ]]; then
    echo "❌ Missing: $file"
    FAIL=1
    continue
  fi
  for key in level flashcards grammar practice; do
    if ! grep -q "\"$key\"" "$file"; then
      echo "❌ $file: missing key '$key'"
      FAIL=1
    fi
  done
done

# 2. Practice: correctAnswer in options, Listening has audioText (Python check)
check_practice() {
  python3 << 'PY'
import json, os, sys
data_dir = os.environ.get("DATA_PATH", "nplearning")
prefix = os.environ.get("PREFIX", "nepali_learning_data")
levels = ["beginner", "elementary", "intermediate", "advanced", "proficient"]
fail = 0
for lev in levels:
  path = os.path.join(data_dir, f"{prefix}_{lev}.json")
  if not os.path.isfile(path):
    continue
  with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
  for p in data.get("practice", []):
    opts = p.get("options", [])
    correct = p.get("correctAnswer", "")
    if correct and correct not in opts:
      print(f"❌ {path}: correctAnswer '{correct}' not in options", file=sys.stderr)
      fail = 1
    cat = (p.get("category") or "").strip().lower()
    if cat == "listening" and not p.get("audioText"):
      print(f"❌ {path}: listening item missing audioText (id={p.get('id')})", file=sys.stderr)
      fail = 1
sys.exit(fail)
PY
}

export DATA_PATH PREFIX
if ! check_practice; then
  FAIL=1
fi

# 3. Manifest: update file sizes (single Python pass)
if [[ -f "$MANIFEST_PATH" ]]; then
  export DATA_PATH MANIFEST_PATH PREFIX
  python3 << PY
import json, os
data_path = os.environ.get("DATA_PATH", ".")
manifest_path = os.environ.get("MANIFEST_PATH", "manifest.json")
prefix = os.environ.get("PREFIX", "nepali_learning_data")
levels = ["beginner", "elementary", "intermediate", "advanced", "proficient"]
with open(manifest_path, "r", encoding="utf-8") as f:
    m = json.load(f)
for lev in levels:
    fn = f"{prefix}_{lev}.json"
    path = os.path.join(data_path, fn)
    if os.path.isfile(path) and "files" in m and fn in m["files"]:
        m["files"][fn]["size"] = os.path.getsize(path)
        print("Updated manifest size:", fn, m["files"][fn]["size"])
with open(manifest_path, "w", encoding="utf-8") as f:
    json.dump(m, f, indent=2)
PY
  echo "✓ Manifest sizes updated"
fi

if [[ $FAIL -eq 0 ]]; then
  echo "✓ All consistency checks passed (app-ready)"
else
  echo "⚠ Some checks failed (see above)"
  exit 1
fi
