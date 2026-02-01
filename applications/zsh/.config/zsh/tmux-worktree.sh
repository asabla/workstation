#!/usr/bin/env bash
# tmux-worktree.sh - Manage git worktrees + tmux sessions

set -euo pipefail

die() {
  echo "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

need git
need tmux
need fzf

pane_path="$(tmux display-message -p "#{pane_current_path}")"
repo_root="$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null)" || die "Not in a git repo"

repo_name="$(basename "$repo_root")"
repo_parent="$(cd "$repo_root/.." && pwd)"

branch_to_dir_suffix() {
  # Keep it readable and path-safe.
  # - feature/login -> feature-login
  # - spaces -> -
  echo "$1" | tr '/ ' '--'
}

dir_to_session_name() {
  # Match tmux-sessionizer.sh naming (basename, dots -> underscores).
  basename "$1" | tr . _
}

switch_to_path_session() {
  local path session
  path="$1"
  session="$(dir_to_session_name "$path")"

  if ! tmux has-session -t="$session" 2>/dev/null; then
    tmux new-session -ds "$session" -n code -c "$path"
  fi

  tmux switch-client -t "$session"
}

list_worktrees_for_repo() {
  # Output lines as: <path>\t<branch-or-detached>
  # `git worktree list --porcelain` is the stable, parseable format.
  git -C "$repo_root" worktree list --porcelain |
    awk '
      $1=="worktree" { path=$2; branch=""; detached=0 }
      $1=="branch"   { branch=$2; sub(/^refs\/heads\//, "", branch) }
      $1=="detached" { detached=1 }
      /^$/ {
        if (path != "") {
          if (detached == 1) {
            print path "\t(detached)"
          } else if (branch != "") {
            print path "\t" branch
          } else {
            print path "\t(unknown)"
          }
        }
      }
    '
}

select_base_ref() {
  # Prefer local branches, but include origin/* as bases.
  # Printed as refname:short (e.g. main, origin/main).
  git -C "$repo_root" for-each-ref --format="%(refname:short)" refs/heads refs/remotes/origin |
    awk '!/^(origin\/HEAD)$/' |
    fzf --prompt="Base> "
}

prompt() {
  local label
  label="$1"
  read -r -p "$label" REPLY
  printf '%s' "$REPLY"
}

action_create() {
  local base new_branch suffix wt_path

  base="$(select_base_ref || true)"
  [ -n "${base:-}" ] || exit 0

  new_branch="$(prompt "New branch: ")"
  [ -n "${new_branch:-}" ] || exit 0

  suffix="$(branch_to_dir_suffix "$new_branch")"
  wt_path="$repo_parent/${repo_name}--${suffix}"

  # If base is a remote, this creates a local branch at that commit.
  git -C "$repo_root" worktree add "$wt_path" -b "$new_branch" "$base"
  switch_to_path_session "$wt_path"
}

action_open() {
  local choice wt_path

  choice="$(list_worktrees_for_repo | fzf --prompt="Worktree> " --with-nth=1,2 --delimiter=$'\t' || true)"
  [ -n "${choice:-}" ] || exit 0

  wt_path="$(printf '%s' "$choice" | awk -F'\t' '{print $1}')"
  [ -n "${wt_path:-}" ] || exit 0

  switch_to_path_session "$wt_path"
}

action_remove() {
  local choice wt_path session yn

  choice="$(list_worktrees_for_repo | fzf --prompt="Remove> " --with-nth=1,2 --delimiter=$'\t' || true)"
  [ -n "${choice:-}" ] || exit 0

  wt_path="$(printf '%s' "$choice" | awk -F'\t' '{print $1}')"
  [ -n "${wt_path:-}" ] || exit 0

  # Prevent removing the worktree you're currently in.
  [ "$wt_path" != "$repo_root" ] || die "Refusing to remove the current worktree"

  yn="$(prompt "Remove worktree + kill tmux session? [y/N] ")"
  case "${yn:-}" in
    y|Y)
      git -C "$repo_root" worktree remove -f "$wt_path"
      git -C "$repo_root" worktree prune

      session="$(dir_to_session_name "$wt_path")"
      if tmux has-session -t="$session" 2>/dev/null; then
        tmux kill-session -t "$session"
      fi
      ;;
    *)
      exit 0
      ;;
  esac
}

main() {
  local action

  action="$(printf '%s\n' create open remove | fzf --prompt="Action> " || true)"
  case "${action:-}" in
    create) action_create ;;
    open) action_open ;;
    remove) action_remove ;;
    *) exit 0 ;;
  esac
}

main
