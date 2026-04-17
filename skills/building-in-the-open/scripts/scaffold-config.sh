#!/usr/bin/env bash
set -euo pipefail

# Scaffold a default .bito.yaml for the building-in-the-open plugin.
#
# Usage: bash scaffold-config.sh [--force]
#
# Environment overrides (all optional):
#   DIALECT              en-us | en-gb | en-ca | en-au   (default: en-us)
#   DOC_OUTPUT_DIR       path for ADRs/designs            (default: record)
#   MAX_GRADE            Flesch-Kincaid ceiling           (default: 12.0)
#   PASSIVE_MAX_PERCENT  max passive voice percentage     (default: 15.0)

FORCE=0
if [ "${1:-}" = "--force" ]; then
  FORCE=1
fi

# Skip if any bito config already exists in the project (unless --force)
# Matches bito's config discovery precedence: .config/ > dotfile > bare name
if [ "$FORCE" -eq 0 ]; then
  for f in .config/bito.yaml .config/bito.toml .config/bito.json \
           .bito.yaml .bito.toml .bito.json \
           bito.yaml bito.toml bito.json \
           .bito-lint.yaml .bito-lint.toml .bito-lint.json; do
    if [ -f "$f" ]; then
      echo "building-in-the-open: found existing config at $f — leaving untouched (pass --force to overwrite)"
      exit 0
    fi
  done
fi

# Resolve values — accept either bare env vars or the CLAUDE_PLUGIN_OPTION_* names
DIALECT="${DIALECT:-${CLAUDE_PLUGIN_OPTION_DIALECT:-en-us}}"
DOC_DIR="${DOC_OUTPUT_DIR:-${CLAUDE_PLUGIN_OPTION_DOC_OUTPUT_DIR:-record}}"
MAX_GRADE="${MAX_GRADE:-${CLAUDE_PLUGIN_OPTION_MAX_GRADE:-12.0}}"
PASSIVE_MAX="${PASSIVE_MAX_PERCENT:-${CLAUDE_PLUGIN_OPTION_PASSIVE_MAX_PERCENT:-15.0}}"

# Resolve template relative to this script's location so the script works
# whether invoked from the plugin tree or copied into another location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/../../../defaults/bito.yaml"

# Fall back to CLAUDE_PLUGIN_ROOT if we were moved out of the plugin tree
if [ ! -f "$TEMPLATE" ] && [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  TEMPLATE="${CLAUDE_PLUGIN_ROOT}/defaults/bito.yaml"
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "building-in-the-open: defaults/bito.yaml not found (looked in $TEMPLATE)" >&2
  exit 1
fi

# Prefer .config/ if it already exists, otherwise use dotfile at root
if [ -d ".config" ]; then
  TARGET=".config/bito.yaml"
else
  TARGET=".bito.yaml"
fi

sed \
  -e "s/__DIALECT__/${DIALECT}/g" \
  -e "s/__DOC_DIR__/${DOC_DIR}/g" \
  -e "s/__MAX_GRADE__/${MAX_GRADE}/g" \
  -e "s/__PASSIVE_MAX__/${PASSIVE_MAX}/g" \
  "$TEMPLATE" > "$TARGET"

echo "building-in-the-open: wrote ${TARGET} (dialect=${DIALECT}, doc_dir=${DOC_DIR}, max_grade=${MAX_GRADE}, passive_max=${PASSIVE_MAX})"
