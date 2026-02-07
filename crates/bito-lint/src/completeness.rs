use std::path::Path;
use std::process;

use anyhow::{Result, bail};

/// Check that a markdown file has all required sections filled.
/// Template types: adr, handoff, design-doc.
pub fn check(content: &str, template: &str, file: &Path) -> Result<()> {
    let required_sections = match template {
        "adr" => vec![
            "Context and Problem Statement",
            "Decision Drivers",
            "Considered Options",
            "Decision Outcome",
            "Consequences",
        ],
        "handoff" => vec![
            "Where things stand",
            "Decisions made",
            "What's next",
            "Landmines",
        ],
        "design-doc" => vec![
            "Overview",
            "Context",
            "Approach",
            "Alternatives considered",
            "Consequences",
        ],
        _ => bail!("Unknown template type: {template}. Use: adr, handoff, design-doc"),
    };

    let mut missing: Vec<&str> = Vec::new();
    let mut empty: Vec<&str> = Vec::new();

    for section in &required_sections {
        match find_section_content(content, section) {
            SectionState::Missing => missing.push(section),
            SectionState::Empty => empty.push(section),
            SectionState::Present => {}
        }
    }

    let has_issues = !missing.is_empty() || !empty.is_empty();

    if has_issues {
        eprintln!("FAIL: {} ({template} completeness check)", file.display());

        for section in &missing {
            eprintln!("  MISSING: ## {section}");
        }
        for section in &empty {
            eprintln!("  EMPTY:   ## {section} (contains only placeholders or whitespace)");
        }

        process::exit(1);
    }

    println!("PASS: {} ({template} completeness check)", file.display());
    Ok(())
}

enum SectionState {
    Missing,
    Empty,
    Present,
}

/// Find a section by heading and check if it has substantive content.
fn find_section_content(content: &str, section_name: &str) -> SectionState {
    let section_lower = section_name.to_lowercase();
    let lines: Vec<&str> = content.lines().collect();

    // Find the heading line
    let heading_idx = lines.iter().position(|line| {
        let trimmed = line.trim().to_lowercase();
        // Match ## Section Name or ### Section Name
        (trimmed.starts_with("## ") || trimmed.starts_with("### "))
            && trimmed.contains(&section_lower)
    });

    let Some(idx) = heading_idx else {
        return SectionState::Missing;
    };

    // Collect content until the next heading of same or higher level
    let heading_level = lines[idx].trim().chars().take_while(|c| *c == '#').count();
    let mut section_text = String::new();

    for line in &lines[idx + 1..] {
        let trimmed = line.trim();
        // Stop at next heading of same or higher level
        if trimmed.starts_with('#') {
            let level = trimmed.chars().take_while(|c| *c == '#').count();
            if level <= heading_level {
                break;
            }
        }
        section_text.push_str(trimmed);
        section_text.push('\n');
    }

    let section_text = section_text.trim();

    // Check for empty or placeholder-only content
    if section_text.is_empty() {
        return SectionState::Empty;
    }

    let placeholder_patterns = ["tbd", "todo", "n/a", "...", "—", "placeholder"];
    let is_placeholder = placeholder_patterns
        .iter()
        .any(|p| section_text.to_lowercase().trim() == *p);

    if is_placeholder {
        return SectionState::Empty;
    }

    // Very short content is suspicious but not a failure
    SectionState::Present
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_complete_handoff() {
        let content = r#"# Handoff: Test

**Date:** 2026-02-07
**Branch:** main
**State:** Green

## Where things stand

Everything works fine.

## Decisions made

- Chose X over Y because Z.

## What's next

1. Do the thing.

## Landmines

- Watch out for the thing.
"#;
        let result = check(content, "handoff", &PathBuf::from("test.md"));
        assert!(result.is_ok());
    }

    #[test]
    fn test_missing_section() {
        let content = r#"# Handoff: Test

## Where things stand

Everything works fine.

## Decisions made

- Chose X.
"#;
        // This will call process::exit, so we test the helper instead
        assert!(matches!(
            find_section_content(content, "Landmines"),
            SectionState::Missing
        ));
    }

    #[test]
    fn test_empty_section() {
        let content = r#"# Handoff: Test

## Where things stand

Everything works fine.

## Landmines

TBD

## What's next

Do stuff.
"#;
        assert!(matches!(
            find_section_content(content, "Landmines"),
            SectionState::Empty
        ));
    }
}
