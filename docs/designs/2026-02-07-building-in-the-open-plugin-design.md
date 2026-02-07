# Building in the Open: Plugin Design

**Date:** 2026-02-07
**Status:** Design Complete, Awaiting Implementation

## Overview

We are building a Claude Code plugin called `building-in-the-open` that ensures every artifact committed to a repository is professional, self-contained, and useful to anyone who reads it — whether that reader is a future maintainer, an open-source contributor, or an AI agent picking up where the last one left off.

The core problem: developers working with AI coding agents generate enormous context during a session — decisions, trade-offs, dead ends, frustrations, breakthroughs. Most of that context evaporates when the session ends. What little survives often isn't fit for public consumption. We lose institutional knowledge on one end and risk embarrassment on the other.

This plugin solves both problems with a layered architecture: composable **writer personas** that define editorial voice, **artifact-specific skills** that define document structure and workflow, and **quality gate tooling** that enforces standards before anything reaches the repository.

## Architecture

Three layers, loosely coupled:

```
┌─────────────────────────────────────────────────────┐
│  SKILLS (artifact-specific workflows)               │
│  "What are we producing?"                           │
│  curating-context, writing-adrs, writing-design-    │
│  docs, writing-end-user-docs, writing-changelogs,   │
│  editorial-review                                   │
├─────────────────────────────────────────────────────┤
│  PERSONAS (composable voice layer)                  │
│  "Who is writing it, and for whom?"                 │
│  technical-writer, doc-writer, marketing-           │
│  copywriter, context-curator                        │
├─────────────────────────────────────────────────────┤
│  TOOLING (quality gates)                            │
│  "Is it good enough to ship?"                       │
│  token counter, readability scorer, tone firewall,  │
│  completeness checker                               │
└─────────────────────────────────────────────────────┘
```

**How they compose:** A skill selects the appropriate persona for the artifact type it produces, then routes the output through the tooling layer before it reaches the repository.

**The tone firewall is a gate on the commit path, not on the writing path.** Everything gets drafted freely. Only artifacts destined for the repository get filtered. Private context captures (`PRIVATE_MEMORY.md`) bypass the firewall entirely — that's the point.

## Personas

Personas are reference files stored at `personas/<name>.md` in the plugin. They are not skills — they are voice definitions that skills load when drafting content. Each persona file contains a voice summary (~300 tokens), a do/don't table, and 2-3 calibration examples showing the same information written poorly vs. well for that persona.

The calibration examples are the most important part. Telling an agent "be approachable" is vague. Showing it *"The configuration subsystem initializes during the bootstrap phase..."* rewritten as *"When your app starts, it reads `config.toml` and sets up..."* is concrete and reproducible.

### Technical Writer

**Serves:** ADRs, design documents, iteration history, retrospectives, architectural commentary.

**Reader:** Future developers, contributors, and agents consuming architectural context.

**Voice:** Rigorous and opinionated, but warm. Writes like someone who has formed views through experience and respects the reader enough to share the reasoning, not just the conclusion. First-person plural. Treats the reader as an intelligent person who simply doesn't have this particular context yet.

**Core traits:**

- **Opinionated but grounded.** "We chose SQLite over Postgres because this is a single-user CLI tool and eliminating a server dependency cuts the onboarding surface in half." Not "SQLite was selected due to various considerations."
- **First-person plural.** Always "we" — the reader joins the team the moment they start reading. Never passive voice to dodge accountability.
- **Assumes competence, provides context.** The reader doesn't need `HashMap` explained; they do need to know why we're using one instead of a `BTreeMap` here.
- **States trade-offs explicitly.** Every decision has a cost. Name it. "This means we lose X, which is acceptable because Y."
- **No hedge words.** Not "we might want to consider possibly using..." — instead "we use X. If requirements change to include Y, revisit this."

**Anti-patterns:** Passive voice ("it was decided that..."). Weasel phrases ("for various reasons", "due to complexity"). Negativity about alternatives. Over-qualifying.

### Doc Writer

**Serves:** End-user documentation website — tutorials, guides, API references, getting-started content.

**Reader:** Developers who want to use this project. They're evaluating it, learning it, or looking up a specific thing. They have nine browser tabs open and will bounce if we waste their time.

**Voice:** Accessible and engaging — makes you want to keep reading. Technical accuracy wrapped in genuine approachability. The kind of technical writing where the reader feels smarter after reading, not impressed by the author's vocabulary.

**Core traits:**

- **Example first, explanation second.** Show the code that works, then explain why. The reader came to do something, not to read a preamble.
- **Respects the reader's time ruthlessly.** If a getting-started guide takes more than five minutes to reach "hello world," it's broken.
- **Light humor where natural, never forced.** A well-placed aside that acknowledges shared frustration ("Yes, you really do need both flags. We wish you didn't.") — not jokes for their own sake.
- **Short paragraphs, scannable headers, generous whitespace.** The reader is scanning. Help them find what they need.
- **Progressive disclosure.** Getting started, then common tasks, then advanced usage, then internals. Don't front-load edge cases.

**Anti-patterns:** "Simply" / "just" / "obviously" (if it were obvious, they wouldn't be reading docs). Jargon without definition on first use. Walls of text before the first code block. Documenting the API without showing how to use it.

### Marketing Copywriter

**Serves:** README introductions, landing pages, release announcements, conference abstracts, social posts.

**Reader:** Someone who hasn't committed yet. They're deciding whether to star, clone, or close the tab. We have about eight seconds.

**Voice:** Technically honest enthusiasm. The energy of a smart colleague saying "you have to try this" — not a press release, not a pitch deck.

**Core traits:**

- **Benefits before features.** Not "supports pluggable middleware" — instead "add authentication in three lines."
- **Technically credible.** This audience detects hype instantly. "Blazingly fast" with no benchmarks is a red flag. "Processes 50k events/sec on a single core" is a reason to keep reading.
- **Honest about scope.** "This is a CLI tool for X. If you need Y, look at Z." Confidently stating what we're *not* builds more trust than pretending to do everything.
- **One core message per artifact.** A README intro has one job. A release announcement has one job. Don't dilute.

**Anti-patterns:** Superlatives without evidence. Disparaging alternatives. Feature laundry lists with no narrative. Corporate voice ("we are pleased to announce...").

### Context Curator

**Serves:** `.handoffs/` documents (committed), `PRIVATE_MEMORY.md` (gitignored), `MEMORY.md` files, session context.

**Reader (public mode):** The next agent or human picking up this work. They need to be effective after reading fewer than 2,000 tokens.

**Reader (private mode):** Future you. Full picture. No filter needed.

**Voice:** No editorial flair. This is information architecture — structured, dense, scannable. Optimized for tokens-to-insight ratio.

**Public mode traits:**

- **Rigid structure.** Current State, Decisions Made, Next Steps, Landmines. Every time. Predictable structure means the reader knows exactly where to look.
- **Token-efficient.** Every sentence earns its place. No throat-clearing, no "as previously discussed."
- **Actionable.** "Next: implement retry logic in `src/client.rs:47`, following the pattern in `src/server.rs:112`" — not "next steps involve further development."
- **Names the landmines.** "The `parse_config` function silently swallows YAML anchor errors — this will bite you if you touch the config loader." This is the highest-value content in a handoff.
- **Self-contained.** A stranger with repo access and this document can start working. No references to context not captured here or findable in the repo.

**Private mode traits:**

- Full candor, including motivations and frustrations.
- Hunches and half-formed ideas worth preserving.
- People dynamics and emotional context.
- No filtering — this never reaches the repository.

## Skills

Six artifact-specific skills, organized by when they fire in a project's lifecycle.

### curating-context

**Trigger:** End of sessions, at decision points, when switching focus areas. The highest-frequency skill.

**Persona:** Context Curator (both modes).

**Produces:**
- `PRIVATE_MEMORY.md` — gitignored, unfiltered
- `.handoffs/YYYY-MM-DD-HHMMSS-<topic>.md` — committed, tone-firewalled, token-budgeted

**Behavior:** Asks "what happened this session that the next agent needs?" and "what happened that only future-me needs?" Writes both outputs. The public handoff gets a completeness check (could a stranger start from this alone?) and a token budget check (target: under 2,000 tokens, enforced by tooling).

**Inherits:** The `/handoff` invocation name, enhancing it with private context capture and quality gates.

### writing-adrs

**Trigger:** After a technical decision is made — often after `brainstorming` converges, or when a decision made implicitly during implementation needs to be captured.

**Persona:** Technical Writer.

**Produces:** `docs/decisions/NNNN-<title>.md` following the [MADR 4.0.0](https://github.com/adr/madr/blob/4.0.0/template/adr-template.md) structure.

**Behavior:** Captures the *why* aggressively. The decision itself is usually obvious from the code; the rationale is what disappears when people leave. Forces explicit trade-off statements: "We gain X. We lose Y. This is acceptable because Z."

### writing-design-docs

**Trigger:** Before or during significant feature work. Often the formalized output of a `brainstorming` session.

**Persona:** Technical Writer.

**Produces:** `docs/designs/YYYY-MM-DD-<topic>.md`.

**Behavior:** Takes exploratory brainstorming output and shapes it into a document a newcomer can read months later and understand what we built, why, and what we considered but rejected. References ADRs for individual decisions rather than duplicating rationale.

### writing-end-user-docs

**Trigger:** When a feature is stable enough to document for users. Can also be invoked proactively for docs-driven development.

**Persona:** Doc Writer.

**Produces:** Content for the documentation website — tutorials, guides, API references. Format depends on site tooling.

**Behavior:** Starts from "what does the user want to accomplish?" not "what did we build?" Structures content as progressive disclosure. Targets a lower readability complexity threshold than internal docs.

### writing-changelogs

**Trigger:** At release time, or incrementally as features land.

**Persona:** Technical Writer for `CHANGELOG.md` entries, Marketing Copywriter for release announcements.

**Produces:**
- `CHANGELOG.md` entry — factual, scannable, focused on what changed and any migration steps
- Release announcement copy — same information reframed as benefits for the broader audience

**Behavior:** Dual-persona output from the same set of changes. The changelog serves existing users upgrading; the announcement serves potential users discovering the project.

### editorial-review

**Trigger:** Before any artifact is committed. The tone firewall skill — the final quality gate.

**Persona:** None. This is the reviewer, not a writer. Operates as a checklist and scoring agent.

**Checks:**
- **Conference-talk test.** Would this be uncomfortable to present at a technical deep-dive?
- **Negative references.** Any people, projects, or products mentioned disparagingly?
- **Assumed context.** Does the document stand alone? Are there references to conversations or knowledge not captured in the repo?
- **Readability score.** Appropriate for the target audience and persona?
- **Completeness.** For handoffs: could a stranger start working? For ADRs: are trade-offs explicit?
- **Tone consistency.** Does it match the selected persona's voice?

**Produces:** Pass/fail with specific callouts. On fail, identifies exact passages and suggests revisions.

## Tooling

The quality gate layer uses **real tools for measurement and agents for judgment**. Agents are unreliable at counting tokens and computing readability scores. Math is for tools; taste is for agents.

### Token Counter

**Implementation:** Hook wrapping `tiktoken-rs` or equivalent.

**Trigger:** Pre-commit on `.handoffs/` files.

**Behavior:** Counts tokens in the document. Handoffs targeting under 2,000 tokens get a hard pass/fail with the exact count. Provides actionable feedback: "This handoff is 3,847 tokens. Target is 2,000. Compress."

### Readability Scorer

**Implementation:** CLI readability tool computing Flesch-Kincaid grade level.

**Trigger:** Pre-commit on `docs/` files.

**Targets:**

| Persona | Target Grade | Rationale |
|---------|-------------|-----------|
| Doc Writer | ≤ 8 | Accessible to broadest developer audience |
| Technical Writer | ≤ 12 | Technical but clear |
| Marketing Copywriter | ≤ 8 | Scannable, punchy |
| Context Curator (public) | No grade — density metric | Optimizes for tokens-to-insight ratio |

These are initial targets. Phase 3 calibrates them against real artifacts produced in Phases 0-2.

### Section Completeness Checker

**Implementation:** Pattern matcher (no agent needed).

**Trigger:** Pre-commit on all doc artifacts.

**Behavior:** Validates that required sections per template are present and substantive (not "TBD" or single-word placeholders).

### Tone Firewall

**Implementation:** Hybrid. Rule-based layer for obvious catches (negative names, profanity, passive-aggressive patterns). Agent-assisted layer for subtlety (sarcasm, damning-with-faint-praise, implied criticism).

**Trigger:** Pre-commit on all committed artifacts; also available as an on-demand check invoked by other skills.

**Behavior:** The rule-based layer runs first (fast, deterministic). If it passes, the agent layer runs a focused review: "Flag any passage that would be uncomfortable to read aloud at a technical conference." Failures include the specific passage and a suggested revision.

## Integration with Existing Skills

These skills augment existing superpowers workflows at natural handoff points.

```
brainstorming
    │
    ├──→ writing-design-docs (formalize the exploration)
    │       │
    │       └──→ writing-adrs (extract individual decisions)
    │
    ▼
writing-plans
    │
    ▼
subagent-driven-development / executing-plans
    │
    ├──→ curating-context (end of session / at decision points)
    │
    ▼
finishing-a-development-branch
    │
    ├──→ writing-changelogs (what changed, why it matters)
    ├──→ writing-end-user-docs (user-facing docs for new features)
    ├──→ curating-context (final handoff for the branch)
    │
    ▼
editorial-review (gate before commit/merge)
```

**Key integration points:**

1. **brainstorming → writing-design-docs → writing-adrs.** Brainstorming produces exploratory output. The design-docs skill reshapes it through the Technical Writer persona. Discrete decisions get extracted into ADRs — one brainstorming session might produce one design doc and several ADRs.

2. **finishing-a-development-branch → writing-changelogs + curating-context.** Before merging, we capture what changed (changelog), update user-facing docs (end-user-docs), and write the handoff (curating-context).

3. **curating-context inherits the `/handoff` name.** The existing handoff skill writes to `.handoffs/`. Context curation enhances this with `PRIVATE_MEMORY.md`, the tone firewall, and token budget enforcement — same invocation, more capability.

4. **editorial-review as a pre-commit gate.** Runs against any committed artifact. Can also run as a git pre-commit hook — manually edited docs still get checked.

## Document Templates

Templates stored at `templates/<artifact-type>.md` define required sections and their purpose. These are structural scaffolding, not prose mad-libs.

### ADR Template (MADR 4.0.0)

```markdown
---
status: {proposed | accepted | deprecated | superseded by NNNN}
date: YYYY-MM-DD
decision-makers: [who was involved in the decision]
consulted: [subject-matter experts consulted]
informed: [who is kept up-to-date]
---

# NNNN: [Short title of solved problem and solution]

## Context and Problem Statement

[Describe the context and problem in 2-3 sentences. Articulate the problem as a question where possible.]

## Decision Drivers

- [Force, concern, or constraint driving this decision]
- [Another driver]

## Considered Options

- [Option 1]
- [Option 2]
- [Option 3]

## Decision Outcome

Chosen option: "[Option N]", because [justification].

### Consequences

- Good, because [positive consequence]
- Bad, because [negative consequence]

### Confirmation

[How we will verify the decision was implemented correctly — review, test, metric, etc.]

## Pros and Cons of the Options

### [Option 1]

[Brief description or pointer to more information]

- Good, because [argument]
- Bad, because [argument]

### [Option 2]

[Brief description or pointer to more information]

- Good, because [argument]
- Bad, because [argument]

## More Information

[Links to related ADRs, design docs, or resources. When/how to revisit this decision.]
```

### Handoff Template

```markdown
# Handoff: [Topic]

**Date:** YYYY-MM-DD
**Branch:** [current branch]
**State:** [Green | Yellow | Red] — can the next person run tests and see green?

## Where things stand
[Current state in 2-3 sentences]

## Decisions made
[Bulleted, with brief rationale]

## What's next
[Prioritized, actionable, with file:line pointers where helpful]

## Landmines
[Things that will bite you if you don't know about them]
```

### Design Doc Template

```markdown
# [Feature/System Name]

**Date:** YYYY-MM-DD
**Status:** [Draft | In Review | Accepted | Implemented]

## Overview
[What we're building and why, in 2-3 sentences]

## Context
[What prompted this work? What constraints exist?]

## Approach
[What we decided to build, and how]

## Alternatives considered
[What we rejected, and why]

## Consequences
[What this approach gains, what it costs, what it defers]

## Related decisions
[Links to ADRs for individual decisions within this design]
```

## Implementation Roadmap

### Phase 0: Plugin Scaffolding + First Persona

**Goal:** A working plugin with one persona, proving the pattern loads.

**Deliverables:**
- Plugin directory structure with `plugin.json`
- Technical Writer persona file
- ADR template

**Validation:** Write ADR-0001 ("Plugin architecture for building-in-the-open") using the persona and template manually.

### Phase 1: Context Curation

**Goal:** Replace the existing `handoff` skill with dual-output context curation.

**Deliverables:**
- `curating-context` skill
- Context Curator persona
- Handoff template
- `PRIVATE_MEMORY.md` convention
- Agent-based tone firewall (no tooling hooks yet)

**Validation:** End this implementation phase with a real handoff written through the new skill. The `.handoffs/` document should be good enough that a fresh agent can pick up Phase 2 cold.

### Phase 2: Decision Capture

**Goal:** ADRs and design docs as first-class workflows.

**Deliverables:**
- `writing-adrs` skill
- `writing-design-docs` skill
- Design doc template
- Integration with `brainstorming` output

**Validation:** Rewrite this plugin's design doc through the skill. Extract ADRs for decisions made during the design phase.

### Phase 3: Tooling Hooks

**Goal:** Replace agent-based measurement with real tools.

**Deliverables:**
- Token counter hook (`tiktoken-rs` or equivalent)
- Readability scorer hook
- Section completeness checker
- Pre-commit hook integration

**Validation:** Run hooks against all artifacts produced in Phases 0-2. Calibrate thresholds with real data.

### Phase 4: External-Facing Content

**Goal:** End-user docs and release communications.

**Deliverables:**
- `writing-end-user-docs` skill
- `writing-changelogs` skill
- Doc Writer persona
- Marketing Copywriter persona

**Validation:** Write the README for the `building-in-the-open` plugin itself — Marketing Copywriter for the introduction, Doc Writer for the usage guide.

### Phase 5: Editorial Review + Polish

**Goal:** Standalone editorial review skill, calibration from real usage.

**Deliverables:**
- `editorial-review` skill
- Calibration examples in each persona drawn from real artifacts, not hypotheticals
- Full integration with `finishing-a-development-branch` and `requesting-code-review`

**Validation:** Full editorial pass on every artifact produced during Phases 0-4.

## Design Decisions

Decisions made during the design of this plugin that warrant their own ADRs:

1. **Personas as a composable voice layer** rather than per-skill voice definitions or standalone agent skills. Gives maximum flexibility — new artifact types select an existing persona without creating new voice definitions.

2. **Tone firewall on the commit path, not the writing path.** Agents draft freely; only repository-bound artifacts get filtered. Private context capture (`PRIVATE_MEMORY.md`) bypasses the firewall by design.

3. **Real tools for measurement, agents for judgment.** Token counts and readability scores use deterministic CLI tools. Tone and subtlety detection use agent-assisted review. Each does what it's good at.

4. **Prompted ADR extraction, not automatic.** When a design doc contains discrete decisions, the skill identifies them and asks whether to create ADRs. Automatic extraction is too noisy; manual extraction loses decisions.

5. **Public handoffs target a 2,000-token budget.** Enforced by tooling with an exact count, not agent estimation. Optimizes for the next agent's context window efficiency.

6. **PRIVATE_MEMORY.md is gitignored; .handoffs/ is committed.** Private memory captures full candor for future-self. Handoffs are public artifacts that go through the same quality gates as any other committed document.
