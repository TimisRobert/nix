return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.selene,
      -- null_ls.builtins.formatting.prettierd,
      -- null_ls.builtins.formatting.nixfmt,
      -- null_ls.builtins.formatting.mix.with {
      --   extra_filetypes = { "heex" },
      -- },
      null_ls.builtins.diagnostics.credo.with {
        condition = function(utils) return utils.root_has_file { ".credo.exs" } end,
      },
    }
    return config -- return final config table
  end,
}
