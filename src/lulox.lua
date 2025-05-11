local Lexer = require("lexer")

local EXIT_SUCCESS = 0
local EXIT_FAILED  = 1

local lulox = { haderror = false }

function lulox:run(input)
    local lexer = Lexer:new(input)
    local tokens = lexer:scantoks()
    lulox.haderror = lexer.haderror

    for _, tok in pairs(tokens) do
        print(string.format("%-15s", tok.toktype), tok.lexme, tok.literal, tok.line)
    end

    if lulox.haderror then print("!!! damn it !!!") end
end

function lulox:report(line, where, message)
    io.stderr:wirte("[line " .. line .. "] ERROR " .. where .. ": " .. message .. "\n")
end

function lulox:exfile(path) 
    local file = io.open(path, "r")
    if not file then
        io.stderr:write("ERROR: could not open file: " .. path)
        os.exit(EXIT_FAILED)
    end

    local bytes = file:read("*all")
    file:close()

    lulox:run(bytes)

    if lulox.haderror == true then
        os.exit(EXIT_FAILED)
    end
end

function lulox:interact() 
    while true do
        io.write("> ")
        io.flush()
        local input = io.read("l")
        if input == nil then break end
        if input ~= "" then 
            print("input: " .. input) 
            lulox:run(input)
        end
    end
end

local function main()
    if #arg > 1 then
        io.stderr:write("Usage: lua lulox.lua <FILE>\n")
    elseif #arg == 1 then
        lulox:exfile(arg[1])
    else
        lulox:interact()
    end
end

main()
