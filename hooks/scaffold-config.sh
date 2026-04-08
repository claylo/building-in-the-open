#!/usr/bin/env bash
set -euo pipefail

# Skip if any bito config already exists in the project
# Matches bito's config discovery precedence: .config/ > dotfile > bare name
for f in .config/bito.yaml .config/bito.toml .config/bito.json \
         .bito.yaml .bito.toml .bito.json \
         bito.yaml bito.toml bito.json \
         .bito-lint.yaml .bito-lint.toml .bito-lint.json; do
  [ -f "$f" ] && exit 0
done

# Resolve userConfig values with defaults
DIALECT="${CLAUDE_PLUGIN_OPTION_DIALECT:-en-us}"
DOC_DIR="${CLAUDE_PLUGIN_OPTION_DOC_OUTPUT_DIR:-record}"
MAX_GRADE="${CLAUDE_PLUGIN_OPTION_MAX_GRADE:-12.0}"
PASSIVE_MAX="${CLAUDE_PLUGIN_OPTION_PASSIVE_MAX_PERCENT:-15.0}"

TEMPLATE="${CLAUDE_PLUGIN_ROOT}/defaults/bito.yaml"

if [ ! -f "$TEMPLATE" ]; then
  echo "building-in-the-open: defaults/bito.yaml not found in plugin" >&2
  exit 0
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

echo "building-in-the-open: created ${TARGET} with quality gates (dialect=${DIALECT}, doc_dir=${DOC_DIR})"
exit 0
