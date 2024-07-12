local M = {}

local options = {
    filetypes = {}
}
M.setup = function(opts)
    if (opts ~= nil) then
        options = opts
    end
end

local function split_string(input_str)
    local lines = {}
    for line in input_str:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    return lines
end
M.compile = function()
    local filetype = vim.bo.filetype;
    local fn = options.filetypes[filetype]
    if (fn == nil) then
        print(filetype .. " not supported")
        return
    end
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    print("Compiling " .. file .. "...")
    fn = fn:gsub("%%f", file)
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
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, split_string(output))
    -- Split the window at the bottom and set it to the new buffer
    vim.cmd('split')    -- create a horizontal split
    vim.cmd('wincmd J') -- move to the bottom window
    vim.api.nvim_win_set_buf(0, buf)
end

return M
