use anyhow::{Context, Result};
use csv::{ReaderBuilder, WriterBuilder};
use fs2::FileExt;
use serde::{Deserialize, Serialize};
use std::fs::{File, OpenOptions};
use std::io::{BufReader, BufWriter};
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Entry {
    pub path: String,
    pub rank: f64,
    pub timestamp: i64,
}

const MAX_SCORE: f64 = 1000.0; // same as Python implementation

pub fn current_timestamp() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards")
        .as_secs() as i64
}

pub fn lock_file(path: &Path, exclusive: bool) -> Result<File> {
    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .open(path)
        .with_context(|| format!("Failed to open {}", path.display()))?;
    if exclusive {
        file.lock_exclusive()?;
    } else {
        file.lock_shared()?;
    }
    Ok(file)
}

pub fn read_data(path: &Path) -> Result<Vec<Entry>> {
    let file = lock_file(path, false)?;
    let mut rdr = ReaderBuilder::new()
        .has_headers(false)
        .delimiter(b'|')
        .from_reader(BufReader::new(&file));
    let mut entries = Vec::new();
    for result in rdr.deserialize() {
        let entry: Entry = result.with_context(|| "Failed to deserialize entry")?;
        entries.push(entry);
    }
    Ok(entries)
}

pub fn write_data(path: &Path, entries: &[Entry]) -> Result<()> {
    let file = lock_file(path, true)?;
    let mut wtr = WriterBuilder::new()
        .has_headers(false)
        .delimiter(b'|')
        .from_writer(BufWriter::new(&file));
    for entry in entries {
        wtr.serialize(entry).with_context(|| "Failed to serialize entry")?;
    }
    wtr.flush()?;
    Ok(())
}

pub fn frecency(rank: f64, ts: i64, now: i64) -> f64 {
    // Simple frecency: rank / (now - ts + 1)
    rank / ((now - ts + 1) as f64)
}

pub fn aging(entries: &mut Vec<Entry>) {
    let total_rank: f64 = entries.iter().map(|e| e.rank).sum();
    if total_rank > MAX_SCORE {
        for entry in entries.iter_mut() {
            entry.rank *= 0.99;
        }
        entries.retain(|e| e.rank >= 1.0);
    }
}

pub fn get_exclude_dirs() -> Vec<String> {
    // Mimic Python EXCLUDE_DIRS env var (colon separated)
    if let Ok(val) = std::env::var("EXCLUDE_DIRS") {
        val.split(':').map(|s| s.to_string()).collect()
    } else {
        Vec::new()
    }
}
