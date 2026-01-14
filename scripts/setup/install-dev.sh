#!/bin/bash

# Install development version managers: nvm, pyenv, rbenv, bun, pnpm, yarn
# Also installs AI coding tools: opencode, claude-code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

echo "==> Installing development tools..."

# nvm (Node Version Manager)
install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    echo "nvm is already installed"
  else
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    echo "nvm installed"
  fi

  # Load nvm and install LTS as default if no default is set
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  if ! nvm version default &>/dev/null || [[ "$(nvm version default)" == "N/A" ]]; then
    echo "Installing Node LTS and setting as default..."
    nvm install --lts
    nvm alias default lts/*
    echo "Node LTS set as default"
  fi
}

# pyenv (Python Version Manager)
install_pyenv() {
  if [[ -d "$HOME/.pyenv" ]]; then
    echo "pyenv is already installed"
    return
  fi

  echo "Installing pyenv..."
  curl https://pyenv.run | bash
  echo "pyenv installed"
}

# rbenv (Ruby Version Manager)
install_rbenv() {
  if [[ "$OS" == "macos" ]]; then
    if command -v rbenv &>/dev/null; then
      echo "rbenv is already installed"
      return
    fi
    echo "Installing rbenv..."
    pkg_install rbenv ruby-build
    echo "rbenv installed"
  else
    if [[ -d "$HOME/.rbenv" ]]; then
      echo "rbenv is already installed"
      return
    fi
    echo "Installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
    git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
    echo "rbenv installed"
  fi
}

# bun
install_bun() {
  if command -v bun &>/dev/null; then
    echo "bun is already installed"
    return
  fi

  # bun requires unzip
  ensure_command unzip

  echo "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
  echo "bun installed"
}

# pnpm
install_pnpm() {
  if command -v pnpm &>/dev/null; then
    echo "pnpm is already installed"
    return
  fi

  echo "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  echo "pnpm installed"
}

# yarn (requires npm/node)
install_yarn() {
  if command -v yarn &>/dev/null; then
    echo "yarn is already installed"
    return
  fi

  echo "Installing yarn..."
  case "$PKG_MANAGER" in
    brew|pacman|dnf)
      pkg_install yarn
      ;;
    apt)
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt update && sudo apt install -y yarn
      ;;
  esac
  echo "yarn installed"
}

install_nvm
install_pyenv
install_rbenv
install_bun
install_pnpm
install_yarn

# opencode (AI coding assistant)
install_opencode() {
  if command -v opencode &>/dev/null; then
    echo "opencode is already installed"
    return
  fi

  echo "Installing opencode..."
  curl -fsSL https://opencode.ai/install.sh | bash
  echo "opencode installed"
}

# claude-code (Anthropic's CLI for Claude)
# Installed via standalone script to avoid nvm version switching issues
install_claude_code() {
  if [[ -x "$HOME/.local/share/claude" ]]; then
    echo "claude-code is already installed"
    return
  fi

  echo "Installing claude-code..."
  curl -fsSL https://claude.ai/install.sh | sh
  echo "claude-code installed"
}

install_opencode
install_claude_code

echo "==> Development tools installed"
echo "Note: Restart your shell or source ~/.zshrc to use version managers"
