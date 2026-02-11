use std::env;
use std::fs;

use anyhow::{Context, Result};
use serde::Serialize;

#[derive(Serialize)]
struct TokenReport {
    file: String,
    tiktoken: usize,
    claude_local: usize,
    bpe_openai: usize,
}

fn main() -> Result<()> {
    let path = env::args()
        .nth(1)
        .context("Usage: token-compare <file>")?;

    let text = fs::read_to_string(&path)
        .with_context(|| format!("Failed to read {path}"))?;

    let bpe = tiktoken_rs::cl100k_base()
        .context("Failed to load cl100k_base")?;
    let tiktoken_count = bpe.encode_ordinary(&text).len();

    let claude_count = claude_tokenizer::count_tokens(&text)
        .context("Failed to count with claude-tokenizer")?;

    let bpe_openai_count = bpe_openai::cl100k_base().count(&text);

    let report = TokenReport {
        file: path,
        tiktoken: tiktoken_count,
        claude_local: claude_count,
        bpe_openai: bpe_openai_count,
    };

    println!("{}", serde_json::to_string(&report)?);
    Ok(())
}
