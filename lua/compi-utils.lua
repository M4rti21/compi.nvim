local M = {}
M.split_string = function(input_str)
    local lines = {}
    for line in input_str:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    return lines
end


M.split_lines = function(str)
    local t = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(t, line)
    end
    return t
end

M.cmd = function(command)
    local handle = io.popen(command)
    if handle == nil then
        print("something went wrong")
        return
    end
    local result = handle:read("*a")
    handle:close()
    return result
end

M.get_new_pane_id = function(panes_before, panes_after)
    local panes_before_table = M.split_lines(panes_before)
    local panes_after_table = M.split_lines(panes_after)
    local new_pane_id = nil
    for _, pane_after in ipairs(panes_after_table) do
        local is_new = true
        for _, pane_before in ipairs(panes_before_table) do
            if pane_after == pane_before then
                is_new = false
                break
            end
        end
        if is_new then
            new_pane_id = pane_after
            break
        end
    end
    return new_pane_id
end

return M
