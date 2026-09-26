# Documenting justfiles

Source: https://just.systems/man/en/ (documentation comments, groups and attributes chapters).

`just --list` is the justfile's user interface. Every public recipe and module should be understandable from it alone.

## Doc comments

A `#` comment on the line **directly** above a recipe or `mod` becomes its description in `just --list`. A blank line in between breaks the association.

```just
# Build release binaries for all targets
build-release:
    cargo build --release
```

renders as `build-release # Build release binaries for all targets`.

- Write them in the imperative, one line, no trailing period: "Run the test suite", not "This recipe runs tests."
- Say what the recipe *does* for the user, not how: "Start the dev server with live reload", not "Run air".
- Mention side effects or prerequisites that matter: "Deploy to production (requires AWS_PROFILE)".

## `[doc]` attribute (≥ 1.27)

```just
# internal note for maintainers: keep in sync with CI
[doc("Run the full CI pipeline locally")]
ci: lint test
```

- `[doc("text")]` overrides the comment. Use it when the comment above the recipe is for maintainers, not users.
- A bare `[doc]` suppresses documentation entirely.
- It also works on `mod` statements.

## Groups (≥ 1.27; on modules ≥ 1.33)

```just
# Run unit tests
[group("test")]
test:
    go test ./...

# Run linters
[group("check")]
[group("test")]
lint:
    golangci-lint run
```

- `just --list` prints a heading per group (`[test]`), with ungrouped recipes first.
- A recipe can be in several groups.
- `just --groups` lists group names; `just --list --group test` (or `JUST_GROUP=test`) filters to one group.
- Use a small, consistent vocabulary, for example `build`, `test`, `check`, `dev`, `release`, `ci`, `docs`, `db`, `deploy`. Don't bother with groups under about 6 recipes.
- Order in `--list` is alphabetical within a group unless the user runs `just --list --unsorted`.

## Parameters: `[arg]` (≥ 1.45; help/long/short ≥ 1.46)

```just
# Deploy the app to an environment
[arg("verbose", long, value="true")]
[arg("env", short="e", pattern="dev|staging|prod", help="Target environment")]
deploy verbose="false" env="dev":
    ./deploy.sh --env {{ quote(env) }} --verbose={{ verbose }}
```

- `help="…"` appears in `just --usage deploy`.
- `long` / `long="name"` and `short="e"` turn a parameter into an option (`--env prod`, `-e prod`). `long` alone uses the parameter name.
- `value="true"` makes an option a value-less flag: `just deploy --verbose`. Give that parameter a default for when it's absent.
- `pattern="regex"` validates input before the recipe runs.
- `min` and `max` (≥ 1.56) bound variadic counts.
- `[arg(..., flag)]` and `which()` require unstable `set lists`. Don't use them unless the project already enables unstable features.
- Recipes with options show `[OPTIONS]` in `--list`, and `just --usage <recipe>` prints full help. Mention `--usage` in agent docs for recipes with options.

## Private recipes, aliases and variables

- `_name` or `[private]` hides a recipe from `--list` (it can still be invoked). Use this for helpers and the `default` recipe.
- `[private]` on an assignment hides it from `just --variables` / `--evaluate`.
- `alias t := test` appears as `test # … [alias: t]`. Add aliases sparingly, for the 2–3 most-typed recipes.

## Listing flags worth knowing

```bash
just --list                      # grouped, documented list
just --list --list-submodules    # include module recipes inline
just --list api                  # one module
just --summary                   # names only, space separated (scripts/CI)
just --show build                # print a recipe's source
just --usage deploy              # parameter/option help
just --groups                    # group names
just --dump --dump-format json   # machine-readable, including docs, groups and attributes
```
