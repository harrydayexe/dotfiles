#!/usr/bin/env bash
# Deny any attempt to read/search the Go module cache on disk.
# Steer the agent to the gopls MCP server instead.
#
# Triggers on: Bash (command field), Read (file_path), Grep/Glob (path).
# Deliberately does NOT inspect Grep/Glob `pattern` to avoid blocking
# legitimate greps for the *text* "GOPATH" inside the repo.
#
# Matches `pkg/mod` only as a whole path segment pair, so a project's own
# `pkg/` tree (pkg/models, pkg/module, ...) is never blocked.

input=$(cat)

haystack=$(printf '%s' "$input" | jq -r '
  [ .tool_input.command,
    .tool_input.file_path,
    .tool_input.path
  ] | map(select(. != null)) | join("\n")')

# The real cache location, if the toolchain can tell us.
modcache=$(go env GOMODCACHE 2>/dev/null)

blocked=0

# pkg/mod as a complete segment pair: preceded by a slash (or string start)
# and followed by a slash or end of token.
if printf '%s' "$haystack" | grep -qE '(^|[^[:alnum:]_.-])pkg/mod(/|$|[^[:alnum:]_.-])'; then
  blocked=1
fi

# Env-var indirection into the cache, e.g. $GOMODCACHE, $(go env GOPATH)/pkg.
if printf '%s' "$haystack" | grep -qE 'GOPATH|GOMODCACHE'; then
  blocked=1
fi

# The resolved cache path itself, in case it lives outside $GOPATH/pkg/mod.
if [ -n "$modcache" ] && printf '%s' "$haystack" | grep -qF "$modcache"; then
  blocked=1
fi

if [ "$blocked" -eq 1 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: do not access the Go module cache on disk (matched GOPATH / GOMODCACHE / pkg/mod). Use the gopls MCP server instead: go_search to find packages/symbols, go_package_api to inspect a package API, or go_file_context to understand file dependencies."}}'
fi
exit 0
