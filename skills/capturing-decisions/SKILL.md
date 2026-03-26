---
name: capturing-decisions
description: Creates and maintains MADR-format Architectural Decision Records with explicit trade-offs, considered alternatives, and consequence analysis. Use when a technical decision has been made, after brainstorming converges on an approach, when writing an ADR or architecture decision record, or when an implicit decision should be captured explicitly.
argument-hint: "[decision-summary]"
allowed-tools: Read, Bash(bito *)
license: MIT
---

# Capturing Decisions

**Announce at start:** "I'm using the capturing-decisions skill with the Technical Writer persona to record this decision."

This skill creates (and keeps tidy) **Architectural Decision Records (ADRs)** using **MADR (Markdown Architectural Decision Records) v4.0.0**.

A helpful bar for what "counts" as an *architectural decision* is Martin Fowler's: **"a decision you wish you could get right early."** (["Who needs an architect?"](https://web.archive.org/web/20231221064723/https://ieeexplore.ieee.org/document/1231144?arnumber=1231144), IEEE Software, 2003)

Primary reference: [Markdown Architectural Decision Records](https://adr.github.io/madr/)

## Existing ADRs

Injected at skill load time — use this to determine the next sequence number.

!`ls ${user_config.doc_output_dir}/decisions/[0-9]*.md 2>/dev/null || ls record/decisions/[0-9]*.md 2>/dev/null || ls docs/decisions/[0-9]*.md 2>/dev/null || echo "(no existing ADRs found)"`

## Repository layout and naming

All ADRs live in:

- `{PROJECT_ROOT}/${user_config.doc_output_dir}/decisions/NNNN-title-with-dashes.md` (defaults to `record/` if not configured)

Where:

- `NNNN` is a **zero-padded 4-digit** sequence number (`0001`, `0002`, ...)
- `title-with-dashes` is a **lowercase slug** (letters/digits/hyphens)

If `{PROJECT_ROOT}/${user_config.doc_output_dir}/decisions/` does not exist yet, create it.

## Template

Use the ADR template from `${CLAUDE_PLUGIN_ROOT}/templates/adr.md`.

Create new ADRs by copying the template and replacing placeholders. Optional sections may be removed (the template marks them clearly).

## Required metadata

Each ADR must include YAML front matter at the top with:

- `status`: one of `proposed`, `accepted`, `rejected`, `deprecated`, or `superseded by ADR-NNNN`
- `date`: `YYYY-MM-DD` (update when the ADR is materially changed)

## Status emoji for the index

Maintain an index at `{PROJECT_ROOT}/${user_config.doc_output_dir}/decisions/README.md` that lists **all** ADRs with:

- status emoji
- ADR title (matching the H1 of the ADR), as a link to the full ADR
- date last updated

Use this mapping:

- proposed
- accepted
- rejected
- deprecated
- superseded

## Process

1. **Pick the next number** by scanning existing ADR filenames in `{PROJECT_ROOT}/${user_config.doc_output_dir}/decisions/` and incrementing the highest `NNNN`. Start at `0001` if none exist.
2. **Slugify the title** into `title-with-dashes` (lowercase, hyphens, no punctuation).
3. **Load the persona.** Load the **Technical Writer** persona from `${CLAUDE_PLUGIN_ROOT}/personas/technical-writer.md`.
4. **Check dialect.** Check for `BITO_DIALECT` environment variable or the project's bito config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, use that dialect's spelling conventions consistently throughout the draft. If not set, default to en-US.
5. **Create the ADR** from `${CLAUDE_PLUGIN_ROOT}/templates/adr.md`.
   - Default `status` to `proposed` unless the change set includes implementation and agreement to accept.
   - Title format: `NNNN: [Problem solved and solution chosen]`. Good: "0007: Pluggable tokenizer backends for handoff budget enforcement." Bad: "0007: Token counting decision."
   - Frame the Context and Problem Statement as a question where possible.
   - Minimum two Considered Options. Three is ideal. Include options you rejected — future readers will ask "why didn't we just...?"
   - At least one "Good, because..." and one "Bad, because..." in Consequences. If you can't name a downside, you haven't thought hard enough about the trade-off.
6. **Update `${user_config.doc_output_dir}/decisions/README.md`**:
   - Add the ADR in numeric order.
   - Ensure the emoji matches the ADR's `status`.
7. **Quality check.** Before saving, verify:
   - Trade-offs are explicit — at least one "Bad, because..." consequence
   - At least two options were considered
   - The title describes both the problem and the solution
   - Links to related ADRs and design docs are included
   - The document stands alone — no assumed context from conversations
8. **Tone firewall.** Run the ADR through the editorial review process (agent or self-check). Ensure it passes the conference-talk test and matches the Technical Writer persona voice.
9. If an ADR is **superseded**, keep the old ADR file, set its status to `superseded by ADR-NNNN`, and update the index row emoji.

## Integration

- **Upstream:** Brainstorming sessions and `writing-design-docs` produce decisions that this skill captures
- **Downstream:** ADRs are referenced by design docs, handoffs, and changelogs
- **Paired with:** `writing-design-docs` — if a design doc contains discrete decisions, they should be extracted into ADRs and referenced from the design doc

## Output expectations

- ADR markdown should be clean and readable in GitHub rendering.
- Keep ADRs concise, but include enough context that a new reader can understand why the decision was made.
- One decision per ADR. If a design involves five decisions, write five ADRs and one design doc that references them.
- Supersede, don't delete. When a decision is reversed, mark the original as `superseded by ADR-NNNN` and write a new ADR explaining what changed.
