# alt-z

[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](LICENSE)

A Rust reimplementation of [rupa/z](https://github.com/rupa/z) - a smarter `cd` command that tracks your most used directories and enables quick navigation based on **frecency** (frequency + recency).

This project is based on the original [z](https://github.com/rupa/z) by rupa, reimplemented in Rust for improved performance and extended with additional shell support.

[日本語版 README](README_ja.md)

## Features

- 🎯 **Frecency-based navigation** - Jump to directories based on how frequently and recently you visit them
- ⚡ **Fast Rust implementation** - Blazing fast directory lookups
- 🐚 **Multi-shell support** - Works with Bash, Zsh, and Fish
- 🔍 **Regex pattern matching** - Find directories using flexible patterns
- 🐟 **Fish shell bonus** - Command-not-found fallback (type a directory name as if it were a command!)
- 📊 **Smart ranking** - Automatically learns and prioritizes your workflow

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/ymmtmdk/alt-z.git
cd alt-z

# Build and install (installs to ~/.local by default)
make install

# Or install to a custom location
make install PREFIX=/usr/local
```

### Shell Integration

Add the following to your shell configuration file:

**Bash** (`~/.bashrc`):
```bash
source ~/.local/share/alt-z/az.sh
```

**Zsh** (`~/.zshrc`):
```bash
source ~/.local/share/alt-z/az.sh
```

**Fish** (`~/.config/fish/config.fish`):
```fish
source ~/.local/share/alt-z/az.fish
```

Restart your shell or source the configuration file.

## Usage

### Basic Navigation

```bash
# Jump to a directory containing "project"
az project

# Jump to a directory containing both "work" and "docs"
az work docs

# List all matching directories with scores
az -l project

# Echo the best match without changing directory
az -e project
```

### Advanced Options

```bash
# Sort by rank (frequency) only
az -r project

# Sort by time (recency) only
az -t project

# Manually add a directory
az add /path/to/directory

# Clean up non-existent directories
az clean
```

### Fish Shell Exclusive Feature

Fish shell users get automatic command-not-found fallback:

```fish
$ myproject  # If 'myproject' command doesn't exist, az will try to jump to it
az: jumping to /home/user/projects/myproject
```

## How It Works

1. **Automatic Tracking**: Every time you `cd` to a directory, it's automatically recorded
2. **Frecency Scoring**: Directories are ranked based on:
   - **Frequency**: How often you visit
   - **Recency**: How recently you visited
3. **Smart Matching**: Use regex patterns to find directories
4. **Quick Jump**: Type a few characters and jump to the best match

## Examples

```bash
# After using these directories frequently:
cd ~/projects/work/important-project
cd ~/documents/work/reports
cd ~/downloads

# You can now jump quickly:
az imp        # → ~/projects/work/important-project
az rep        # → ~/documents/work/reports
az down       # → ~/downloads
```

## Requirements

- Rust toolchain (for building)
- Bash, Zsh, or Fish shell

## Building from Source

```bash
# Build release binary
make

# Run tests
make test

# Clean build artifacts
make clean
```

## Testing

The project includes comprehensive test suites for all supported shells:

```bash
# Run all tests
make test

# Run individual shell tests
bash tests/test_az_sh.sh           # Bash/Zsh integration tests
fish tests/test_az_fish.fish       # Fish integration tests

# Test command-not-found fallback (Fish only)
fish tests/test_az_fish_fallback.fish
```

Test coverage includes:
- Directory addition and tracking
- Query functionality (echo mode, cd mode, explicit query)
- Pattern matching and scoring
- Shell integration hooks
- Fish command-not-found fallback

## Benchmarking

Performance benchmarks are available to compare with the original z implementation:

```bash
# Generate test data (1000 entries)
python3 bench/benchmark_gen_data.py 1000

# Run benchmark comparison
python3 bench/run_benchmark.py

# Manual benchmark
bash bench/benchmark_runner.sh new query 1000 /tmp/.z
```

The Rust implementation shows significant performance improvements over the original shell script implementation, especially for large datasets.

## Uninstall

```bash
make uninstall
```

Don't forget to remove the `source` line from your shell configuration.

## Data Storage

Directory data is stored in `~/.z` by default. You can override this by setting the `_Z_DATA` environment variable:

```bash
export _Z_DATA=~/.config/alt-z/data
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

WTFPL (Do What The Fuck You Want To Public License) - see [LICENSE](LICENSE) file for details.

## Acknowledgments

This project is a Rust reimplementation based on the original [z](https://github.com/rupa/z) by [rupa](https://github.com/rupa).

The core algorithm and concept are derived from rupa/z, with the following enhancements:
- Rewritten in Rust for better performance
- Extended shell support (Bash, Zsh, Fish)
- Fish shell command-not-found fallback feature
- Modern build system with Makefile

Also inspired by [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide).

## Author

ymmtmdk
