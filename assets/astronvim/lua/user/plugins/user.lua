return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      overrides = function(colors)
        return {
          ["@module"] = { link = "@namespace" },
        }
      end,
    },
  },
}
