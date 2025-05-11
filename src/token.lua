local Util = require("util")

local Token = {}

local token_type = Util.create_enum({
    -- single-character tokens
    "LEFT_PAREN", "RIGHT_PAREN", "LEFT_BRACE", "RIGHT_BRACE",
    "COMMA", "DOT", "MINUS", "PLUS", "SEMICOLON", "SLASH", "STAR",

    -- one or two character tokens
    "BANG", "BANG_EQUAL",
    "EQUAL", "EQUAL_EQUAL",
    "GREATER", "GREATER_EQUAL",
    "LESS", "LESS_EQUAL",

    -- literals
    "IDENTIFIER", "STRING", "NUMBER",

    -- keywords
    "AND", "CLASS", "ELSE", "FALSE", "FUN", "FOR", "IF", "NIL", "OR",
    "PRINT", "RETURN", "SUPER", "THIS", "TRUE", "VAR", "WHILE",

    "EOF"
})

function Token:new(toktype, lexeme, literal, line)
    local obj   = {}
    -- obj.toktype = self:to(toktype)
    obj.toktype = toktype
    obj.lexeme  = lexeme
    obj.literal = literal
    obj.line    = line
    setmetatable(obj, Token)
    return obj
end

function Token:to(toktype)
    return token_type[toktype]
end

return Token
