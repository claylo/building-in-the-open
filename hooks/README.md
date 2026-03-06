# Hooks

This directory contains both Claude Code plugin hooks and a git pre-commit hook.

## Plugin hooks (hooks.json)

Registered automatically when the plugin is installed.

### SessionStart — `check-bito-lint.sh`

Checks whether `bito-lint` is on PATH. If missing, injects install instructions into Claude's context.

With bito-lint v0.3+, also announces available custom content entries (writer personas) from `.bito.yaml`. Skills can load a persona on demand via `bito-lint custom show <name> --config .bito.yaml`. The four personas registered are:

| Entry | Persona | Used by |
|-------|---------|---------|
| `technical-writer` | Rigorous, opinionated, warm | ADRs, design docs, changelogs |
| `context-curator` | Dense, scannable, no flair | Handoffs, memory |
| `doc-writer` | Accessible, example-first | End-user docs |
| `marketing-copywriter` | Honest enthusiasm | READMEs, release announcements |

### PostToolUse (Write|Edit) — `check-docs-on-write.sh`

Runs `bito-lint lint` on any markdown file Claude writes or edits. The lint command matches the file path against rules in `.bito.yaml` and runs all applicable checks in one pass. No match = silent pass.

On failure, stderr is fed back to Claude so it can fix the issue automatically.

Individual checks are fast (~10–100ms on Apple M3 Max). A `bito-lint lint` pass typically adds under 150ms to a Write.

## Git hook — `pre-commit-docs`

Not auto-installed. Copy it into your project:

```sh
cp hooks/pre-commit-docs .git/hooks/pre-commit
```

Runs the same checks as the PostToolUse hook, but against staged files at commit time. Belt and suspenders.
