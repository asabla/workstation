# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Dotfiles and workstation configuration repo. Uses GNU Stow for symlink management on Unix, PowerShell symlinks on Windows. Supports macOS (Homebrew), Ubuntu/Debian (apt), Arch (pacman/yay), and Windows (winget).

## Commands

```sh
# Lint all shell scripts
shellcheck scripts/**/*.sh

# Dry-run stow (check for conflicts without making changes)
stow -d applications -t ~ -n -v <package>

# Install specific apps
./scripts/install.sh nvim tmux zsh
./scripts/install.sh --skip-packages nvim   # Link configs only
./scripts/install.sh --force tmux           # Force (remove conflicts)
./scripts/install.sh --list                 # List available apps

# Stow operations
./scripts/stow/stow.sh stow nvim tmux zsh
./scripts/stow/stow.sh unstow nvim
./scripts/stow/stow.sh list

# Backup/restore
./scripts/backup/backup.sh backup
./scripts/backup/backup.sh restore <name> tmux
./scripts/backup/backup.sh list
```

## Architecture

**Stow directory layout** — files in `applications/<app>/` mirror the home directory structure:
```
applications/tmux/.tmux.conf        → ~/.tmux.conf
applications/nvim/.config/nvim/     → ~/.config/nvim/
applications/zsh/.config/zsh/       → ~/.config/zsh/
```

**Installation flow**: `scripts/install.sh` → detects OS via `lib/detect-os.sh` → installs packages via `scripts/packages/<os>.sh` → stows configs via `scripts/stow/stow.sh` → runs post-install hooks from `scripts/post-install/<app>.sh`.

**Shared libraries**:
- `scripts/lib/common.sh` — logging (`log_info`, `log_success`, `log_warn`, `log_error`, `log_step`), prompts, `command_exists`
- `scripts/lib/detect-os.sh` — sets `$OS`, `$OS_FAMILY`, `$ARCH`

**Applications**: nvim, tmux, zsh, ssh, vscode, karabiner (macOS), opencode, colima (macOS). Each lives in `applications/<app>/` with optional package definitions in `scripts/packages/*.sh` and post-install hooks in `scripts/post-install/<app>.sh`.

## Code Conventions

- Shell scripts use `#!/bin/sh` (POSIX-compliant) unless bash features are needed (`#!/usr/bin/env bash`)
- Always `set -e` at script start
- Functions: `snake_case`. Constants: `UPPER_SNAKE_CASE`. Files: `kebab-case.sh`
- Always quote variables: `"$variable"`. Use `$()` not backticks
- Don't use `cut` with multi-char delimiters — use `awk -F'delimiter'`
- Don't use bash arrays in POSIX scripts — use space-separated strings
- Source libraries with guard: `if [ -z "$WORKSTATION_LIB_LOADED" ]; then . "$SCRIPT_DIR/../lib/common.sh"; fi`

## Adding a New Application

1. Create stow-compatible directory: `applications/myapp/.config/myapp/`
2. Add package definitions in `scripts/packages/*.sh`
3. (Optional) Create post-install hook: `scripts/post-install/myapp.sh` with `post_install_myapp()` function
4. Add to `AVAILABLE_APPS` in `scripts/install.sh`
