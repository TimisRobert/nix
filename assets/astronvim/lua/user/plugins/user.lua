return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      overrides = function(colors)
        return {
          ["@variable.parameter"] = { link = "@parameter" },
          ["@variable.member"] = { link = "@field" },
          ["@module"] = { link = "@namespace" },
          ["@number.float"] = { link = "@float" },
          ["@string.special.symbol"] = { link = "@symbol" },
          ["@string.regexp"] = { link = "@string.regex" },
          ["@markup.strong"] = { link = "@text.strong" },
          ["@markup.italic"] = { link = "@text.emphasis" },
          ["@markup.heading"] = { link = "@text.title" },
          ["@markup.raw"] = { link = "@text.literal" },
          ["@markup.quote"] = { link = "@text.quote" },
          ["@markup.math"] = { link = "@text.math" },
          ["@markup.environment"] = { link = "@text.environment" },
          ["@markup.environment.name"] = { link = "@text.environment.name" },
          ["@markup.link.url"] = { link = "@text.uri" },
          ["@markup.link.label"] = { link = "@string.special" },
          ["@markup.list"] = { link = "@punctuation.special" },
          ["@comment.note"] = { link = "@text.note" },
          ["@comment.warning"] = { link = "@text.warning" },
          ["@comment.danger"] = { link = "@text.danger" },
          ["@diff.plus"] = { link = "@text.diff.add" },
          ["@diff.minus"] = { link = "@text.diff.delete" },
        }
      end,
    },
  },
}
