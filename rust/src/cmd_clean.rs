use anyhow::{Context, Result};
use std::env;
use std::path::PathBuf;

use crate::lib::{self, Entry, read_data, write_data, get_exclude_dirs};

pub fn run(args: Vec<String>) -> Result<()> {
    // args may contain "-x" to remove current directory
    let mut remove_current = false;
    for arg in &args {
        if arg == "-x" {
            remove_current = true;
        }
    }

    // Data file path
    let data_path = env::var("_Z_DATA").unwrap_or_else(|_| "~/.z".to_string());
    let data_path = shellexpand::tilde(&data_path).to_string();
    let data_path = PathBuf::from(data_path);

    let mut entries = read_data(&data_path)?;
    // Remove entries whose paths no longer exist
    entries.retain(|e| PathBuf::from(&e.path).exists());

    // If -x, also remove the current working directory
    if remove_current {
        if let Ok(cwd) = env::current_dir() {
            let cwd_str = cwd.to_string_lossy().to_string();
            entries.retain(|e| e.path != cwd_str);
        }
    }

    write_data(&data_path, &entries)?;
    Ok(())
}
