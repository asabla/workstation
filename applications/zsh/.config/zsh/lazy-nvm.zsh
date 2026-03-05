#!/bin/zsh
# lazy-nvm.zsh - On-demand NVM loading
# NVM adds 300-800ms to startup; this defers loading until actually needed

# NVM_DIR is exported in .zshenv for all shell types

# Function to load NVM (called on first use)
_load_nvm() {
    # Unset placeholder functions first
    unfunction nvm yarn pnpm corepack 2>/dev/null

    # Load NVM from various possible locations
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
    elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        \. "/opt/homebrew/opt/nvm/nvm.sh"
    elif [ -s "/usr/share/nvm/nvm.sh" ]; then
        \. "/usr/share/nvm/nvm.sh"
    fi

    # Load bash completion if available
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \
        \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

# Create placeholder functions that load NVM on first use
# When any of these commands are called, NVM loads and then the real command runs
# Note: node/npm/npx are already on PATH via .zshenv, so we only shim nvm and
# package managers that aren't available without full NVM init.
nvm() {
    _load_nvm
    nvm "$@"
}

yarn() {
    _load_nvm
    yarn "$@"
}

pnpm() {
    _load_nvm
    pnpm "$@"
}

corepack() {
    _load_nvm
    corepack "$@"
}
