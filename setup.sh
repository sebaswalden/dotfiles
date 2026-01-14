#!/bin/bash

# Main setup script - runs all installation scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/scripts/setup"

echo "========================================"
echo "        Dotfiles Setup"
echo "========================================"
echo ""

# Run all setup scripts in order
"$SETUP_DIR/install-tools.sh"
echo ""

"$SETUP_DIR/install-shell.sh"
echo ""

"$SETUP_DIR/install-dev.sh"
echo ""

"$SETUP_DIR/install-fonts.sh"
echo ""

"$SETUP_DIR/install-dotfiles.sh"
echo ""

echo "========================================"
echo "        Setup Complete!"
echo "========================================"
echo ""
# Install nvim plugins with Lazy
echo "Installing nvim plugins with Lazy..."
nvim --headless "+Lazy sync" +qa

echo "Next steps:"
echo "  1. Restart your terminal or run: zsh"
echo "  2. Set your terminal font to 'JetBrainsMono Nerd Font'"
echo ""
echo "API keys need manual setup:"
echo "  - opencode: Set ANTHROPIC_API_KEY or configure via 'opencode'"
echo "  - claude-code: Run 'claude' and follow the authentication prompts"
echo ""
