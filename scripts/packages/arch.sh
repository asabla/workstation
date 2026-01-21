#!/bin/sh
# arch.sh - Package installation for Arch Linux using pacman/yay
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Pacman packages
COMMON_PACKAGES="git stow fzf ripgrep fd curl wget base-devel"
NVIM_PACKAGES="neovim nodejs npm"
TMUX_PACKAGES="tmux"
ZSH_PACKAGES="zsh"

# AUR packages (require yay or similar)
AUR_VSCODE="visual-studio-code-bin"

# Check if running with sudo available
check_sudo() {
  if ! command_exists sudo; then
    log_error "sudo is required but not installed"
    exit 1
  fi
}

# Update pacman
update_pacman() {
  log_step "Updating pacman..."
  sudo pacman -Sy
  log_success "pacman updated"
}

# Install packages using pacman
install_packages() {
  packages="$1"
  if [ -z "$packages" ]; then
    return 0
  fi
  
  log_step "Installing packages: $packages"
  # shellcheck disable=SC2086
  sudo pacman -S --needed --noconfirm $packages
}

# Install yay AUR helper if not present
ensure_yay() {
  if command_exists yay; then
    log_info "yay already installed"
    return 0
  fi
  
  log_step "Installing yay AUR helper..."
  
  # Install dependencies
  sudo pacman -S --needed --noconfirm git base-devel
  
  # Clone and build yay
  temp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
  cd "$temp_dir/yay"
  makepkg -si --noconfirm
  cd -
  rm -rf "$temp_dir"
  
  log_success "yay installed"
}

# Install AUR packages using yay
install_aur_packages() {
  packages="$1"
  if [ -z "$packages" ]; then
    return 0
  fi
  
  ensure_yay
  
  log_step "Installing AUR packages: $packages"
  # shellcheck disable=SC2086
  yay -S --needed --noconfirm $packages
}

# Install VSCode from AUR
install_vscode() {
  log_step "Installing Visual Studio Code from AUR..."
  install_aur_packages "$AUR_VSCODE"
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

# Main installation function
# Usage: install_arch_packages "nvim tmux zsh vscode"
install_arch_packages() {
  selected_apps="$1"
  
  check_sudo
  update_pacman
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
  
  log_success "Arch Linux package installation complete"
}

# If run directly, install all
if [ "${0##*/}" = "arch.sh" ]; then
  install_arch_packages "nvim tmux zsh vscode"
fi
