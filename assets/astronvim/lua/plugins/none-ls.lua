-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Set a formatter
      null_ls.builtins.formatting.opentofu_fmt,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.black,
      null_ls.builtins.diagnostics.selene,
      null_ls.builtins.code_actions.statix,
      null_ls.builtins.formatting.alejandra,
      null_ls.builtins.diagnostics.deadnix,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.diagnostics.credo.with {
        condition = function(utils) return utils.root_has_file { ".credo.exs" } end,
      },
    })
  end,
}
