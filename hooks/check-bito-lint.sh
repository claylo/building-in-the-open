#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: verify bito-lint is available.
# If missing, inject context so Claude can advise the user.

if command -v bito-lint &>/dev/null; then
    echo "Success"
    exit 0
fi

# bito-lint not found — tell Claude so it can inform the user
cat <<'EOF'
The bito-lint CLI is not installed or not on PATH. Quality gate checks (token counting, readability scoring, completeness) and the pre-commit hook will not work without it.

Install bito-lint with any of:
  cargo binstall bito-lint
  brew install claylo/brew/bito-lint
  npm install -g @claylo/bito-lint

See docs/installation.md for full setup instructions.
EOF
exit 0
