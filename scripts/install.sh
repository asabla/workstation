#!/bin/sh
# install.sh - Main entry point for workstation setup
# POSIX-compliant shell script with interactive menu

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSTATION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source library files
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/common.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/detect-os.sh"

# Available applications
AVAILABLE_APPS="nvim tmux zsh vscode"

# Selected applications (default: none)
SELECTED_APPS=""

# Flags
SKIP_PACKAGES=false
SKIP_STOW=false
SKIP_POST_INSTALL=false
NON_INTERACTIVE=false
FORCE_INSTALL=false

# Print the banner
print_banner() {
  printf "${BOLD}${CYAN}"
  cat << 'EOF'
 __        __         _        _        _   _             
 \ \      / /__  _ __| | _____| |_ __ _| |_(_) ___  _ __  
  \ \ /\ / / _ \| '__| |/ / __| __/ _` | __| |/ _ \| '_ \ 
   \ V  V / (_) | |  |   <\__ \ || (_| | |_| | (_) | | | |
    \_/\_/ \___/|_|  |_|\_\___/\__\__,_|\__|_|\___/|_| |_|
                                                          
EOF
  printf "${NC}"
  printf "  ${BOLD}Workstation Configuration Setup${NC}\n"
  printf "  Detected OS: ${GREEN}%s${NC} (%s)\n\n" "$OS" "$ARCH"
}

# Print usage
print_usage() {
  cat << EOF
Usage: $0 [options] [applications...]

Options:
  -h, --help          Show this help message
  -a, --all           Install all applications
  -y, --yes           Non-interactive mode (use defaults)
  -f, --force         Force overwrite existing configs (removes conflicts)
  --skip-packages     Skip package installation
  --skip-stow         Skip stow/symlink step
  --skip-post-install Skip post-installation hooks
  --list              List available applications

Applications:
  nvim    Neovim editor
  tmux    Terminal multiplexer
  zsh     Z shell with oh-my-zsh
  vscode  Visual Studio Code

Examples:
  $0                  # Interactive menu
  $0 -a               # Install everything
  $0 nvim tmux        # Install specific apps
  $0 --skip-packages nvim  # Link configs only, skip package install
  $0 --force tmux     # Force install tmux, removing conflicting files
EOF
}

# Check if an app is in the selected list
is_selected() {
  app="$1"
  case " $SELECTED_APPS " in
    *" $app "*) return 0 ;;
    *) return 1 ;;
  esac
}

# Toggle selection of an app
toggle_selection() {
  app="$1"
  if is_selected "$app"; then
    # Remove from selection
    SELECTED_APPS=$(echo "$SELECTED_APPS" | sed "s/ *$app */ /g" | sed 's/^ *//;s/ *$//')
  else
    # Add to selection
    SELECTED_APPS="$SELECTED_APPS $app"
  fi
}

# Display the interactive menu
show_menu() {
  clear
  print_banner
  
  printf "${BOLD}Select applications to configure:${NC}\n\n"
  
  idx=1
  for app in $AVAILABLE_APPS; do
    if is_selected "$app"; then
      marker="${GREEN}[x]${NC}"
    else
      marker="[ ]"
    fi
    
    case "$app" in
      nvim)   desc="Neovim editor" ;;
      tmux)   desc="Terminal multiplexer" ;;
      zsh)    desc="Z shell with oh-my-zsh" ;;
      vscode) desc="Visual Studio Code" ;;
      *)      desc="" ;;
    esac
    
    # Check if app is available on this OS
    available=""
    case "$app" in
      tmux|zsh)
        if [ "$OS_FAMILY" = "windows" ]; then
          available=" ${YELLOW}(WSL only)${NC}"
        fi
        ;;
    esac
    
    printf "  %s %s. %-8s - %s%s\n" "$marker" "$idx" "$app" "$desc" "$available"
    idx=$((idx + 1))
  done
  
  printf "\n"
  printf "  ${BOLD}a${NC}. Select all\n"
  printf "  ${BOLD}n${NC}. Select none\n"
  printf "  ${BOLD}q${NC}. Quit\n"
  printf "  ${BOLD}Enter${NC}. Continue with selection\n"
  printf "\n"
}

# Interactive menu loop
interactive_menu() {
  while true; do
    show_menu
    
    printf "Enter choice (1-%d, a, n, q, or Enter): " "$(echo "$AVAILABLE_APPS" | wc -w | tr -d ' ')"
    read -r choice
    
    case "$choice" in
      "")
        # Enter pressed, continue with selection
        if [ -z "$(echo "$SELECTED_APPS" | tr -d ' ')" ]; then
          log_warn "No applications selected"
          printf "Press Enter to continue..."
          read -r _
        else
          break
        fi
        ;;
      q|Q)
        log_info "Exiting..."
        exit 0
        ;;
      a|A)
        SELECTED_APPS="$AVAILABLE_APPS"
        ;;
      n|N)
        SELECTED_APPS=""
        ;;
      [1-9])
        # Toggle the nth application
        idx=1
        for app in $AVAILABLE_APPS; do
          if [ "$idx" -eq "$choice" ]; then
            toggle_selection "$app"
            break
          fi
          idx=$((idx + 1))
        done
        ;;
      *)
        log_warn "Invalid choice: $choice"
        sleep 1
        ;;
    esac
  done
}

# Install packages for the selected applications
install_packages() {
  if [ "$SKIP_PACKAGES" = true ]; then
    log_info "Skipping package installation (--skip-packages)"
    return 0
  fi
  
  print_section "Installing Packages"
  
  case "$OS" in
    macos)
      # shellcheck disable=SC1091
      . "$SCRIPT_DIR/packages/macos.sh"
      install_macos_packages "$SELECTED_APPS"
      ;;
    ubuntu|debian)
      # shellcheck disable=SC1091
      . "$SCRIPT_DIR/packages/ubuntu.sh"
      install_ubuntu_packages "$SELECTED_APPS"
      ;;
    arch|manjaro|endeavouros)
      # shellcheck disable=SC1091
      . "$SCRIPT_DIR/packages/arch.sh"
      install_arch_packages "$SELECTED_APPS"
      ;;
    windows)
      # shellcheck disable=SC1091
      . "$SCRIPT_DIR/packages/windows.sh"
      install_windows_packages "$SELECTED_APPS"
      ;;
    *)
      log_warn "Unsupported OS for automatic package installation: $OS"
      log_info "Please install packages manually"
      ;;
  esac
}

# Link configuration files using stow or symlinks
link_configs() {
  if [ "$SKIP_STOW" = true ]; then
    log_info "Skipping stow/symlink step (--skip-stow)"
    return 0
  fi
  
  print_section "Linking Configuration Files"
  
  # Filter out vscode from stow apps (needs special handling)
  stow_apps=""
  for app in $SELECTED_APPS; do
    if [ "$app" != "vscode" ]; then
      stow_apps="$stow_apps $app"
    fi
  done
  
  if supports_stow; then
    # Use GNU Stow for Unix systems
    # shellcheck disable=SC1091
    . "$SCRIPT_DIR/stow/stow.sh"
    
    # Pass force flag to stow
    if [ "$FORCE_INSTALL" = true ]; then
      FORCE_STOW=true
    fi
    
    if [ -n "$(echo "$stow_apps" | tr -d ' ')" ]; then
      stow_packages "$stow_apps"
    fi
  else
    # Windows: use PowerShell symlinks
    log_info "Using PowerShell for Windows symlinks"
    log_info "Please run: .\\scripts\\stow\\symlink-windows.ps1 -Command link -Packages $SELECTED_APPS"
  fi
  
  # Handle VSCode separately (always needs custom symlink)
  if is_selected "vscode"; then
    # shellcheck disable=SC1091
    . "$SCRIPT_DIR/post-install/vscode.sh"
    link_vscode_config
  fi
}

# Run post-installation hooks
run_post_install() {
  if [ "$SKIP_POST_INSTALL" = true ]; then
    log_info "Skipping post-installation (--skip-post-install)"
    return 0
  fi
  
  print_section "Running Post-Installation Hooks"
  
  for app in $SELECTED_APPS; do
    post_install_script="$SCRIPT_DIR/post-install/$app.sh"
    
    if [ -f "$post_install_script" ]; then
      log_step "Running post-install for $app..."
      # shellcheck disable=SC1090
      . "$post_install_script"
      
      case "$app" in
        nvim)   post_install_nvim ;;
        tmux)   post_install_tmux ;;
        zsh)    post_install_zsh ;;
        vscode) post_install_vscode ;;
      esac
    else
      log_info "No post-install script for $app"
    fi
  done
}

# Print summary
print_summary() {
  print_section "Summary"
  
  log_success "Workstation setup complete!"
  printf "\n"
  log_info "Configured applications:"
  for app in $SELECTED_APPS; do
    printf "  - %s\n" "$app"
  done
  printf "\n"
  
  # Print any reminders
  if is_selected "zsh"; then
    log_info "Remember to restart your terminal or run: source ~/.zshrc"
  fi
  
  if is_selected "tmux"; then
    log_info "Start tmux and press 'prefix + I' to install plugins"
  fi
  
  if is_selected "nvim"; then
    log_info "Open Neovim to complete plugin installation"
  fi
}

# Main function
main() {
  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        print_usage
        exit 0
        ;;
      -a|--all)
        SELECTED_APPS="$AVAILABLE_APPS"
        NON_INTERACTIVE=true
        ;;
      -y|--yes)
        NON_INTERACTIVE=true
        ;;
      --skip-packages)
        SKIP_PACKAGES=true
        ;;
      --skip-stow)
        SKIP_STOW=true
        ;;
      --skip-post-install)
        SKIP_POST_INSTALL=true
        ;;
      -f|--force)
        FORCE_INSTALL=true
        ;;
      --list)
        printf "Available applications:\n"
        for app in $AVAILABLE_APPS; do
          printf "  - %s\n" "$app"
        done
        exit 0
        ;;
      -*)
        log_error "Unknown option: $1"
        print_usage
        exit 1
        ;;
      *)
        # Assume it's an application name
        if echo "$AVAILABLE_APPS" | grep -qw "$1"; then
          SELECTED_APPS="$SELECTED_APPS $1"
          NON_INTERACTIVE=true
        else
          log_error "Unknown application: $1"
          exit 1
        fi
        ;;
    esac
    shift
  done
  
  # Change to workstation root
  cd "$WORKSTATION_ROOT"
  
  # Verify we're in the right directory
  verify_workstation_dir
  
  # Don't run as root
  check_not_root
  
  # Show banner
  print_banner
  
  # Show OS info
  log_info "Operating System: $OS ($OS_FAMILY)"
  log_info "Architecture: $ARCH"
  printf "\n"
  
  # Interactive menu if no apps specified
  if [ -z "$(echo "$SELECTED_APPS" | tr -d ' ')" ] && [ "$NON_INTERACTIVE" = false ]; then
    interactive_menu
  fi
  
  # Trim whitespace from selected apps
  SELECTED_APPS=$(echo "$SELECTED_APPS" | tr -s ' ' | sed 's/^ *//;s/ *$//')
  
  # Confirm selection
  if [ "$NON_INTERACTIVE" = false ]; then
    printf "\n"
    log_info "Selected applications: $SELECTED_APPS"
    if ! confirm_yes "Proceed with installation?"; then
      log_info "Aborted"
      exit 0
    fi
  else
    log_info "Selected applications: $SELECTED_APPS"
  fi
  
  printf "\n"
  
  # Run installation steps
  install_packages
  link_configs
  run_post_install
  
  # Print summary
  print_summary
}

# Run main
main "$@"
