#!/bin/bash

# Install zsh, oh-my-zsh, base16-shell, and set default shell

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

echo "==> Installing shell components..."

# Ensure UTF-8 locale is available (required for unicode in themes)
setup_locale() {
  if locale -a 2>/dev/null | grep -qi "en_US.utf"; then
    echo "en_US.UTF-8 locale is available"
    return
  fi

  echo "Setting up en_US.UTF-8 locale..."
  if [[ "$OS" == "linux" ]]; then
    case "$PKG_MANAGER" in
      pacman)
        # Arch: uncomment en_US.UTF-8 in locale.gen and generate
        sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        sudo locale-gen
        ;;
      apt)
        sudo locale-gen en_US.UTF-8
        sudo update-locale LANG=en_US.UTF-8
        ;;
      dnf)
        sudo dnf install -y glibc-langpack-en
        ;;
    esac
  fi
  echo "Locale setup complete"
}

setup_locale

# Install zsh
install_zsh() {
  install_package zsh
}

# Install oh-my-zsh
install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "oh-my-zsh is already installed"
    return
  fi

  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "oh-my-zsh installed"
}

# Install base16-shell
install_base16_shell() {
  if [[ -d "$HOME/.config/base16-shell" ]]; then
    echo "base16-shell is already installed"
    return
  fi

  echo "Installing base16-shell..."
  git clone https://github.com/tinted-theming/base16-shell.git "$HOME/.config/base16-shell"
  echo "base16-shell installed"
}

# Set zsh as default shell
set_default_shell() {
  if [[ "$SHELL" == *"zsh"* ]]; then
    echo "zsh is already the default shell"
    return
  fi

  echo "Setting zsh as default shell..."
  local zsh_path
  zsh_path="$(which zsh)"

  if [[ "$OS" == "linux" ]] && ! grep -q "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  chsh -s "$zsh_path"
  echo "Default shell changed to zsh (takes effect on next login)"
}

install_zsh
install_oh_my_zsh
install_base16_shell
set_default_shell

echo "==> Shell components installed"
