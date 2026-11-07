#!/bin/sh

cd "/Users/harryday/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe"
git pull
/usr/bin/python3 ~/Developer/dotfiles/bin/update-hub-index.py . || echo "hub index update failed" >&2
git add .
git commit --no-gpg-sign -m "Auto-commit: $(date)"
git push
