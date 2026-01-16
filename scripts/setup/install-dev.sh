#!/bin/bash

# Install development version managers: mise, bun, pnpm, yarn
# Also installs AI coding tools: opencode, claude-code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

echo "==> Installing development tools..."

# mise (version manager for Node, Python, Ruby, etc.)
install_mise() {
  if command -v mise &>/dev/null; then
    echo "mise is already installed"
  else
    echo "Installing mise..."
    curl https://mise.run | sh
    echo "mise installed"
  fi

  # Load mise and install default tools
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(mise activate bash)"

  # Trust mise config if it exists
  mise trust "$HOME/.config/mise/config.toml" 2>/dev/null || true

  # Ensure global tools are installed
  echo "Installing global mise tools..."
  mise install
  echo "Global mise tools installed"
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

install_mise
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

# Neovim provider packages (for plugins that use remote hosts)
install_nvim_providers() {
  echo "Installing Neovim provider packages..."

  # Node.js provider
  if command -v npm &>/dev/null; then
    npm install -g neovim
    echo "Node.js neovim package installed"
  fi

  # Python provider
  if command -v pip &>/dev/null; then
    pip install pynvim
    echo "Python pynvim package installed"
  fi

  # Ruby provider
  if command -v gem &>/dev/null; then
    gem install neovim
    echo "Ruby neovim gem installed"
  fi
}

install_nvim_providers

echo "==> Development tools installed"
echo "Note: Restart your shell or source ~/.zshrc to use version managers"
