# Onboarding Interview Questions

Ask **one question at a time.** Prefer multiple choice when possible.

## Phase 2: Writer and audience

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
> - **Grade 8** — Clear and accessible. Good for user guides and end-user docs.
> - **Grade 10** — Moderate complexity. Good for technical content aimed at a broad technical audience.
> - **Grade 12** — Dense but readable. Good for ADRs and design docs where precision matters.
> - **No limit** — You care about accuracy more than readability scoring.
>
> Does grade [N] sound right, or would you adjust it?

## Phase 3: Standards

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

## Phase 4: Document types

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
