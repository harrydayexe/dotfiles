#!/usr/bin/env bash
# After a justfile is edited, validate it with just's own tooling (parse,
# canonical formatting of the file and its modules, parser warnings) and feed
# any failure back to the agent.
#
# Triggers on: Edit/Write/MultiEdit whose file_path is a justfile
# (justfile, Justfile, .justfile, *.just).

input=$(cat)

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

case "$(basename -- "$file")" in
  justfile | Justfile | JUSTFILE | .justfile | *.just) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0
command -v just >/dev/null 2>&1 || exit 0

validator="$HOME/.claude/skills/writing-justfiles/scripts/validate.sh"
[ -x "$validator" ] || exit 0

if ! out=$("$validator" "$file" 2>&1); then
  {
    echo "justfile validation failed for $file:"
    echo "$out"
    echo "Fix these issues (for formatting, run: just --justfile '$file' --fmt) and re-validate."
  } >&2
  exit 2
fi
exit 0
