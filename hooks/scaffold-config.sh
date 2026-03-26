#!/usr/bin/env bash
set -euo pipefail

# Skip if any bito config already exists in the project
for f in .bito.yaml .bito.toml .bito.json .bito-lint.yaml .bito-lint.toml .bito-lint.json; do
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

sed \
  -e "s/__DIALECT__/${DIALECT}/g" \
  -e "s/__DOC_DIR__/${DOC_DIR}/g" \
  -e "s/__MAX_GRADE__/${MAX_GRADE}/g" \
  -e "s/__PASSIVE_MAX__/${PASSIVE_MAX}/g" \
  "$TEMPLATE" > .bito.yaml

echo "building-in-the-open: created .bito.yaml with quality gates (dialect=${DIALECT}, doc_dir=${DOC_DIR})"
exit 0
