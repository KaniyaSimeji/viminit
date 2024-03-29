return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            dependencies = {
                "williamboman/mason.nvim",
                "aznhe21/actions-preview.nvim",
                "SmiteshP/nvim-navic",
                { "creativenull/efmls-configs-nvim", version = "v1.x.x" },
                --{ dir = "/data/repo/efmls-configs-nvim" },
                { "folke/neodev.nvim" },
            },
            config = function()
                require("mason").setup()
                require("neodev").setup({})
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                local mason_lspconfig = require("mason-lspconfig")
                local on_attach = function(client, bufnr)
                    if client.server_capabilities["documentSymbolProvider"] then
                        require("nvim-navic").attach(client, bufnr)
                    end
                end
                -- from https://zenn.dev/uga_rosa/articles/afe384341fc2e1
                ---@return string[]
                local function solve_local_library()
                    local paths = require("config.plugin").get_plugin_lua_paths();
                    table.insert(paths, vim.fn.stdpath("config") .. "lua")
                    table.insert(paths, vim.env.VIMRUNTIME .. "lua")
                    table.insert(paths, "${3rd}/busted/library")
                    table.insert(paths, "${3rd}/luassert/library")
                    return paths
                end

                mason_lspconfig.setup_handlers({
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                        })
                    end,
                    ["rust_analyzer"] = function() end,
                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = {
                                Lua = {
                                    completion = {
                                        callSnippet = "Replace",
                                    },
                                    format = {
                                        enable = false,
                                    },
                                    runtime = {
                                        version = "LuaJIT",
                                        pathStrict = true,
                                        path = { "?.lua", "?/init.lua" },
                                    },
                                    workspace = {
                                        library = solve_local_library(),
                                        checkThirdParty = "Disable",
                                    },
                                },
                            },
                        })
                    end,
                    ["tsserver"] = function()
                        require("lspconfig").tsserver.setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            root_dir = require("lspconfig").util.root_pattern("package.json"),
                            single_file_support = false,
                        })
                    end,
                    ["efm"] = function()
                        local languages = require("config.efm").languages
                        local efmls_config = {
                            filetypes = vim.tbl_keys(languages),
                            settings = {
                                rootMarkers = { ".git/" },
                                languages = languages,
                            },
                            init_options = {
                                documentFormatting = true,
                                documentRangeFormatting = true,
                            },
                        }

                        require("lspconfig").efm.setup(vim.tbl_extend("force", efmls_config, {
                            on_attach = on_attach,
                            capabilities = capabilities,
                        }))
                    end,
                })
                require("lspconfig").denols.setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
                })
                require("lspconfig").biome.setup({
                    cmd = { "pnpm", "exec", "biome", "lsp-proxy" },
                    capabilities = capabilities,
                    on_attach = on_attach,
                })
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(_)
                        vim.keymap.set("n", "K", function()
                            vim.lsp.buf.hover()
                        end)
                        vim.keymap.set("n", "ff", function()
                            vim.lsp.buf.format()
                        end)
                        vim.keymap.set("n", "gr", "<cmd>Glance references<CR>")
                        vim.keymap.set("n", "gd", "<cmd>Glance definitions<CR>")
                        vim.keymap.set("n", "gD", function()
                            vim.lsp.buf.declaration()
                        end)
                        vim.keymap.set("n", "gi", "<cmd>Glance implementations<CR>")
                        vim.keymap.set("n", "gt", "<cmd>Glance type_definitions<CR>")
                        vim.keymap.set("n", "rn", function()
                            vim.lsp.buf.rename()
                        end)
                        vim.keymap.set({ "v", "n" }, "ca", require("actions-preview").code_actions)
                        vim.keymap.set("n", "ge", function()
                            vim.diagnostic.open_float()
                        end)
                        vim.keymap.set("n", "g]", function()
                            vim.diagnostic.goto_next()
                        end)
                        vim.keymap.set("n", "g[", function()
                            vim.diagnostic.goto_prev()
                        end)
                    end,
                })
            end,
        },
    },
    {
        "smjonas/inc-rename.nvim",
        event = { "LspAttach" },
        dependencies = {
            "stevearc/dressing.nvim",
        },
        config = function()
            require("inc_rename").setup({
                input_buffer_type = "dressing",
            })
            require("dressing").setup({
                input = {
                    override = function(conf)
                        conf.col = -1
                        conf.row = 0
                        return conf
                    end,
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(_)
                    vim.keymap.set("n", "<leader>rn", function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { expr = true, silent = true })
                end,
            })
        end,
    },
    {
        "lvimuser/lsp-inlayhints.nvim",
        event = { "LspAttach" },
        config = function()
            require("lsp-inlayhints").setup({})
            vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
            vim.api.nvim_create_autocmd("LspAttach", {
                group = "LspAttach_inlayhints",
                callback = function(args)
                    if not (args.data and args.data.client_id) then
                        return
                    end

                    local bufnr = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    require("lsp-inlayhints").on_attach(client, bufnr)
                end,
            })
        end,
    },
}
