local M = {}
local utils = require("compi-utils")

local options = {
    compile = {},
    run = {},
    compnrun = {},
}

M.setup = function(opts)
    if (opts ~= nil) then
        options = opts
    end
end

-- EXAMPLE FILE = something/src/example.txt

-- %f (filename)    = "example.txt"
-- %b (basename)    = "example"
-- %d (dir)         = "something/src"
-- %e (extension)   = "txt"

M.run = function()
    local filename = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local extension = filename:match("^.+%.([^%.]+)$")
    local basename = filename:match("(.+)%..+")

    local fn = options.run[extension]

    if (fn == nil) then
        print(extension .. " not configured")
        return
    end

    print("Compiling " .. filename .. "...")

    fn = fn:gsub("%%f", filename)
    fn = fn:gsub("%%b", basename)
    fn = fn:gsub("%%d", dir)

    local panes_before = utils.cmd("tmux list-panes -F \"#{pane_id}\"")
    utils.cmd("tmux neww")
    local panes_after = utils.cmd("tmux list-panes -F \"#{pane_id}\"")
    local new_pane_id = utils.get_new_pane_id(panes_before, panes_after)
    -- Output the new pane ID
    if new_pane_id == nil then
        print("No new pane found")
        return
    end
    print("New pane ID: " .. new_pane_id)
    utils.cmd("tmux send-keys -t " .. new_pane_id .. " '" .. fn .. "' Enter")
    print("Finished compiling")
end

M.compnrun = function()
    local filename = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local extension = filename:match("^.+%.([^%.]+)$")
    local basename = filename:match("(.+)%..+")

    local fn = options.run[extension]

    if (fn == nil) then
        print(extension .. " not configured")
        return
    end

    print("Compiling " .. filename .. "...")

    fn = fn:gsub("%%f", filename)
    fn = fn:gsub("%%b", basename)
    fn = fn:gsub("%%d", dir)

    local panes_before = utils.cmd("tmux list-panes -F \"#{pane_id}\"")
    local tmux = utils.cmd("echo $TMUX");
    if true then
        print(tmux)
        return
    end
    utils.cmd("tmux neww")
    local panes_after = utils.cmd("tmux list-panes -F \"#{pane_id}\"")
    local new_pane_id = utils.get_new_pane_id(panes_before, panes_after)
    -- Output the new pane ID
    if new_pane_id == nil then
        print("No new pane found")
        return
    end
    print("New pane ID: " .. new_pane_id)
    utils.cmd("tmux send-keys -t " .. new_pane_id .. " '" .. fn .. "' Enter")
end

M.compile = function()
    local filename = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local extension = filename:match("^.+%.([^%.]+)$")
    local basename = filename:match("(.+)%..+")

    local fn = options.compile[extension]

    if (fn == nil) then
        print(extension .. " not configured")
        return
    end

    print("Compiling " .. filename .. "...")

    fn = fn:gsub("%%f", filename)
    fn = fn:gsub("%%b", basename)
    fn = fn:gsub("%%d", dir)

    -- runs command on a sub-process.
    local handle = io.popen(fn)
    if handle == nil then
        print("something went wrong")
        return
    end

    -- reads command output.
    local output = handle:read('*a')
    if output == "" then
        print("compiling finished!")
        return
    end
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- create a new buffer, not listed
    -- Set the content of the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, utils.split_string(output))
    -- Split the window at the bottom and set it to the new buffer
    vim.cmd('split')    -- create a horizontal split
    vim.cmd('wincmd J') -- move to the bottom window
    vim.api.nvim_win_set_buf(0, buf)
end

return M
