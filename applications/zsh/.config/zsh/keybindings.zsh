#!/bin/zsh
# keybindings.zsh - Custom key bindings

# =========================================================================
# Edit command line with $EDITOR
# =========================================================================

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line  # Alt+e to edit current command in editor

# =========================================================================
# Tmux sessionizer (Ctrl+F)
# =========================================================================

tmux_sessionizer() {
    "$HOME/.config/zsh/tmux-sessionizer.sh"
}

# Bind Ctrl+F to launch tmux sessionizer
bindkey -s '^f' 'tmux_sessionizer\n'
