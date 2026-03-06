---
name: onboarding
description: Use when a user installs the building-in-the-open plugin for the first time, wants to configure quality gates for their writing, or asks how to set up bito-lint. Conducts a guided interview to discover writing standards and generates a .bito.yaml config.
---

# Onboarding

**Announce at start:** "I'm using the onboarding skill to set up your writing quality gates."

## Overview

Discover a writer's standards, voice, and document types through a guided interview, then generate a `.bito.yaml` config that enforces those standards automatically. The interview replaces the manual work of reading config docs and guessing at thresholds — you answer questions about how you write, and the config writes itself.

<HARD-GATE>
Do NOT generate the config file until you have completed the interview and the user has approved the draft. Skipping questions leads to wrong thresholds, and wrong thresholds lead to the config being deleted. Get it right.
</HARD-GATE>

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check for existing config, docs, writing samples, CLAUDE.md
2. **Discover writer and audience** — who they are, who reads their output, reading level
3. **Discover standards** — dialect, style conventions, anti-patterns
4. **Discover document types** — what they produce, where it lives, required sections
5. **Present draft config** — show the `.bito.yaml`, iterate until approved
6. **Write config and supporting files** — save to project root, update routing skill if needed

## Process

### Phase 1: Explore project context

Before asking anything, look around:

- Check for existing `.bito.yaml`, `.bito.toml`, `.bito-lint.yaml`
- Check for `CLAUDE.md` or `.claude/` project instructions
- Check for a style guide (look in `docs/`, root, common names like `STYLE.md`, `CONTRIBUTING.md`)
- Read 2–3 existing documentation files if they exist — get a feel for current voice and structure
- Check `docs/decisions/`, `.handoffs/`, `docs/designs/` to see what artifact types are already in use

If existing config or docs exist, use them to pre-fill answers. Don't ask questions you can already answer from the project.

### Phase 2: Discover writer and audience

Ask **one question at a time.** Prefer multiple choice when possible.

**Question 1 — What kind of writing?**

> What kind of writing do you primarily produce with this project?
>
> a) **Technical docs** — ADRs, design docs, internal knowledge (developer audience)
> b) **User guides** — tutorials, how-tos, API references (end-user audience)
> c) **Marketing content** — READMEs, announcements, landing pages
> d) **Mixed** — some combination of the above

**Question 2 — Who reads it?**

> Who's your primary reader?
>
> a) **Developers** — comfortable with code, jargon is fine
> b) **Technical users** — power users who aren't developers
> c) **General audience** — no assumed technical background
> d) **Mixed** — different docs for different readers

**Question 3 — Reading level**

Based on their answers, propose a readability target with context:

> Based on what you've told me, I'd suggest a readability target of **grade [N]**. For reference:
>
> - **Grade 8** — Clear and accessible. What newspapers aim for. Good for user guides and end-user docs.
> - **Grade 10** — Moderate complexity. Good for technical content aimed at a broad technical audience.
> - **Grade 12** — Dense but readable. Good for ADRs and design docs where precision matters.
> - **No limit** — You care about accuracy more than readability scoring.
>
> Does grade [N] sound right, or would you adjust it?

### Phase 3: Discover standards

**Question 4 — Dialect**

> Which English dialect should we enforce for spelling?
>
> a) **American English** (en-us) — color, organize, center
> b) **British English** (en-gb) — colour, organise, centre
> c) **Canadian English** (en-ca) — colour, organize, centre
> d) **Australian English** (en-au) — colour, organise, centre

**Question 5 — Passive voice**

> How strict should we be about passive voice?
>
> a) **Strict** (max 10%) — Almost never. Active voice everywhere.
> b) **Moderate** (max 15%) — Some passive is fine when the actor doesn't matter.
> c) **Relaxed** (max 25%) — Passive voice isn't a problem in your domain.
> d) **Don't check** — You have other ways of handling this.

**Question 6 — Style guide** (if not found in Phase 1)

> Do you have an existing style guide or set of writing conventions? If so, point me to it — I'll read it and extract the rules I can enforce. If not, no worries — we'll build from the answers you've already given.

If they provide a style guide, read it and extract:
- Heading conventions (sentence case vs title case)
- List formatting preferences
- Terminology requirements or bans
- UI text formatting rules
- Any other enforceable patterns

Present what you extracted and confirm: "Here's what I pulled from your style guide — did I miss anything?"

### Phase 4: Discover document types

**Question 7 — What do you produce?**

> What types of documents does this project need? Pick all that apply:
>
> a) **Handoffs** — session context for the next person/agent
> b) **ADRs** — architecture decision records
> c) **Design docs** — narrative context for architectural work
> d) **User guides** — tutorials, how-tos, getting-started
> e) **Changelogs** — release notes for users
> f) **READMEs** — project introduction and onboarding
> g) **Other** — describe what you need

**For each selected type, ask:**

> Where do [type] docs live in your repo? (e.g., `.handoffs/*.md`, `docs/guides/*.md`)

And if applicable:

> Are there required sections for [type] docs? (e.g., every ADR must have Context, Decision, Consequences)

Use built-in templates (`adr`, `handoff`, `design-doc`) where they match. For custom types, build a custom completeness template from their answers.

**Question 8 — Token budgets**

> Do any document types have a length constraint? Handoffs, for example, work well under 2,000 tokens — short enough to load into a fresh session without eating context. Any others?

### Phase 5: Present draft config

Assemble the `.bito.yaml` from all the answers. Present it to the user:

> Here's your draft config. Take a look — I'll explain any field that's unclear.

```yaml
# .bito.yaml — generated by building-in-the-open onboarding

dialect: en-us
max_grade: 10.0
passive_max_percent: 15.0
tokenizer: claude

rules:
  - paths: [".handoffs/*.md"]
    checks:
      tokens: { budget: 2000 }
      completeness: { template: handoff }

  # ... (assembled from their answers)
```

Walk through each section. Ask: "Does this look right? Anything you'd change?"

Iterate until they approve.

### Phase 6: Write config and supporting files

Once approved:

1. **Write `.bito.yaml`** to the project root
2. **If a custom persona was discussed**, write it to `personas/<name>.md`
3. **If style guide rules can't be captured in config**, suggest additions for `CLAUDE.md`:

```markdown
## Writing Standards
- Headings in sentence case
- UI element names in **bold**, not `code`
- No contractions in user-facing documentation
```

4. **Suggest next steps:**
   - "Run `bito-lint doctor` to verify the setup"
   - "Try `bito-lint lint <file>` on an existing doc to see the gates in action"
   - "The pre-commit hook at `hooks/pre-commit-docs` will enforce these on every commit"

## Key Principles

- **One question at a time** — Don't overwhelm. Writers aren't configuring a build system, they're describing how they write.
- **Multiple choice preferred** — Easier to answer, faster to converge.
- **Pre-fill from context** — If you can answer a question from existing files, don't ask it. Tell them what you found and confirm.
- **Explain the "why"** — When suggesting a threshold, say why. "Grade 8 because your readers are non-technical" builds trust. A bare number doesn't.
- **The config is the artifact** — This skill produces a file, not a conversation. The interview is the means, the `.bito.yaml` is the end.
- **Iterate, don't guess** — Wrong thresholds get the config deleted. It's faster to ask one more question than to debug a config that's rejecting good writing.
