require("bootstrap")
require("editor")
require("relative")

require("lazy").setup("plugins", {
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            }
        }
    }
})

require("keymap")
vim.cmd("colorscheme onedark")
