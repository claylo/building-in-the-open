---
name: building-in-the-open
description: Use when asked to write documentation, set up documentation tooling, configure quality gates, or when the request is ambiguous about which type of documentation to produce. Routes to the right writing skill and manages bito-lint configuration.
---

# Building in the Open

## Overview

This is the entry point for the building-in-the-open plugin. If you know exactly what artifact to produce, use the specific skill directly. If the request is ambiguous ("write docs", "set up documentation", "configure quality gates"), start here.

## Routing

| User wants... | Use this skill |
|---|---|
| Capture session context for the next person/agent | `curating-context` (handoff) |
| Record a technical decision | `capturing-decisions` |
| Formalize a design before or during implementation | `writing-design-docs` |
| Write tutorials, guides, or API references for end users | `writing-end-user-docs` |
| Produce CHANGELOG entries or release announcements | `writing-changelogs` |
| Review an artifact before committing | `editorial-review` |
| Set up quality gates for the first time | `onboarding` (guided interview) |
| Configure or troubleshoot bito-lint | Continue below |

## bito-lint Setup

bito-lint provides the deterministic quality gates (token counting, readability scoring, completeness checking) that every writing skill depends on. The plugin works without it — skills still produce artifacts — but quality gates won't run without bito-lint installed.

### Installation

```sh
cargo binstall bito-lint          # pre-built binary, fastest
brew install claylo/brew/bito-lint # macOS / Linux
npm install -g @claylo/bito-lint   # wraps the native binary
```

Verify: `bito-lint doctor`

### Configuration file

bito-lint discovers config files by walking up from the current directory to the nearest `.git` boundary. Supported formats: `.bito-lint.yaml`, `.bito-lint.toml`, `.bito-lint.json`.

```yaml
# .bito-lint.yaml — project-wide defaults (all fields optional)

dialect: en-us            # en-us | en-gb | en-ca | en-au — spelling enforcement
token_budget: 2000        # default budget for `bito-lint tokens`
max_grade: 12.0           # default Flesch-Kincaid ceiling for `bito-lint readability`
passive_max_percent: 15.0 # max passive voice % for `bito-lint grammar`
style_min_score: 70       # min style score for `bito-lint analyze`
tokenizer: claude         # claude (conservative, overcounts ~4%) | openai (exact cl100k_base)

# Custom completeness templates beyond the built-in adr, handoff, design-doc
templates:
  runbook: ["## Overview", "## Prerequisites", "## Steps", "## Rollback"]
```

**Discovery order** (highest precedence first):
1. `--config <path>` CLI flag
2. `.bito-lint.yaml` / `.bito-lint.toml` / `.bito-lint.json` in current or ancestor directory (up to `.git` boundary)
3. `~/.config/bito-lint/config.toml` (user-level defaults)

**Environment variable overrides** — any field can be set via `BITO_LINT_` prefix:

```sh
BITO_LINT_DIALECT=en-gb
BITO_LINT_TOKEN_BUDGET=3000
BITO_LINT_TOKENIZER=openai
```

### Path-based rules

Instead of hardcoding check logic in hook scripts, declare what checks run on what files in your config. The `rules` array maps glob patterns to checks with per-rule settings:

```yaml
# .bito-lint.yaml
rules:
  - paths: [".handoffs/*.md"]
    checks:
      completeness:
        template: handoff
      tokens:
        budget: 2000
      grammar:
        passive_max: 15.0

  - paths: ["docs/decisions/*.md"]
    checks:
      completeness:
        template: adr
      analyze:
        max_grade: 10.0

  - paths: ["docs/designs/*.md"]
    checks:
      completeness:
        template: design-doc
      readability:
        max_grade: 12.0

  - paths: ["docs/**/*.md", "README.md"]
    checks:
      readability:
        max_grade: 8.0
      grammar:
        passive_max: 20.0
```

**Rule resolution:**
- All matching rules accumulate — a file matching two rules gets the union of their checks
- When two rules configure the same check, the more specific pattern wins (specificity = number of literal path segments)
- `docs/decisions/*.md` (2 literal segments) beats `docs/**/*.md` (1 literal)

**Running rules:** Use `bito-lint lint <file>` to match a file against configured rules and run all resolved checks in one pass:

```sh
bito-lint lint docs/decisions/0001-my-adr.md        # human-readable output
bito-lint lint docs/decisions/0001-my-adr.md --json  # machine-readable
```

No matching rule = clean exit (exit 0). Any failing threshold = exit 1.

### Available checks in rules

| Check | Settings | Description |
|---|---|---|
| `analyze` | `checks`, `exclude`, `max_grade`, `passive_max`, `style_min`, `dialect` | Full 18-check writing analysis |
| `readability` | `max_grade` | Flesch-Kincaid grade level gate |
| `grammar` | `passive_max` | Passive voice percentage gate |
| `completeness` | `template` (required) | Template section validation |
| `tokens` | `budget`, `tokenizer` | Token count gate |

### Inline suppressions

Suppress specific checks for sections that intentionally break rules:

```markdown
<!-- bito-lint disable grammar -->
This section uses passive voice on purpose.
<!-- bito-lint enable grammar -->

<!-- bito-lint disable-next-line readability -->
This extraordinarily sesquipedalian sentence is intentional.

<!-- bito-lint disable grammar,cliches -->
Multiple checks suppressed at once.
<!-- bito-lint enable grammar,cliches -->
```

An unclosed `disable` suppresses for the rest of the file.

### MCP server

For real-time quality feedback during writing sessions, configure bito-lint as an MCP server. This lets writing skills call quality gate tools directly without shelling out.

Add to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "bito-lint": {
      "command": "bito-lint",
      "args": ["serve"]
    }
  }
}
```

The MCP server exposes: `count_tokens`, `check_readability`, `check_completeness`, `analyze`, `check_grammar`, and `lint_file` (runs path-based rules). When available, writing skills should prefer MCP tool calls over shell commands.

### Tokenizer backends

bito-lint ships two tokenizer backends:

- **claude** (default) — Uses a 38K verified Claude vocabulary with greedy longest-match. Overcounts by ~4% on prose. Safe for budget enforcement: you'll never silently exceed a limit.
- **openai** — Exact BPE encoding using cl100k_base (GPT-4/GPT-3.5 vocabulary). Use only when targeting OpenAI models.

Set the backend via config (`tokenizer: claude`), env var (`BITO_LINT_TOKENIZER=openai`), or CLI flag (`--tokenizer openai`).

## Quality Gate Quick Reference

| Check | Command | What it measures |
|---|---|---|
| Lint (rules) | `bito-lint lint <file>` | Run all checks matching file path rules |
| Token count | `bito-lint tokens <file> --budget 2000` | Tokens vs budget (handoffs) |
| Readability | `bito-lint readability <file> --max-grade 12` | Flesch-Kincaid grade level |
| Completeness | `bito-lint completeness <file> --template adr` | Required sections present |
| Grammar | `bito-lint grammar <file>` | Passive voice, sentence issues |
| Full analysis | `bito-lint analyze <file> --dialect en-us` | All checks + style score |

Built-in completeness templates: `adr`, `handoff`, `design-doc`. Define custom templates in config.

## Personas

Every writing skill uses a persona to control voice. Personas are composable — the same artifact type always gets the same voice regardless of which agent writes it.

- **Technical Writer** (`personas/technical-writer.md`) — ADRs, design docs, changelogs
- **Context Curator** (`personas/context-curator.md`) — Handoffs
- **Doc Writer** (`personas/doc-writer.md`) — End-user docs
- **Marketing Copywriter** (`personas/marketing-copywriter.md`) — READMEs, release announcements

## Composing Skills and Personas

Most artifacts use a single skill and a single persona. A few require blending.

### Single-persona artifacts

| Artifact | Skill | Persona |
|---|---|---|
| Handoff | `curating-context` | Context Curator |
| ADR | `capturing-decisions` | Technical Writer |
| Design doc | `writing-design-docs` | Technical Writer |
| End-user doc | `writing-end-user-docs` | Doc Writer |
| CHANGELOG entry | `writing-changelogs` | Technical Writer |
| Release announcement | `writing-changelogs` | Marketing Copywriter |

### Multi-persona artifacts

**README** — The above-the-fold sections (project pitch, value proposition, "why this exists") use the **Marketing Copywriter** persona. The below-the-fold sections (installation, quickstart, configuration, project structure) use the **Doc Writer** persona. The transition happens at the first `## Installation` or `## Getting Started` heading. Use `writing-end-user-docs` for the Doc Writer sections and `writing-changelogs` (release announcement mode) as voice reference for the Marketing Copywriter intro.

**CHANGELOG + release announcement** — The `writing-changelogs` skill handles this natively. CHANGELOG entries get Technical Writer voice (factual, scannable). Release announcements get Marketing Copywriter voice (benefit-forward, enthusiastic but credible). Same changes, two voices, one skill invocation.

### Skill chaining

Skills often trigger each other:

- **`writing-design-docs` → `capturing-decisions`** — Design docs surface discrete decisions. Step 4 of the design-docs skill prompts for ADR extraction.
- **`curating-context` → `capturing-decisions`** — If decisions were made during the session, capture them as ADRs and reference them from the handoff.
- **Any writing skill → `editorial-review`** — Every skill's final step runs the tone firewall. The editorial review is a quality layer, not a writing layer — it has no persona of its own.

### When personas blend within a single document

Keep voice transitions clean. Don't let the Marketing Copywriter voice leak into technical sections or the Technical Writer voice stiffen a getting-started guide. The heading structure is the boundary — each section commits to one persona's voice. If you're unsure which persona owns a section, ask: "Is this section trying to attract or instruct?" Attract = Marketing Copywriter. Instruct = Doc Writer or Technical Writer.

## Pre-commit Hook

The plugin includes a git pre-commit hook that runs quality gates on staged documentation files. To install it:

```sh
cp hooks/pre-commit-docs .git/hooks/pre-commit
```

Or source it from an existing hook:

```sh
# In your existing .git/hooks/pre-commit
source ~/.claude/plugins/building-in-the-open/hooks/pre-commit-docs
```

With path-based rules configured, the pre-commit hook can use `bito-lint lint` instead of per-file check logic — the config becomes the single source of truth for what checks run where.
