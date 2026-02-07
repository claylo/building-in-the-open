use std::path::Path;
use std::process;

use anyhow::Result;

/// Score readability using Flesch-Kincaid Grade Level.
///
/// Formula: 0.39 * (words/sentences) + 11.8 * (syllables/words) - 15.59
///
/// Lower grade = more readable. Target: ≤ 8 for user docs, ≤ 12 for technical docs.
pub fn check(content: &str, max_grade: Option<f64>, file: &Path) -> Result<()> {
    // Strip markdown formatting for cleaner text analysis
    let text = strip_markdown(content);

    let sentences = count_sentences(&text);
    let words = count_words(&text);
    let syllables = count_syllables(&text);

    if words == 0 || sentences == 0 {
        println!("SKIP: {} has no scorable text", file.display());
        return Ok(());
    }

    let words_per_sentence = words as f64 / sentences as f64;
    let syllables_per_word = syllables as f64 / words as f64;
    let grade = 0.39f64.mul_add(words_per_sentence, 11.8 * syllables_per_word) - 15.59;

    match max_grade {
        Some(max) if grade > max => {
            eprintln!(
                "FAIL: {} scores {grade:.1} (max: {max:.0}). Simplify sentences or reduce jargon.",
                file.display()
            );
            process::exit(1);
        }
        Some(max) => {
            println!("PASS: {} scores {grade:.1} (max: {max:.0})", file.display());
        }
        None => {
            println!("{grade:.1}");
        }
    }

    Ok(())
}

/// Strip markdown syntax for cleaner text analysis.
/// Removes code blocks, inline code, links, images, headers, and emphasis markers.
fn strip_markdown(text: &str) -> String {
    let mut result = String::with_capacity(text.len());
    let mut in_code_block = false;
    let mut in_frontmatter = false;
    let mut line_num = 0;

    for line in text.lines() {
        line_num += 1;

        // Handle YAML frontmatter
        if line.trim() == "---" {
            if line_num == 1 {
                in_frontmatter = true;
                continue;
            } else if in_frontmatter {
                in_frontmatter = false;
                continue;
            }
        }
        if in_frontmatter {
            continue;
        }

        // Handle fenced code blocks
        if line.trim_start().starts_with("```") {
            in_code_block = !in_code_block;
            continue;
        }
        if in_code_block {
            continue;
        }

        // Skip headers (we want to score prose, not section titles)
        if line.trim_start().starts_with('#') {
            continue;
        }

        // Skip table rows
        if line.trim_start().starts_with('|') {
            continue;
        }

        // Skip blockquotes marker but keep text
        let line = line
            .trim_start()
            .strip_prefix('>')
            .map_or(line, |rest| rest.trim_start());

        // Remove inline code
        let line = remove_pattern(line, '`', '`');

        // Remove links but keep text: [text](url) -> text
        let line = remove_markdown_links(&line);

        // Remove emphasis markers
        let line = line.replace("**", "").replace("__", "");
        let line = line.replace(['*', '_'], "");

        if !line.trim().is_empty() {
            result.push_str(line.trim());
            result.push(' ');
        }
    }

    result
}

fn remove_pattern(text: &str, open: char, close: char) -> String {
    let mut result = String::with_capacity(text.len());
    let mut inside = false;

    for c in text.chars() {
        if c == open && !inside {
            inside = true;
        } else if c == close && inside {
            inside = false;
        } else if !inside {
            result.push(c);
        }
    }

    result
}

fn remove_markdown_links(text: &str) -> String {
    let mut result = String::with_capacity(text.len());
    let mut chars = text.chars().peekable();

    while let Some(&c) = chars.peek() {
        chars.next();
        if c == '[' {
            let mut link_text = String::new();
            let mut found_close = false;
            for inner in chars.by_ref() {
                if inner == ']' {
                    found_close = true;
                    break;
                }
                link_text.push(inner);
            }
            if found_close && chars.peek() == Some(&'(') {
                chars.next(); // consume '('
                for inner in chars.by_ref() {
                    if inner == ')' {
                        break;
                    }
                }
            } else if !found_close {
                result.push('[');
            }
            result.push_str(&link_text);
        } else {
            result.push(c);
        }
    }

    result
}

fn count_sentences(text: &str) -> usize {
    text.chars()
        .filter(|c| matches!(c, '.' | '!' | '?' | ':'))
        .count()
        .max(1)
}

fn count_words(text: &str) -> usize {
    text.split_whitespace().count()
}

fn count_syllables(text: &str) -> usize {
    text.split_whitespace().map(count_word_syllables).sum()
}

/// Estimate syllable count for a single word.
/// Uses a simple vowel-group heuristic — not perfect, but good enough
/// for Flesch-Kincaid scoring across a full document.
fn count_word_syllables(word: &str) -> usize {
    let word = word.to_lowercase();
    let word = word.trim_matches(|c: char| !c.is_alphabetic());

    if word.is_empty() {
        return 0;
    }

    if word.len() <= 3 {
        return 1;
    }

    let vowels = b"aeiouy";
    let bytes = word.as_bytes();
    let mut count = 0;
    let mut prev_vowel = false;

    for &b in bytes {
        let is_vowel = vowels.contains(&b);
        if is_vowel && !prev_vowel {
            count += 1;
        }
        prev_vowel = is_vowel;
    }

    // Silent 'e' at end
    if word.ends_with('e') && count > 1 {
        count -= 1;
    }

    count.max(1)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_syllable_counts() {
        assert_eq!(count_word_syllables("the"), 1);
        assert_eq!(count_word_syllables("hello"), 2);
        assert_eq!(count_word_syllables("beautiful"), 3);
        assert_eq!(count_word_syllables("a"), 1);
    }

    #[test]
    fn test_strip_markdown_removes_code_blocks() {
        let input = "Some text.\n```rust\nlet x = 1;\n```\nMore text.";
        let result = strip_markdown(input);
        assert!(!result.contains("let x"));
        assert!(result.contains("Some text"));
        assert!(result.contains("More text"));
    }

    #[test]
    fn test_strip_markdown_removes_frontmatter() {
        let input = "---\nstatus: accepted\ndate: 2026-02-07\n---\n\nSome text.";
        let result = strip_markdown(input);
        assert!(!result.contains("status"));
        assert!(result.contains("Some text"));
    }

    #[test]
    fn test_strip_markdown_removes_headers() {
        let input = "# Header\n\nSome text.\n\n## Subheader\n\nMore text.";
        let result = strip_markdown(input);
        assert!(!result.contains("Header"));
        assert!(result.contains("Some text"));
        assert!(result.contains("More text"));
    }
}
