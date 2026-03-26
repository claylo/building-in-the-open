#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: verify bito is available and announce custom content.
# If missing, inject context so Claude can advise the user.
# If present and v0.3+, list available persona entries so skills know
# they can load them via `bito custom show <name>`.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-}"
CONFIG_FILE="${PLUGIN_ROOT}/.bito.yaml"

# Resolve bito binary: PATH → plugin node_modules → plugin data dir → install
resolve_bito() {
    # 1. Already on PATH
    if command -v bito &>/dev/null; then
        return 0
    fi

    # 2. Bundled in plugin's own node_modules (mcpb or local npm install)
    local bundled="${PLUGIN_ROOT}/node_modules/.bin/bito"
    if [[ -x "$bundled" ]]; then
        export PATH="${PLUGIN_ROOT}/node_modules/.bin:$PATH"
        return 0
    fi

    # 3. Previously installed in persistent plugin data dir
    if [[ -n "$PLUGIN_DATA" ]]; then
        local data_bin="${PLUGIN_DATA}/node_modules/.bin/bito"
        if [[ -x "$data_bin" ]]; then
            export PATH="${PLUGIN_DATA}/node_modules/.bin:$PATH"
            return 0
        fi

        # 4. Auto-install into plugin data dir
        if command -v npm &>/dev/null; then
            if [[ ! -f "${PLUGIN_DATA}/package.json" ]] || \
               ! diff -q "${PLUGIN_ROOT}/package.json" "${PLUGIN_DATA}/package.json" &>/dev/null; then
                cp "${PLUGIN_ROOT}/package.json" "${PLUGIN_DATA}/"
                npm install --prefix "${PLUGIN_DATA}" --no-fund --no-audit 2>/dev/null || true
            fi
            if [[ -x "$data_bin" ]]; then
                export PATH="${PLUGIN_DATA}/node_modules/.bin:$PATH"
                return 0
            fi
        fi
    fi

    return 1
}

if ! resolve_bito; then
    cat <<'EOF'
The bito CLI is not installed or not on PATH. Quality gate checks (token counting, readability scoring, completeness) and the pre-commit hook will not work without it.

Install bito with any of:
  cargo binstall bito
  brew install claylo/brew/bito
  npm install -g @claylo/bito
EOF
    exit 0
fi

echo "Success"

# Announce custom content entries (personas) if config exists and bito supports it
if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0
fi

# Check that bito has the custom subcommand (v0.3+)
if ! bito custom list --config "$CONFIG_FILE" &>/dev/null; then
    exit 0
fi

NAMES=$(bito custom list --config "$CONFIG_FILE" 2>/dev/null) || exit 0

if [[ -z "$NAMES" ]]; then
    exit 0
fi

cat <<EOF

Writer personas are available via bito custom content (v0.3+).
Skills that produce documentation artifacts should load the appropriate persona
before drafting. To load a persona into context:

  bito custom show <name> --config ${CONFIG_FILE}

Available personas:
EOF

while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    echo "  - ${name}"
done <<< "$NAMES"
