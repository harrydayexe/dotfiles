#!/usr/bin/env bash
# Validate a justfile and every module it declares, using just's own tooling.
#
# Usage: validate.sh [path/to/justfile-or-module-file]
#   With no argument, validates the justfile `just` would find from $PWD.
#
# Checks (never runs recipes or evaluates backticks):
#   1. `just --summary`       parses the whole module tree
#   2. `just --fmt --check`   on the root and on every module source file
#                             (--fmt --check alone skips module files)
#   3. parser warnings from `--dump --dump-format json`
#
# Exit status: 0 if all checks pass, 1 otherwise.
set -uo pipefail

if ! command -v just >/dev/null 2>&1; then
  echo "validate.sh: 'just' is not installed or not on PATH" >&2
  exit 1
fi

target="${1:-}"
if [[ -z "$target" ]]; then
  # Let just resolve the justfile the same way it would when invoked here.
  target="$(just --dump --dump-format json 2>/dev/null | jq -r '.source // empty' 2>/dev/null || true)"
  if [[ -z "$target" ]]; then
    echo "validate.sh: no justfile found from $PWD (pass a path explicitly)" >&2
    exit 1
  fi
fi

if [[ ! -f "$target" ]]; then
  echo "validate.sh: $target does not exist" >&2
  exit 1
fi

failed=0
echo "just $(just --version | awk '{print $2}') — validating $target"

# 1. Parse the whole tree (modules included).
if ! parse_out="$(just --justfile "$target" --summary 2>&1)"; then
  echo "✗ parse failed:" >&2
  echo "$parse_out" >&2
  echo "  hint: check syntax against the installed version — just --changelog | grep -i '<feature>'" >&2
  exit 1
fi
echo "✓ parses (recipes: ${parse_out:-<none>})"

# 2. Collect the root plus every module source, recursively.
sources=("$target")
warnings=""
if command -v jq >/dev/null 2>&1; then
  dump="$(just --justfile "$target" --dump --dump-format json 2>/dev/null)"
  while IFS= read -r src; do
    [[ -n "$src" ]] && sources+=("$src")
  done < <(jq -r '.. | objects | select(has("modules")) | .modules[]?.source // empty' <<<"$dump" | sort -u)
  warnings="$(jq -r '.. | objects | select(has("warnings")) | .warnings[]? | tostring' <<<"$dump")"
else
  echo "! jq not found: module files are not format-checked" >&2
fi

for src in "${sources[@]}"; do
  if fmt_out="$(just --justfile "$src" --fmt --check 2>&1)"; then
    echo "✓ formatted: $src"
  else
    failed=1
    echo "✗ not canonically formatted: $src (fix with: just --justfile '$src' --fmt)" >&2
    echo "$fmt_out" >&2
  fi
done

# 3. Parser warnings.
if [[ -n "$warnings" ]]; then
  failed=1
  echo "✗ warnings:" >&2
  echo "$warnings" >&2
fi

# 4. Deprecated settings that just itself doesn't warn about. The replacement
#    (conditional attributes on settings) needs just >= 1.56.
version="$(just --version | awk '{print $2}')"
if [[ "$(printf '%s\n' 1.56.0 "$version" | sort -V | head -1)" == "1.56.0" ]]; then
  for src in "${sources[@]}"; do
    if hits="$(command grep -nE '^[[:space:]]*set[[:space:]]+windows-(shell|powershell)' "$src")"; then
      failed=1
      echo "✗ deprecated setting in $src:" >&2
      echo "$hits" >&2
      echo "  replace with: [windows] set shell := [...] (plus [unix] set shell := [...])" >&2
    fi
  done
fi

if (( failed )); then
  echo "validation FAILED" >&2
  exit 1
fi
echo "validation passed"
