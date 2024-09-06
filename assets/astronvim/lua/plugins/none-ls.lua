-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      null_ls.builtins.formatting.opentofu_fmt,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.selene,
      null_ls.builtins.code_actions.statix,
      null_ls.builtins.formatting.alejandra,
      null_ls.builtins.diagnostics.deadnix,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.diagnostics.credo.with {
        condition = function(utils) return utils.root_has_file { ".credo.exs" } end,
      },
    }
    return config -- return final config table
  end,
}
