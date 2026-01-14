#!/bin/bash

# Install system tools: neovim, git, curl, make, gcc, ripgrep, fd, autojump, terraform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

# Install Homebrew on macOS if not present
if [[ "$OS" == "macos" ]] && ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install yay (AUR helper) on Arch if no AUR helper is present
if [[ "$PKG_MANAGER" == "pacman" ]] && ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
  echo "Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
  (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp_dir"
  echo "yay installed"
fi

echo "==> Installing system tools..."

# Install neovim (special case: needs PPA on Ubuntu for latest version)
install_neovim() {
  if command -v nvim &>/dev/null; then
    echo "neovim is already installed"
    return
  fi

  echo "Installing neovim..."
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    # Use PPA for latest neovim on Debian/Ubuntu
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt update && sudo apt install -y neovim
  else
    pkg_install neovim
  fi
  echo "neovim installed"
}

# Install packages
install_package git
install_package curl
install_package make
install_package gcc
install_package rg --pkg ripgrep
install_package fd
install_package autojump --aur
install_neovim

# Terraform (optional, needs special repos on some distros)
install_terraform() {
  if command -v terraform &>/dev/null; then
    echo "terraform is already installed"
    return
  fi

  echo "Installing terraform..."
  case "$PKG_MANAGER" in
    brew)
      brew tap hashicorp/tap
      brew install hashicorp/tap/terraform
      ;;
    pacman)
      pkg_install terraform
      ;;
    apt)
      wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update && sudo apt install -y terraform
      ;;
    dnf)
      sudo dnf install -y dnf-plugins-core
      sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
      sudo dnf install -y terraform
      ;;
  esac
  echo "terraform installed"
}

install_terraform

echo "==> System tools installed"
