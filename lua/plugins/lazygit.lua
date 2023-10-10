return {
    "kdheepak/lazygit.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>gg", "<cmd>LazyGit<CR>", mode = { "n" }, desc = "LazyGit" },
    },
}
