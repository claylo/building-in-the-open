use std::path::Path;
use std::process;

use anyhow::Result;
use tiktoken_rs::cl100k_base;

/// Count tokens in content using tiktoken cl100k_base tokenizer.
///
/// This is an approximation — Claude uses its own tokenizer. For exact counts,
/// use the Anthropic token counting API (free, rate-limited):
/// https://platform.claude.com/docs/en/build-with-claude/token-counting
pub fn check(content: &str, budget: Option<usize>, file: &Path) -> Result<()> {
    let bpe = cl100k_base()?;
    let token_count = bpe.encode_ordinary(content).len();

    match budget {
        Some(max) if token_count > max => {
            eprintln!(
                "FAIL: {} is {token_count} tokens (budget: {max}). Compress.",
                file.display()
            );
            process::exit(1);
        }
        Some(max) => {
            println!(
                "PASS: {} is {token_count} tokens (budget: {max})",
                file.display()
            );
        }
        None => {
            println!("{token_count}");
        }
    }

    Ok(())
}
