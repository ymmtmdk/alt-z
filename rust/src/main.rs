#![allow(special_module_name)]

use clap::{Parser, Subcommand};
use anyhow::Result;

mod lib;
mod cmd_add;
mod cmd_query;
mod cmd_clean;

#[derive(Parser)]
#[command(name = "alt-z")]
#[command(author = "")]
#[command(version = "0.1.0")]
#[command(about = "Directory navigation tool")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Add a directory to the database
    Add {
        /// Path to add (optional, reads from stdin if omitted)
        #[arg(value_name = "PATH")]
        path: Option<String>,
    },
    /// Query the database
    Query {
        /// Regex patterns (AND semantics)
        #[arg(value_name = "PATTERN")]
        patterns: Vec<String>,
        /// Echo mode – print the best match without cd
        #[arg(short, long)]
        e: bool,
        /// List mode – list all matches with scores
        #[arg(short, long)]
        l: bool,
        /// Sort by rank only
        #[arg(short, long)]
        r: bool,
        /// Sort by timestamp only
        #[arg(short, long)]
        t: bool,
    },
    /// Clean the database
    Clean {
        /// Remove the current working directory from the database
        #[arg(short, long)]
        x: bool,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::Add { path } => {
            let args = match path { Some(p) => vec![p], None => vec![] };
            cmd_add::run(args)?;
        }
        Commands::Query { patterns, e, l, r, t } => {
            let mut args = Vec::new();
            if e { args.push("-e".to_string()); }
            if l { args.push("-l".to_string()); }
            if r { args.push("-r".to_string()); }
            if t { args.push("-t".to_string()); }
            args.extend(patterns);
            cmd_query::run(args)?;
        }
        Commands::Clean { x } => {
            let mut args = Vec::new();
            if x { args.push("-x".to_string()); }
            cmd_clean::run(args)?;
        }
    }
    Ok(())
}
