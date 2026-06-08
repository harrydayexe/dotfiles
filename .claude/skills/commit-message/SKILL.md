---
name: commit-message
description: Generate a concise, well-formed commit message for the current uncommitted changes.
---
# commit-message Skill

## Purpose
Generate a concise, well-formed commit message for the current uncommitted changes, strictly following the Conventional Commits specification.

## Steps

1. Run `git diff --staged` to see staged changes. If there are none, run `git diff` to see unstaged changes. If there are still none, check `git status` for untracked files and inform the user there is nothing to commit.

2. Run `git log --oneline -10` to understand the commit style and conventions used in this repo.

3. Analyse the diff: understand what changed, why it likely changed (infer from context), and what the effect is.

4. Check the current conversation for any GitHub issue numbers the user mentioned working on. If any are present and the commit resolves that issue, include a `Closes #<number>` (or `Fixes #<number>`) footer.

5. Write a commit message following the **Conventional Commits 1.0.0 specification**:

   ### Format
   ```
   <type>[optional scope]: <description>

   [optional body]

   [optional footer(s)]
   ```

   ### Rules
   - **type** MUST be a noun: `feat`, `fix`, `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, or `test`.
   - **feat** — new feature (SemVer MINOR bump).
   - **fix** — bug patch (SemVer PATCH bump).
   - **scope** is optional; if used, it MUST be a noun in parentheses, e.g. `feat(auth):`.
   - A `!` MAY be appended before the colon to signal a breaking change, e.g. `feat!:` or `feat(api)!:`.
   - The **description** MUST immediately follow `<type>[scope]: ` — imperative mood, no trailing period, ≤72 characters for the whole first line.
   - The **body** is optional. If present, it MUST be separated from the description by one blank line, and MUST explain the *why* (not the *what*). Wrap at 72 characters.
   - **Footers** are optional. Each footer token uses the format `Token: value` or `Token #value` (git trailer convention). `BREAKING CHANGE` (or `BREAKING-CHANGE`) MUST be a footer when a breaking change is not already signalled by `!`.
   - Breaking changes appear in MAJOR SemVer bumps regardless of type.

   ### Issue linking (when applicable)
   If a GitHub issue number was mentioned in this conversation and the commit resolves it, add a footer on its own line:
   ```
   Closes #<issue-number>
   ```
   Use `Fixes` instead of `Closes` if the issue is a bug fix.

6. Output the final commit message inside a fenced code block so the user can copy it easily.

7. Do NOT run `git commit` unless the user explicitly asks you to.
