#!/usr/bin/env bash
# tmux-sessionizer.sh - Workspace finder for tmux sessions
#
# Keybinding: C-f (in tmux popup)
# Finds directories in workspace paths and creates/switches to tmux sessions
#
# Configuration (set in .zshrc or .bashrc):
#   WORKSPACE_DIRS  - Colon-separated list of directories to search
#                     Default: ~/code
#                     Example: export WORKSPACE_DIRS="$HOME/code:$HOME/projects:$HOME/work"
#
#   WORKSPACE_DEPTH - How deep to search for directories (default: 2)
#                     Example: export WORKSPACE_DEPTH=3

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Use WORKSPACE_DIRS if set, otherwise use default
    if [[ -n "$WORKSPACE_DIRS" ]]; then
        IFS=':' read -ra dirs <<< "$WORKSPACE_DIRS"
    else
        dirs=(~/code)
    fi

    # Use WORKSPACE_DEPTH if set, otherwise default to 2
    depth="${WORKSPACE_DEPTH:-3}"

    # Filter to only existing directories
    existing_dirs=()
    for dir in "${dirs[@]}"; do
        expanded_dir="${dir/#\~/$HOME}"
        [[ -d "$expanded_dir" ]] && existing_dirs+=("$expanded_dir")
    done

    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        echo "No workspace directories found."
        echo "Set WORKSPACE_DIRS or create ~/code"
        echo ""
        echo "Example: export WORKSPACE_DIRS=\"\$HOME/code:\$HOME/projects\""
        exit 1
    fi

    selected=$(find "${existing_dirs[@]}" -mindepth 1 -maxdepth "$depth" -type d 2>/dev/null | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -n code -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -n code -c $selected
fi

tmux switch-client -t $selected_name
