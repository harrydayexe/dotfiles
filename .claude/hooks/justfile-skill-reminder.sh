#!/usr/bin/env bash
# Make sure the writing-justfiles skill is loaded before the agent edits a
# justfile.
#
# Triggers on: Edit/Write/MultiEdit whose file_path is a justfile
# (justfile, Justfile, .justfile, *.just).
#
# If the session transcript doesn't yet contain the skill's body, the first
# justfile edit of the session is denied with a reason telling the agent to
# load the skill and retry. The deny happens at most once per session (marker
# file), so the agent can never get stuck in a loop.
# (additionalContext on PreToolUse only arrives *after* the edit runs, which
# is too late, hence the deny.)

input=$(cat)

file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
session=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

case "$(basename -- "$file")" in
  justfile | Justfile | JUSTFILE | .justfile | *.just) ;;
  *) exit 0 ;;
esac

# A sentence that only appears once SKILL.md has been loaded into the session.
sentinel='Never write just syntax from memory alone.'
if [ -n "$transcript" ] && [ -f "$transcript" ] && command grep -qF "$sentinel" "$transcript"; then
  exit 0
fi

marker="${TMPDIR:-/tmp}/claude-justfile-skill-${session}"
[ -e "$marker" ] && exit 0
touch "$marker"

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"This edit touches a justfile. Load the writing-justfiles skill with the Skill tool first, follow its conventions, then retry this exact edit. (If the skill is already loaded, just retry.)"}}'
exit 0
