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
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "elixir")
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "heex")
    end
  end,
}
