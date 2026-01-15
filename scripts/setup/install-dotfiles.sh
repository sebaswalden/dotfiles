#!/bin/bash

# Symlink dotfiles to their correct locations

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR..."

# Backup existing files if they exist and aren't symlinks
backup_if_exists() {
  if [[ -e "$1" && ! -L "$1" ]]; then
    echo "Backing up existing $1 to $1.backup"
    mv "$1" "$1.backup"
  elif [[ -L "$1" ]]; then
    echo "Removing existing symlink $1"
    rm "$1"
  fi
}

# Create symlink
create_symlink() {
  local src="$1"
  local dest="$2"
  backup_if_exists "$dest"
  echo "Linking $dest -> $src"
  ln -s "$src" "$dest"
}

# Ensure .config directory exists
mkdir -p "$HOME/.config"

# Install zshrc
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Install nvim config
create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

# Install mise config
create_symlink "$DOTFILES_DIR/.config/mise" "$HOME/.config/mise"

echo "==> Dotfiles installed"
