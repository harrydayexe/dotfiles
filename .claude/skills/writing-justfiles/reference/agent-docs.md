# Recording key commands in agent docs

After adding, renaming or removing recipes, keep the project's agent instruction files in sync. Agents then use `just <recipe>` instead of re-deriving raw commands.

## Which file to update (per directory)

Apply this rule in **each directory that owns a justfile or module file**:

1. `CLAUDE.md` exists in that directory (or `.claude/CLAUDE.md` at the repo root): update it.
2. Otherwise, `AGENTS.md` exists: update it.
3. Otherwise, create `AGENTS.md`.

Never create a second instruction file next to an existing one. If both exist, update the one that holds the existing commands section. If neither has one, update `CLAUDE.md`.

## Monorepo levels

| Level | File location | Contents |
|---|---|---|
| Root | repo root | cross-cutting recipes (`just test-all`, `just fmt`, `just ci`), plus a table of modules with how to invoke them (`just api <recipe>`) |
| Module | the module's directory (for `mod api "services/api"`: `services/api/`) | that module's key recipes, written as run from the repo root (`just api test`). If the module is a standalone `justfile`, also note that `just test` works from inside the directory |
| Topic module with no directory (`release.just` beside root) | root file only | list under the root's module table |

Claude Code loads subdirectory CLAUDE.md/AGENTS.md files on demand when it reads files there, so module-level docs reach agents working in that package.

## What to include

- Curate the 5–10 most useful recipes per level: setup, build, test, lint/fmt, dev/run, release/deploy. Don't paste the whole `just --list`.
- Show real invocations with common arguments (`just test ./pkg/...`, `just deploy -e staging`).
- Flag recipes with side effects (`[confirm]`, production deploys) and required env vars.
- Always end with the discovery command, so the list doesn't need to be exhaustive.
- Keep the wording in sync with the recipe doc comments.

## Template

Replace the existing section in place if there is one (look for a `## Commands`, `## Tasks` or `## Development` heading that mentions `just`). Otherwise append:

```markdown
## Commands

Tasks run through [just](https://just.systems). Run `just --list --list-submodules` for everything, and `just --usage <recipe>` for arguments.

| Command | Purpose |
|---|---|
| `just setup` | Install toolchains and dependencies |
| `just build` | Build debug binaries |
| `just test [args]` | Run the test suite; extra args go to the test runner |
| `just lint` | Run linters (CI fails on these) |
| `just fmt` | Format all code |
| `just dev` | Start the app with live reload |
| `just deploy -e <env>` | Deploy (asks for confirmation; needs `AWS_PROFILE`) |

Prefer these recipes over the raw underlying commands.
```

Root file in a monorepo: add a modules table after the commands table:

```markdown
### Modules

| Module | Location | Example |
|---|---|---|
| `api` | `services/api/` | `just api test` |
| `web` | `services/web/` | `just web dev` |

Each module directory has its own AGENTS.md/CLAUDE.md with module-specific commands.
```

## Check before finishing

- Every command in the docs appears in `just --summary` output (module recipes as `api::test`).
- No documented recipe was renamed or removed without updating the docs.
