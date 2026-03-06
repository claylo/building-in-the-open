# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-01

Initial public release.

### Added

- **8 skills** for artifact generation: building-in-the-open (routing + setup), onboarding (guided interview → config), curating-context, capturing-decisions, writing-design-docs, writing-end-user-docs, writing-changelogs, editorial-review
- **4 writer personas** with distinct voice profiles: Technical Writer, Context Curator, Doc Writer, Marketing Copywriter
- **Skill announcements** — every skill announces itself and its persona on invocation, so users and agents always know which voice is active
- **Persona composition guide** — documents how to blend personas for multi-voice artifacts (READMEs, release announcements) and when skills chain into each other
- **Superpowers-aware skill loading** — writing-design-docs conditionally loads with-superpowers or without-superpowers workflow based on available skills, avoiding context burn and preventing confusion when superpowers plugin isn't installed
- **Editorial reviewer agent** template for tone firewall enforcement (agents/editorial-reviewer.md)
- **3 document templates**: handoff (2,000-token budget), ADR (MADR 4.0.0 with optional section markers), design-doc
- **Quality gate integration** with bito-lint CLI — path-based rules in `.bito.yaml` drive all checks (token counting, readability scoring, completeness validation, grammar)
- **Dialect awareness** across all skills — checks `BITO_LINT_DIALECT` env var or project config for en-us, en-gb, en-ca, en-au spelling enforcement
- **Plugin hooks** — SessionStart (bito-lint availability check), PostToolUse (real-time quality gates via `bito-lint lint`), UserPromptSubmit (suggests curating-context when `/handoff` appears in messages)
- **Pre-commit hook** (`hooks/pre-commit-docs`) for automated quality checks on staged documentation
- **7 architecture decision records** documenting design choices (ADR-0001 through ADR-0007)
- **Design document** with full plugin architecture specification
- **Path-based lint rules** — `bito-lint lint <file>` runs all matching checks in one pass
- Plugin metadata (`.claude-plugin/plugin.json`) for Claude Code plugin discovery
- Dual license: Apache-2.0 OR MIT

[1.0.0]: https://github.com/claylo/building-in-the-open/releases/tag/v1.0.0
