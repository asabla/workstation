#!/bin/sh
# backup.sh - Backup and restore functionality for workstation configurations
# POSIX-compliant shell script

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSTATION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/detect-os.sh"

# Default backup directory
BACKUP_DIR="${WORKSTATION_BACKUP_DIR:-$HOME/.workstation-backups}"

# Applications and their target locations
# Format: app_name:target_path (relative to $HOME)
get_app_targets() {
  cat << 'EOF'
nvim:.config/nvim
tmux:.tmux.conf
zsh:.zshrc
zsh:.config/zsh
zsh:.oh-my-zsh
tmux:.tmux
karabiner:.config/karabiner
EOF
}

# VSCode has OS-specific paths
get_vscode_target() {
  case "$OS" in
    macos)
      echo "Library/Application Support/Code/User"
      ;;
    windows)
      echo "AppData/Roaming/Code/User"
      ;;
    *)
      echo ".config/Code/User"
      ;;
  esac
}

# Create a timestamp for backup naming
get_timestamp() {
  date +%Y%m%d_%H%M%S
}

# List existing backups
list_backups() {
  log_info "Backups in $BACKUP_DIR:"
  printf "\n"
  
  if [ ! -d "$BACKUP_DIR" ]; then
    log_warn "No backup directory found"
    return 0
  fi
  
  # List directories sorted by date (newest first)
  backups=$(ls -1td "$BACKUP_DIR"/*/ 2>/dev/null || true)
  
  if [ -z "$backups" ]; then
    log_warn "No backups found"
    return 0
  fi
  
  idx=1
  echo "$backups" | while read -r backup; do
    backup_name=$(basename "$backup")
    # Extract timestamp from backup name
    timestamp=$(echo "$backup_name" | grep -oE '[0-9]{8}_[0-9]{6}' || echo "unknown")
    
    # Get backup size
    size=$(du -sh "$backup" 2>/dev/null | cut -f1)
    
    # List contents
    contents=$(ls -1 "$backup" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    
    printf "  %d. %s (%s)\n" "$idx" "$backup_name" "$size"
    printf "     Contents: %s\n" "$contents"
    printf "\n"
    idx=$((idx + 1))
  done
}

# Create a backup of current configuration
create_backup() {
  apps="${1:-all}"
  backup_name="${2:-backup_$(get_timestamp)}"
  backup_path="$BACKUP_DIR/$backup_name"
  
  print_section "Creating Backup"
  log_info "Backup location: $backup_path"
  
  # Create backup directory
  if [ -d "$backup_path" ]; then
    log_error "Backup already exists: $backup_path"
    return 1
  fi
  
  mkdir -p "$backup_path"
  
  # Determine which apps to backup
  if [ "$apps" = "all" ]; then
    apps_to_backup="nvim tmux zsh vscode karabiner"
  else
    apps_to_backup="$apps"
  fi
  
  log_info "Backing up: $apps_to_backup"
  printf "\n"
  
  for app in $apps_to_backup; do
    backup_app "$app" "$backup_path"
  done
  
  # Create manifest file
  create_manifest "$backup_path" "$apps_to_backup"
  
  log_success "Backup created: $backup_path"
  printf "\n"
  
  # Show backup size
  size=$(du -sh "$backup_path" | cut -f1)
  log_info "Total backup size: $size"
}

# Backup a single application
backup_app() {
  app="$1"
  backup_path="$2"
  app_backup_dir="$backup_path/$app"
  
  log_step "Backing up $app..."
  
  case "$app" in
    nvim)
      target="$HOME/.config/nvim"
      if [ -d "$target" ] || [ -L "$target" ]; then
        mkdir -p "$app_backup_dir"
        cp -RL "$target" "$app_backup_dir/.config/" 2>/dev/null || {
          # If it's a symlink to our repo, note that
          if [ -L "$target" ]; then
            echo "symlink:$(readlink "$target")" > "$app_backup_dir/symlink_info"
            log_info "  $app is symlinked to $(readlink "$target")"
          else
            log_warn "  Could not backup $target"
          fi
        }
      else
        log_info "  No existing $app config found"
      fi
      ;;
    tmux)
      mkdir -p "$app_backup_dir"
      # Backup .tmux.conf (follow symlinks to get actual content)
      if [ -f "$HOME/.tmux.conf" ] || [ -L "$HOME/.tmux.conf" ]; then
        if [ -L "$HOME/.tmux.conf" ]; then
          # Record symlink target for reference
          echo "symlink:$(readlink "$HOME/.tmux.conf")" > "$app_backup_dir/tmux.conf.symlink_info"
          log_info "  .tmux.conf is symlinked, backing up content"
          # Follow symlink to backup actual content
          cp -L "$HOME/.tmux.conf" "$app_backup_dir/.tmux.conf" 2>/dev/null || true
        else
          cp "$HOME/.tmux.conf" "$app_backup_dir/.tmux.conf"
        fi
      fi
      # Backup .tmux directory (plugins, etc.)
      if [ -d "$HOME/.tmux" ]; then
        cp -R "$HOME/.tmux" "$app_backup_dir/"
      fi
      ;;
    zsh)
      mkdir -p "$app_backup_dir"
      # Backup .zshrc (follow symlinks to get actual content)
      if [ -f "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
        if [ -L "$HOME/.zshrc" ]; then
          # Record symlink target for reference
          echo "symlink:$(readlink "$HOME/.zshrc")" > "$app_backup_dir/zshrc.symlink_info"
          log_info "  .zshrc is symlinked, backing up content"
          # Follow symlink to backup actual content
          cp -L "$HOME/.zshrc" "$app_backup_dir/.zshrc" 2>/dev/null || true
        else
          cp "$HOME/.zshrc" "$app_backup_dir/.zshrc"
        fi
      fi
      # Backup .config/zsh (follow symlinks)
      if [ -d "$HOME/.config/zsh" ]; then
        mkdir -p "$app_backup_dir/.config"
        cp -RL "$HOME/.config/zsh" "$app_backup_dir/.config/" 2>/dev/null || true
      fi
      # Backup oh-my-zsh custom directory (custom themes/plugins)
      if [ -d "$HOME/.oh-my-zsh/custom" ]; then
        mkdir -p "$app_backup_dir/.oh-my-zsh"
        cp -R "$HOME/.oh-my-zsh/custom" "$app_backup_dir/.oh-my-zsh/"
      fi
      ;;
    vscode)
      vscode_target="$HOME/$(get_vscode_target)"
      if [ -d "$vscode_target" ]; then
        mkdir -p "$app_backup_dir"
        # Only backup settings and keybindings, not extensions cache
        [ -f "$vscode_target/settings.json" ] && cp "$vscode_target/settings.json" "$app_backup_dir/"
        [ -f "$vscode_target/keybindings.json" ] && cp "$vscode_target/keybindings.json" "$app_backup_dir/"
        [ -d "$vscode_target/snippets" ] && cp -R "$vscode_target/snippets" "$app_backup_dir/"
        
        # Export extensions list
        if command_exists code; then
          code --list-extensions > "$app_backup_dir/extensions.txt" 2>/dev/null || true
        fi
      else
        log_info "  No existing VSCode config found"
      fi
      ;;
    karabiner)
      target="$HOME/.config/karabiner"
      if [ -d "$target" ] || [ -L "$target" ]; then
        mkdir -p "$app_backup_dir/.config"
        if [ -L "$target" ]; then
          echo "symlink:$(readlink "$target")" > "$app_backup_dir/symlink_info"
          log_info "  karabiner config is symlinked, backing up content"
          cp -RL "$target" "$app_backup_dir/.config/" 2>/dev/null || true
        else
          cp -R "$target" "$app_backup_dir/.config/"
        fi
      else
        log_info "  No existing karabiner config found"
      fi
      ;;
    *)
      log_warn "  Unknown application: $app"
      ;;
  esac
}

# Create a manifest file with backup metadata
create_manifest() {
  backup_path="$1"
  apps="$2"
  manifest="$backup_path/manifest.txt"
  
  cat > "$manifest" << EOF
# Workstation Backup Manifest
# Created: $(date)
# OS: $OS ($OS_FAMILY)
# Architecture: $ARCH
# Hostname: $(hostname)
# User: $(whoami)

Applications backed up:
$apps

EOF
}

# Restore from a backup
restore_backup() {
  backup_name="$1"
  apps="${2:-all}"
  
  # Handle backup selection
  if [ -z "$backup_name" ]; then
    # Interactive selection
    backup_name=$(select_backup)
    if [ -z "$backup_name" ]; then
      log_error "No backup selected"
      return 1
    fi
  fi
  
  # Resolve backup path
  if [ -d "$backup_name" ]; then
    backup_path="$backup_name"
  elif [ -d "$BACKUP_DIR/$backup_name" ]; then
    backup_path="$BACKUP_DIR/$backup_name"
  else
    log_error "Backup not found: $backup_name"
    return 1
  fi
  
  print_section "Restoring Backup"
  log_info "Restoring from: $backup_path"
  
  # Read manifest if available
  if [ -f "$backup_path/manifest.txt" ]; then
    log_info "Backup created on: $(grep 'Created:' "$backup_path/manifest.txt" | cut -d: -f2-)"
  fi
  
  # Determine which apps to restore
  if [ "$apps" = "all" ]; then
    # Restore all apps found in backup
    apps_to_restore=$(ls -1 "$backup_path" | grep -v manifest.txt | tr '\n' ' ')
  else
    apps_to_restore="$apps"
  fi
  
  log_info "Restoring: $apps_to_restore"
  printf "\n"
  
  if ! confirm "This will overwrite existing configurations. Continue?"; then
    log_info "Restore cancelled"
    return 0
  fi
  
  for app in $apps_to_restore; do
    restore_app "$app" "$backup_path"
  done
  
  log_success "Restore complete"
}

# Restore a single application
restore_app() {
  app="$1"
  backup_path="$2"
  app_backup_dir="$backup_path/$app"
  
  if [ ! -d "$app_backup_dir" ]; then
    log_warn "No backup found for $app"
    return 0
  fi
  
  log_step "Restoring $app..."
  
  case "$app" in
    nvim)
      target="$HOME/.config/nvim"
      if [ -d "$app_backup_dir/.config/nvim" ]; then
        # Remove existing (might be symlink)
        rm -rf "$target"
        mkdir -p "$(dirname "$target")"
        cp -R "$app_backup_dir/.config/nvim" "$target"
        log_success "  Restored $target"
      elif [ -f "$app_backup_dir/symlink_info" ]; then
        log_info "  Original was symlinked, skipping restore"
      fi
      ;;
    tmux)
      if [ -f "$app_backup_dir/.tmux.conf" ]; then
        rm -f "$HOME/.tmux.conf"
        cp "$app_backup_dir/.tmux.conf" "$HOME/.tmux.conf"
        log_success "  Restored ~/.tmux.conf"
      fi
      if [ -d "$app_backup_dir/.tmux" ]; then
        rm -rf "$HOME/.tmux"
        cp -R "$app_backup_dir/.tmux" "$HOME/.tmux"
        log_success "  Restored ~/.tmux/"
      fi
      ;;
    zsh)
      if [ -f "$app_backup_dir/.zshrc" ]; then
        rm -f "$HOME/.zshrc"
        cp "$app_backup_dir/.zshrc" "$HOME/.zshrc"
        log_success "  Restored ~/.zshrc"
      fi
      if [ -d "$app_backup_dir/.config/zsh" ]; then
        rm -rf "$HOME/.config/zsh"
        mkdir -p "$HOME/.config"
        cp -R "$app_backup_dir/.config/zsh" "$HOME/.config/"
        log_success "  Restored ~/.config/zsh/"
      fi
      if [ -d "$app_backup_dir/.oh-my-zsh/custom" ]; then
        if [ -d "$HOME/.oh-my-zsh" ]; then
          rm -rf "$HOME/.oh-my-zsh/custom"
          cp -R "$app_backup_dir/.oh-my-zsh/custom" "$HOME/.oh-my-zsh/"
          log_success "  Restored ~/.oh-my-zsh/custom/"
        else
          log_warn "  oh-my-zsh not installed, skipping custom directory"
        fi
      fi
      ;;
    vscode)
      vscode_target="$HOME/$(get_vscode_target)"
      mkdir -p "$vscode_target"
      
      [ -f "$app_backup_dir/settings.json" ] && {
        cp "$app_backup_dir/settings.json" "$vscode_target/"
        log_success "  Restored settings.json"
      }
      [ -f "$app_backup_dir/keybindings.json" ] && {
        cp "$app_backup_dir/keybindings.json" "$vscode_target/"
        log_success "  Restored keybindings.json"
      }
      [ -d "$app_backup_dir/snippets" ] && {
        rm -rf "$vscode_target/snippets"
        cp -R "$app_backup_dir/snippets" "$vscode_target/"
        log_success "  Restored snippets/"
      }
      
      # Offer to install extensions
      if [ -f "$app_backup_dir/extensions.txt" ] && command_exists code; then
        ext_count=$(wc -l < "$app_backup_dir/extensions.txt" | tr -d ' ')
        if confirm "Install $ext_count VSCode extensions from backup?"; then
          while IFS= read -r ext || [ -n "$ext" ]; do
            log_info "  Installing: $ext"
            code --install-extension "$ext" --force 2>/dev/null || true
          done < "$app_backup_dir/extensions.txt"
        fi
      fi
      ;;
    karabiner)
      target="$HOME/.config/karabiner"
      if [ -d "$app_backup_dir/.config/karabiner" ]; then
        rm -rf "$target"
        mkdir -p "$(dirname "$target")"
        cp -R "$app_backup_dir/.config/karabiner" "$target"
        log_success "  Restored $target"
      elif [ -f "$app_backup_dir/symlink_info" ]; then
        log_info "  Original was symlinked, skipping restore"
      fi
      ;;
    *)
      log_warn "  Unknown application: $app"
      ;;
  esac
}

# Interactive backup selection
select_backup() {
  if [ ! -d "$BACKUP_DIR" ]; then
    return 1
  fi
  
  backups=$(ls -1td "$BACKUP_DIR"/*/ 2>/dev/null || true)
  
  if [ -z "$backups" ]; then
    return 1
  fi
  
  printf "\nAvailable backups:\n\n"
  
  idx=1
  echo "$backups" | while read -r backup; do
    backup_name=$(basename "$backup")
    size=$(du -sh "$backup" 2>/dev/null | cut -f1)
    printf "  %d. %s (%s)\n" "$idx" "$backup_name" "$size"
    idx=$((idx + 1))
  done
  
  printf "\n"
  printf "Select backup (1-%d): " "$(echo "$backups" | wc -l | tr -d ' ')"
  read -r choice
  
  if [ -z "$choice" ]; then
    return 1
  fi
  
  selected=$(echo "$backups" | sed -n "${choice}p")
  if [ -n "$selected" ]; then
    basename "$selected"
  fi
}

# Delete a backup
delete_backup() {
  backup_name="$1"
  
  if [ -z "$backup_name" ]; then
    backup_name=$(select_backup)
    if [ -z "$backup_name" ]; then
      log_error "No backup selected"
      return 1
    fi
  fi
  
  backup_path="$BACKUP_DIR/$backup_name"
  
  if [ ! -d "$backup_path" ]; then
    log_error "Backup not found: $backup_name"
    return 1
  fi
  
  if confirm "Delete backup '$backup_name'?"; then
    rm -rf "$backup_path"
    log_success "Deleted: $backup_name"
  else
    log_info "Cancelled"
  fi
}

# Clean old backups, keep N most recent
clean_backups() {
  keep="${1:-5}"
  
  if [ ! -d "$BACKUP_DIR" ]; then
    log_info "No backups to clean"
    return 0
  fi
  
  backup_count=$(ls -1d "$BACKUP_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$backup_count" -le "$keep" ]; then
    log_info "Only $backup_count backups exist, nothing to clean (keeping $keep)"
    return 0
  fi
  
  to_delete=$((backup_count - keep))
  log_info "Found $backup_count backups, will delete $to_delete oldest"
  
  if ! confirm "Delete $to_delete old backups?"; then
    log_info "Cancelled"
    return 0
  fi
  
  # Delete oldest backups
  ls -1td "$BACKUP_DIR"/*/ | tail -n "$to_delete" | while read -r backup; do
    log_info "Deleting: $(basename "$backup")"
    rm -rf "$backup"
  done
  
  log_success "Cleaned $to_delete old backups"
}

# Print usage
print_usage() {
  cat << EOF
Usage: $0 <command> [options]

Commands:
  backup [apps] [name]   Create a backup of current configuration
  restore [name] [apps]  Restore from a backup
  list                   List available backups
  delete [name]          Delete a backup
  clean [keep]           Remove old backups, keep N most recent (default: 5)

Options:
  apps    Space-separated list of apps (nvim, tmux, zsh, vscode, karabiner) or 'all'
  name    Backup name (defaults to timestamp)
  keep    Number of backups to keep when cleaning

Environment:
  WORKSTATION_BACKUP_DIR  Override backup directory (default: ~/.workstation-backups)

Examples:
  $0 backup                      # Backup all apps
  $0 backup nvim tmux            # Backup specific apps
  $0 backup all my_backup        # Backup all with custom name
  $0 restore                     # Interactive restore
  $0 restore my_backup           # Restore specific backup
  $0 restore my_backup nvim      # Restore only nvim from backup
  $0 list                        # List all backups
  $0 clean 3                     # Keep only 3 most recent backups
EOF
}

# Main
main() {
  if [ $# -lt 1 ]; then
    print_usage
    exit 1
  fi
  
  command="$1"
  shift
  
  case "$command" in
    backup)
      # Parse arguments
      apps=""
      name=""
      for arg in "$@"; do
        case "$arg" in
          nvim|tmux|zsh|vscode|karabiner|all)
            apps="$apps $arg"
            ;;
          *)
            name="$arg"
            ;;
        esac
      done
      apps="${apps:-all}"
      create_backup "$(echo "$apps" | tr -s ' ' | sed 's/^ //')" "$name"
      ;;
    restore)
      # First arg is backup name, rest are apps
      backup_name="$1"
      shift 2>/dev/null || true
      apps="$*"
      restore_backup "$backup_name" "$apps"
      ;;
    list)
      list_backups
      ;;
    delete)
      delete_backup "$1"
      ;;
    clean)
      clean_backups "${1:-5}"
      ;;
    -h|--help|help)
      print_usage
      ;;
    *)
      log_error "Unknown command: $command"
      print_usage
      exit 1
      ;;
  esac
}

# Run if executed directly
if [ "${0##*/}" = "backup.sh" ]; then
  main "$@"
fi
