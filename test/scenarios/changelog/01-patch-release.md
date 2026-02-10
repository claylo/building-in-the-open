---
skill: writing-changelogs
persona: technical-writer
expected_type: changelog
expected_path_pattern: "CHANGELOG.md"
description: Patch release with bug fixes and one small feature.
---

# Scenario: Patch release changelog

## Release context

You are writing the changelog entry for tidy-conf v0.2.1. This is a patch release with two bug fixes and one small feature.

**Changes since v0.2.0:**

1. **Bug fix:** YAML files with anchors (`&anchor` / `*anchor`) were losing the anchor definitions during normalization. The YAML parser now preserves anchor/alias relationships.

2. **Bug fix:** The `--check` flag was returning exit code 0 even when files needed formatting, if the file ended with a trailing newline that would be removed. Fixed the comparison to account for trailing whitespace normalization.

3. **Feature:** Added `--ignore-comments` flag that strips comments during normalization. Useful for generating minimal production configs from well-documented development configs.

**Commit range:** v0.2.0..v0.2.1 (12 commits, 3 authors)

## Expected behavior

The writing-changelogs skill should produce a CHANGELOG.md entry that:
- Follows Keep a Changelog format
- Clearly categorizes changes (Fixed, Added)
- Uses concise, user-focused language
- Mentions the version and date
