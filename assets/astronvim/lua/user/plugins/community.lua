return {
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- Packs
  -- Motion
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  -- Colorscheme
  { import = "astrocommunity.colorscheme.kanagawa-nvim", enabled = true },
}
