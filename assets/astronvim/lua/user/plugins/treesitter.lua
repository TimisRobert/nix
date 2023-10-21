local utils = require "astronvim.utils"

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
    if opts.ensure_installed ~= "all" then
      -- Elixir
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "elixir")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "heex")
      -- Nix
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "nix")
      -- Bash
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "bash")
      -- Svelte
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "svelte")
      -- Typescript
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "javascript")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "typescript")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "tsx")
      -- Json
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "json")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "jsonc")
      -- HTML CSS
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "html")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "css")
      -- Yaml
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "yaml")
      -- Zig
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "zig")
      -- Java
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "java")
    end
  end,
}
