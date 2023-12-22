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
      -- Lua
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.diagnostics.selene,
      -- Nix
      null_ls.builtins.code_actions.statix,
      null_ls.builtins.formatting.alejandra,
      null_ls.builtins.diagnostics.deadnix,
      -- Bash
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.formatting.shfmt,
      -- Typescript
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.diagnostics.eslint_d,
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
