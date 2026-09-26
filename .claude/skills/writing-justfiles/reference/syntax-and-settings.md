# Syntax, settings and attributes

Sources: https://just.systems/man/en/ and `just --changelog` (version floors below come from it). Probe anything not listed here with `just --justfile /dev/stdin --summary`.

## Contents
- Settings
- Recipe attributes
- Parameters
- Dependencies
- Recipe lines and bodies
- Variables and expressions
- Anti-patterns

## Settings

Declare settings at the top of the file, before any recipes. Add only the ones you need.

| Setting | Use | Since |
|---|---|---|
| `set shell := ["bash", "-euo", "pipefail", "-c"]` | shell for recipe lines and backticks (default is `sh -cu`) | — |
| `set dotenv-load` | load `.env` if present | — |
| `set dotenv-required` / `dotenv-path := "…"` / `dotenv-filename := "…"` | require or relocate the env file | 1.16–1.28 |
| `set dotenv-override` | `.env` wins over the existing environment | 1.41 |
| `set export` | export all variables as env vars (prefer per-variable `export x := …`) | — |
| `set positional-arguments` | also pass args as `$1…`/`$@` | — |
| `set quiet` | don't echo lines (`[no-quiet]` to opt a recipe back in) | 1.23 |
| `set working-directory := "…"` | base directory for recipes and backticks | 1.33 |
| `set no-exit-message` | suppress "recipe failed" lines | 1.39 |
| `set lazy` | don't evaluate unused variables (avoids slow or side-effect backticks) | 1.47 |
| `set no-cd` | recipes run in the invocation directory | 1.51 |
| `set default-list` | bare `just` lists recipes | 1.52 |
| `set default-script` | recipes default to script (not per-line) mode; `[shell]` opts out | 1.52 |
| `set minimum-version := "1.52.0"` | fail clearly on older just | 1.55 |
| `set indentation := "  "` | formatter indentation (default 4 spaces) | 1.56 |
| `set allow-duplicate-recipes` / `allow-duplicate-variables` | later definitions override earlier ones; avoid, and use OS attributes instead | — / 1.27 |
| `set fallback` | search parent directories when a recipe isn't found | — |
| `set tempdir := "…"`, `set script-interpreter := [...]` | script temp files / `[script]` default interpreter (`sh -eu`) | 1.7 / 1.33 |
| `set unstable` | enable unstable features (e.g. `set lists`); avoid in shared repos | 1.31 |

Deprecated: `set windows-shell` and `set windows-powershell`. Use `[windows] set shell := [...]` (≥ 1.56); see platform.md.

## Recipe attributes

| Attribute | Purpose | Since |
|---|---|---|
| `[private]` | hide from `--list` | 1.10 |
| `[doc("…")]` / `[doc]` | set / suppress description | 1.27 |
| `[group("…")]` | list heading; repeatable | 1.27 |
| `[confirm]` / `[confirm("prompt")]` | ask before running (`--yes` skips) | 1.17 / 1.23 |
| `[default]` | mark the module's default recipe instead of relying on file order | 1.43 |
| `[no-cd]` | run in the invocation directory | 1.9 |
| `[working-directory("path")]` | run in a specific directory | 1.38 |
| `[script]` / `[script("python3")]` | run the body as one script (default interpreter `sh -eu`) | 1.33 |
| `[shell]` | force per-line mode when `default-script` is set | 1.52 |
| `[extension(".py")]` | temp-file extension for script/shebang recipes | 1.32 |
| `[positional-arguments]` | per-recipe positional args | 1.29 |
| `[parallel]` | run this recipe's dependencies concurrently | 1.42 |
| `[env("NAME", "value")]` | set an env var for the recipe | 1.47 |
| `[no-exit-message]` / `[exit-message]` | control failure messages | 1.7 / 1.39 |
| `[no-quiet]` | echo lines despite `set quiet` | 1.23 |
| `[metadata("…")]` | arbitrary metadata, visible in the JSON dump | 1.42 |
| `[continue(...)]` | keep going on the given signals | 1.54 |
| `[cache]` | skip if a cache entry exists; **script recipes only** | 1.54 |
| `[timestamp]` / `[timestamp("fmt")]` | print timestamps for command lines | 1.58 |
| `[arg(...)]` | parameter help, options and validation; see documentation.md | 1.45+ |
| OS attributes | see platform.md | 1.8+ |

Attributes go one per line above the recipe. The `[group: "x"]` shorthand parses, but `--fmt` rewrites it to `[group("x")]`, so write the call form.

## Parameters

```just
# Build a target
build target="debug" *flags:
    cargo build --profile {{ quote(target) }} {{ flags }}

# Format the given files (at least one)
fmt +files:
    prettier --write {{ files }}

# Run with RUST_LOG exported to the environment
run $RUST_LOG="info":
    cargo run
```

- Required parameters first, then defaulted ones, then at most one variadic (`+` one-or-more, `*` zero-or-more).
- `$name` exports the parameter as an environment variable for that recipe.
- Interpolated values are pasted into shell source. Use `{{ quote(x) }}` for single values that might contain spaces or quotes. Variadics are space-joined, so with `set positional-arguments` use `"$@"` for correct quoting.
- Defaults can be expressions: `target=os()`.

## Dependencies

```just
release: lint test && tag publish
tag version=`git describe --tags`:
    git tag {{ version }}
deploy env: (build "release") (migrate env)
```

- Prior dependencies (before `&&`) run first; subsequent ones (after `&&`) run after the recipe body succeeds.
- `(recipe "arg")` passes arguments to a dependency. Each unique recipe-plus-arguments pair runs **once** per invocation.
- `api::build` depends on a module recipe (≥ 1.42).
- Add `[parallel]` to run the prior dependencies concurrently.
- Prefer dependencies to calling `just other` inside a body.

## Recipe lines and bodies

- `@line` doesn't echo this line; `@recipe:` inverts echoing for the whole recipe.
- `-line` ignores this line's failure.
- **Each line runs in a separate shell.** `cd`, `export` and shell variables don't persist. Use `[working-directory]`, `&&` on one line, or a `[script]` recipe.
- Multi-line logic uses `[script("bash")]` (preferred; clean, and `--fmt` handles it) or a shebang recipe (`#!/usr/bin/env bash` then `set -euo pipefail`).
- Write a literal `{{` as `{{{{` or `{{ "{{" }}`.

## Variables and expressions

```just
version := `git describe --tags --always`
export DATABASE_URL := env("DATABASE_URL", "postgres://localhost/dev")
[private]
build_dir := justfile_directory() / "target"
image := "ghcr.io/org/app:" + version
```

- Top-level backticks run whenever *any* recipe runs, even one that doesn't use them. `--list`, `--summary` and `--dry-run` don't run them. `set lazy` (≥ 1.47) skips unused ones. Keep backticks cheap and side-effect free, or move them into recipes.
- `shell("cmd", args...)` is a function alternative to backticks.
- Useful functions: `env()`, `require()`, `quote()`, `replace()`, `trim()`, `uppercase()`, `path_exists()`, `invocation_directory()`, `justfile_directory()`, `source_directory()`, `datetime("%Y-%m-%d")`, `uuid()`, `sha256_file()`, `error("msg")`.
- Conditionals: `if a == b { x } else if c =~ 'regex' { y } else { z }`.
- Override from the command line: `just version=1.2.3 release` or `just --set version 1.2.3 release`.

## Anti-patterns

| Don't | Do |
|---|---|
| `cd sub` on one line, then work on the next | `[working-directory("sub")]` or `cd sub && …` |
| Long `\`-continued shell pipelines | `[script("bash")]` recipe |
| Recursive `just other-recipe` in bodies | dependencies, or `(recipe "arg")` |
| Unquoted `{{ user_input }}` in shell | `{{ quote(user_input) }}` or `$`-exported params |
| Two recipes with the same name and no OS gate plus `allow-duplicate-recipes` | OS attributes or per-OS variables |
| Expensive backticks at top level | `set lazy`, or compute inside the recipe |
| Undocumented public recipes | a doc comment on every public recipe |
| `set export` when one variable needs exporting | `export NAME := …` |
| `set unstable` / unstable features in shared repos | stable equivalents (`require()` over `which()`) |
| Hand-aligned formatting | `just --fmt` |
