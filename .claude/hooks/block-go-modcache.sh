#!/usr/bin/env bash
# Deny any attempt to read/search the Go module cache on disk.
# Steer the agent to the gopls MCP server instead.
#
# Triggers on: Bash (command field), Read (file_path), Grep/Glob (path).
# Deliberately does NOT inspect Grep/Glob `pattern` to avoid blocking
# legitimate greps for the *text* "GOPATH" inside the repo.

input=$(cat)

haystack=$(printf '%s' "$input" | jq -r '
  [ .tool_input.command,
    .tool_input.file_path,
    .tool_input.path
  ] | map(select(. != null)) | join("\n")')

if printf '%s' "$haystack" | grep -qE 'pkg/mod|GOPATH|GOMODCACHE'; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: do not access the Go module cache on disk (matched GOPATH / GOMODCACHE / pkg/mod). Use the gopls MCP server instead: go_search to find packages/symbols, go_package_api to inspect a package API, or go_file_context to understand file dependencies."}}'
fi
exit 0
