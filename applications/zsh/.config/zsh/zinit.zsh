#!/bin/zsh
# zinit.zsh - Plugin manager with turbo mode for fast startup
# Plugins are loaded asynchronously after prompt appears

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# =========================================================================
# Essential plugins (loaded async with turbo mode)
# =========================================================================

# Syntax highlighting and autosuggestions (turbo mode - load after prompt)
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# History substring search
zinit wait lucid for \
    atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
        zsh-users/zsh-history-substring-search

# =========================================================================
# Oh-My-Zsh libraries we actually need (lightweight)
# =========================================================================

zinit wait lucid for \
    OMZL::completion.zsh \
    OMZL::history.zsh \
    OMZL::key-bindings.zsh \
    OMZL::directories.zsh

# =========================================================================
# Oh-My-Zsh plugins - deferred loading
# =========================================================================

# Core plugins (always useful, low overhead when deferred)
zinit wait lucid for \
    OMZP::git \
    OMZP::tmux \
    OMZP::golang

# Docker completions (native from Docker CLI repo, includes compose v2)
zinit ice wait lucid has'docker' as'completion'
zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

# Dotenv - auto-load .env files on cd (user requested to keep this)
zinit ice wait lucid
zinit snippet OMZP::dotenv

# =========================================================================
# Heavy/conditional plugins - load only when tools are present
# =========================================================================

# Azure CLI (only if az command exists)
zinit ice wait"2" lucid has'az'
zinit snippet OMZP::azure

# .NET (only if dotnet command exists)
zinit ice wait"2" lucid has'dotnet'
zinit snippet OMZP::dotnet

# =========================================================================
# History configuration
# =========================================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="yyyy-mm-dd"

setopt EXTENDED_HISTORY       # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_VERIFY            # Show command before executing from history
setopt SHARE_HISTORY          # Share history between sessions

# =========================================================================
# General zsh options
# =========================================================================

DISABLE_AUTO_TITLE="true"
