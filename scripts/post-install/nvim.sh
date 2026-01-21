#!/bin/sh
# nvim.sh - Post-installation setup for Neovim
# POSIX-compliant shell script

set -e

if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
fi

# Sync Neovim plugins using Lazy.nvim
sync_plugins() {
  log_step "Syncing Neovim plugins with Lazy.nvim..."
  
  if ! command_exists nvim; then
    log_error "Neovim is not installed"
    return 1
  fi
  
  # Run Lazy sync in headless mode
  # This will install all plugins defined in the configuration
  nvim --headless "+Lazy! sync" +qa
  
  log_success "Neovim plugins synced"
}

# Update Treesitter parsers
update_treesitter() {
  log_step "Updating Treesitter parsers..."
  
  # Update all installed parsers
  nvim --headless "+TSUpdateSync" +qa 2>/dev/null || {
    log_info "Treesitter update skipped (may not be configured yet)"
  }
}

# Check Mason for LSP servers (optional)
check_mason() {
  log_info "Mason will install LSP servers on first use"
  log_info "Open Neovim and run :Mason to manage LSP servers"
}

# Run health check
run_healthcheck() {
  log_step "Running Neovim health check..."
  log_info "Run ':checkhealth' in Neovim to see detailed health information"
}

# Main post-install function
post_install_nvim() {
  print_section "Neovim Post-Installation"
  
  sync_plugins
  update_treesitter
  check_mason
  run_healthcheck
  
  log_success "Neovim post-installation complete"
}

# If run directly
if [ "${0##*/}" = "nvim.sh" ]; then
  post_install_nvim
fi
