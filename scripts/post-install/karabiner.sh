#!/bin/sh
# karabiner.sh - Post-installation for Karabiner-Elements
# POSIX-compliant shell script

# Only runs on macOS
if [ "$(uname)" != "Darwin" ]; then
  return 0 2>/dev/null || exit 0
fi

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Post-installation hook for Karabiner-Elements
post_install_karabiner() {
  log_step "Configuring Karabiner-Elements..."
  
  # Check if Karabiner-Elements is installed
  if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    log_warn "Karabiner-Elements not found in /Applications"
    log_info "Install it via: brew install --cask karabiner-elements"
    return 0
  fi
  
  # Config should already be linked by stow at this point
  config_path="$HOME/.config/karabiner/karabiner.json"
  
  if [ -f "$config_path" ] || [ -L "$config_path" ]; then
    log_success "Karabiner config linked at $config_path"
  else
    log_warn "Karabiner config not found at $config_path"
    log_info "Run stow to link the configuration"
  fi
  
  # Check if Karabiner services are running
  if pgrep -x "karabiner_grabber" >/dev/null 2>&1; then
    log_info "Karabiner-Elements is running"
    log_info "Config changes will be auto-reloaded"
  else
    log_info "Karabiner-Elements is not running"
    log_info "Open Karabiner-Elements.app to start the service"
  fi
  
  # Remind about permissions
  log_info ""
  log_info "Karabiner-Elements requires accessibility permissions:"
  log_info "  System Settings > Privacy & Security > Accessibility"
  log_info "  Enable: karabiner_grabber and karabiner_observer"
  log_info ""
  log_info "For input monitoring (required for some features):"
  log_info "  System Settings > Privacy & Security > Input Monitoring"
  log_info "  Enable: karabiner_grabber and karabiner_observer"
}

# If run directly
if [ "${0##*/}" = "karabiner.sh" ]; then
  post_install_karabiner
fi
