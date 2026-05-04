#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pre-create directories whose contents should be linked individually rather
# than folded into a single directory symlink. Stow folds dirs by default; if
# the target already exists as a real directory, stow descends into it instead.
mkdir -p "$HOME/.config" "$HOME/.claude"

cd "$DOTFILES_DIR"
stow "$(basename "$DOTFILES_DIR")" "$@"
