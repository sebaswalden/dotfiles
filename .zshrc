# Locale (required for unicode in themes/prompts)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Source secrets file (not tracked in git)
[[ -f ~/.secrets ]] && source ~/.secrets

# OS Detection
case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
esac

# Path exports (cross-platform)
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.lmstudio/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# macOS-specific paths (Homebrew)
if [[ "$OS" == "macos" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/sbin:$PATH"
  export HOMEBREW_NO_AUTO_UPDATE=1
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# mise (version manager for Node, Python, Ruby, etc.)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pnpm
if [[ "$OS" == "macos" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Terraform completion
autoload -U +X bashcompinit && bashcompinit
if [[ "$OS" == "macos" ]]; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
else
  command -v terraform &>/dev/null && complete -o nospace -C "$(which terraform)" terraform
fi

# Base16 Shell theme
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && source "$BASE16_SHELL/profile_helper.sh"
type base16_default-dark &>/dev/null && base16_default-dark

# iTerm2 integration (macOS only)
[[ "$OS" == "macos" ]] && test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# Aliases (cross-platform)
alias order_branches="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
alias vim="nvim"
alias vi="nvim"
alias garca="ga . && grbc"
alias nvm="mise"

# macOS-only aliases
if [[ "$OS" == "macos" ]]; then
  alias yabaires="launchctl kickstart -k \"gui/${UID}/homebrew.mxcl.yabai\""
  alias skhdres="launchctl kickstart -k \"gui/${UID}/homebrew.mxcl.skhd\""
fi
export PATH="$HOME/.local/bin:$PATH"
