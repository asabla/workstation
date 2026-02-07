#!/bin/sh
# windows.sh - Package installation for Windows using winget/scoop
# This script is intended to run in PowerShell or Git Bash on Windows
# POSIX-compliant shell script (for Git Bash compatibility)

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Winget packages
COMMON_PACKAGES_WINGET="Git.Git junegunn.fzf BurntSushi.ripgrep.MSVC sharkdp.fd"
NVIM_PACKAGES_WINGET="Neovim.Neovim OpenJS.NodeJS"
VSCODE_PACKAGES_WINGET="Microsoft.VisualStudioCode"

# Note: tmux and zsh are not natively available on Windows
# They should be used through WSL

# Check if winget is available
check_winget() {
  if ! command_exists winget; then
    log_error "winget is not available. Please install it from the Microsoft Store (App Installer)"
    log_info "Alternatively, you can use Windows Package Manager from: https://github.com/microsoft/winget-cli"
    return 1
  fi
  return 0
}

# Install packages using winget
install_winget_packages() {
  packages="$1"
  if [ -z "$packages" ]; then
    return 0
  fi
  
  log_step "Installing packages with winget: $packages"
  for pkg in $packages; do
    log_info "Installing $pkg..."
    winget install --id "$pkg" --accept-source-agreements --accept-package-agreements || {
      # winget returns error if already installed, which is fine
      log_info "$pkg may already be installed or requires manual intervention"
    }
  done
}

# Install common CLI tools
install_common() {
  log_step "Installing common CLI tools..."
  install_winget_packages "$COMMON_PACKAGES_WINGET"
}

# Install nvim packages
install_nvim() {
  log_step "Installing Neovim and dependencies..."
  install_winget_packages "$NVIM_PACKAGES_WINGET"
}

# Install tmux packages (Windows note)
install_tmux() {
  log_warn "tmux is not natively available on Windows"
  log_info "To use tmux, please install WSL (Windows Subsystem for Linux)"
  log_info "Run: wsl --install"
  log_info "Then run this setup script from within WSL"
}

# Install zsh packages (Windows note)
install_zsh() {
  log_warn "zsh is not natively available on Windows"
  log_info "To use zsh, please install WSL (Windows Subsystem for Linux)"
  log_info "Run: wsl --install"
  log_info "Then run this setup script from within WSL"
}

# Install ssh packages
install_ssh() {
  log_info "OpenSSH client is included with modern Windows builds; no additional packages needed for ssh config"
}

# Install VSCode
install_vscode() {
  log_step "Installing Visual Studio Code..."
  install_winget_packages "$VSCODE_PACKAGES_WINGET"
}

# Main installation function
# Usage: install_windows_packages "nvim tmux zsh vscode"
install_windows_packages() {
  selected_apps="$1"
  
  if ! check_winget; then
    log_error "Cannot proceed without winget"
    exit 1
  fi
  
  install_common
  
  for app in $selected_apps; do
    case "$app" in
      nvim)   install_nvim ;;
      tmux)   install_tmux ;;
      zsh)    install_zsh ;;
      ssh)    install_ssh ;;
      vscode) install_vscode ;;
      *)      log_warn "Unknown application: $app" ;;
    esac
  done
  
  log_success "Windows package installation complete"
}

# If run directly, install all
if [ "${0##*/}" = "windows.sh" ]; then
  install_windows_packages "nvim vscode"
fi
