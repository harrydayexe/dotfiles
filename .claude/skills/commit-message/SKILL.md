---
name: commit-message
description: Generate a concise, well-formed commit message for the current uncommitted changes.
---
# commit-message Skill

## Purpose
Generate a concise, well-formed commit message for the current uncommitted changes.

## Steps

1. Run `git diff --staged` to see staged changes. If there are none, run `git diff` to see unstaged changes. If there are still none, check `git status` for untracked files and inform the user there is nothing to commit.

2. Run `git log --oneline -10` to understand the commit style and conventions used in this repo.

3. Analyse the diff: understand what changed, why it likely changed (infer from context), and what the effect is.

4. Write a commit message following these rules:
   - **Subject line** (first line): 50–72 characters, imperative mood ("Add", "Fix", "Remove", not "Added"/"Fixes"), no trailing period.
   - **Body** (optional, separated by a blank line): explain the *why* and any non-obvious consequences, not the *what* (the diff already shows that). Wrap at 72 characters.
   - Follow the repo's existing style if it deviates from the above (e.g. Conventional Commits like `feat:`, `fix:`).

5. Output the final commit message in the conventional commits format inside a fenced code block so the user can copy it easily.

6. Do NOT run `git commit` unless the user explicitly asks you to.
