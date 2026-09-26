# Platform and OS gating

Sources: https://just.systems/man/en/ (attributes, functions and settings chapters) and the README's "Enabling and Disabling Recipes" section.

## Contents
- Conditional attributes (semantics, version floors)
- Patterns: per-OS recipes, per-OS variables, inline expressions, per-OS shell, OS-specific modules
- Functions
- Cross-platform tips

## Conditional attributes

`[android]`, `[dragonfly]`, `[freebsd]`, `[linux]`, `[macos]`, `[netbsd]`, `[openbsd]`, `[unix]`, `[windows]`

- An item with no conditional attribute is always enabled.
- Several conditional attributes combine with **OR**. `[linux]` plus `[macos]` means "Linux or macOS". `[unix]` already covers macOS, Linux and the BSDs.
- `just --fmt` puts each attribute on its own line, so write `[linux]` and `[macos]` on separate lines, not `[linux, macos]`.
- There is **no** `[any(...)]`, `[not(...)]` or `[cfg(...)]` syntax. To exclude one OS, list the others.
- **just ≥ 1.56:** conditional attributes work on *all* items: settings, variables, `mod`/`import` and aliases, not just recipes. Before 1.56 they apply to recipes only. Add `set minimum-version := "1.56.0"` if you rely on this.

## Patterns

### 1. Same recipe name, per-OS bodies

Best when the commands differ completely. Repeat the doc comment on each variant so `just --list` shows it on every platform:

```just
# Install system dependencies
[macos]
deps:
    brew bundle

# Install system dependencies
[linux]
deps:
    sudo apt-get install -y $(cat packages.txt)

# Install system dependencies
[windows]
deps:
    winget import -i winget.json
```

### 2. Per-OS variables (just ≥ 1.56)

Best when only a value differs. Keeps one recipe:

```just
[macos]
opener := "open"

[linux]
opener := "xdg-open"

[windows]
opener := "start"

# Open the built docs
docs-open:
    {{ opener }} target/doc/index.html
```

### 3. Inline expression

Works on any version and suits one-off differences:

```just
opener := if os() == "macos" { "open" } else if os() == "windows" { "start" } else { "xdg-open" }
exe := if os_family() == "windows" { ".exe" } else { "" }
```

### 4. Per-OS shell (replaces the deprecated `set windows-shell`)

```just
[unix]
set shell := ["bash", "-euo", "pipefail", "-c"]

[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]
```

`set windows-shell` and `set windows-powershell` are deprecated. Use pattern 4 on just ≥ 1.56; otherwise keep `windows-shell` only if the file must support older versions.

### 5. OS-specific modules

```just
[macos]
mod? macos "platform/macos.just"
```

## Functions

| Function | Returns |
|---|---|
| `os()` | `"macos"`, `"linux"`, `"windows"`, `"freebsd"`, `"android"`, … |
| `os_family()` | `"unix"` or `"windows"` |
| `arch()` | `"aarch64"`, `"x86_64"`, `"arm"`, … |
| `num_cpus()` | logical CPU count, as a string |
| `env("NAME", "default")` | environment variable with a fallback |
| `require("tool")` | absolute path to `tool`, or an error at run time if not on PATH (≥ 1.39) |
| `path_exists(p)` | `"true"` / `"false"` |
| `a / b`, `join(a, b)` | path join, `/` separator |

`which()` exists but needs unstable `set lists` on just ≥ 1.53. Prefer `require()`, or `command -v` inside the recipe.

## Cross-platform tips

- Shebang recipes on Windows translate interpreter paths containing `/` with `cygpath`. To avoid needing Cygwin, use a bare interpreter name (`#!pwsh`) or `[script("pwsh")]`.
- Keep portable logic in a language available everywhere (`[script("python3")]`, `uv run`, `node`) rather than branching bash vs PowerShell for complex tasks.
- Gate recipes that only make sense on one OS (`[macos] notarize:`) rather than letting them fail at run time.
- Validate on the current OS with `scripts/validate.sh`. Parsing checks every variant regardless of OS, but only the current OS's variant appears in `--list`/`--summary`.
