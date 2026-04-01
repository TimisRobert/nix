Always use jj (jujutsu) instead of git.
Avoid writing comments, unless asked to do so.
For any named symbol (definition, references, type info, file structure): use LSP first. Fall back to Grep only for strings, comments, config values, or file types without an LSP server.

## Model delegation

You run on Opus with 1M context. Use it for reasoning, planning, and decisions. Delegate everything else:

- Spawn subagents with `model: "haiku"` for: file exploration, symbol search, reading unfamiliar code, any open-ended codebase traversal. These tasks don't need reasoning — just retrieval.
- Spawn subagents with `model: "sonnet"` for: tasks that need code generation or structured output but not deep reasoning.
- Never spawn a subagent on Opus.
- Delegate implementation tasks to a subagent with `model: "sonnet"` rather than implementing directly.
