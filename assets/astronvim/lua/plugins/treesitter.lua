-- Customize Treesitter

---@type LazySpec
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
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      "lua",
      "elixir",
      "heex",
      "nix",
      "bash",
      "svelte",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "jsonc",
      "html",
      "css",
      "yaml",
      "zig",
      "astro",
    })
  end,
}
