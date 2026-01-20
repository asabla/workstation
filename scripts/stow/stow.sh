#!/bin/sh
# stow.sh - GNU Stow wrapper for dotfile management
# POSIX-compliant shell script

set -e

# Only source libraries if not already loaded (when run standalone)
if [ -z "$WORKSTATION_LIB_LOADED" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/common.sh"
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/../lib/detect-os.sh"
fi

# Get the workstation root directory
if [ -z "$WORKSTATION_ROOT" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  WORKSTATION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi
APPLICATIONS_DIR="$WORKSTATION_ROOT/applications"

# Global flags
FORCE_STOW=false

# Check if stow is installed
ensure_stow() {
  if ! command_exists stow; then
    log_error "GNU Stow is not installed. Please install it first."
    log_info "  macOS: brew install stow"
    log_info "  Ubuntu: sudo apt install stow"
    log_info "  Arch: sudo pacman -S stow"
    exit 1
  fi
}

# Get list of files that would be created by stowing a package
get_stow_targets() {
  pkg="$1"
  pkg_dir="$APPLICATIONS_DIR/$pkg"
  
  # Find all files in the package and convert to target paths
  cd "$pkg_dir"
  find . -type f -o -type l | sed 's|^\./||' | while read -r file; do
    echo "$HOME/$file"
  done
  cd - > /dev/null
}

# Check for conflicts before stowing
check_conflicts() {
  pkg="$1"
  pkg_dir="$APPLICATIONS_DIR/$pkg"
  conflicts=""
  
  cd "$pkg_dir"
  # Find all files and directories that would be created
  find . -type f -o -type l | sed 's|^\./||' | while read -r file; do
    target="$HOME/$file"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "$target"
    elif [ -L "$target" ]; then
      # Check if symlink points to our stow package
      link_target="$(readlink "$target" 2>/dev/null || true)"
      case "$link_target" in
        *"$APPLICATIONS_DIR/$pkg"*) 
          # Already points to our package, no conflict
          ;;
        *)
          # Points elsewhere, conflict
          echo "$target"
          ;;
      esac
    fi
  done
  cd - > /dev/null
}

# Remove conflicting files (with backup)
remove_conflicts() {
  pkg="$1"
  
  log_step "Checking for conflicts with $pkg..."
  
  conflicts=$(check_conflicts "$pkg")
  
  if [ -z "$conflicts" ]; then
    log_info "No conflicts found for $pkg"
    return 0
  fi
  
  log_warn "Found conflicting files for $pkg:"
  echo "$conflicts" | while read -r file; do
    [ -n "$file" ] && printf "  - %s\n" "$file"
  done
  
  if [ "$FORCE_STOW" = true ]; then
    log_info "Force mode: removing conflicts..."
  else
    if ! confirm "Remove these files to continue? (They should be backed up first)"; then
      log_error "Aborted. Please backup and remove conflicts manually, or use --force"
      return 1
    fi
  fi
  
  echo "$conflicts" | while read -r file; do
    if [ -n "$file" ] && [ -e "$file" ]; then
      rm -rf "$file"
      log_info "Removed: $file"
    fi
  done
  
  return 0
}

# Stow a single package
# Usage: stow_package <package_name>
stow_package() {
  pkg="$1"
  pkg_dir="$APPLICATIONS_DIR/$pkg"
  
  if [ ! -d "$pkg_dir" ]; then
    log_error "Package directory not found: $pkg_dir"
    return 1
  fi
  
  log_step "Stowing $pkg..."
  
  # Check and handle conflicts first
  if ! remove_conflicts "$pkg"; then
    return 1
  fi
  
  # Run stow from the applications directory, targeting home
  cd "$APPLICATIONS_DIR"
  
  # Use --restow to handle updates (unstow then stow)
  # Use --verbose for detailed output
  # Use --no-folding to create intermediate directories
  if stow --restow --verbose=1 --target="$HOME" "$pkg" 2>&1; then
    log_success "Stowed $pkg"
  else
    log_error "Failed to stow $pkg"
    log_info "Try running: ./scripts/backup/backup.sh backup $pkg"
    log_info "Then retry with: ./scripts/stow/stow.sh stow $pkg"
    return 1
  fi
  
  cd - > /dev/null
}

# Unstow a single package
# Usage: unstow_package <package_name>
unstow_package() {
  pkg="$1"
  pkg_dir="$APPLICATIONS_DIR/$pkg"
  
  if [ ! -d "$pkg_dir" ]; then
    log_error "Package directory not found: $pkg_dir"
    return 1
  fi
  
  log_step "Unstowing $pkg..."
  
  cd "$APPLICATIONS_DIR"
  
  if stow --delete --verbose=1 --target="$HOME" "$pkg" 2>&1; then
    log_success "Unstowed $pkg"
  else
    log_error "Failed to unstow $pkg"
    return 1
  fi
  
  cd - > /dev/null
}

# Stow multiple packages
# Usage: stow_packages "nvim tmux zsh"
stow_packages() {
  packages="$1"
  
  ensure_stow
  
  for pkg in $packages; do
    # Skip vscode - it needs special handling due to non-standard paths
    if [ "$pkg" = "vscode" ]; then
      log_info "Skipping vscode (requires custom symlink handling)"
      continue
    fi
    
    stow_package "$pkg"
  done
}

# Unstow multiple packages
# Usage: unstow_packages "nvim tmux zsh"
unstow_packages() {
  packages="$1"
  
  ensure_stow
  
  for pkg in $packages; do
    if [ "$pkg" = "vscode" ]; then
      continue
    fi
    
    unstow_package "$pkg"
  done
}

# List available packages
list_packages() {
  log_info "Available packages in $APPLICATIONS_DIR:"
  for dir in "$APPLICATIONS_DIR"/*/; do
    if [ -d "$dir" ]; then
      pkg_name=$(basename "$dir")
      printf "  - %s\n" "$pkg_name"
    fi
  done
}

# Adopt existing files (useful for first-time setup)
# This moves existing files into the stow package and creates symlinks
adopt_package() {
  pkg="$1"
  
  ensure_stow
  
  log_step "Adopting existing files for $pkg..."
  
  cd "$APPLICATIONS_DIR"
  
  if stow --adopt --verbose=1 --target="$HOME" "$pkg" 2>&1; then
    log_success "Adopted $pkg"
    log_warn "Check the adopted files - they may have overwritten your configs!"
    log_info "Use 'git diff' to review changes in the applications directory"
  else
    log_error "Failed to adopt $pkg"
    return 1
  fi
  
  cd - > /dev/null
}

# Print usage
print_usage() {
  cat << EOF
Usage: $0 [options] <command> [packages...]

Options:
  -f, --force      Force remove conflicting files without prompting

Commands:
  stow <packages>    Stow (link) the specified packages
  unstow <packages>  Unstow (unlink) the specified packages
  restow <packages>  Restow (update) the specified packages
  adopt <package>    Adopt existing files into a package
  list               List available packages

Examples:
  $0 stow nvim tmux zsh
  $0 --force stow tmux     # Force stow, removing conflicts
  $0 unstow nvim
  $0 list

Note: Before stowing, it's recommended to backup your existing configs:
  ./scripts/backup/backup.sh backup <package>
EOF
}

# Main entry point when run directly
if [ "${0##*/}" = "stow.sh" ]; then
  if [ $# -lt 1 ]; then
    print_usage
    exit 1
  fi
  
  # Parse options
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--force)
        FORCE_STOW=true
        shift
        ;;
      -*)
        if [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
          log_error "Unknown option: $1"
          print_usage
          exit 1
        fi
        print_usage
        exit 0
        ;;
      *)
        break
        ;;
    esac
  done
  
  if [ $# -lt 1 ]; then
    print_usage
    exit 1
  fi
  
  command="$1"
  shift
  
  case "$command" in
    stow)
      if [ $# -lt 1 ]; then
        log_error "No packages specified"
        exit 1
      fi
      stow_packages "$*"
      ;;
    unstow)
      if [ $# -lt 1 ]; then
        log_error "No packages specified"
        exit 1
      fi
      unstow_packages "$*"
      ;;
    restow)
      if [ $# -lt 1 ]; then
        log_error "No packages specified"
        exit 1
      fi
      stow_packages "$*"  # --restow is already used
      ;;
    adopt)
      if [ $# -ne 1 ]; then
        log_error "Adopt requires exactly one package"
        exit 1
      fi
      adopt_package "$1"
      ;;
    list)
      list_packages
      ;;
    *)
      log_error "Unknown command: $command"
      print_usage
      exit 1
      ;;
  esac
fi
