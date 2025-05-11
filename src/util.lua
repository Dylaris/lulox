local Util = {}

function Util.create_enum(tbl, start_idx)
    local enum_tbl = {}
    local enum_idx = start_idx or 0
    for idx, val in ipairs(tbl) do
        enum_tbl[val] = idx + enum_idx
    end
    return enum_tbl
end

function Util.do_switch(tbl, trigger)
    if tbl[trigger] and type(tbl[trigger]) == "function" then 
        tbl[trigger]() 
    end
end

function Util.report_error(line, message)
    io.stderr:write("[line " .. line .. "] ERROR " .. ": " .. message .. "\n")
end

function Util.isdigit(ch)
    return ch >= '0' and ch <= '9'
end

function Util.isalpha(ch)
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_'
end

function Util.isalnum(ch)
    return Util.isdigit(ch) or Util.isalpha(ch)
end

return Util
