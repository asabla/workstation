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

# Key bindings are loaded via zinit atload hook on OMZL::key-bindings.zsh
# (see zinit.zsh) to ensure they apply after OMZ resets the keymap

# Start/reuse ssh-agent across shells.
# Prefers an existing agent (macOS launchd / Linux desktop environment) over
# starting a custom one, so UseKeychain and gnome-keyring keep working.
SSH_ENV="$HOME/.ssh/agent.env"

_ssh_agent_alive() {
  ssh-add -l >/dev/null 2>&1
  [ $? -ne 2 ]
}

# 1. Use existing agent from environment (macOS launchd / Linux desktop)
# 2. Fall back to our persisted agent
# 3. Start a new agent as last resort
if ! _ssh_agent_alive; then
  [ -f "$SSH_ENV" ] && . "$SSH_ENV" >/dev/null
  if ! _ssh_agent_alive; then
    (umask 077; ssh-agent -s > "$SSH_ENV")
    . "$SSH_ENV" >/dev/null
  fi
fi

# Add any private keys when the agent is running but has no identities loaded.
ssh-add -l >/dev/null 2>&1
if [ $? -eq 1 ]; then
  for _key in "$HOME"/.ssh/id_*(N) "$HOME"/.ssh/*/id_*(N); do
    [[ "$_key" != *.pub ]] && ssh-add "$_key" >/dev/null 2>&1
  done
  unset _key
fi

# =========================================================================
# Read env variables
# =========================================================================
[ -f ~/.zshenv_secrets ] && source ~/.zshenv_secrets

# =========================================================================
# Starship Prompt (fast, async)
# =========================================================================

eval "$(starship init zsh)"

# =========================================================================
# Profiling output (uncomment to debug)
# =========================================================================

# zprof
