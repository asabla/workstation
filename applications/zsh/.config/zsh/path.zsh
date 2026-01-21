#!/bin/zsh
# path.zsh - PATH configuration
# Loaded early, no external commands for fast startup

# Ensure unique PATH entries only (no duplicates)
typeset -U path

# Build PATH array (order matters - first entries take precedence)
path=(
    "$HOME/.opencode/bin"
    "$HOME/.local/bin"
    "$HOME/.dotnet/tools"
    "/usr/local/share/dotnet"
    "/usr/local/go/bin"
    "$HOME/.lmstudio/bin"
    "$HOME/Library/pnpm"
    "$HOME/Library/Application Support/reflex/bun/bin"
    $path
)

export PATH

# pnpm home (for package storage, not PATH)
export PNPM_HOME="$HOME/Library/pnpm"

# bun installation path
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
