---
name: taskwarrior
description: Manage tasks using Taskwarrior. Use when the user mentions "taskwarrior" or "task warrior" explicitly, or asks to work on the next task.
user_invocable: true
---

Use the `task` CLI (Taskwarrior 3) via Bash to manage tasks. Always show output after mutations.

The `task` command works within the sandbox — do not disable it.

For any operation that requires confirmation (delete, undo, bulk modifications, etc.), pass `rc.confirmation=off` to suppress interactive prompts. Example: `task rc.confirmation=off ID delete`.

## Adding Tasks

```
task add "description" [due:DATE] [project:NAME] [priority:H|M|L] [+tag]
```

Infer project/tags/priority from context when not explicit. "remind me to review the PR for work" → `task add "review the PR" project:work`.

## Dates

`today`, `tomorrow`, `monday`, `friday`, `eow` (end of week), `eom` (end of month), `eoy` (end of year), `2026-03-15`, `3d` (in 3 days), `1w` (in 1 week).

## Common Operations

```
task list
task project:work list
task +OVERDUE list
task due:today list
task due.before:eow list
task ID done
task ID modify due:tomorrow
task ID modify priority:H
task ID annotate "note"
task ID delete
```

## Next Task

When asked to work on the next task or pick a task:

1. Filter by the current directory name as the project: `task project:<dirname> next limit:1`. NEVER run `task next` without a project filter.
2. Read task details and annotations: `task <ID> info`
3. Analyze the codebase to understand what's needed
4. Enter plan mode with a step-by-step implementation plan
5. Wait for user approval before starting work

