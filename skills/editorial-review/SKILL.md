---
name: editorial-review
description: Use before committing any documentation artifact to the repository. The tone firewall skill — coordinates deterministic quality gates (token count, readability, completeness) with agent-based editorial judgment (conference-talk test, tone consistency, assumed context).
---

# Editorial Review

## Overview

The final gate before an artifact reaches the repository. This skill coordinates two layers of quality checking: **deterministic tools** for things agents are bad at (counting tokens, computing readability scores, validating section completeness) and **agent-based review** for things tools can't catch (sarcasm, assumed context, tone drift, the conference-talk test).

This is the tone firewall in practice — the enforcement mechanism behind ADR-0002.

## When to Use

- Before committing any documentation artifact (ADR, handoff, design doc, end-user doc, changelog, release announcement)
- When another skill's final step says "run through editorial review"
- As an on-demand check during drafting, if you want early feedback before the commit path
- When manually-written docs are staged for commit — they need the same quality gate as agent-written docs

## When NOT to Use

- For `PRIVATE_MEMORY.md` — private context bypasses the firewall entirely. That's the point.
- As a writing tool — this skill reviews, it doesn't draft. Use the appropriate writing skill first.

## Quick Reference

| Layer | Tool | What it checks | When it fails |
|-------|------|----------------|---------------|
| Deterministic | `bito-lint tokens` | Token count vs. budget | Handoffs over 2,000 tokens |
| Deterministic | `bito-lint readability` | Flesch-Kincaid grade level | Above persona target (≤8 for Doc Writer, ≤12 for Technical Writer) |
| Deterministic | `bito-lint completeness` | Required sections present and substantive | Missing or placeholder sections |
| Agent-based | `agents/editorial-reviewer.md` | Conference-talk test, negative refs, assumed context, tone consistency | Any passage that would be uncomfortable on stage |

## Process

### Step 1: Identify the artifact

Determine:
- **Artifact type:** adr, handoff, design-doc, end-user-doc, changelog, or release-announcement
- **Target persona:** Which persona voice should the artifact match?
- **File path:** Where the artifact lives

### Step 2: Run deterministic checks

**Dialect:** Check for `BITO_LINT_DIALECT` environment variable or the project's bito-lint config for a dialect preference (en-us, en-gb, en-ca, en-au). If set, pass `--dialect <value>` to `bito-lint analyze` to enforce dialect-consistent spelling. The consistency checker will flag wrong-dialect spellings in addition to mixed usage.

Run the applicable `bito-lint` checks. Not all checks apply to all artifact types.

| Artifact type | Token check | Readability check | Completeness check |
|---------------|-------------|--------------------|--------------------|
| Handoff | Yes (budget: 2000) | No (density metric, not grade) | Yes (template: handoff) |
| ADR | No | Yes (max-grade: 12) | Yes (template: adr) |
| Design doc | No | Yes (max-grade: 12) | Yes (template: design-doc) |
| End-user doc | No | Yes (max-grade: 8) | No (structure varies) |
| Changelog entry | No | No (too short for meaningful score) | No |
| Release announcement | No | Yes (max-grade: 8) | No |

Commands:

```sh
# Token check (handoffs only)
bito-lint tokens <file> --budget 2000

# Readability check
bito-lint readability <file> --max-grade <target>

# Completeness check
bito-lint completeness <file> --template <type>
```

If any deterministic check fails, report the failure. The artifact should be revised before proceeding to agent review — no point checking tone on a document that's missing required sections.

### Step 3: Run agent-based review

Load the editorial reviewer agent template from `agents/editorial-reviewer.md`. Fill the placeholders:

- `{ARTIFACT_CONTENT}` — the full text of the artifact
- `{ARTIFACT_TYPE}` — from Step 1
- `{PERSONA_NAME}` — from Step 1

The agent works through six checks:

1. **Conference-talk test.** Would every sentence be comfortable to say on stage at a technical deep-dive?
2. **Negative references.** Any people, projects, or products mentioned disparagingly? (Factual comparisons are fine.)
3. **Assumed context.** Does the document stand alone? Any "as discussed" without a link?
4. **Tone consistency.** Does the voice match the target persona?
5. **Readability.** Short paragraphs? Scannable headers? Jargon defined?
6. **Completeness (qualitative).** Beyond section presence — is the content substantive?

### Step 4: Report results

Produce a structured review report:

**If all checks pass:**

```markdown
## Editorial Review: [artifact type]

**Overall:** PASS

**Deterministic checks:**
- Tokens: [N/A or PASS (count/budget)]
- Readability: [N/A or PASS (grade/target)]
- Completeness: [N/A or PASS]

**Agent review:** No issues found. The artifact meets professional standards and is ready to commit.
```

**If any checks fail:**

```markdown
## Editorial Review: [artifact type]

**Overall:** FAIL — N issues found

**Deterministic checks:**
- Tokens: [PASS/FAIL with details]
- Readability: [PASS/FAIL with details]
- Completeness: [PASS/FAIL with details]

**Agent review issues:**

### Issue 1: [Category]
**Passage:** "[quoted text]"
**Problem:** [what's wrong]
**Suggested revision:** "[revised text]"

### Notes
[Optional observations that aren't failures but worth considering]
```

### Step 5: Iterate if needed

If the review fails:
1. Report the specific issues to the writing agent or user
2. Let them revise the artifact
3. Re-run only the failed checks (deterministic and/or agent) on the revised version
4. Repeat until PASS

Do not auto-fix agent review issues. The reviewer identifies problems and suggests revisions; the writer decides how to address them. The writer persona may have good reasons to push back on a suggestion.

## Integration

- **Called by:** Every other writing skill as its final step (`curating-context`, `writing-adrs`, `writing-design-docs`, `writing-end-user-docs`, `writing-changelogs`)
- **Also triggered by:** Pre-commit hook (`hooks/pre-commit-docs`) for manually-written or externally-modified docs
- **Depends on:** `bito-lint` CLI (`cargo install bito-lint`) for deterministic checks, `agents/editorial-reviewer.md` for agent-based review
- **Enforces:** ADR-0002 (tone firewall on commit path), ADR-0003 (real tools for measurement, agents for judgment), ADR-0005 (token budget for handoffs)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping deterministic checks and going straight to agent review | Run tools first. Agent review on a document missing required sections wastes an API call and produces noisy feedback. |
| Auto-fixing agent review issues without writer input | The reviewer suggests; the writer decides. Flag the issue and let the writing skill or user choose how to address it. |
| Applying the wrong readability target | Match the target to the persona, not the artifact type. Doc Writer docs target grade ≤ 8; Technical Writer docs target grade ≤ 12. |
| Running editorial review on PRIVATE_MEMORY.md | Never. Private memory is explicitly outside the firewall. If someone asks to review it, decline. |
| Treating "Notes" as failures | Notes are observations, not blockers. A note might say "consider shortening this paragraph" — that's advice, not a gate. |
| Re-running all checks after a minor revision | If only the agent review failed, re-run only the agent review. Deterministic checks are idempotent but unnecessary to repeat if the relevant content didn't change. |
