set shell := ["bash", "-c"]
set dotenv-load := true
toolchain := `taplo get -f rust-toolchain.toml toolchain.channel | tr -d '"'`
msrv := "1.88.0"

default:
  @just --list

fmt:
  cargo fmt --all

clippy:
  cargo +{{toolchain}} clippy --all-targets --all-features --message-format=short -- -D warnings

fix:
  echo "Using toolchain {{toolchain}}"
  cargo +{{toolchain}} clippy --fix --allow-dirty --allow-staged -- -W clippy::all

# Check dependencies for security advisories and license compliance
deny:
  cargo deny check

test:
  cargo nextest run

doc-test:
  cargo test --doc

cov:
  @cargo llvm-cov clean --workspace
  cargo llvm-cov nextest --no-report
  @cargo llvm-cov report --html
  @cargo llvm-cov report --summary-only --json --output-path target/llvm-cov/summary.json

check: fmt clippy test doc-test

# Build release binary
build-release:
  cargo build -p bito-lint --release

# Run bito-lint token counter against all handoff files
lint-handoffs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in .handoffs/*.md; do
    [ -f "$f" ] || continue
    cargo run -p bito-lint -- tokens "$f" --budget 2000
    cargo run -p bito-lint -- completeness "$f" --template handoff
  done

# Run bito-lint completeness check against all ADRs
lint-adrs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in docs/decisions/*.md; do
    [ -f "$f" ] || continue
    [[ "$(basename "$f")" == "README.md" ]] && continue
    cargo run -p bito-lint -- completeness "$f" --template adr
  done

# Run bito-lint readability check against all design docs
lint-design-docs:
  #!/usr/bin/env bash
  set -euo pipefail
  for f in docs/designs/*.md; do
    [ -f "$f" ] || continue
    cargo run -p bito-lint -- readability "$f" --max-grade 12
    cargo run -p bito-lint -- completeness "$f" --template design-doc
  done

# Run all doc quality checks
lint-docs: lint-handoffs lint-adrs lint-design-docs
