return {
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- Packs
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.svelte" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.yaml" },
  -- { import = "astrocommunity.pack.lua" },
  -- Motion
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  -- Colorscheme
  { import = "astrocommunity.colorscheme.kanagawa-nvim", enabled = true },
}
