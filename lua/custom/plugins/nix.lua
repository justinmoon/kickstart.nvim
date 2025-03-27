-- Nix language support configuration
return {
  'oxalica/nil',
  -- Configure LSP for nil (Nix Language Server)
  dependencies = {
    'neovim/nvim-lspconfig',
    'stevearc/conform.nvim',
  },

  config = function()
    -- Configure nil language server
    -- This assumes nil is already installed via your flake.nix
    if require('lspconfig').nil_ls then
      require('lspconfig').nil_ls.setup {
        cmd = { 'nil' },
        root_dir = require('lspconfig.util').find_git_ancestor,
        settings = {
          ['nil'] = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      }
    end

    -- Configure formatter
    -- Add nixfmt to conform's formatters
    local conform = require("conform")
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.nix = { "nixfmt" }
    
    -- Note: nixfmt not installed via Mason as it fails on MacOS
    -- Use the one from your flake.nix
  end,
}