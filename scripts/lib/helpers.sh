#!/bin/bash

# Shared helper functions for setup scripts
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

# =============================================================================
# OS Detection
# =============================================================================

case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      echo "Unsupported OS"; exit 1 ;;
esac

# =============================================================================
# Package Manager Detection
# =============================================================================

detect_pkg_manager() {
  if [[ "$OS" == "macos" ]]; then
    echo "brew"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  else
    echo "unknown"
  fi
}

PKG_MANAGER="$(detect_pkg_manager)"

# =============================================================================
# Package Installation
# =============================================================================

# Install a package using the system package manager
# Usage: pkg_install <package> [package2 ...]
pkg_install() {
  case "$PKG_MANAGER" in
    brew)   brew install "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    apt)    sudo apt update && sudo apt install -y "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    *)      echo "Unknown package manager. Please install manually: $*"; return 1 ;;
  esac
}

# Install a package from AUR (Arch only, falls back to pkg_install on other systems)
# Usage: aur_install <package>
aur_install() {
  if [[ "$PKG_MANAGER" != "pacman" ]]; then
    pkg_install "$@"
    return
  fi

  if command -v yay &>/dev/null; then
    yay -S --noconfirm "$@"
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm "$@"
  else
    echo "No AUR helper found (yay/paru). Please install manually: $*"
    return 1
  fi
}

# Install a package with different names per package manager
# Usage: install_package <command> [--pkg <pkg>] [--brew <pkg>] [--pacman <pkg>] [--apt <pkg>] [--dnf <pkg>] [--aur]
#   --pkg sets the package name for all package managers (use when package name differs from command)
install_package() {
  local name=""
  local pkg=""
  local brew_pkg=""
  local pacman_pkg=""
  local apt_pkg=""
  local dnf_pkg=""
  local aur=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pkg)    pkg="$2"; shift 2 ;;
      --brew)   brew_pkg="$2"; shift 2 ;;
      --pacman) pacman_pkg="$2"; shift 2 ;;
      --apt)    apt_pkg="$2"; shift 2 ;;
      --dnf)    dnf_pkg="$2"; shift 2 ;;
      --aur)    aur=true; shift ;;
      *)        name="$1"; shift ;;
    esac
  done

  # Default package names: specific overrides > --pkg > command name
  pkg="${pkg:-$name}"
  brew_pkg="${brew_pkg:-$pkg}"
  pacman_pkg="${pacman_pkg:-$pkg}"
  apt_pkg="${apt_pkg:-$pkg}"
  dnf_pkg="${dnf_pkg:-$pkg}"

  if command -v "$name" &>/dev/null; then
    echo "$name is already installed"
    return
  fi

  echo "Installing $name..."
  case "$PKG_MANAGER" in
    brew)   pkg_install "$brew_pkg" ;;
    pacman)
      if [[ "$aur" == true ]]; then
        aur_install "$pacman_pkg"
      else
        pkg_install "$pacman_pkg"
      fi
      ;;
    apt)    pkg_install "$apt_pkg" ;;
    dnf)    pkg_install "$dnf_pkg" ;;
    *)      echo "Unknown package manager. Please install $name manually."; return 1 ;;
  esac
  echo "$name installed"
}

# Ensure a command is available, installing it if needed
# Usage: ensure_command <command> [install_package args...]
# Example: ensure_command unzip
# Example: ensure_command rg --brew ripgrep --apt ripgrep
ensure_command() {
  local cmd="$1"
  if command -v "$cmd" &>/dev/null; then
    return 0
  fi
  install_package "$@"
}
