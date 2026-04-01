---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
      },
      disabled = {
        "ts_ls",
      },
      timeout_ms = 1000,
    },
    servers = {
      "helm_ls",
      "ruff",
      "pyright",
      "taplo",
      "clangd",
      "lua_ls",
      "bashls",
      "svelte",
      "ts_ls",
      "emmet_ls",
      "tailwindcss",
      "yamlls",
      "buf_ls",
      "cssls",
      "expert",
      "nixd",
      "astro",
      "terraformls",
      "dockerls",
      "rust_analyzer",
      "just",
      "gopls",
    },
    ---@diagnostic disable: missing-fields
    config = {
      clangd = {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "hpp" },
      },
      pyright = {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
        },
      },
      html = {
        filetypes = { "html", "edge" },
      },
      emmet_ls = {
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "svelte",
          "pug",
          "typescriptreact",
          "vue",
          "edge",
        },
      },
      cssls = {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      expert = {
        cmd = { "expert", "--stdio" },
        root_markers = { "mix.exs", ".git" },
        filetypes = { "elixir", "eelixir", "heex" },
        settings = {},
      },
      tailwindcss = {
        settings = {
          tailwindCSS = {
            includeLanguages = {
              elixir = "html-eex",
              eelixir = "html-eex",
              heex = "html-eex",
            },
          },
        },
      },
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
  },
}
