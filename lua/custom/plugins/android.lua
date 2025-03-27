-- Android/Kotlin development configuration
return {
  'kotlin-language-server/kotlin-language-server',
  -- Configure LSP for Kotlin language server
  dependencies = {
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'nvim-treesitter/nvim-treesitter',
  },

  config = function()
    -- Capture the Android SDK environment variables from your Nix shell
    vim.g.android_sdk_root = os.getenv 'ANDROID_SDK_ROOT'
    vim.g.android_home = os.getenv 'ANDROID_HOME'
    vim.g.android_ndk_root = os.getenv 'ANDROID_NDK_ROOT'
    vim.g.java_home = os.getenv 'JAVA_HOME'
    
    -- Create user command to show Android SDK info
    vim.api.nvim_create_user_command('AndroidInfo', function()
      if vim.g.android_sdk_root then
        vim.notify('Android SDK found at: ' .. vim.g.android_sdk_root)
      else
        vim.notify 'Android SDK not found in environment'
      end

      if vim.g.java_home then
        vim.notify('Java Home found at: ' .. vim.g.java_home)
      else
        vim.notify 'Java Home not found in environment'
      end
    end, { desc = 'Show Android SDK environment info' })
    
    -- Only run configuration for .kt files
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.kt",
      callback = function()
        -- Ensure kotlin-language-server is installed (only once)
        if not vim.g.kotlin_server_installed then
          require('mason-tool-installer').setup {
            ensure_installed = { 'kotlin-language-server' },
          }
          
          -- Ensure Kotlin parser is installed for treesitter (only once)
          local ts_configs = require 'nvim-treesitter.configs'
          ts_configs.setup {
            ensure_installed = { 'kotlin' },
          }
          
          vim.g.kotlin_server_installed = true
        end

        -- Kotlin-specific settings for the current buffer
        local project_root = vim.fn.getcwd()
        if vim.lsp.buf.semantic_tokens_refresh then
          vim.lsp.buf.semantic_tokens_refresh()
        end

        -- Configure Kotlin LSP if not already set up
        if require('lspconfig').kotlin_language_server and not vim.g.kotlin_lsp_setup then
          require('lspconfig').kotlin_language_server.setup {
            cmd = { 'kotlin-language-server' },
            init_options = {
              storagePath = vim.fn.expand '~/.cache/kotlin-language-server',
              transport = 'stdio',
            },
            root_dir = function(fname)
              return require('lspconfig.util').root_pattern('settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts')(fname)
                or require('lspconfig.util').find_git_ancestor(fname)
            end,
            settings = {
              kotlin = {
                compiler = {
                  jvm = {
                    target = '17',
                  },
                },
                externalSources = {
                  autoConvertToKotlin = true,
                  useKlsScheme = true,
                },
                -- Make KLS read the gradle project
                indexing = {
                  enabled = true,
                },
                diagnostics = {
                  disabled = {
                    -- Temporarily disable unresolved reference errors while debugging
                    'unresolved-reference',
                  },
                },
              },
            },
            cmd_env = {
              ANDROID_HOME = vim.g.android_home,
              ANDROID_SDK_ROOT = vim.g.android_sdk_root,
              ANDROID_NDK_ROOT = vim.g.android_ndk_root,
              JAVA_HOME = vim.g.java_home,
            },
          }
          vim.g.kotlin_lsp_setup = true
        end
      end,
    })
  end,
}

