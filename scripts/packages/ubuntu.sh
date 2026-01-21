#!/bin/sh
# ubuntu.sh - Package installation for Ubuntu/Debian using apt
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# APT packages
COMMON_PACKAGES="git stow fzf ripgrep fd-find curl wget build-essential"
NVIM_PACKAGES="nodejs npm"
TMUX_PACKAGES="tmux"
ZSH_PACKAGES="zsh"

# Check if running with sudo available
check_sudo() {
  if ! command_exists sudo; then
    log_error "sudo is required but not installed"
    exit 1
  fi
}

# Update apt cache
update_apt() {
  log_step "Updating apt cache..."
  sudo apt-get update
  log_success "apt cache updated"
}

# Install packages using apt
install_packages() {
  packages="$1"
  if [ -z "$packages" ]; then
    return 0
  fi
  
  log_step "Installing packages: $packages"
  # shellcheck disable=SC2086
  sudo apt-get install -y $packages
}

# Add Neovim PPA for latest version
add_neovim_ppa() {
  if ! grep -q "neovim-ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
    log_step "Adding Neovim PPA..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
  fi
}

# Install Neovim
install_neovim() {
  add_neovim_ppa
  log_step "Installing Neovim..."
  sudo apt-get install -y neovim
}

# Install VSCode
install_vscode() {
  if command_exists code; then
    log_info "VSCode already installed"
    return 0
  fi
  
  log_step "Installing Visual Studio Code..."
  
  # Install dependencies
  sudo apt-get install -y wget gpg apt-transport-https
  
  # Add Microsoft GPG key
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  rm packages.microsoft.gpg
  
  # Add VSCode repository
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  
  # Install
  sudo apt-get update
  sudo apt-get install -y code
  
  log_success "VSCode installed"
}

# Install common CLI tools
install_common() {
  log_step "Installing common CLI tools..."
  install_packages "$COMMON_PACKAGES"
  
  # Create fd symlink (Ubuntu names it fdfind)
  if command_exists fdfind && ! command_exists fd; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  fi
}

# Install nvim packages
install_nvim() {
  log_step "Installing Neovim and dependencies..."
  install_neovim
  install_packages "$NVIM_PACKAGES"
}

# Install tmux packages
install_tmux() {
  log_step "Installing tmux..."
  install_packages "$TMUX_PACKAGES"
}

# Install Starship prompt
install_starship() {
  if command_exists starship; then
    log_info "Starship already installed"
    return 0
  fi
  
  log_step "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  log_success "Starship installed"
}

# Install zsh packages
install_zsh() {
  log_step "Installing zsh..."
  install_packages "$ZSH_PACKAGES"
  install_starship
}

# Main installation function
# Usage: install_ubuntu_packages "nvim tmux zsh vscode"
install_ubuntu_packages() {
  selected_apps="$1"
  
  check_sudo
  update_apt
  install_common
  
  for app in $selected_apps; do
    case "$app" in
      nvim)   install_nvim ;;
      tmux)   install_tmux ;;
      zsh)    install_zsh ;;
      vscode) install_vscode ;;
      *)      log_warn "Unknown application: $app" ;;
    esac
  done
  
  log_success "Ubuntu package installation complete"
}

# If run directly, install all
if [ "${0##*/}" = "ubuntu.sh" ]; then
  install_ubuntu_packages "nvim tmux zsh vscode"
fi
