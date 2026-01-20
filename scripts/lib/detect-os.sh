#!/bin/sh
# detect-os.sh - Detect the operating system
# POSIX-compliant shell script
#
# Sets the following variables:
#   OS        - The detected OS (macos, ubuntu, debian, arch, fedora, windows, unknown)
#   OS_FAMILY - The OS family (macos, debian, arch, redhat, windows, unknown)
#   ARCH      - The CPU architecture (x86_64, arm64, etc.)

detect_os() {
  OS="unknown"
  OS_FAMILY="unknown"
  ARCH="$(uname -m)"

  case "$(uname -s)" in
    Darwin)
      OS="macos"
      OS_FAMILY="macos"
      ;;
    Linux)
      if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "$ID" in
          ubuntu)
            OS="ubuntu"
            OS_FAMILY="debian"
            ;;
          debian)
            OS="debian"
            OS_FAMILY="debian"
            ;;
          arch|manjaro|endeavouros)
            OS="arch"
            OS_FAMILY="arch"
            ;;
          fedora)
            OS="fedora"
            OS_FAMILY="redhat"
            ;;
          centos|rhel|rocky|almalinux)
            OS="$ID"
            OS_FAMILY="redhat"
            ;;
          *)
            # Try to detect family from ID_LIKE
            case "$ID_LIKE" in
              *debian*|*ubuntu*)
                OS="$ID"
                OS_FAMILY="debian"
                ;;
              *arch*)
                OS="$ID"
                OS_FAMILY="arch"
                ;;
              *rhel*|*fedora*)
                OS="$ID"
                OS_FAMILY="redhat"
                ;;
              *)
                OS="$ID"
                ;;
            esac
            ;;
        esac
      elif [ -f /etc/arch-release ]; then
        OS="arch"
        OS_FAMILY="arch"
      elif [ -f /etc/debian_version ]; then
        OS="debian"
        OS_FAMILY="debian"
      elif [ -f /etc/redhat-release ]; then
        OS="redhat"
        OS_FAMILY="redhat"
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      OS="windows"
      OS_FAMILY="windows"
      ;;
    *)
      # Check for WSL
      if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
        # Running in WSL, detect the underlying distro
        if [ -f /etc/os-release ]; then
          # shellcheck disable=SC1091
          . /etc/os-release
          OS="$ID"
          case "$ID" in
            ubuntu|debian) OS_FAMILY="debian" ;;
            arch) OS_FAMILY="arch" ;;
            *) OS_FAMILY="unknown" ;;
          esac
        fi
      fi
      ;;
  esac

  export OS
  export OS_FAMILY
  export ARCH
}

# Print detected OS information
print_os_info() {
  printf "Operating System: %s\n" "$OS"
  printf "OS Family: %s\n" "$OS_FAMILY"
  printf "Architecture: %s\n" "$ARCH"
}

# Check if the current OS is supported
is_supported_os() {
  case "$OS" in
    macos|ubuntu|debian|arch|fedora)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Check if stow is supported on this OS
supports_stow() {
  case "$OS_FAMILY" in
    macos|debian|arch|redhat)
      return 0
      ;;
    windows)
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

# Run detection on source
detect_os
