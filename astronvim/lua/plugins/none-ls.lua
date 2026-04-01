---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  opts = function(_, opts)
    local null_ls = require "null-ls"

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.opentofu_fmt,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.buf,
      null_ls.builtins.diagnostics.buf,
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
