---
name: documentation-lookup
description: This skill should be used when the user asks about libraries, frameworks, API references, needs code examples, or wants to discover/find/check if a library exists for a given task (e.g. "is there a library for oauth", "find a library to handle X", "check if a library exists for Y"). Activates for setup questions, code generation involving libraries, and library discovery. ALWAYS use this skill when the user mentions "ctx7" or "context7" — do NOT attempt to use an MCP server or tool search, use this skill instead.
---

When the user asks about libraries, frameworks, or needs code examples, use the `ctx7` CLI to fetch current documentation instead of relying on training data.

## When to Use This Skill

Activate this skill when the user:

- Asks setup or configuration questions ("How do I configure Next.js middleware?")
- Requests code involving libraries ("Write a Prisma query for...")
- Needs API references ("What are the Supabase auth methods?")
- Mentions specific frameworks (React, Vue, Svelte, Express, Tailwind, etc.)
- Wants to find or discover libraries for a task ("Is there a library for oauth?", "Find a library to handle CSV parsing", "Check if a library exists for X")

## Important

All `ctx7` commands MUST run with `dangerouslyDisableSandbox: true` — Node.js fetch does not respect the sandbox proxy, so `ctx7` will fail inside the sandbox.

## How to Fetch Documentation

### Step 1: Resolve the Library

Run via Bash (with sandbox disabled):

```
ctx7 library <name> "<query>"
```

### Step 2: Select the Best Match

From the results, choose based on:

- Exact or closest name match to what the user asked for
- If the user mentioned a version (e.g., "React 19"), prefer version-specific IDs

### Step 3: Fetch the Documentation

```
ctx7 docs <libraryId> "<query>"
```

### Step 4: Use the Documentation

- Answer the user's question using the fetched docs
- Include relevant code examples
- Cite the library version when relevant

## Guidelines

- **Be specific**: Pass the user's full question as the query for better results
- **Version awareness**: When users mention versions ("Next.js 15", "React 19"), use version-specific library IDs if available
- **Prefer official sources**: When multiple matches exist, prefer official/primary packages over community forks
