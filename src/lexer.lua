local lexer = {}

function lexer:new()
    local obj = {}
    setmetatable(obj, lexer)
    return obj
end

function lexer:scantok()
    return {}
end

return lexer
