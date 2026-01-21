#!/bin/sh
# tmux.sh - Post-installation setup for tmux
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Install TPM (Tmux Plugin Manager)
install_tpm() {
  log_step "Installing Tmux Plugin Manager (TPM)..."
  
  if [ -d "$TPM_DIR" ]; then
    log_info "TPM already installed, updating..."
    cd "$TPM_DIR"
    git pull --quiet
    cd - > /dev/null
    log_success "TPM updated"
  else
    log_info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_success "TPM installed"
  fi
}

# Install tmux plugins
install_plugins() {
  log_step "Installing tmux plugins..."
  
  if [ ! -x "$TPM_DIR/bin/install_plugins" ]; then
    log_error "TPM install script not found"
    return 1
  fi
  
  # Run the install_plugins script
  "$TPM_DIR/bin/install_plugins"
  
  log_success "tmux plugins installed"
}

# Update tmux plugins
update_plugins() {
  log_step "Updating tmux plugins..."
  
  if [ -x "$TPM_DIR/bin/update_plugins" ]; then
    "$TPM_DIR/bin/update_plugins" all
    log_success "tmux plugins updated"
  fi
}

# Print usage instructions
print_instructions() {
  log_info "tmux plugin management:"
  log_info "  prefix + I    - Install plugins"
  log_info "  prefix + U    - Update plugins"
  log_info "  prefix + alt+u - Uninstall unused plugins"
  log_info ""
  log_info "Your prefix key is: Ctrl+b (default)"
}

# Main post-install function
post_install_tmux() {
  print_section "tmux Post-Installation"
  
  if ! command_exists tmux; then
    log_error "tmux is not installed"
    return 1
  fi
  
  if ! command_exists git; then
    log_error "git is required for TPM installation"
    return 1
  fi
  
  install_tpm
  install_plugins
  print_instructions
  
  log_success "tmux post-installation complete"
}

# If run directly
if [ "${0##*/}" = "tmux.sh" ]; then
  post_install_tmux
fi
