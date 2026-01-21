#!/bin/sh
# opencode.sh - Post-installation for OpenCode
# POSIX-compliant shell script

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Post-installation hook for OpenCode
post_install_opencode() {
  log_step "Configuring OpenCode..."
  
  # Check if OpenCode is installed
  if ! command_exists opencode; then
    log_warn "OpenCode not found in PATH"
    log_info "Install it via: brew install opencode (macOS) or npm install -g opencode"
    return 0
  fi
  
  # Config should already be linked by stow at this point
  config_path="$HOME/.config/opencode/opencode.json"
  
  if [ -f "$config_path" ] || [ -L "$config_path" ]; then
    log_success "OpenCode config linked at $config_path"
  else
    log_warn "OpenCode config not found at $config_path"
    log_info "Run stow to link the configuration"
  fi
  
  # Check for MCP dependencies
  log_info ""
  log_info "OpenCode MCP servers configured:"
  log_info "  - context7 (remote, no setup needed)"
  log_info "  - playwright (requires npx @playwright/mcp)"
  log_info ""
  log_info "To install Playwright MCP dependencies:"
  log_info "  npx playwright install"
}

# If run directly
if [ "${0##*/}" = "opencode.sh" ]; then
  post_install_opencode
fi
