# Modules

Source: https://just.systems/man/en/modules.html. Modules are stable since just 1.31.

## Contents
- Declaring
- Invoking (including module recipes as dependencies)
- Working directory
- Isolation
- `import` vs `mod`
- Monorepo layout (full example)

## Declaring

```just
# Backend API tasks
[group("services")]
mod api # searches api.just, api/mod.just, api/justfile, api/.justfile

mod? local # optional: no error if no source file exists
mod deploy "ops/deploy.just" # explicit path to a file or directory
```

- Prefer `name/mod.just` for a module that belongs to a subdirectory (package/service). Prefer `name.just` beside the root justfile for a topic split of a large single-project justfile (`docker.just`, `release.just`).
- Use a plain `name/justfile` when the subproject should also work standalone (`cd api && just test`). Running `just` inside `api/` then finds `api/justfile` first. A `mod.just` is only reachable through the parent.
- `mod?` suits developer-local overrides (`mod? local` plus `local.just` in `.gitignore`).
- `[doc("…")]` and `[group("…")]` work on `mod` statements, as do doc comments on the line above (shown in `just --list`).

## Invoking

```bash
just api test          # subcommand style
just api::test         # path style
just api               # runs the api module's default (first or [default]) recipe
just --list api        # list one module
just --list --list-submodules   # full tree
just --usage api::test
```

Parent recipes can depend on module recipes (just ≥ 1.42). Prefer this to shelling out to `just`, because dependencies are deduplicated and can run with `[parallel]`:

```just
# Build every service
[parallel]
build-all: api::build web::build
```

A module recipe that depends on an absent `mod?` module is disabled rather than erroring.

## Working directory

- Recipes in a module run with the working directory set to **the module file's directory**, not the invocation directory or the root.
- Use `[no-cd]` on a recipe to run it from the directory `just` was invoked in. Use `[working-directory("path")]` for an explicit directory.
- `justfile()` and `justfile_directory()` always refer to the **root** justfile. `source_file()` and `source_directory()` refer to the current module file. Use `source_directory()` when a module needs paths relative to itself in expressions.

## Isolation

- Each module has its own recipes, aliases, variables and **settings**. Re-declare `set shell := [...]`, `set dotenv-load` and similar in each module file that needs them. They are not inherited: a module without `set shell` runs under `sh -cu` even when the root uses bash.
- Variables can't be referenced across modules. Share values through environment variables (exported variables in the parent are visible to children) or duplicate the small constant.
- Each module loads its own `.env` when `dotenv-load` is set.

## `import` vs `mod`

- `import "path.just"` inlines another file into the *same* namespace (recipes appear top-level; settings merge). Use it for shared helpers or variables.
- `mod` creates a *namespace*. Use it for subprojects and to keep `--list` navigable.
- `import? "path"` is optional, like `mod?`.

## Monorepo layout

```
repo/
├── justfile             # root: settings, default, cross-cutting recipes, mod declarations
├── AGENTS.md            # (or CLAUDE.md) root commands + module entrypoints
├── services/
│   ├── api/
│   │   ├── mod.just     # api tasks; runs in services/api/
│   │   └── AGENTS.md    # api-specific commands
│   └── web/
│       ├── mod.just
│       └── AGENTS.md
└── tools/release.just   # topic module, no own directory
```

Root `justfile`:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

# Backend API
[group("services")]
mod api "services/api"

# Frontend web app
[group("services")]
mod web "services/web"

# Release tooling
mod release "tools/release.just"

# List all recipes, including modules
[private]
default:
    @just --list --list-submodules

# Run every service's tests
[group("ci")]
test-all: api::test web::test
```

`services/api/mod.just`:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

# Run the API test suite
test *args:
    go test ./... {{ args }}

# Start the API with live reload
dev:
    air
```

Validate the whole tree with `scripts/validate.sh`. `just --fmt --check` on the root alone does **not** check module files.
