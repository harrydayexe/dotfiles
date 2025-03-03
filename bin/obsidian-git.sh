#!/bin/sh

cd "/Users/harryday/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe"
git pull
git add .
git commit -m "Auto-commit: $(date)"
git push
