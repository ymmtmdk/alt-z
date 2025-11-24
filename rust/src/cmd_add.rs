use anyhow::{Context, Result};
use std::env;
use std::path::PathBuf;
use std::fs;

use crate::lib::{self, Entry, read_data, write_data, aging, get_exclude_dirs};

pub fn run(args: Vec<String>) -> Result<()> {
    // Determine path argument or read from stdin
    let path_opt = if !args.is_empty() {
        Some(args.join(" "))
    } else {
        // read from stdin
        let mut buf = String::new();
        std::io::stdin().read_line(&mut buf).ok();
        let trimmed = buf.trim();
        if trimmed.is_empty() { None } else { Some(trimmed.to_string()) }
    };

    let path_str = match path_opt {
        Some(p) => p,
        None => return Ok(()), // nothing to add
    };

    // Resolve absolute path
    let abs_path = fs::canonicalize(&path_str)
        .with_context(|| format!("Failed to canonicalize path {}", path_str))?;
    let abs_str = abs_path.to_string_lossy().to_string();

    // Exclusions: home, root, EXCLUDE_DIRS env var
    if let Ok(home) = env::var("HOME") {
        if abs_str == home { return Ok(()); }
    }
    if abs_str == "/" { return Ok(()); }
    for excl in get_exclude_dirs() {
        if !excl.is_empty() && abs_str.starts_with(&excl) { return Ok(()); }
    }

    // Data file path
    let data_path = env::var("_Z_DATA").unwrap_or_else(|_| "~/.z".to_string());
    let data_path = shellexpand::tilde(&data_path).to_string();
    let data_path = PathBuf::from(data_path);

    let mut entries = read_data(&data_path)?;
    let now = lib::current_timestamp();
    let mut found = false;
    for entry in entries.iter_mut() {
        if entry.path == abs_str {
            entry.rank += 1.0;
            entry.timestamp = now;
            found = true;
            break;
        }
    }
    if !found {
        entries.push(Entry { path: abs_str.clone(), rank: 1.0, timestamp: now });
    }
    // Aging if needed
    aging(&mut entries);
    write_data(&data_path, &entries)?;
    Ok(())
}
