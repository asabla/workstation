#!/bin/sh
# colima.sh - Post-installation for Colima
# POSIX-compliant shell script

# Only runs on macOS
if [ "$(uname)" != "Darwin" ]; then
  return 0 2>/dev/null || exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/../lib/common.sh"

# Post-installation hook for Colima
post_install_colima() {
  log_step "Configuring Colima..."
  
  # Check if Colima is installed
  if ! command_exists colima; then
    log_warn "Colima not found in PATH"
    log_info "Install it via: brew install colima docker"
    return 0
  fi
  
  # Config location
  config_path="$HOME/.colima/default/colima.yaml"
  
  if [ -f "$config_path" ] || [ -L "$config_path" ]; then
    log_success "Colima config at $config_path"
  else
    log_warn "Colima config not found at $config_path"
    log_info "Config will be created on first 'colima start'"
  fi
  
  # Check if Docker CLI is installed
  if ! command_exists docker; then
    log_warn "Docker CLI not found"
    log_info "Install it via: brew install docker"
  else
    log_success "Docker CLI installed"
  fi
  
  # Check Colima status
  if colima status 2>/dev/null | grep -q "Running"; then
    log_info "Colima is currently running"
  else
    log_info "Colima is not running"
  fi
  
  log_info ""
  log_info "Colima commands:"
  log_info "  colima start       - Start the VM"
  log_info "  colima stop        - Stop the VM"
  log_info "  colima status      - Check status"
  log_info "  colima delete      - Delete the VM (to apply config changes)"
  log_info ""
  log_info "Note: To apply config changes, delete and recreate the VM:"
  log_info "  colima delete && colima start"
}

# If run directly
if [ "${0##*/}" = "colima.sh" ]; then
  post_install_colima
fi
