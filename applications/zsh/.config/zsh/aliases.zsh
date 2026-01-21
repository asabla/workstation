#!/bin/zsh
# aliases.zsh - Shell aliases

# Kubectl.nvim - Kubernetes management in Neovim
alias k8s='nvim +"lua require(\"kubectl\").open()"'

# Neovide - always fork to background
alias neovide="neovide --fork"

# Editor shortcuts
alias v='nvim'
alias vim='nvim'
