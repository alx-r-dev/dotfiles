#!/usr/bin/env bash
set -euo pipefail
if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if ! test -d "/opt/homebrew/opt/powerlevel10k"; then
  command -v brew >/dev/null 2>&1 && brew install powerlevel10k || true
fi
echo "oh-my-zsh bootstrap complete."
