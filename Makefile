# Makefile for alt-z

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/alt-z

CARGO = cargo
INSTALL = install
RM = rm -f
MKDIR = mkdir -p

# Build targets
.PHONY: all build release clean install uninstall test help

all: release

# Build in debug mode
build:
	cd rust && $(CARGO) build

# Build in release mode (optimized)
release:
	cd rust && $(CARGO) build --release

# Clean build artifacts
clean:
	cd rust && $(CARGO) clean

# Run tests
test:
	cd rust && $(CARGO) test
	bash tests/test_az_sh.sh
	fish tests/test_az_fish.fish

# Install alt-z
install: release
	@echo "Installing alt-z..."
	$(MKDIR) $(DESTDIR)$(BINDIR)
	$(MKDIR) $(DESTDIR)$(SHAREDIR)
	$(INSTALL) -m 755 rust/target/release/alt-z $(DESTDIR)$(BINDIR)/alt-z
	$(INSTALL) -m 644 shell/az.sh $(DESTDIR)$(SHAREDIR)/az.sh
	$(INSTALL) -m 644 shell/az.fish $(DESTDIR)$(SHAREDIR)/az.fish
	@echo ""
	@echo "=========================================="
	@echo "alt-z has been installed successfully!"
	@echo "=========================================="
	@echo ""
	@echo "To enable shell integration, add the following to your shell configuration:"
	@echo ""
	@echo "  Bash (~/.bashrc):"
	@echo "    source $(SHAREDIR)/az.sh"
	@echo ""
	@echo "  Zsh (~/.zshrc):"
	@echo "    source $(SHAREDIR)/az.sh"
	@echo ""
	@echo "  Fish (~/.config/fish/config.fish):"
	@echo "    source $(SHAREDIR)/az.fish"
	@echo ""
	@echo "After adding the line, restart your shell or run:"
	@echo "  source ~/.bashrc    # for Bash"
	@echo "  source ~/.zshrc     # for Zsh"
	@echo "  source ~/.config/fish/config.fish  # for Fish"
	@echo ""
	@echo "Usage:"
	@echo "  az <keyword>        Jump to a directory matching the keyword"
	@echo "  az -l <keyword>     List all matching directories"
	@echo "  az -e <keyword>     Echo the best match without changing directory"
	@echo ""
	@echo "Fish shell users also get command-not-found fallback:"
	@echo "  Just type a directory name as if it were a command!"
	@echo "=========================================="

# Uninstall alt-z
uninstall:
	@echo "Uninstalling alt-z..."
	$(RM) $(DESTDIR)$(BINDIR)/alt-z
	$(RM) $(DESTDIR)$(SHAREDIR)/az.sh
	$(RM) $(DESTDIR)$(SHAREDIR)/az.fish
	@rmdir $(DESTDIR)$(SHAREDIR) 2>/dev/null || true
	@echo "alt-z has been uninstalled."
	@echo "Don't forget to remove the source line from your shell configuration."

# Show help
help:
	@echo "alt-z Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make              Build release binary (default)"
	@echo "  make build        Build debug binary"
	@echo "  make release      Build release binary (optimized)"
	@echo "  make clean        Remove build artifacts"
	@echo "  make test         Run all tests"
	@echo "  make install      Install alt-z to $(PREFIX)"
	@echo "  make uninstall    Uninstall alt-z"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX            Installation prefix (default: ~/.local)"
	@echo "  DESTDIR           Staging directory for package builds"
	@echo ""
	@echo "Examples:"
	@echo "  make install"
	@echo "  make install PREFIX=/usr/local"
	@echo "  make install PREFIX=/usr"
