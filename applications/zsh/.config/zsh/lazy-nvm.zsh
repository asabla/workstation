#!/bin/zsh
# lazy-nvm.zsh - On-demand NVM loading
# NVM adds 300-800ms to startup; this defers loading until actually needed

export NVM_DIR="$HOME/.nvm"

# Function to load NVM (called on first use)
_load_nvm() {
    # Unset placeholder functions first
    unfunction nvm node npm npx yarn pnpm corepack 2>/dev/null

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
nvm() {
    _load_nvm
    nvm "$@"
}

node() {
    _load_nvm
    node "$@"
}

npm() {
    _load_nvm
    npm "$@"
}

npx() {
    _load_nvm
    npx "$@"
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
