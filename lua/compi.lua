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

    local new_pane_id = utils.create_pane()
    if new_pane_id == nil then
        print("No new pane found")
        return
    end
    utils.cmd("tmux send-keys -t " .. new_pane_id .. " '" .. fn .. "' Enter")
    print("Ran " .. filename)
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

    fn = fn:gsub("%%f", filename)
    fn = fn:gsub("%%b", basename)
    fn = fn:gsub("%%d", dir)

    local new_pane_id = utils.create_pane()
    if new_pane_id == nil then
        print("No new pane found")
        return
    end
    utils.cmd("tmux send-keys -t " .. new_pane_id .. " '" .. fn .. "' Enter")
    print("Compiled and ran " .. filename)
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
    print("Compiled " .. filename)
    if output == "" then
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
