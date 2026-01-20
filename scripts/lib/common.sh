#!/bin/sh
# common.sh - Shared utility functions for workstation setup
# POSIX-compliant shell script

# Colors (only if terminal supports it)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  BOLD=''
  NC=''
fi

# Logging functions
log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
  printf "${GREEN}[OK]${NC} %s\n" "$1"
}

log_warn() {
  printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

log_step() {
  printf "${MAGENTA}[STEP]${NC} %s\n" "$1"
}

# Print a header banner
print_header() {
  printf "\n${BOLD}${CYAN}========================================${NC}\n"
  printf "${BOLD}${CYAN}  %s${NC}\n" "$1"
  printf "${BOLD}${CYAN}========================================${NC}\n\n"
}

# Print a section divider
print_section() {
  printf "\n${BOLD}--- %s ---${NC}\n\n" "$1"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Prompt for yes/no confirmation
# Usage: confirm "Do you want to continue?" && echo "yes" || echo "no"
confirm() {
  printf "%s [y/N] " "$1"
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

# Prompt for yes/no with default yes
# Usage: confirm_yes "Do you want to continue?" && echo "yes" || echo "no"
confirm_yes() {
  printf "%s [Y/n] " "$1"
  read -r response
  case "$response" in
    [nN][oO]|[nN]) return 1 ;;
    *) return 0 ;;
  esac
}

# Get the directory where the script is located
get_script_dir() {
  # Works for most cases including symlinks
  cd "$(dirname "$0")" && pwd
}

# Get the root directory of the workstation repo
get_workstation_root() {
  script_dir="$(get_script_dir)"
  # Navigate up from scripts/ or scripts/lib/ to root
  case "$script_dir" in
    */scripts/lib) dirname "$(dirname "$script_dir")" ;;
    */scripts/*) dirname "$(dirname "$script_dir")" ;;
    */scripts) dirname "$script_dir" ;;
    *) dirname "$script_dir" ;;
  esac
}

# Check if running as root (generally we don't want this)
check_not_root() {
  if [ "$(id -u)" -eq 0 ]; then
    log_error "This script should not be run as root"
    exit 1
  fi
}

# Ensure a directory exists
ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    log_info "Created directory: $1"
  fi
}

# Create a backup of a file if it exists
backup_file() {
  if [ -f "$1" ]; then
    backup="${1}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$1" "$backup"
    log_info "Backed up $1 to $backup"
  fi
}

# Safe symlink creation (backs up existing files)
safe_symlink() {
  src="$1"
  dest="$2"
  
  if [ -L "$dest" ]; then
    # It's already a symlink, remove it
    rm "$dest"
  elif [ -f "$dest" ] || [ -d "$dest" ]; then
    # It's a regular file/dir, back it up
    backup_file "$dest"
    rm -rf "$dest"
  fi
  
  # Create parent directory if needed
  ensure_dir "$(dirname "$dest")"
  
  ln -s "$src" "$dest"
  log_success "Linked $dest -> $src"
}

# Check if we're in the workstation directory
verify_workstation_dir() {
  if [ ! -d "applications" ] || [ ! -d "scripts" ]; then
    log_error "This script must be run from the workstation root directory"
    exit 1
  fi
}
