if not jit.os == "Windows" then
    local mail = require("terminal").terminal:new({
        layout = { open_cmd = "float" },
        cmd = { "neomutt" },
        autoclose = true,
    })

    vim.api.nvim_create_user_command("Mail", function()
        mail:toggle(nil, true)
    end, {})

    local spotify = require("terminal").terminal:new({
        layout = { open_cmd = "float" },
        cmd = { "spt" },
        autoclose = true,
    })

    vim.api.nvim_create_user_command("Music", function()
        spotify:toggle(nil, true)
    end, {})
end

local term2 = require("terminal").terminal:new({
    layout = { open_cmd = "float" },
    cmd = { vim.o.shell },
    autoclose = true,
})

vim.api.nvim_create_user_command("Term", function()
    vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], { silent = true })
    term2:toggle(nil, true)
end, {})

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "TermOpen" }, {
    callback = function(args)
        if vim.startswith(vim.api.nvim_buf_get_name(args.buf), "term://") then
            vim.cmd("startinsert")
        end
    end,
})
