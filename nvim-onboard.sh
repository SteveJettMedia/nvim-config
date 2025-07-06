#!/usr/bin/env bash
# nvim-onboard.sh — Clone & bootstrap your Neovim config on a new machine
# USAGE: ./nvim-onboard.sh [repo-url]  (defaults to your GitHub repo)

set -euo pipefail
IFS=$'\n\t'

REPO="${1:-git@github.com:SteveJettMedia/nvim-config.git}"
DEST="$HOME/.config/nvim"
BACKUP="$HOME/.config/nvim.$(date +%s).bak"

echo "📝  Neovim bootstrap starting…"
echo "📦  Installing core packages (git, neovim, build tools)…"
sudo apt update -y
sudo apt install -y git neovim curl build-essential \
     ripgrep fd-find python3-pip nodejs npm

# fd-find installs as fdfind on Debian/Ubuntu; symlink to fd for tools expecting it
command -v fd >/dev/null 2>&1 || sudo ln -s $(command -v fdfind) /usr/local/bin/fd

echo "🐍  Ensuring pynvim for Python plugins…"
pip3 install --user --upgrade pynvim

# Backup any existing config
if [[ -d "$DEST" ]]; then
  echo "📂  Existing Neovim config detected — backing up to $BACKUP"
  mv "$DEST" "$BACKUP"
fi

echo "⬇️  Cloning $REPO → $DEST"
git clone --depth 1 "$REPO" "$DEST"

echo "⚙️  Bootstrapping plugins via lazy.nvim (headless)…"
nvim --headless "+lua require('lazy').sync()" +qa

echo "✅  Done! Launch Neovim and enjoy your fully-cloned setup."

