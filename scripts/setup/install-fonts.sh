#!/bin/bash

# Install Nerd Fonts (JetBrainsMono)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

FONT_NAME="JetBrainsMono"

echo "==> Installing Nerd Fonts ($FONT_NAME)..."

install_font_macos() {
  if [[ -d "$HOME/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" ]] || ls ~/Library/Fonts/*JetBrains* &>/dev/null 2>&1; then
    echo "$FONT_NAME Nerd Font is already installed"
    return
  fi

  echo "Installing $FONT_NAME Nerd Font via Homebrew..."
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew install --cask font-jetbrains-mono-nerd-font
  echo "$FONT_NAME Nerd Font installed"
}

install_font_linux() {
  local font_dir="$HOME/.local/share/fonts"

  if ls "$font_dir"/*JetBrains* &>/dev/null 2>&1; then
    echo "$FONT_NAME Nerd Font is already installed"
    return
  fi

  # Ensure unzip is available
  ensure_command unzip

  echo "Installing $FONT_NAME Nerd Font..."
  mkdir -p "$font_dir"

  local version="v3.1.1"
  local zip_file="/tmp/${FONT_NAME}.zip"

  curl -fLo "$zip_file" "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${FONT_NAME}.zip"
  unzip -o "$zip_file" -d "$font_dir"
  rm "$zip_file"

  # Refresh font cache
  fc-cache -fv

  echo "$FONT_NAME Nerd Font installed"
}

if [[ "$OS" == "macos" ]]; then
  install_font_macos
else
  install_font_linux
fi

echo "==> Nerd Fonts installed"
echo "Note: Set your terminal to use '$FONT_NAME Nerd Font' for icons to display correctly"
