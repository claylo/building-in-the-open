# Quickstart

Three workflows to try right away. Each produces a real artifact and runs it through quality gates.

## Your first handoff

A handoff captures session state — decisions made, context gathered, work completed — in a format another agent (or future-you) can pick up without the full conversation history.

1. Work on something in your project for a while — write code, make decisions, hit dead ends.

2. Ask Claude to create a handoff:

   ```
   Create a handoff document for what we accomplished in this session.
   ```

   The `curating-context` skill activates the **Context Curator** persona: dense, structured, scannable prose optimized for tokens-to-insight ratio.

3. The skill writes the handoff to `.handoffs/YYYY-MM-DD-HHMMSS-<topic>.md` and runs quality gates:
   - **Token count** must stay under 2,000 tokens (ADR-0005)
   - **Completeness** checks against the handoff template
   - If checks fail, the skill revises before finalizing

4. Verify locally:

   ```sh
   bito-lint tokens .handoffs/2026-02-08-143000-my-session.md --budget 2000
   bito-lint completeness .handoffs/2026-02-08-143000-my-session.md --template handoff
   ```

## Your first ADR

Architecture Decision Records capture the *why* behind technical choices — context that's invisible in code diffs.

1. Make a technical decision during your session. For example: choosing a serialization format, picking a framework, or deciding on an error handling strategy.

2. Ask Claude to document it:

   ```
   Write an ADR for our decision to use TOML for configuration instead of YAML.
   ```

   The `writing-adrs` skill activates the **Technical Writer** persona: rigorous, opinionated, warm. The ADR follows MADR 4.0.0 format with explicit trade-offs.

3. The skill writes the ADR to `docs/decisions/NNNN-<kebab-case-title>.md` and runs:
   - **Completeness** check against the ADR template (title, status, context, decision, consequences)
   - **Readability** check (target: grade level ≤ 12)

4. Verify:

   ```sh
   bito-lint completeness docs/decisions/0001-toml-for-configuration.md --template adr
   bito-lint readability docs/decisions/0001-toml-for-configuration.md --max-grade 12
   ```

## The editorial review pipeline

The full draft-review-commit loop shows how the tone firewall works in practice.

1. **Draft** — Use any writing skill to produce an artifact:

   ```
   Write a design document for our new authentication system.
   ```

2. **Review** — The writing skill's final step triggers `editorial-review`, which runs:
   - Deterministic checks (tokens, readability, completeness via bito-lint)
   - Agent-based review (conference-talk test, negative references, assumed context, tone consistency)

3. **Iterate** — If the review finds issues, the writing skill revises. Deterministic failures are fixed automatically; agent-based issues are flagged for the writer to address.

4. **Commit** — Once editorial review passes, the artifact is ready. The pre-commit hook provides a final safety net:

   ```sh
   git add docs/designs/2026-02-08-authentication-system.md
   git commit -m "docs: add authentication system design document"
   ```

   The hook runs the same deterministic checks that the skill already passed — belt and suspenders.

## Batch quality checks

Run all quality gates across all committed artifacts at once:

```sh
just lint-docs
```

This checks:
- All handoffs: token budget + completeness
- All ADRs: completeness
- All design docs: readability + completeness
