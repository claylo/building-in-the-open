# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-08

Initial public release.

### Added

- **6 skills** for artifact generation: curating-context, writing-adrs, writing-design-docs, writing-end-user-docs, writing-changelogs, editorial-review
- **4 writer personas** with distinct voice profiles: Technical Writer, Context Curator, Doc Writer, Marketing Copywriter
- **Editorial reviewer agent** template for tone firewall enforcement (agents/editorial-reviewer.md)
- **3 document templates**: handoff (2,000-token budget), ADR (MADR 4.0.0), design-doc
- **Quality gate integration** with bito-lint CLI for deterministic checks (token counting, readability scoring, completeness validation)
- **Dialect awareness** across all skills — checks `BITO_LINT_DIALECT` env var or project config for en-us, en-gb, en-ca, en-au spelling enforcement
- **Pre-commit hook** (`hooks/pre-commit-docs`) for automated quality checks on staged documentation
- **6 architecture decision records** documenting design choices (ADR-0001 through ADR-0006)
- **Design document** with full plugin architecture specification
- **Justfile recipes** for batch quality checks: `lint-handoffs`, `lint-adrs`, `lint-design-docs`, `lint-docs`
- Plugin metadata (`.claude-plugin/plugin.json`) for Claude Code plugin discovery

[0.1.0]: https://github.com/claylo/building-in-the-open/releases/tag/v0.1.0
