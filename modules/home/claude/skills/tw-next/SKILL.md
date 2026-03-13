---
name: tw-next
description: Pick the next highest-urgency task from Taskwarrior and plan implementation. Use when user says "/tw-next" or asks to work on the next task.
user_invocable: true
---

Pick the next task from Taskwarrior and create an implementation plan.

## Steps

1. Invoke /taskwarrior for the full command reference
2. IMPORTANT: You MUST filter by the current directory name as the taskwarrior project. Get the project name from the current working directory basename (e.g. if in `~/projects/shrine`, the project is `shrine`). Run `task project:<dirname> next limit:1`. NEVER run `task next` without a project filter.
3. Read the task details including annotations: `task ID info`
3. Analyze the task description and any annotations for context
4. Look at the current project/codebase to understand what's needed
5. Enter plan mode and create a step-by-step implementation plan
6. Present the plan and wait for user approval before starting work
