#!/usr/bin/env bash
# tmux-session-switcher.sh - fzf-based session/window/pane switcher
#
# Keybinding: C-g (in tmux popup)
# Displays all sessions, windows, and panes with their running commands
# Format: session: window (pane command)

# Get all panes with their session:window and running command
# Format: display_text:::target_reference
targets=$(tmux list-panes -a -F '#{session_name}: #{window_name} (#{pane_current_command}):::#{session_name}:#{window_index}.#{pane_index}')

if [[ -z "$targets" ]]; then
    echo "No tmux sessions found"
    exit 0
fi

# Use fzf to select, showing only the display text (before :::)
selected=$(echo "$targets" | fzf --delimiter=':::' --with-nth=1 --preview-window=hidden)

if [[ -z "$selected" ]]; then
    exit 0
fi

# Extract the target reference (after :::)
target=$(echo "$selected" | cut -d':::' -f2)

if [[ -n "$target" ]]; then
    tmux switch-client -t "$target"
fi
