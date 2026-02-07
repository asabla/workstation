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

# Start/reuse ssh-agent across shells.
# Persisting agent variables avoids running eval manually each time.
SSH_ENV="$HOME/.ssh/agent.env"

load_ssh_agent() {
  [ -f "$SSH_ENV" ] && . "$SSH_ENV" >/dev/null
}

start_ssh_agent() {
  (umask 077; ssh-agent -s > "$SSH_ENV")
  . "$SSH_ENV" >/dev/null
}

load_ssh_agent
ssh-add -l >/dev/null 2>&1
if [ $? -eq 2 ]; then
  start_ssh_agent
fi

# Add default key when the agent is running but has no identities loaded.
ssh-add -l >/dev/null 2>&1
if [ $? -eq 1 ] && [ -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
fi

# =========================================================================
# Starship Prompt (fast, async)
# =========================================================================

eval "$(starship init zsh)"

# =========================================================================
# Profiling output (uncomment to debug)
# =========================================================================

# zprof

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/asabla/.lmstudio/bin"
# End of LM Studio CLI section
