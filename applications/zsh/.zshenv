# ~/.zshenv - sourced by ALL zsh invocations
# Keep this minimal — it runs for every zsh process

export NVM_DIR="$HOME/.nvm"

# Add nvm default node to PATH (so node works in non-interactive shells)
if [[ -r "$HOME/.nvm/alias/default" ]]; then
    _nvm_default=$(<"$HOME/.nvm/alias/default")
    _nvm_node_dir="$HOME/.nvm/versions/node"

    if [[ "$_nvm_default" == "node" ]]; then
        # "node" alias means latest installed version
        _nvm_match=$(ls -d "$_nvm_node_dir"/v* 2>/dev/null | sort -V | tail -1)
    else
        # Match version prefix (handles "22" matching "v22.14.0", or exact "22.14.0")
        _nvm_match=$(ls -d "$_nvm_node_dir"/v${_nvm_default}* 2>/dev/null | sort -V | tail -1)
    fi

    if [[ -d "$_nvm_match/bin" ]]; then
        path=("$_nvm_match/bin" $path)
    fi
    unset _nvm_default _nvm_node_dir _nvm_match
fi
