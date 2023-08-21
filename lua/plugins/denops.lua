-- WARNING: plugins that depend on denops.vim should not be lazy loaded with lazy.nvim configuration
return {
    {
        'vim-denops/denops.vim',
        event = "VeryLazy"
    },
    {
        "vim-skk/skkeleton",
        dependencies = {
            "vim-denops/denops.vim"
        },
        keys = {
            { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
        },
        config = function()
            -- Lazy loaded by using this function
            vim.fn["denops#plugin#register"]("skkeleton")

            vim.fn["skkeleton#config"] {
                useSkkServer = false
            }
        end
    },
    {
        "lambdalisue/kensaku.vim",
        dependencies = {
            "vim-denops/denops.vim"
        },
        lazy = true,
        config = function()
            vim.fn["denops#plugin#register"]("kensaku")
        end
    },
    {
        "yuki-yano/fuzzy-motion.vim",
        dependencies = {
            "vim-denops/denops.vim",
            "lambdalisue/kensaku.vim"
        },
        keys = {
            { "<leader>fz", "<Cmd>FuzzyMotion<CR>", desc = "fuzzy finder" }
        },
        config = function()
            vim.fn["denops#plugin#register"]("fuzzy-motion")
            vim.g.fuzzy_motion_matchers = { "fzf", "kensaku" }
        end
    }
}
