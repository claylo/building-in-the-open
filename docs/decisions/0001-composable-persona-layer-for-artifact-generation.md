---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0001: Composable persona layer for artifact generation

## Context and Problem Statement

We need AI coding agents to produce professional, consistent documentation artifacts — ADRs, design docs, handoffs, end-user documentation, release announcements — across different contexts and invocation patterns. How should we define and manage the editorial voice for these artifacts?

## Decision Drivers

- Different artifact types serve different audiences and require different voices
- Multiple agents and sub-agents may produce artifacts within the same project, and voice must remain consistent
- Adding new artifact types should not require defining a new voice from scratch
- Persona definitions must be small enough to load into agent context without significant token cost (~300 tokens each)

## Considered Options

- Composable persona layer (standalone voice definitions that skills select)
- Per-skill voice definitions (each skill embeds its own editorial guidelines)
- Standalone agent skills (each persona is a skill you invoke directly)

## Decision Outcome

Chosen option: "Composable persona layer," because it gives maximum flexibility — new artifact types select an existing persona without duplicating voice definitions, and the same persona can serve multiple skills.

### Consequences

- Good, because adding a new skill (e.g., `writing-retrospectives`) requires only selecting an existing persona, not defining voice from scratch
- Good, because voice consistency is enforced structurally — all ADR-producing skills use the same Technical Writer persona file
- Good, because persona files are small reference documents (~300 tokens) that don't bloat agent context
- Bad, because there's an indirection layer — a skill must load a persona file before drafting, adding a step to the workflow
- Bad, because persona definitions must be self-contained enough that an agent without prior context can follow them (no assumed familiarity)

### Confirmation

We confirm this works by writing the first artifacts (this ADR and the plugin design doc) using the Technical Writer persona file directly. If the voice is consistent across both documents without per-document tuning, the composable model holds.

## Pros and Cons of the Options

### Composable persona layer

Personas are standalone reference files. Skills load the appropriate persona when drafting content. One persona can serve many skills.

- Good, because new artifact types compose with existing voices
- Good, because voice consistency is enforced by file identity, not convention
- Good, because personas can evolve independently of skills
- Neutral, because it requires a naming convention and directory structure
- Bad, because agents must load an extra file before writing

### Per-skill voice definitions

Each skill embeds its own editorial guidelines inline in the SKILL.md file.

- Good, because everything needed to produce an artifact is in one file
- Good, because no indirection — the skill knows its own voice
- Bad, because voice definitions get duplicated across skills that share an audience
- Bad, because updating voice guidelines means editing every skill that uses that voice
- Bad, because consistency depends on manual synchronization

### Standalone agent skills

Each persona is a skill that agents invoke directly (e.g., `/technical-writer`), and it handles all artifact types for that voice.

- Good, because the invocation model is simple — one skill per voice
- Bad, because a single skill must know how to produce ADRs, design docs, retrospectives, and anything else in that voice
- Bad, because artifact structure and voice are coupled — changing ADR format means editing every persona skill
- Bad, because the skill grows unboundedly as artifact types are added

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md`
- Persona files: `personas/technical-writer.md`, `personas/context-curator.md` (initial set)
- Future personas (Phase 4): `personas/doc-writer.md`, `personas/marketing-copywriter.md`
