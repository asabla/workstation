#!/bin/zsh
# .zshrc - Minimal zsh configuration
# Optimized for fast startup with modular config files
#
# Startup time profiling (uncomment to debug):
# zmodload zsh/zprof

# =========================================================================
# XDG Base Directories
# =========================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# =========================================================================
# Editor Configuration
# =========================================================================

export EDITOR='nvim'
export VISUAL='nvim'

# =========================================================================
# Load Modular Configuration
# =========================================================================

# PATH setup (loaded first, no external deps)
source "$XDG_CONFIG_HOME/zsh/path.zsh"

# Plugin manager (zinit with turbo mode)
source "$XDG_CONFIG_HOME/zsh/zinit.zsh"

# Lazy NVM loading (0ms until first use)
source "$XDG_CONFIG_HOME/zsh/lazy-nvm.zsh"

# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases.zsh"

# Key bindings
source "$XDG_CONFIG_HOME/zsh/keybindings.zsh"

# =========================================================================
# Starship Prompt (fast, async)
# =========================================================================

eval "$(starship init zsh)"

# =========================================================================
# Profiling output (uncomment to debug)
# =========================================================================

# zprof
