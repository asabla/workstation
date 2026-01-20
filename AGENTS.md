# AGENTS.md - Coding Agent Guidelines

This repository contains dotfiles and scripts for setting up development workstations.
It uses GNU Stow for symlink management on Unix systems.

## Supported Platforms

- **macOS** - Homebrew package manager, GNU Stow
- **Ubuntu/Debian** - apt package manager, GNU Stow
- **Arch Linux** - pacman/yay, GNU Stow
- **Windows** - winget, PowerShell symlinks (no Stow)

## Build/Lint/Test Commands

### Testing Scripts

```sh
# Syntax check all shell scripts (POSIX)
shellcheck scripts/**/*.sh

# Syntax check a single script
shellcheck scripts/install.sh

# Dry-run stow to check for conflicts (doesn't make changes)
stow -d applications -t ~ -n -v <package>

# Test install script help
./scripts/install.sh --help

# List available packages
./scripts/install.sh --list
./scripts/stow/stow.sh list
./scripts/backup/backup.sh list
```

### Running Installation

```sh
# Interactive mode
./scripts/install.sh

# Install specific apps (skip packages if already installed)
./scripts/install.sh --skip-packages tmux zsh

# Force install (removes conflicting files)
./scripts/install.sh --force --skip-packages tmux

# Direct stow operations
./scripts/stow/stow.sh stow nvim tmux zsh
./scripts/stow/stow.sh --force stow tmux
./scripts/stow/stow.sh unstow nvim
```

### Backup Operations

```sh
./scripts/backup/backup.sh backup              # Backup all
./scripts/backup/backup.sh backup tmux zsh     # Backup specific apps
./scripts/backup/backup.sh restore             # Interactive restore
./scripts/backup/backup.sh restore <name> tmux # Restore specific app
```

## Code Style Guidelines

### Shell Scripts (scripts/*.sh)

**Shebang and Compliance:**
- Use `#!/bin/sh` for POSIX-compliant scripts (most scripts)
- Use `#!/usr/bin/env bash` only when bash-specific features are needed
- Add comment: `# POSIX-compliant shell script` after shebang

**File Header Format:**
```sh
#!/bin/sh
# filename.sh - Brief description of purpose
# POSIX-compliant shell script

set -e
```

**Sourcing Libraries:**
```sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/common.sh"
```

**Naming Conventions:**
- Functions: `snake_case` (e.g., `install_packages`, `log_error`)
- Variables: `UPPER_SNAKE_CASE` for constants, `lower_snake_case` for locals
- Files: `kebab-case.sh` or `snake_case.sh`

**Logging:**
Use functions from `scripts/lib/common.sh`:
```sh
log_info "Information message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"      # Outputs to stderr
log_step "Step description"
```

**Error Handling:**
- Use `set -e` at script start
- Check command existence: `command_exists <cmd>` or `command -v <cmd> >/dev/null 2>&1`
- Validate directories exist before operations
- Provide helpful error messages with recovery suggestions

**Conditionals and Loops:**
```sh
# POSIX-compliant conditionals
if [ -f "$file" ]; then
  # ...
fi

# Iterate over space-separated list
for item in $list; do
  # ...
done
```

**Quoting:**
- Always quote variables: `"$variable"`
- Use `$()` for command substitution, not backticks

### Bash Scripts (applications/zsh/.config/zsh/*.sh)

User-facing scripts can use bash features:
```bash
#!/usr/bin/env bash

# Arrays
dirs=(~/code ~/projects)
for dir in "${dirs[@]}"; do
  # ...
done

# String manipulation
${var:-default}
${var/#pattern/replacement}
```

### Lua Files (applications/nvim/)

Neovim configuration uses Lua with lazy.nvim plugin manager.

**Plugin Format:**
```lua
return {
  'author/plugin-name',
  dependencies = { 'dep/plugin' },
  config = function()
    require('plugin').setup({
      -- options
    })
  end,
}
```

### JSON Files (applications/vscode/)

- Use 4-space indentation (VSCode default)
- Include comments where helpful (JSONC format)
- Keep keybindings organized by category

## Directory Structure Conventions

### Adding a New Application

1. Create stow-compatible directory:
   ```
   applications/myapp/.config/myapp/   # For ~/.config/myapp/
   applications/myapp/.myapprc         # For ~/.myapprc
   ```

2. Add package definitions in `scripts/packages/*.sh`

3. (Optional) Create post-install hook: `scripts/post-install/myapp.sh`
   ```sh
   post_install_myapp() {
     # Post-installation steps
   }
   ```

4. Add to `AVAILABLE_APPS` in `scripts/install.sh`

### Stow Directory Layout

Files mirror the home directory structure:
```
applications/tmux/.tmux.conf        → ~/.tmux.conf
applications/nvim/.config/nvim/     → ~/.config/nvim/
applications/zsh/.config/zsh/       → ~/.config/zsh/
```

## Important Patterns

### OS Detection

Use `scripts/lib/detect-os.sh` which sets:
- `$OS` - Specific OS (macos, ubuntu, arch, windows)
- `$OS_FAMILY` - OS family (macos, debian, arch, windows)
- `$ARCH` - CPU architecture

### Conflict Handling

When stowing over existing files:
1. Check for conflicts with `check_conflicts()`
2. Prompt user or use `--force` flag
3. Remove conflicting files before stowing

### Library Loading Guard

Prevent double-sourcing:
```sh
if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  . "$SCRIPT_DIR/../lib/common.sh"
fi
```

## Common Pitfalls

1. **Don't use `cut` with multi-char delimiters** - Use `awk -F'delimiter'` instead
2. **Don't use bash arrays in POSIX scripts** - Use space-separated strings
3. **Don't hardcode paths** - Use `$HOME` or detect dynamically
4. **Always backup before stowing** - Recommend `./scripts/backup/backup.sh backup`
5. **Test on multiple platforms** - Scripts should work on macOS, Ubuntu, and Arch
