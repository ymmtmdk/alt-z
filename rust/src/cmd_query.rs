use anyhow::Result;
use std::env;
use std::path::PathBuf;
use regex::Regex;

use crate::lib::{self, Entry, read_data};

pub fn run(args: Vec<String>) -> Result<()> {
    // Parse flags and patterns
    let mut echo_mode = false;
    let mut list_mode = false;
    let mut rank_sort = false;
    let mut time_sort = false;
    let mut patterns: Vec<String> = Vec::new();

    for arg in args.iter() {
        match arg.as_str() {
            "-e" => echo_mode = true,
            "-l" => list_mode = true,
            "-r" => rank_sort = true,
            "-t" => time_sort = true,
            _ => patterns.push(arg.clone()),
        }
    }

    // Resolve data file path
    let data_path = env::var("_Z_DATA").unwrap_or_else(|_| "~/.z".to_string());
    let data_path = shellexpand::tilde(&data_path).to_string();
    let data_path = PathBuf::from(data_path);

    let entries = read_data(&data_path)?;
    let now = lib::current_timestamp();

    // Filter entries by regex patterns (AND semantics)
    let matches: Vec<&Entry> = entries.iter().filter(|e| {
        for pat in &patterns {
            let re = Regex::new(pat).unwrap_or_else(|_| Regex::new(&regex::escape(pat)).unwrap());
            if !re.is_match(&e.path) {
                return false;
            }
        }
        true
    }).collect();

    if matches.is_empty() {
        std::process::exit(1);
    }

    // Score entries
    let mut scored: Vec<(Entry, f64)> = matches.iter().map(|e| {
        let score = if rank_sort {
            e.rank
        } else if time_sort {
            e.timestamp as f64
        } else {
            lib::frecency(e.rank, e.timestamp, now)
        };
        ((*e).clone(), score)
    }).collect();

    // Sort descending by score
    scored.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());

    if list_mode {
        for (entry, score) in scored.iter() {
            println!("{:>10} {}", *score as i64, entry.path);
        }
    } else {
        let best = &scored[0].0;
        if echo_mode {
            println!("{}", best.path);
        } else {
            // Shell wrapper will handle cd; we just print the path
            println!("{}", best.path);
        }
    }
    Ok(())
}
