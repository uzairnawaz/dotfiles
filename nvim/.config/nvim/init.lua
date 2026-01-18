vim.g.mapleader = " "
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y') -- yank to clipboard
vim.keymap.set("n", "<leader>Y", '"+yg_')        -- yank line to clipboard
vim.keymap.set("n", "<leader>p", '"+p')          -- paste from clipboard
vim.keymap.set("n", "<leader>P", '"+P')          -- paste before

vim.opt.termguicolors = true
-- Remove background to use terminal default
vim.cmd([[highlight Normal ctermbg=none guibg=none]])
vim.cmd([[highlight NonText ctermbg=none guibg=none]])
vim.cmd([[highlight LineNr ctermbg=none guibg=none]])
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.cmd([[highlight Normal ctermbg=none guibg=none]])
        vim.cmd([[highlight NonText ctermbg=none guibg=none]])
        vim.cmd([[highlight LineNr ctermbg=none guibg=none]])
    end,
})

vim.cmd([[set number]])
vim.cmd([[set expandtab]])
vim.cmd([[set shiftwidth=4]])

vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = "LSP: show diagnostic message" })


-- Install lazy.nvim plugin manager if it's not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.install").compilers = { "clang", "gcc" }
            require("nvim-treesitter.configs").setup {
                highlight = { enable = true },
                ensure_installed = { "lua", "python", "javascript", "c", "cpp", "rust", "go" },
            }
        end
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                },
            })
        end,
    },
    -- LSP & auto-installer
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "clangd", "rust_analyzer" }, -- add more as needed
                automatic_installation = true,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            local on_attach = function(_, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                -- Example LSP keybinds
                map("n", "gd", vim.lsp.buf.definition, "Go to Definition")

                map('n', '<leader>e', vim.diagnostic.open_float, "Show diagnostic message")
                -- map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                -- map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                -- map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

                -- Format buffer
                map("n", "<leader>i", function()
                    vim.lsp.buf.format({ async = true })
                end, "Format Code")
            end

            for _, server in ipairs(require("mason-lspconfig").get_installed_servers()) do
                local ok, cfg = pcall(require, "lspconfig." .. server)
                if ok then
                    cfg.setup({
                        capabilities = capabilities,
                    })
                end
                lspconfig[server].setup({
                    on_attach = on_attach
                })
            end
        end,
    },

    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help" },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        prompt_position = "top",
                    },
                    sorting_strategy = "ascending",
                },
            })
        end,
    },

    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2', -- use latest version
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
            },
        },
        keys = {
            -- File Navigation
            { "<leader>ha", function() require("harpoon"):list():add() end,                                    desc = "Harpoon Add File" },
            { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon Menu" },
            -- Quick access to files 1–5
            { "<leader>h1", function() require("harpoon"):list():select(1) end,                                desc = "Harpoon to File 1" },
            { "<leader>h2", function() require("harpoon"):list():select(2) end,                                desc = "Harpoon to File 2" },
            { "<leader>h3", function() require("harpoon"):list():select(3) end,                                desc = "Harpoon to File 3" },
            { "<leader>h4", function() require("harpoon"):list():select(4) end,                                desc = "Harpoon to File 4" },
        }
    },

    {
        "lervag/vimtex",
        ft = { "tex", "plaintex", "latex" },
        config = function()
            vim.g.vimtex_view_method = 'zathura'
            vim.g.vimtex_view_general_viewer = 'zathura'
            vim.g.vimtex_view_general_options = '--synctex-forward @line:@col:@tex --fork @pdf'
        end
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    }

})
