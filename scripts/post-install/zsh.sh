#!/bin/sh
# zsh.sh - Post-installation setup for zsh with oh-my-zsh
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

OMZ_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

# Install oh-my-zsh
install_oh_my_zsh() {
  log_step "Installing oh-my-zsh..."
  
  if [ -d "$OMZ_DIR" ]; then
    log_info "oh-my-zsh already installed"
    return 0
  fi
  
  # Download and run the installer in unattended mode
  # --unattended: Don't change the default shell
  # --keep-zshrc: Don't overwrite existing .zshrc
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  
  log_success "oh-my-zsh installed"
}

# Install a zsh plugin from GitHub
install_plugin() {
  repo="$1"
  name="${repo##*/}"
  plugin_dir="$ZSH_CUSTOM/plugins/$name"
  
  if [ -d "$plugin_dir" ]; then
    log_info "Plugin $name already installed, updating..."
    cd "$plugin_dir"
    git pull --quiet
    cd - > /dev/null
  else
    log_info "Installing plugin $name..."
    git clone "https://github.com/$repo" "$plugin_dir"
  fi
}

# Install custom plugins used in the zshrc
install_custom_plugins() {
  log_step "Installing custom zsh plugins..."
  
  # Ensure the plugins directory exists
  mkdir -p "$ZSH_CUSTOM/plugins"
  
  # Install plugins referenced in the .zshrc
  install_plugin "zsh-users/zsh-autosuggestions"
  install_plugin "zsh-users/zsh-syntax-highlighting"
  install_plugin "zsh-users/zsh-completions"
  install_plugin "zsh-users/zsh-history-substring-search"
  
  log_success "Custom plugins installed"
}

# Set zsh as the default shell
set_default_shell() {
  log_step "Setting zsh as default shell..."
  
  current_shell="$(basename "$SHELL")"
  
  if [ "$current_shell" = "zsh" ]; then
    log_info "zsh is already the default shell"
    return 0
  fi
  
  zsh_path="$(which zsh)"
  
  if [ -z "$zsh_path" ]; then
    log_error "zsh not found in PATH"
    return 1
  fi
  
  # Check if zsh is in /etc/shells
  if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
    log_warn "zsh might not be in /etc/shells"
    log_info "You may need to add it: sudo sh -c 'echo $zsh_path >> /etc/shells'"
  fi
  
  if confirm "Change default shell to zsh?"; then
    chsh -s "$zsh_path"
    log_success "Default shell changed to zsh"
    log_info "Please log out and log back in for the change to take effect"
  else
    log_info "Skipping shell change"
  fi
}

# Print usage instructions
print_instructions() {
  log_info "zsh configuration:"
  log_info "  Theme: bira"
  log_info "  Config: ~/.zshrc"
  log_info ""
  log_info "Installed plugins:"
  log_info "  - zsh-autosuggestions"
  log_info "  - zsh-syntax-highlighting"
  log_info "  - zsh-completions"
  log_info "  - zsh-history-substring-search"
  log_info ""
  log_info "To update oh-my-zsh: omz update"
}

# Main post-install function
post_install_zsh() {
  print_section "zsh Post-Installation"
  
  if ! command_exists zsh; then
    log_error "zsh is not installed"
    return 1
  fi
  
  if ! command_exists git; then
    log_error "git is required for oh-my-zsh installation"
    return 1
  fi
  
  if ! command_exists curl; then
    log_error "curl is required for oh-my-zsh installation"
    return 1
  fi
  
  install_oh_my_zsh
  install_custom_plugins
  set_default_shell
  print_instructions
  
  log_success "zsh post-installation complete"
}

# If run directly
if [ "${0##*/}" = "zsh.sh" ]; then
  post_install_zsh
fi
