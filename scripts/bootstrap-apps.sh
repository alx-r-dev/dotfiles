#!/usr/bin/env bash
set -euo pipefail
command -v nvim >/dev/null 2>&1 || brew install neovim
if [ ! -d "/Applications/Ghostty.app" ] && ! command -v ghostty >/dev/null 2>&1; then
  brew install --cask ghostty
fi
echo "apps present."

# skhd (hotkey daemon for yabai)
command -v skhd >/dev/null 2>&1 || brew install skhd
