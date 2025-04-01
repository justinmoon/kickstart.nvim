return {
  'neovim/nvim-lspconfig',
  ft = 'rust', -- Only load for Rust files
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'mfussenegger/nvim-lint',
    'stevearc/conform.nvim',
  },

  config = function()
    -- Print setup notification
    vim.notify("Loading Rust configuration")
    
    -- Ensure Rust parser is installed for treesitter
    local ts_configs = require 'nvim-treesitter.configs'
    ts_configs.setup {
      ensure_installed = { 'rust' },
    }

    -- Configure Rust LSP
    local lspconfig = require('lspconfig')
    if lspconfig.rust_analyzer then
      lspconfig.rust_analyzer.setup {
        -- Use rust-analyzer directly
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_dir = lspconfig.util.root_pattern('Cargo.toml', 'rust-project.json'),
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
              extraArgs = { '--no-deps' },
            },
            cargo = {
              allFeatures = true,
            },
            procMacro = {
              enable = true,
            },
          },
        },
        -- Print debug information
        on_attach = function(client, bufnr)
          vim.notify("Rust analyzer attached to buffer")
        end,
      }
    else
      vim.notify("rust_analyzer not available in lspconfig", vim.log.levels.ERROR)
    end

    -- Configure formatter for Rust files
    local conform = require 'conform'
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.rust = { 'rustfmt' }
    
    -- Configure linter for Rust files to show clippy errors
    local lint = require 'lint'
    lint.linters_by_ft = lint.linters_by_ft or {}
    lint.linters_by_ft.rust = { 'clippy' }
  end,
}