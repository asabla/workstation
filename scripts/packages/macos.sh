#!/bin/sh
# macos.sh - Package installation for macOS using Homebrew
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Homebrew packages
COMMON_PACKAGES="git stow fzf ripgrep fd curl wget"
NVIM_PACKAGES="neovim node"
TMUX_PACKAGES="tmux"
ZSH_PACKAGES="zsh"
VSCODE_PACKAGES="visual-studio-code"

# Homebrew casks (GUI apps)
KARABINER_PACKAGES="karabiner-elements"
COLIMA_PACKAGES="colima docker"
OPENCODE_PACKAGES="opencode"

# Check and install Homebrew
ensure_homebrew() {
  if ! command_exists brew; then
    log_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [ -f "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log_success "Homebrew installed"
  else
    log_success "Homebrew already installed"
  fi
}

# Update Homebrew
update_homebrew() {
  log_step "Updating Homebrew..."
  brew update
  log_success "Homebrew updated"
}

# Install packages using Homebrew
install_packages() {
  packages="$1"
  if [ -z "$packages" ]; then
    return 0
  fi
  
  log_step "Installing packages: $packages"
  for pkg in $packages; do
    if brew list "$pkg" >/dev/null 2>&1; then
      log_info "$pkg already installed"
    else
      log_info "Installing $pkg..."
      brew install "$pkg"
    fi
  done
}

# Install casks (GUI applications)
install_casks() {
  casks="$1"
  if [ -z "$casks" ]; then
    return 0
  fi
  
  log_step "Installing casks: $casks"
  for cask in $casks; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
      log_info "$cask already installed"
    else
      log_info "Installing $cask..."
      brew install --cask "$cask"
    fi
  done
}

# Install common CLI tools
install_common() {
  log_step "Installing common CLI tools..."
  install_packages "$COMMON_PACKAGES"
}

# Install nvim packages
install_nvim() {
  log_step "Installing Neovim and dependencies..."
  install_packages "$NVIM_PACKAGES"
}

# Install tmux packages
install_tmux() {
  log_step "Installing tmux..."
  install_packages "$TMUX_PACKAGES"
}

# Install zsh packages
install_zsh() {
  log_step "Installing zsh..."
  install_packages "$ZSH_PACKAGES"
}

# Install VSCode
install_vscode() {
  log_step "Installing Visual Studio Code..."
  install_casks "$VSCODE_PACKAGES"
}

# Install Karabiner-Elements
install_karabiner() {
  log_step "Installing Karabiner-Elements..."
  install_casks "$KARABINER_PACKAGES"
}

# Install OpenCode
install_opencode() {
  log_step "Installing OpenCode..."
  install_packages "$OPENCODE_PACKAGES"
}

# Install Colima
install_colima() {
  log_step "Installing Colima and Docker CLI..."
  install_packages "$COLIMA_PACKAGES"
}

# Main installation function
# Usage: install_macos_packages "nvim tmux zsh vscode"
install_macos_packages() {
  selected_apps="$1"
  
  ensure_homebrew
  update_homebrew
  install_common
  
  for app in $selected_apps; do
    case "$app" in
      nvim)      install_nvim ;;
      tmux)      install_tmux ;;
      zsh)       install_zsh ;;
      vscode)    install_vscode ;;
      karabiner) install_karabiner ;;
      opencode)  install_opencode ;;
      colima)    install_colima ;;
      *)         log_warn "Unknown application: $app" ;;
    esac
  done
  
  log_success "macOS package installation complete"
}

# If run directly, install all
if [ "${0##*/}" = "macos.sh" ]; then
  install_macos_packages "nvim tmux zsh vscode"
fi
