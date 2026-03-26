# building-in-the-open

Ask an AI agent to write three documents in the same session. You'll get three different voices, three different quality levels, and zero consistency.

That's fine for throwaway drafts. It's not fine for anything that reaches your repository.

`building-in-the-open` is a Claude Code plugin that fixes this with **writer personas** for consistent voice, **quality gates** for measurable standards, and an **editorial firewall** that catches tone drift, sarcasm, and assumed context before anything ships.

Whether you're a developer capturing the reasoning behind architectural decisions or a technical writer maintaining documentation—the problem is the same. AI agents need guardrails on their prose, not just their code. Technical writers are [already discovering this](https://medium.com/@jennifer.oakleytx/day-1-with-claude-code-a-technical-writers-first-impressions-8ab46cf704e8)—and so are [UX writers](https://uxwritinghub.com/claude-code-ux-writing/) and [documentation teams](https://www.mintlify.com/blog/how-mintlify-uses-claude-code-as-a-technical-writing-assistant).

Seven skills. Four writer personas. One tone firewall. Zero embarrassing commits.

### What this is—and isn't

This produces **development artifacts**—the documentation that emerges *during* building: ADRs, design docs, handoffs, changelogs, end-user guides. If you need a documentation site generator, look at mdBook or Docusaurus. If you need the documents worth putting *on* that site, you're in the right place.

## How it works

Three layers, loosely coupled:

```
┌─────────────────────────────────────────────────────┐
│  SKILLS (artifact-specific workflows)               │
│  curating-context, capturing-decisions, writing-    │
│  design-docs, writing-end-user-docs, writing-       │
│  changelogs, editorial-review, building-in-the-open │
├─────────────────────────────────────────────────────┤
│  PERSONAS (composable voice layer)                  │
│  technical-writer, doc-writer, marketing-           │
│  copywriter, context-curator                        │
├─────────────────────────────────────────────────────┤
│  TOOLING (quality gates)                            │
│  bito: token counter, readability scorer,      │
│  completeness checker, path-based rules engine      │
└─────────────────────────────────────────────────────┘
```

**Skills** define *what* to produce. **Personas** define *how* to sound. **Tooling** enforces *whether it's good enough to ship*.

Each skill announces itself and its persona when invoked—so you always know which voice is active and why.

## Installation

```sh
claude plugin add claylo-marketplace/building-in-the-open
```

Or install manually:

```sh
git clone https://github.com/claylo/building-in-the-open ~/.claude/plugins/building-in-the-open
```

**Quality gates** (optional but recommended):

```sh
brew install claylo/brew/bito # macOS / Linux, easiest
npm install -g @claylo/bito   # wraps the native binary
cargo binstall bito           # if you've got a rust environment
```

Verify: `bito doctor`

See the [installation guide](docs/installation.md) for pre-commit hooks, MCP server setup, and dialect configuration.

## Quickstart

See the [quickstart walkthrough](docs/quickstart.md) for hands-on examples:
- **Your first handoff** — capture session context with quality gates
- **Your first ADR** — document an architectural decision
- **The editorial review pipeline** — the full draft-review-commit loop

## Skills

Each skill lives in `skills/<name>/SKILL.md` and defines a complete workflow for one artifact type.

| Skill | What it produces | Persona |
|-------|-----------------|---------|
| `building-in-the-open` | Routing + bito setup and configuration | — |
| `curating-context` | Public handoffs + private memory | Context Curator |
| `capturing-decisions` | Architecture decision records (MADR 4.0.0) | Technical Writer |
| `writing-design-docs` | Design documents | Technical Writer |
| `writing-end-user-docs` | Tutorials, guides, API references | Doc Writer |
| `writing-changelogs` | CHANGELOG.md + release announcements | Technical Writer + Marketing Copywriter |
| `editorial-review` | Pass/fail quality review | None (reviewer, not writer) |

Skills are superpowers-aware—if the [superpowers](https://github.com/anthropics/superpowers) plugin is installed, workflow integration happens automatically. If not, every skill works standalone.

## Personas

Personas are voice guides stored in `personas/<name>.md`. They tell an agent *how* to write—not what to say, but how to sound saying it.

- **Technical Writer** — Rigorous, opinionated, warm. First-person plural. Explicit trade-offs. For ADRs and design docs.
- **Context Curator** — Dense, structured, scannable. Optimized for tokens-to-insight ratio. For handoffs.
- **Doc Writer** — Accessible, example-first, respects the reader's time. For end-user docs.
- **Marketing Copywriter** — Benefits before features, technically credible. For READMEs and announcements.

Personas compose. A README uses Marketing Copywriter above the fold and Doc Writer below. The `writing-changelogs` skill produces two outputs from the same changes—Technical Writer for the CHANGELOG, Marketing Copywriter for the release announcement. The `building-in-the-open` skill documents all the composition points.

## Quality gates

Define what checks run on what files in your config—no hardcoded scripts:

```yaml
# .bito.yaml
rules:
  - paths: [".handoffs/*.md"]
    checks:
      tokens: { budget: 2000 }
      completeness: { template: handoff }

  - paths: ["record/decisions/*.md"]
    checks:
      completeness: { template: adr }

  - paths: ["record/designs/*.md"]
    checks:
      completeness: { template: design-doc }
      readability: { max_grade: 12 }
```

Run all matching checks in one pass:

```sh
bito lint record/decisions/0001-my-adr.md
```

The `editorial-review` skill adds agent-based judgment on top of these deterministic checks—catching sarcasm, implied criticism, and tone mismatches that a pattern matcher can't reach.

## The tone firewall

Everything gets drafted freely. Private context (`PRIVATE_MEMORY.md`) stays completely unfiltered—motivations, frustrations, hunches, the real story. Only artifacts destined for the repository get filtered through the quality gates.

The rule: if you wouldn't say it at a technical conference, it doesn't reach the repo.

## Project structure

```
.bus-factor/        Archived handoffs (project timeline)
.claude-plugin/     Plugin metadata
.handoffs/          Active handoff documents (committed)
agents/             Subagent definitions (editorial reviewer)
record/decisions/     Architecture decision records
record/designs/       Design documents
hooks/              Plugin hooks + pre-commit hook
personas/           Writer voice definitions
skills/             Artifact-specific workflows
templates/          Document structure templates
```

## Architecture decisions

This project's own ADRs document the key design choices:

- [ADR-0001](record/decisions/0001-composable-persona-layer-for-artifact-generation.md) — Composable persona layer
- [ADR-0002](record/decisions/0002-tone-firewall-on-commit-path-not-writing-path.md) — Tone firewall on commit path
- [ADR-0003](record/decisions/0003-real-tools-for-measurement-agents-for-judgment.md) — Real tools for measurement, agents for judgment
- [ADR-0004](record/decisions/0004-prompted-adr-extraction-from-design-docs.md) — Prompted ADR extraction
- [ADR-0005](record/decisions/0005-token-budget-for-public-handoffs.md) — 2,000-token handoff budget
- [ADR-0006](record/decisions/0006-private-memory-gitignored-handoffs-committed.md) — Private memory gitignored, handoffs committed
- [ADR-0007](record/decisions/0007-use-pluggable-tokenizer-backends-in-bito.md) — Pluggable tokenizer backends

## License

MIT
