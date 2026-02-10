set shell := ["bash", "-c"]
set dotenv-load := true

# bito-lint binary — override with BITO_LINT env var if needed
bito_lint := env("BITO_LINT", "bito-lint")

default:
  @just --list

# Run all doc quality checks
lint-docs: lint-handoffs lint-adrs lint-design-docs

# Run a single file through all applicable checks
lint file:
  #!/usr/bin/env bash
  set -euo pipefail
  f="{{file}}"
  if [[ "$f" == .handoffs/*.md ]]; then
    {{bito_lint}} tokens "$f" --budget 2000
    {{bito_lint}} completeness "$f" --template handoff
  elif [[ "$f" == docs/decisions/*.md ]]; then
    {{bito_lint}} completeness "$f" --template adr
  elif [[ "$f" == docs/designs/*.md ]]; then
    {{bito_lint}} readability "$f" --max-grade 12
    {{bito_lint}} completeness "$f" --template design-doc
  else
    echo "Unknown artifact type for: $f"
    echo "Running general analysis..."
    {{bito_lint}} analyze "$f"
  fi

# Check token budget and completeness for all handoff files
lint-handoffs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in .handoffs/*.md; do
    [ -f "$f" ] || continue
    {{bito_lint}} tokens "$f" --budget 2000
    {{bito_lint}} completeness "$f" --template handoff
  done

# Check completeness for all ADRs
lint-adrs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in docs/decisions/*.md; do
    [ -f "$f" ] || continue
    [[ "$(basename "$f")" == "README.md" ]] && continue
    {{bito_lint}} completeness "$f" --template adr
  done

# Check readability and completeness for all design docs
lint-design-docs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in docs/designs/*.md; do
    [ -f "$f" ] || continue
    {{bito_lint}} readability "$f" --max-grade 12
    {{bito_lint}} completeness "$f" --template design-doc
  done
