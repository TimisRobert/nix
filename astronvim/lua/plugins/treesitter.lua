-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "terraform",
      "elixir",
      "heex",
      "nix",
      "bash",
      "svelte",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "jsonc",
      "html",
      "css",
      "yaml",
      "zig",
      "astro",
    },
  },
}
