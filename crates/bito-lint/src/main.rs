#![allow(missing_docs)]

use std::path::PathBuf;

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};

mod completeness;
mod readability;
mod tokens;

#[derive(Parser)]
#[command(name = "bito-lint", about = "Quality gate tooling for building-in-the-open artifacts")]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Count tokens in a file (approximate, using tiktoken cl100k_base).
    /// For exact Claude token counts, use the Anthropic token counting API.
    Tokens {
        /// File to count tokens in
        file: PathBuf,

        /// Maximum token budget (exit code 1 if exceeded)
        #[arg(long)]
        budget: Option<usize>,
    },

    /// Score readability of a file using Flesch-Kincaid grade level
    Readability {
        /// File to score
        file: PathBuf,

        /// Maximum grade level (exit code 1 if exceeded)
        #[arg(long, value_name = "GRADE")]
        max_grade: Option<f64>,
    },

    /// Check that a markdown file has all required sections filled
    Completeness {
        /// File to check
        file: PathBuf,

        /// Template type: adr, handoff, or design-doc
        #[arg(long, value_name = "TYPE")]
        template: String,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Command::Tokens { file, budget } => {
            let content = std::fs::read_to_string(&file)
                .with_context(|| format!("Failed to read {}", file.display()))?;
            tokens::check(&content, budget, &file)
        }
        Command::Readability {
            file,
            max_grade,
        } => {
            let content = std::fs::read_to_string(&file)
                .with_context(|| format!("Failed to read {}", file.display()))?;
            readability::check(&content, max_grade, &file)
        }
        Command::Completeness { file, template } => {
            let content = std::fs::read_to_string(&file)
                .with_context(|| format!("Failed to read {}", file.display()))?;
            completeness::check(&content, &template, &file)
        }
    }
}
