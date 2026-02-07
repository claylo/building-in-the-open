# Handoff Template

**Persona:** Context Curator (public mode)

**Location:** `.handoffs/YYYY-MM-DD-HHMMSS-<short-kebab-topic>.md`

**Token budget:** Target under 2,000 tokens. Enforced by tooling when available, self-enforced until then.

---

## Template

```markdown
# Handoff: [Topic]

**Date:** YYYY-MM-DD
**Branch:** [current branch]
**State:** [Green | Yellow | Red]

> Green = tests pass, safe to continue. Yellow = tests pass but known issues exist. Red = broken state, read Landmines first.

## Where things stand

[Current state in 2-3 sentences. What works. What doesn't yet.]

## Decisions made

- [Decision, with brief rationale or link to ADR]
- [Another decision]

## What's next

1. [Highest priority next step, with file:line pointers where helpful]
2. [Next step]
3. [Next step]

## Landmines

- [Specific thing that will bite you if you don't know about it]
- [Another one]
```

---

## Guidance

- **Self-contained or it fails.** A stranger with repo access and this document should be able to start working. If you catch yourself writing "as discussed" or "per our conversation," you're referencing context that isn't captured. State it or link to where it's captured.
- **Compress ruthlessly.** Every token the next reader spends parsing this document is a token they're not spending on productive work. If a sentence doesn't help the reader *act*, cut it.
- **Landmines are the highest-value section.** A handoff without landmines is either incomplete or describes a trivially simple project. Think: what will confuse or surprise someone who hasn't been staring at this code?
- **State color honestly.** Yellow is not a failure. Red is not a crisis. They're information. Misrepresenting state wastes the next reader's time when they discover reality doesn't match the document.
- **Link to ADRs for decision rationale.** The handoff captures *that* a decision was made and a one-line rationale. The ADR captures the full reasoning. Don't duplicate.
