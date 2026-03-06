#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: verify bito-lint is available and announce custom content.
# If missing, inject context so Claude can advise the user.
# If present and v0.3+, list available persona entries so skills know
# they can load them via `bito-lint custom show <name>`.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
CONFIG_FILE="${PLUGIN_ROOT}/.bito.yaml"

if ! command -v bito-lint &>/dev/null; then
    cat <<'EOF'
The bito-lint CLI is not installed or not on PATH. Quality gate checks (token counting, readability scoring, completeness) and the pre-commit hook will not work without it.

Install bito-lint with any of:
  cargo binstall bito-lint
  brew install claylo/brew/bito-lint
  npm install -g @claylo/bito-lint
EOF
    exit 0
fi

echo "Success"

# Announce custom content entries (personas) if config exists and bito-lint supports it
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0
fi

# Check that bito-lint has the custom subcommand (v0.3+)
if ! bito-lint custom list --config "$CONFIG_FILE" &>/dev/null; then
    exit 0
fi

NAMES=$(bito-lint custom list --config "$CONFIG_FILE" 2>/dev/null) || exit 0

if [[ -z "$NAMES" ]]; then
    exit 0
fi

cat <<EOF

Writer personas are available via bito-lint custom content (v0.3+).
Skills that produce documentation artifacts should load the appropriate persona
before drafting. To load a persona into context:

  bito-lint custom show <name> --config ${CONFIG_FILE}

Available personas:
EOF

while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    echo "  - ${name}"
done <<< "$NAMES"
