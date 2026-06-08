#!/usr/bin/env bash
# Reads the session transcript and rewakes Claude if any TodoWrite todos are incomplete.
# Exit 2 = rewake Claude with stdout as a system reminder.
# Exit 0 = let Claude stop normally.

SESSION_ID=$(jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION_ID" ] && exit 0

TRANSCRIPT=$(find ~/.claude/projects -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
[ -z "$TRANSCRIPT" ] && exit 0

INCOMPLETE=$(jq -rs '
  [
    .[] |
    (
      (.message.content // .content // [])[]? |
      select(type == "object") |
      select(.type == "tool_use" and .name == "TodoWrite") |
      .input.todos
    ) // empty
  ] |
  last? // [] |
  .[] |
  select(.status != "completed") |
  "- [" + .status + "] " + .content
' "$TRANSCRIPT" 2>/dev/null)

[ -n "$INCOMPLETE" ] && printf '%s' "$INCOMPLETE" && exit 2
exit 0
