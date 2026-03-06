# Hooks

This directory contains both Claude Code plugin hooks and a git pre-commit hook.

## Plugin hooks (hooks.json)

Registered automatically when the plugin is installed.

### SessionStart — `check-bito-lint.sh`

Checks whether `bito-lint` is on PATH. If missing, injects install instructions into Claude's context.

### PostToolUse (Write|Edit) — `check-docs-on-write.sh`

Runs bito-lint quality gates in real time whenever Claude writes or edits files in watched directories:

| Path pattern | Checks |
|---|---|
| `.handoffs/*.md` | tokens (budget 2000) + completeness (handoff) |
| `docs/decisions/*.md` | completeness (adr) |
| `docs/designs/*.md` | completeness (design-doc) + readability (max-grade 12) |
| `README.md`, other `docs/**/*.md` | readability (max-grade 8) + grammar |

Specific paths (handoffs, ADRs, design docs) match first. The README/docs catch-all only fires for general documentation that doesn't match the patterns above.

On failure, stderr is fed back to Claude so it can fix the issue automatically.

### Invocation times (bito-lint 0.1.7, Apple M3 Max)

| Check | Wall time |
|---|---|
| `tokens --budget 2000` | ~100ms |
| `completeness --template handoff` | ~13ms |
| `completeness --template adr` | ~11ms |
| `completeness --template design-doc` | ~33ms |
| `readability --max-grade 12` | ~20ms |
| `readability --max-grade 8` | ~20ms |
| `grammar` | ~15ms |

Worst case (handoff: tokens + completeness) adds ~115ms to a Write. Design docs (completeness + readability) add ~50ms. READMEs and general docs (readability + grammar) add ~35ms.

## Git hook — `pre-commit-docs`

Not auto-installed. Copy it into your project:

```sh
cp hooks/pre-commit-docs .git/hooks/pre-commit
```

Runs the same checks as the PostToolUse hook, but against staged files at commit time. Belt and suspenders.
