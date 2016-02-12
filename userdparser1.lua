#!/usr/bin/env lua
-- userdparser1.lua
-- Glenn G. Chappell
-- 12 Feb 2016
--
-- For CS 331 Spring 2016
-- Simple Main Program for rdparser1 Module
-- Requires rdparser1.lua, lexer.lua

rdparser1 = require "rdparser1"


-- check
-- Given a "program", check its syntactic correctness using rdparser1.
-- Print results.
function check(program)
    dashstr = "-"
    io.write(dashstr:rep(72).."\n")
    io.write("Program: "..program.."\n")

    local good = rdparser1.parse(program)

    if good then
        io.write("Syntactically correct\n")
    else
        io.write("NOT SYNTACTICALLY CORRECT\n")
    end
end


-- Main program
-- Check several "programs".
io.write("Recursive-Descent Parser: Simple\n")
check("abc3")
check("345")
check("(((abc_3)))")

