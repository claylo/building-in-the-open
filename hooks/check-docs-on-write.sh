#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook: run bito-lint quality gates when docs are written or edited.
# Uses path-based rules from .bito.yaml — the config is the single source of truth.
# Exit 0 = pass (silent). Exit 2 = fail (stderr fed back to Claude).

if ! command -v bito-lint &>/dev/null; then
    exit 0
fi

if ! command -v jq &>/dev/null; then
    exit 0
fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Only lint markdown files
case "$FILE_PATH" in
    *.md) ;;
    *) exit 0 ;;
esac

# Let bito-lint rules handle the matching. No match = clean exit.
OUTPUT=$(bito-lint lint "$FILE_PATH" 2>&1) || {
    echo "$OUTPUT" >&2
    exit 2
}

exit 0
