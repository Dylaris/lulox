local lulox_lexer = require("lexer")

local lulox = {}

function lulox.run() 
    local lexer = lulox_lexer:new()
    local tokens = lexer:scantok()
    for _, val in ipairs(tokens) do
        print(val)
    end
end

function lulox.exfile(filename) 
end

function lulox.interact() 
    while true do
        io.write("> ")
        io.flush()
        local input = io.read()
        if input == nil then break end
        if input ~= "" then print(input) end
    end
end

local function main()
    if #arg > 1 then
        print("Usage: lua lulox.lua <FILE>")
    elseif #arg == 1 then
        lulox.exfile(arg[1])
    else
        lulox.interact()
    end
end

main()
