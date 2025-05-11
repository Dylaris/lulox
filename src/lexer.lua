local Util = require("util")
local Token = require("token")

local Lexer = {}
Lexer.__index = Lexer

local keywords = {
    ["and"]    = "AND",
    ["class"]  = "CLASS",
    ["else"]   = "ELSE",
    ["false"]  = "FALSE",
    ["for"]    = "FOR",
    ["fun"]    = "FUN",
    ["if"]     = "IF",
    ["nil"]    = "NIL",
    ["or"]     = "OR",
    ["print"]  = "PRINT",
    ["return"] = "RETURN",
    ["super"]  = "SUPER",
    ["this"]   = "THIS",
    ["true"]   = "TRUE",
    ["var"]    = "VAR",
    ["while"]  = "WHILE"
}

function Lexer:new(source)
    local obj    = {}
    obj.start    = 1         -- point to the first character of the current lexeme being scanned (offset)
    obj.current  = 1         -- point to the character currently being considered (offset)
    obj.line     = 1         -- track which line the 'current' character is on
    obj.source   = source
    obj.tokens   = {}
    obj.haderror = false
    setmetatable(obj, Lexer)
    return obj
end

function Lexer:isover()
    return self.current > #self.source
end

function Lexer:addtok(toktype, literal)
    local text = string.sub(self.source, self.start, self.current)
    table.insert(self.tokens, Token:new(toktype, text, literal, self.line))
end

function Lexer:advance()
    local ch = string.sub(self.source, self.current, self.current)
    self.current = self.current + 1
    return ch
end

function Lexer:match(expected)
    if self:isover() then return false end
    if self.source:sub(self.current, self.current) ~= expected then
        return false
    end
    self.current = self.current + 1
    return true
end

function Lexer:peek()
    if self:isover() then return '\0' end
    return self.source:sub(self.current, self.current)
end

function Lexer:peekn()
    if self.current + 1 > #self.source then return '\0' end
    return self.source:sub(self.current + 1, self.current + 1)
end

local function scan_string(obj)
    while obj:peek() ~= '"' and not obj:isover() do 
        if obj:peek() == '\n' then obj.line = obj.line + 1 end
        obj:advance()
    end

    if obj:isover() then
        Util.report_error(obj.line, "unterminated string")
        obj.haderror = true
    else
        obj:advance()  -- the closing "
        local value = string.sub(obj.source, obj.start + 1, obj.current - 2)
        obj:addtok("STRING", value)
    end
end

local function scan_number(obj)
    while Util.isdigit(obj:peek()) do obj:advance() end
    -- look for a fractional part
    if obj:peek() == '.' and Util.isdigit(obj:peekn()) then
        obj:advance()  -- consume the '.'
        while Util.isdigit(obj:peek()) do obj:advance() end
    end
    obj:addtok("NUMBER", tonumber(obj.source:sub(obj.start, obj.current)))
end

local function scan_identifier(obj)
    while Util.isalnum(obj:peek()) do obj:advance() end
    local text = obj.source:sub(obj.start, obj.current)
    obj:addtok(keywords[text] or "IDENTIFIER")
end

function Lexer:scantok()
    local switch_tbl = {
        ['('] = function () self:addtok("LEFT_PAREN") end,
        [')'] = function () self:addtok("RIGHT_PAREN") end,
        ['{'] = function () self:addtok("LEFT_BRACE") end,
        ['}'] = function () self:addtok("RIGHT_BRACE") end,
        [','] = function () self:addtok("COMMA") end,
        ['.'] = function () self:addtok("DOT") end,
        ['-'] = function () self:addtok("MINUS") end,
        ['+'] = function () self:addtok("PLUS") end,
        [';'] = function () self:addtok("SEMICOLON") end,
        ['*'] = function () self:addtok("STAR") end,
        ['!'] = function () self:addtok(self:match('=') and "BANG_EQUAL" or "BANG") end,
        ['='] = function () self:addtok(self:match('=') and "EQUAL_EQUAL" or "EQUAL") end,
        ['>'] = function () self:addtok(self:match('=') and "GREATER_EQUAL" or "GREATER") end,
        ['<'] = function () self:addtok(self:match('=') and "LESS_EQUAL" or "LESS") end,
        ['/'] = function () 
            if self:match('/') then
                -- comment (skip)
                while (self:peek() ~= '\n') and not self:isover() do
                    self:advance()
                end
            else
                -- division (add)
                self:addtok("SLASH") 
            end
        end,
        ['"']  = function () scan_string(self) end,
        [' ']  = function () end,
        ['\r'] = function () end,
        ['\t'] = function () end,
        ['\n'] = function () self.line = self.line + 1 end,

        __index = function (tbl, key) 
            if Util.isdigit(key) then
                scan_number(self)
            elseif Util.isalpha(key) then
                scan_identifier(self)
            else
                Util.report_error(self.line, "unexpected character -> " .. key)
                self.haderror= true
            end
        end
    }
    setmetatable(switch_tbl, switch_tbl)

    local ch = self:advance()
    Util.do_switch(switch_tbl, ch)
end

function Lexer:scantoks()
    while not self:isover() do
        self.start = self.current
        self:scantok()
    end
    table.insert(self.tokens, Token:new("EOF", "", nil, self.line))

    return self.tokens
end

return Lexer
