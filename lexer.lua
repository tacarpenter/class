-- lexer.lua  UNFINISHED
-- Glenn G. Chappell
-- 9 Feb 2016
--
-- For CS 331 Spring 2016
-- In-Class Lexer Module

-- Usage:
--
--    program = "return a+b;"  -- program to lex
--    for lexstr, cat in lexer.lex(program) do
--        -- lexstr is the string form of a lexeme
--        -- cat is the lexeme category
--        --  It can be used as an index for array lexer.catnames
--    end

local lexer = {}  -- Our module


-- Lexeme Category Names

lexer.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}


-- Kind-of-Character Functions

-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif c >= " " and c <= "~" then
        return false
    else
        return true
    end
end


-- The Lexer Itself

-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexer.lex(prog) do
function lexer.lex(prog)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in prog
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** Lexeme Categories *****

    local KEY = 1
    local ID = 2
    local NUMLIT = 3
    local OP = 4
    local PUNCT = 5
    local MAL = 6

    -- ***** States *****

    local DONE = 0
    local START = 1
    local LETTER = 2

    -- ***** Character-Related Functions *****

    -- currChar
    -- Return the current character, at index pos in prog. Return value
    -- is a single-character string, or the empty string if pos is past
    -- the end.
    local function currChar()
        return prog:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in prog. Return value
    -- is a single-character string, or the empty string if pos+1 is past
    -- the end.
    local function nextChar()
        return prog:sub(pos+1, pos+1)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to prog:len()+1.
    local function skipWhitespace()
        while true do
            while isWhitespace(currChar()) do
                drop1()
            end

            if (currChar() ~= "/") or (nextChar() ~= "*") then
                break
            end
            drop1()
            drop1()

            while true do
                if (currChar() == "*") and (nextChar() == "/") then
                    drop1()
                    drop1()
                    break
                end
                drop1()
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    local function handle_DONE()
        io.write("ERROR: 'DONE' state should not be handled\n")
        assert(0)
    end

    local function handle_START()
        if isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
        elseif isIllegal(ch) then
            add1()
            state = DONE
            category = MAL
        else
            add1()
            state = DONE
            category = PUNCT
        end
    end

    local function handle_LETTER()
        if isLetter(ch) or isDigit(ch) or ch == "_" then
            add1()
        else
            state = DONE
            category = ID
            if lexstr == "begin"
              or lexstr == "end"
              or lexstr == "print" then
                category = KEY
            end
        end
    end

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipWhitespace()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end


-- Module Export

return lexer

