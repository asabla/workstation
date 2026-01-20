#!/bin/sh
# vscode.sh - Post-installation setup for Visual Studio Code
# POSIX-compliant shell script

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/detect-os.sh"

WORKSTATION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VSCODE_CONFIG_DIR="$WORKSTATION_ROOT/applications/vscode"

# Get the VSCode user settings directory based on OS
get_vscode_user_dir() {
  case "$OS" in
    macos)
      echo "$HOME/Library/Application Support/Code/User"
      ;;
    windows)
      echo "$APPDATA/Code/User"
      ;;
    *)
      # Linux and others use XDG config
      echo "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
      ;;
  esac
}

# Link VSCode configuration files
link_vscode_config() {
  log_step "Linking VSCode configuration..."
  
  target_dir="$(get_vscode_user_dir)"
  
  # Create target directory if it doesn't exist
  ensure_dir "$target_dir"
  
  # Link settings.json
  settings_src="$VSCODE_CONFIG_DIR/settings.json"
  settings_dest="$target_dir/settings.json"
  
  if [ -f "$settings_src" ]; then
    safe_symlink "$settings_src" "$settings_dest"
  else
    log_warn "settings.json not found in $VSCODE_CONFIG_DIR"
  fi
  
  # Link keybindings.json
  keybindings_src="$VSCODE_CONFIG_DIR/keybindings.json"
  keybindings_dest="$target_dir/keybindings.json"
  
  if [ -f "$keybindings_src" ]; then
    safe_symlink "$keybindings_src" "$keybindings_dest"
  else
    log_warn "keybindings.json not found in $VSCODE_CONFIG_DIR"
  fi
  
  log_success "VSCode configuration linked"
}

# Unlink VSCode configuration files
unlink_vscode_config() {
  log_step "Unlinking VSCode configuration..."
  
  target_dir="$(get_vscode_user_dir)"
  
  for file in settings.json keybindings.json; do
    target="$target_dir/$file"
    if [ -L "$target" ]; then
      rm "$target"
      log_success "Removed symlink: $target"
    elif [ -f "$target" ]; then
      log_warn "$target is not a symlink, skipping"
    fi
  done
}

# Install VSCode extensions from a list file
install_extensions() {
  extensions_file="$VSCODE_CONFIG_DIR/extensions.txt"
  
  if [ ! -f "$extensions_file" ]; then
    log_info "No extensions.txt found, skipping extension installation"
    return 0
  fi
  
  if ! command_exists code; then
    log_warn "VSCode CLI (code) not found in PATH"
    log_info "On macOS, run: 'Shell Command: Install code command in PATH' from VSCode"
    return 1
  fi
  
  log_step "Installing VSCode extensions..."
  
  while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip empty lines and comments
    case "$extension" in
      ''|\#*) continue ;;
    esac
    
    log_info "Installing extension: $extension"
    code --install-extension "$extension" --force 2>/dev/null || {
      log_warn "Failed to install: $extension"
    }
  done < "$extensions_file"
  
  log_success "VSCode extensions installed"
}

# Export current extensions to extensions.txt
export_extensions() {
  extensions_file="$VSCODE_CONFIG_DIR/extensions.txt"
  
  if ! command_exists code; then
    log_error "VSCode CLI (code) not found in PATH"
    return 1
  fi
  
  log_step "Exporting installed VSCode extensions..."
  
  code --list-extensions > "$extensions_file"
  
  log_success "Extensions exported to $extensions_file"
}

# Print instructions
print_instructions() {
  log_info "VSCode configuration:"
  log_info "  Settings: $(get_vscode_user_dir)/settings.json"
  log_info "  Keybindings: $(get_vscode_user_dir)/keybindings.json"
  log_info ""
  log_info "To export your extensions: $0 export-extensions"
  log_info "To install extensions: $0 install-extensions"
}

# Main post-install function
post_install_vscode() {
  print_section "VSCode Post-Installation"
  
  link_vscode_config
  print_instructions
  
  log_success "VSCode post-installation complete"
}

# Print usage
print_usage() {
  cat << EOF
Usage: $0 [command]

Commands:
  setup             Link VSCode configuration (default)
  unlink            Remove VSCode configuration symlinks
  install-extensions Install extensions from extensions.txt
  export-extensions  Export installed extensions to extensions.txt

EOF
}

# If run directly
if [ "${0##*/}" = "vscode.sh" ]; then
  command="${1:-setup}"
  
  case "$command" in
    setup)
      post_install_vscode
      ;;
    unlink)
      unlink_vscode_config
      ;;
    install-extensions)
      install_extensions
      ;;
    export-extensions)
      export_extensions
      ;;
    *)
      print_usage
      exit 1
      ;;
  esac
fi
