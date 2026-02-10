---
skill: writing-end-user-docs
persona: doc-writer
expected_type: end-user-doc
expected_path_pattern: "docs/*.md"
description: Getting started guide for a CLI tool.
---

# Scenario: CLI getting started guide

## Documentation context

You are writing the getting started guide for `tidy-conf`, a CLI tool that normalizes configuration files. The tool:

- Reads TOML, YAML, or JSON config files
- Normalizes key ordering, formatting, and comment placement
- Writes the result back (in-place or to stdout)
- Supports `--check` mode for CI (exits non-zero if the file would change)

**Target audience:** Developers who use configuration files in their projects and want consistent formatting. Assumes familiarity with the command line but no specific tool knowledge.

**Installation:**
```sh
cargo install tidy-conf
```

**Basic usage:**
```sh
# Format a config file in place
tidy-conf config.toml

# Check without modifying (for CI)
tidy-conf --check config.toml

# Output to stdout instead of in-place
tidy-conf --stdout config.yaml
```

## Expected behavior

The writing-end-user-docs skill should produce a getting started guide that:
- Scores at or below grade 8 readability (Doc Writer target)
- Starts with a concrete example, not abstract description
- Uses Doc Writer voice (accessible, example-first)
- Includes installation, basic usage, and at least one real-world example
