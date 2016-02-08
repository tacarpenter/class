-- lexer.lua  UNFINISHED
-- Glenn G. Chappell
-- 8 Feb 2016
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

    -- ***** Character-Related Functions *****

    -- currChar
    -- Return the current character, at index pos in prog. Return value
    -- is a single-character string, or the empty string if pos is past
    -- the end.
    local function currChar()
        return prog:sub(pos, pos)
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
        -- WRITE THIS!!!
    end

    -- ***** State-Handler Functions *****

    local function handle_DONE()
        io.write("ERROR: 'DONE' state should not be handled\n")
        assert(0)
    end

    local function handle_START()
        add1()
        state = DONE
        category = PUNCT
    end

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
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

