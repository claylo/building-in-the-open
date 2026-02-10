# building-in-the-open

Every AI coding session generates decisions, trade-offs, and context that vanishes when the session ends. `building-in-the-open` captures it — as professional handoff documents, architecture decision records, and end-user docs that pass editorial review before they reach your repo.

Six skills. Four writer personas. One tone firewall. Zero embarrassing commits.

This plugin produces *development artifacts* — the documentation that emerges during building software: ADRs, design docs, handoffs, changelogs. If you need a full-featured documentation site generator, look at mdBook or Docusaurus. If you need the documents *worth putting on that site*, this is the tool.

## How it works

Three layers, loosely coupled:

```
┌─────────────────────────────────────────────────────┐
│  SKILLS (artifact-specific workflows)               │
│  curating-context, writing-adrs, writing-design-    │
│  docs, writing-end-user-docs, writing-changelogs,   │
│  editorial-review                                   │
├─────────────────────────────────────────────────────┤
│  PERSONAS (composable voice layer)                  │
│  technical-writer, doc-writer, marketing-           │
│  copywriter, context-curator                        │
├─────────────────────────────────────────────────────┤
│  TOOLING (quality gates)                            │
│  bito-lint: token counter, readability scorer,      │
│  completeness checker                               │
└─────────────────────────────────────────────────────┘
```

**Skills** define *what* to produce. **Personas** define *how* to sound. **Tooling** enforces *whether it's good enough to ship*.

## Installation

See the [installation guide](docs/installation.md) for complete setup instructions, including:
- Plugin installation (clone into `~/.claude/plugins/`)
- bito-lint quality gate CLI (`cargo install bito-lint`)
- Pre-commit hook setup
- MCP server configuration (optional)
- Dialect and threshold configuration

## Quickstart

See the [quickstart walkthrough](docs/quickstart.md) for hands-on examples:
- **Your first handoff** — capture session context with quality gates
- **Your first ADR** — document an architectural decision
- **The editorial review pipeline** — the full draft-review-commit loop

## Skills

Each skill lives in `skills/<name>/SKILL.md` and defines a complete workflow for one artifact type.

| Skill | What it produces | Persona |
|-------|-----------------|---------|
| `curating-context` | Public handoffs + private memory | Context Curator |
| `writing-adrs` | Architecture decision records (MADR 4.0.0) | Technical Writer |
| `writing-design-docs` | Design documents | Technical Writer |
| `writing-end-user-docs` | Tutorials, guides, API references | Doc Writer |
| `writing-changelogs` | CHANGELOG.md + release announcements | Technical Writer + Marketing Copywriter |
| `editorial-review` | Pass/fail quality review | None (reviewer, not writer) |

## Personas

Personas are voice guides stored in `personas/<name>.md`. They tell an agent *how* to write — not what to say, but how to sound saying it.

- **Technical Writer** — Rigorous, opinionated, warm. First-person plural. Explicit trade-offs. For ADRs and design docs.
- **Context Curator** — Dense, structured, scannable. Optimized for tokens-to-insight ratio. For handoffs.
- **Doc Writer** — Accessible, example-first, respects the reader's time. For end-user docs.
- **Marketing Copywriter** — Benefits before features, technically credible. For READMEs and announcements.

## Quality gates

`bito-lint` provides three deterministic checks:

```sh
# Token counting — are handoffs under budget?
bito-lint tokens .handoffs/my-handoff.md --budget 2000

# Readability scoring — is the prose accessible?
bito-lint readability docs/designs/my-design.md --max-grade 12

# Completeness — are all required sections filled in?
bito-lint completeness docs/decisions/0001-my-adr.md --template adr
```

Templates: `adr`, `handoff`, `design-doc`.

The `editorial-review` skill adds agent-based judgment on top of these deterministic checks — catching sarcasm, implied criticism, and tone mismatches that a pattern matcher can't reach.

## Pre-commit hook

Copy the hook to enable quality checks before every commit:

```sh
cp hooks/pre-commit-docs .git/hooks/pre-commit
```

This runs token budget checks on handoffs, completeness checks on ADRs and design docs, and readability scoring on design docs — all automatically.

## The tone firewall

Everything gets drafted freely. Private context (`PRIVATE_MEMORY.md`) stays completely unfiltered — motivations, frustrations, hunches, the real story. Only artifacts destined for the repository get filtered through the quality gates.

The rule: if you wouldn't say it at a technical deep-dive conference, it doesn't reach the repo.

## Project structure

```
.claude-plugin/     Plugin metadata
.handoffs/          Public handoff documents (committed)
agents/             Agent templates (editorial reviewer)
docs/decisions/     Architecture decision records
docs/designs/       Design documents
hooks/              Pre-commit hook
personas/           Writer voice definitions
skills/             Artifact-specific workflows
templates/          Document structure templates
```

## Architecture decisions

This project's own ADRs document the key design choices:

- [ADR-0001](docs/decisions/0001-composable-persona-layer-for-artifact-generation.md) — Composable persona layer
- [ADR-0002](docs/decisions/0002-tone-firewall-on-commit-path-not-writing-path.md) — Tone firewall on commit path
- [ADR-0003](docs/decisions/0003-real-tools-for-measurement-agents-for-judgment.md) — Real tools for measurement, agents for judgment
- [ADR-0004](docs/decisions/0004-prompted-adr-extraction-from-design-docs.md) — Prompted ADR extraction
- [ADR-0005](docs/decisions/0005-token-budget-for-public-handoffs.md) — 2,000-token handoff budget
- [ADR-0006](docs/decisions/0006-private-memory-gitignored-handoffs-committed.md) — Private memory gitignored, handoffs committed

## License

Apache-2.0 OR MIT
