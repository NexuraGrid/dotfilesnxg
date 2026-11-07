#!/bin/sh
# One-command setup for Linux and WSL (macOS also works).
#   curl -fsSL https://raw.githubusercontent.com/NexuraGrid/dotfilesnxg/main/install.sh | sh
set -eu

REPO="${DOTFILES_REPO:-https://github.com/NexuraGrid/dotfilesnxg.git}"
BIN_DIR="$HOME/.local/bin"

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as a normal user, not root: Homebrew refuses to run as root." >&2
  exit 1
fi

# Homebrew needs these before it can install anything else.
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v gcc >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y build-essential curl file git procps
  else
    echo "Install git, curl and a C compiler with your package manager, then rerun." >&2
    exit 1
  fi
fi

if command -v chezmoi >/dev/null 2>&1; then
  CHEZMOI="chezmoi"
else
  mkdir -p "$BIN_DIR"
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$BIN_DIR"
  CHEZMOI="$BIN_DIR/chezmoi"
fi

"$CHEZMOI" init --apply "$REPO"
echo "Done. Open a new terminal and run: nvim"
