#!/usr/bin/env lua
-- userdparser4.lua
-- Glenn G. Chappell
-- 19 Feb 2016
-- Updated: 24 Feb 2016
--
-- For CS 331 Spring 2016
-- Simple Main Program for rdparser4 Module
-- Requires rdparser4.lua, lexer.lua

rdparser4 = require "rdparser4"


-- String forms of symbolic constants
symbolNames = {
  [1]="BIN_OP",
  [2]="NUMLIT_VAL",
  [3]="ID_VAL"
}

-- writeAST_rdparser4
-- Write an AST, in (roughly) Lua form, with numbers replaced by the
-- symbolic constants used in rdparser4.
-- A table is assumed to represent an array.
-- See rdparser4.lua for the AST Specification.
function writeAST_rdparser4(x)
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            io.write("<ERROR: Unknown constant: "..x..">")
        else
            io.write(name)
        end
    elseif type(x) == "string" then
        io.write('"'..x..'"')
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) == "table" then
        local first = true
        io.write("{")
        for k = 1, #x do  -- ipairs is problematic
            if not first then
                io.write(", ")
            end
            writeAST_rdparser4(x[k])
            first = false
        end
        io.write("}")
    elseif type(x) == "nil" then
        io.write("nil")
    else
        io.write("<ERROR: "..type(x)..">")
    end
end


-- check
-- Given a "program", check its syntactic correctness using rdparser4.
-- Print results.
function check(program)
    dashstr = "-"
    io.write(dashstr:rep(72).."\n")
    io.write("Program: "..program.."\n")

    local good, ast = rdparser4.parse(program)

    if good then
        io.write("AST: ")
        writeAST_rdparser4(ast)
        io.write("\n")
    else
        io.write("SYNTAX ERROR\n")
    end
end


-- Main program
-- Check several "programs".
io.write("Recursive-Descent Parser: Expression\n")
check("abc")
check("123")
check("a b")
check("3a")
check("a + * b")
check("a + b (* c)")
check("a * -3")
check("3 - a")
check("a + +3 - c")
check("a + b - c + d - e")
check("a + (b - (c + (d - e)))")
check("a * +3 + c")
check("a * (+3 + c)")
check("a + +3 * c")
check("(a + +3) * c")

