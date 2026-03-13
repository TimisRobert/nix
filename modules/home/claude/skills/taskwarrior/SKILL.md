---
name: taskwarrior
description: Manage tasks using Taskwarrior. Use when the user mentions "taskwarrior" or "task warrior" explicitly.
---

Use the `task` CLI (Taskwarrior 3) via Bash to manage tasks. Always show output after mutations.

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

## Reminders

Taskwarrior hooks automatically schedule desktop notifications via `systemd-run` for any task with a `due` date. Modifying or completing a task updates/cancels the notification. No manual notification setup needed — just set a due date.
