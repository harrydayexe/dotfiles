---
name: writing-justfiles
description: Writes, edits, reviews and validates idiomatic justfiles for the `just` command runner, grounded in the official manual. Covers recipe documentation and groups, modules (`mod`) for monorepos, OS-gated recipes ([linux]/[macos]/[windows]/[unix]), settings, parameters and dependencies; validates with `just --fmt --check` and `just --summary`; and records key commands in AGENTS.md or CLAUDE.md at each level of a monorepo.
when_to_use: Use whenever creating, editing, reviewing or refactoring a justfile, Justfile, .justfile, *.just or mod.just file, even for a one-line change. Also use when adding, renaming or removing a just recipe, converting a Makefile, package.json scripts, Taskfile or shell scripts to just, setting up a project task runner, or when the user mentions just, `just <recipe>`, recipes or a command runner.
---

# Writing justfiles

## Ground rules

- **Never write just syntax from memory alone.** Features change between releases, and plausible-looking syntax is often invalid. For example, `[any(linux, macos)]` does not exist, `[cache]` only works on script recipes, and `which()` needs the unstable `set lists`. Before using any construct not shown in this skill or its references, probe it against the installed binary:
  ```bash
  just --version
  printf '%s\n' '[linux, macos]' 'foo:' '    echo hi' | just --justfile /dev/stdin --summary
  ```
- To find the version that introduced a feature, run `just --changelog | grep -n -i '<feature>'` (entries sit under `[x.y.z]` release headings). Use it to set `minimum-version`, or to avoid features newer than the installed `just`.
- The authoritative sources are the manual at https://just.systems/man/en/ and the README at https://github.com/casey/just/blob/master/README.md. If a fetched summary contradicts the installed `just`, trust the binary.
- `just --fmt` output is canonical. Write in that style from the start: 4-space indents, `{{ var }}` with inner spaces, and one attribute per line. `--fmt` also reorders attributes and `[arg(...)]` keys, so run `just --fmt` rather than ordering them by hand.

## Workflow

Copy this checklist and tick it off:

```
- [ ] 1. Inspect: just --version; just --list --list-submodules; read existing justfile(s) and agent docs
- [ ] 2. Edit, following the conventions below and the relevant reference file
- [ ] 3. Validate: ~/.claude/skills/writing-justfiles/scripts/validate.sh <path/to/justfile>
- [ ] 4. Fix every error and re-run until it passes (use `just --fmt` to apply formatting)
- [ ] 5. Smoke-test changed recipes safely: just --dry-run <recipe> [args], just --usage <recipe>
- [ ] 6. Update agent docs with key commands. Required, not optional: see "Agent docs" below
```

Step 1: if a justfile already exists, match its style. Never rewrite recipes the user didn't ask about, other than formatting.

Step 5: `--dry-run` prints commands without running them. It skips backticks, and on just ≥ 1.56 also `shell()` calls, so it is safe for checking interpolation and dependency order.

## Core conventions

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

# List available recipes
[private]
default:
    @just --list

# Build the project
[group("build")]
build profile="debug":
    cargo build --profile {{ quote(profile) }}

# Run tests, forwarding extra args to the test runner
[group("test")]
test *args: build
    cargo test {{ args }}

# Delete build artifacts
[confirm("Delete ./target?")]
[group("build")]
clean:
    rm -rf target

_ensure-tool name:
    command -v {{ name }} >/dev/null || { echo "missing {{ name }}" >&2; exit 1; }
```

- **Default recipe:** the first recipe runs when `just` has no arguments. Make it a private `default` that runs `@just --list`, or use `set default-list` (requires just ≥ 1.52; check `just --version`).
- **Shell:** new justfiles use bash strict mode, as above. If Windows needs a different shell, gate the setting: `[unix] set shell := [...]` and `[windows] set shell := ["powershell.exe", "-NoLogo", "-Command"]` (just ≥ 1.56). `set windows-shell` is deprecated. Modules don't inherit settings, so repeat them in each module file. For multi-line logic with control flow, use a `[script("bash")]` recipe or a shebang recipe rather than `\`-continued one-liners. Each line of a normal recipe runs in a *new* shell, so `cd`, `export` and variables do not carry over between lines.
- **Documentation:** every public recipe gets a `#` doc comment on the line directly above it. Use `[group("…")]` once there are about 6+ recipes, and `[arg("name", help="…")]` for parameters whose meaning isn't obvious. See [reference/documentation.md](reference/documentation.md).
- **Private helpers:** prefix with `_` or add `[private]`. Aliases are for genuinely frequent recipes only (`alias b := build`).
- **Naming:** kebab-case recipe names (`build-docs`) and snake_case variables. Verb-first names (`test`, `lint`, `fmt`, `deploy-staging`).
- **Parameters:** give defaults when sensible. Use `*args` to forward flags, `+files` for "one or more", and `$name` to export a parameter as an environment variable. Use `quote()` when interpolating user input into shell.
- **Safety:** add `[confirm]` or `[confirm("prompt")]` to destructive or production recipes. Prefix a line with `-` only when failure is genuinely acceptable.
- **Composition:** express order with dependencies (`release: lint test && tag`) rather than calling `just` recursively. `[parallel]` runs dependencies concurrently.
- **Settings:** add a setting only when needed: `set dotenv-load` for `.env`, `set positional-arguments`, `set export`. Use `set minimum-version := "1.x.0"` when relying on recent features.
- **Tool checks:** `docker := require("docker")` gives a clear error at run time if a tool is missing.

## Modules (monorepos and large justfiles)

Split with `mod` when a justfile grows past about 20–30 recipes, or when subprojects own their own tasks. Recipes in a module run from the module file's directory by default. Settings and variables do not cross module boundaries.

```just
# Backend API tasks
[group("services")]
mod api # api.just, api/mod.just, api/justfile or api/.justfile
mod? local # optional: silently absent if no file
mod deploy "ops/deploy.just"
```

Invoke module recipes as `just api test` or `just api::test`. For resolution rules, `[no-cd]` and a full monorepo layout, see [reference/modules.md](reference/modules.md).

## OS gating

```just
# Open the docs in a browser
[macos]
open-docs:
    open target/doc/index.html

# Open the docs in a browser
[linux]
open-docs:
    xdg-open target/doc/index.html

# Open the docs in a browser
[windows]
open-docs:
    start target\doc\index.html
```

- Stacked conditional attributes combine with OR: put `[linux]` and `[macos]` on separate lines (fmt style), or use `[unix]`. There is no `[any(...)]` or `[not(...)]`.
- Give each variant the same doc comment so `just --list` shows it on every OS.
- For small differences, prefer one recipe with a per-OS variable. On just ≥ 1.56, conditional attributes also work on variables, settings and `mod`: `[windows] set shell := [...]`. On older versions, use an expression: `opener := if os() == "macos" { "open" } else { "xdg-open" }`.

See [reference/platform.md](reference/platform.md).

## Agent docs (always do this)

The user has asked that every justfile change be reflected in the agent instruction files. Do it as part of the task, without asking, whenever recipes are added, renamed or removed.

- **Which file, per directory:** `CLAUDE.md` if it exists, otherwise `AGENTS.md`, otherwise create `AGENTS.md`.
- **Where:** the repo root, plus each module's directory in a monorepo (`mod api "services/api"` → `services/api/`).
- **What:** a `## Commands` section with a table of the key recipes (`just <recipe>`, purpose), ending with "Run `just --list --list-submodules` for everything". Update the section in place if one exists. Curate the list; don't dump all of `just --list`.

Full rules and templates: [reference/agent-docs.md](reference/agent-docs.md).

## References

- [reference/modules.md](reference/modules.md): `mod` syntax, file resolution, working directory, isolation, listing, monorepo layout
- [reference/platform.md](reference/platform.md): OS/arch attributes and functions, cross-platform shells, per-OS patterns
- [reference/documentation.md](reference/documentation.md): doc comments, `[doc]`, groups, `[arg]` help and flags, how `--list` renders
- [reference/syntax-and-settings.md](reference/syntax-and-settings.md): settings, attributes, parameters, dependencies, functions, anti-patterns
- [reference/agent-docs.md](reference/agent-docs.md): which file to update (AGENTS.md or CLAUDE.md), per-module docs, the Commands template

## Validation

Run `scripts/validate.sh [justfile]`. It defaults to the justfile `just` would find from the current directory. It:

- runs `--fmt --check` on the root justfile *and every module file*, because `--fmt --check` alone skips modules
- parses the whole module tree with `--summary`
- reports parser warnings

It never runs recipes or evaluates backticks. A PostToolUse hook also runs it automatically after each justfile edit. Treat its failures as blocking.
