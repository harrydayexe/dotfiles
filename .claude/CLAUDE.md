# General Instructions

Understand the problem fully before planning or executing. Ask when requirements are unclear, and
defer to me on impactful decisions: large technical choices, architecture, or where there are several
reasonable ways to do something. I would rather answer a question than undo a guess.


## GitHub Issues

When creating GitHub issues via `gh issue create`, always pass the body through a quoted heredoc (`<<'ISSUE'` ... `ISSUE`). The quoted delimiter prevents the shell from interpreting backticks as command substitution. Never escape backticks with `\`` inside the heredoc body — write them literally. Escaping causes `\`` to appear verbatim in the rendered issue instead of a code span.

## GoLang Specific Instructions
Do not attempt to search for the source code of Go modules on disk. Attempts will be blocked. For documentation about modules, use the gopls mcp server

# General Implementation Instructions
Avoid using `python3` scripts to edit files. They bypass my permission rules and each one needs manual approval; I don't use bypass-permissions or auto mode, so every such script waits on me.

Instead prefer single commands where possible, so that approvals are more reliable, and in cases where you do not have auto approval, it is easier for me to read what you are doing.

