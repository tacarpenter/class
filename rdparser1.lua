-- rdparser1.lua  UNFINISHED
-- Glenn G. Chappell
-- 12 Feb 2016
--
-- For CS 331 Spring 2016
-- Recursive-Descent Parser: Simple
-- Requires lexer.lua


local rdparser1 = {}  -- Our module

lexer = require "lexer"


-- Variables

-- For lexer iteration
local iter          -- Iterator returned by lexer.lex
local state         -- State for above iterator (maybe not used)
local lexer_out_s   -- Return value #1 from above iterator
local lexer_out_c   -- Return value #2 from above iterator

-- For current lexeme
local lexstr = ""   -- String form of current lexeme
local lexcat = 0    -- Category of current lexeme:
                    --  one of categories below, or 0 for past the end


-- Lexeme Categories

local KEY = 1
local ID = 2
local NUMLIT = 3
local OP = 4
local PUNCT = 5
local MAL = 6


-- Utility Functions

-- advance
-- Go to next lexeme and load it into lexstr, lexcat.
-- Should be called once before any parsing is done.
-- Function init must be called before this function is called.
local function advance()
    -- Advance the iterator
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)

    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
end


-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexer.lex(prog)
    advance()
end


-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end


-- matchCat
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end


-- Primary Function for Client Code

-- parse
-- Given program, initialize parser and call parsing function for start
-- symbol. Returns pair of booleans. First indicates successful parse or
-- not. Second indicates whether the parser reached the end of the
-- input or not.
function rdparser1.parse(prog)
    -- Initialization
    init(prog)

    -- Get results from parsing
    local success = false

    -- And return them
    return success
end


-- Parsing Functions

-- Each of the following is a parsing function for a nonterminal in the
-- grammar. Each function parses the nonterminal in its name. A return
-- value of true means a correct parse, and the current lexeme is just
-- past the end of the string the nonterminal expanded into. A return
-- value of false means an incorrect parse; in this case no guarantees
-- are made about the current lexeme.




-- Module Export

return rdparser1

