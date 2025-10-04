-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Keymaps

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Configuración de editor
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.tabstop = 2        -- Número de espacios que ocupa un tab
vim.opt.softtabstop = 2    -- Número de espacios para tab en modo inserción
vim.opt.shiftwidth = 2     -- Número de espacios para autoindentado
vim.opt.expandtab = true   -- Convierte tabs en espacios
vim.opt.autoindent = true  -- Mantiene el indentado de la línea anterior
vim.opt.smartindent = true -- Indentado inteligente en lenguajes como C
vim.opt.wrap = false       -- No dividir líneas largas
vim.opt.scrolloff = 8      -- Mantener 8 líneas visibles al hacer scroll
vim.opt.sidescrolloff = 8  -- Mantener 8 columnas visibles lateralmente

-- Configuración estándar de 2 espacios para todos los lenguajes

-- Keymaps personalizados
local map = vim.keymap.set
map('n', '<C-s>', ':w<CR>', { desc = 'Guardar archivo' })
map('n', '<leader>bd', ':bd<CR>', { desc = 'Cerrar buffer' })
map('n', '<leader>v', ':vsplit<CR>', { desc = 'Split vertical a la derecha' })
map('n', '<leader>e', ':Oil<CR>', { desc = 'Abrir Oil (explorador)' })
map('n', '<C-h>', '<C-w>h', { desc = 'Mover a la ventana izquierda' })
map('n', '<C-j>', '<C-w>j', { desc = 'Mover a la ventana abajo' })
map('n', '<C-k>', '<C-w>k', { desc = 'Mover a la ventana arriba' })
map('n', '<C-l>', '<C-w>l', { desc = 'Mover a la ventana derecha' })
map('n', '<leader>db', function()
    require('dap').toggle_breakpoint()
end, { desc = 'DAP: Toggle breakpoint' })

-- Filetype detection: treat .yuck files as 'yuck'
-- Removed explicit yuck filetype detection (handled by filetype plugins or treesitter)

-- Mappings para salir de modo insert con combinaciones rápidas
for _, keys in ipairs({ "jk", "kj", "jj", "kk" }) do
    map('i', keys, '<Esc>', { desc = 'Salir a modo normal', noremap = true })
end


-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- add your plugins here
        -- Tokionight theme
        {
            "folke/tokyonight.nvim",
            lazy = false,
            priority = 1000,
            opts = {
                transparent = true
            }
        },
        -- Telescope (buscador de archivos)
        {
            "nvim-telescope/telescope.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
            config = function()
                require("telescope").setup {}
                local map = vim.keymap.set
                map('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Buscar archivos' })
                map('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Buscar texto' })
            end,
        },
        -- Oil plugin
        {
            'stevearc/oil.nvim',
            ---@module 'oil'
            ---@type oil.SetupOpts
            opts = {
              view_options = {
                show_hidden = true
              }
            },
            -- Optional dependencies
            dependencies = { { "echasnovski/mini.icons", opts = {} } },
            -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
            -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
            lazy = false,
        },
        -- treesitter plugin
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            opts = {
                ensure_installed = { "go", "lua", "vim", "bash", "markdown", "markdown_inline" },
                highlight = { enable = true },
            },
            -- Mason for managing LSP servers
            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup()
                end,
            },
            -- Mason LSP integration
            {
                "williamboman/mason-lspconfig.nvim",
                dependencies = { "williamboman/mason.nvim" },
                config = function()
                    require("mason-lspconfig").setup({
                            ensure_installed = { "gopls", "marksman" },
                        })
                end,
            },
            -- LSP config (uses mason-lspconfig)
            {
                "neovim/nvim-lspconfig",
                config = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.gopls.setup({})
                        -- Configure marksman for Markdown if available
                        if lspconfig.marksman then
                            lspconfig.marksman.setup({})
                        end
                end,
            },
            -- Autocompletion
            {
                "hrsh7th/nvim-cmp",
                event = "InsertEnter",
                dependencies = {
                    "hrsh7th/cmp-nvim-lsp",
                    "hrsh7th/cmp-buffer",
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-cmdline",
                    "L3MON4D3/LuaSnip",
                },
                config = function()
                    local cmp = require("cmp")
                    cmp.setup({
                        snippet = {
                            expand = function(args)
                                require("luasnip").lsp_expand(args.body)
                            end,
                        },
                        sources = {
                            { name = "nvim_lsp" },
                            { name = "buffer" },
                            { name = "path" },
                        },
                        mapping = cmp.mapping.preset.insert({
                            ['<C-Space>'] = cmp.mapping.complete(),
                            ['<CR>'] = cmp.mapping.confirm({ select = true }),
                        }),
                    })
                end,
            },
            -- DAP (Debug Adapter Protocol) para Go
            {
                "mfussenegger/nvim-dap",
                config = function()
                    local dap = require("dap")
                    dap.adapters.go = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = "dlv",
                            args = { "dap", "--listen", "127.0.0.1:${port}" },
                        },
                    }
                    dap.configurations.go = {
                        {
                            type = "go",
                            name = "Debug",
                            request = "launch",
                            program = "${file}",
                        },
                    }
                end,
            },
            -- Mason para instalar Delve (dlv)
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
                config = function()
                    require("mason-nvim-dap").setup({
                        ensure_installed = { "delve" },
                    })
                end,
            },
            -- Interfaz visual para DAP
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
                config = function()
                    local dap = require("dap")
                    local dapui = require("dapui")
                    dapui.setup()
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close()
                    end
                end,
            },
        },
        {
            "kylechui/nvim-surround",
            version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        },
        -- Conform.nvim para formateo de código
        {
            "stevearc/conform.nvim",
            event = { "BufWritePre" },
            cmd = { "ConformInfo" },
            keys = {
                {
                    "<leader>f",
                    function()
                        require("conform").format({ async = true, lsp_fallback = true })
                    end,
                    mode = "",
                    desc = "Formatear código",
                },
            },
            config = function()
                require("conform").setup({
                    formatters_by_ft = {
                        lua = { "stylua" },
                        go = { "gofumpt", "goimports" },
                        javascript = { "prettier" },
                        typescript = { "prettier" },
                        javascriptreact = { "prettier" },
                        typescriptreact = { "prettier" },
                        css = { "prettier" },
                        html = { "prettier" },
                        json = { "prettier" },
                        yaml = { "prettier" },
                        markdown = { "prettier" },
                        python = { "isort", "black" },
                        rust = { "rustfmt" },
                        sh = { "shfmt" },
                    },
                    -- Formatear automáticamente al guardar
                    format_on_save = {
                        timeout_ms = 500,
                        lsp_fallback = true,
                    },
                    -- Configurar formateadores específicos si es necesario
                    formatters = {
                        shfmt = {
                            prepend_args = { "-i", "2" },
                        },
                    },
                })
            end,
        },
        -- Lazygit integration
        {
            "kdheepak/lazygit.nvim",
            cmd = {
                "LazyGit",
                "LazyGitConfig",
                "LazyGitCurrentFile",
                "LazyGitFilter",
                "LazyGitFilterCurrentFile",
            },
            -- optional for floating window border decoration
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            -- setting the keybinding for LazyGit with 'keys' is recommended in
            -- order to load the plugin when the command is run for the first time
            keys = {
                { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "Abrir LazyGit" },
                { "<leader>gc", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit archivo actual" },
            }
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})


vim.cmd [[colorscheme tokyonight-moon]]
