return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-context",
      opts = {
        multiline_threshold = 5,
        trim_scope = "inner",
      },
    },
  },
  opts = function(_, opts)
    opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
      "lua",
      -- Elixir
      "elixir",
      "heex",
      -- Nix
      "nix",
      -- Bash
      "bash",
      -- Svelte
      "svelte",
      -- Typescript
      "javascript",
      "typescript",
      "tsx",
      -- Json
      "json",
      "jsonc",
      -- HTML CSS
      "html",
      "css",
      -- Yaml
      "yaml",
      -- Zig
      "zig",
    })
  end,
}
