#!/usr/bin/env lua
-- lexit_test.lua
-- Glenn G. Chappell
-- 14 Feb 2016
--
-- For CS 331 Spring 2016
-- Test Program for Module lexit
-- Used in Assignment 3, Exercise B

lexit = require "lexit"  -- Import lexit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

exit_on_failure = true

-- If exit_on_failure is true, then:
-- - On first failing test, we print the input, expected output, and
--   actual output; then the test program terminates.
-- If exit_on_failure is false, then:
-- - All tests are performed, with a summary of results printed at the
--   end.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

function tester.test(self, success, testName)
    self.countTests = self.countTests+1
    io.write("    Test: " .. testName .. " - ")
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Lexeme Categories
KEY = 1
ID = 2
NUMLIT = 3
STRLIT = 4
OP = 5
PUNCT = 6
MAL = 7


function printNoteAndExit()
    io.write("\n")
    io.write("******************************************************\n")
    io.write("*                                                    *\n")
    io.write("*  NOTE: This program is set to terminate after the  *\n")
    io.write("*        first failing test. If you would prefer to  *\n")
    io.write("*        execute all tests, whether they pass or     *\n")
    io.write("*        not, then set variable exit_on_failure to   *\n")
    io.write("*        false. (See the beginning of the source     *\n")
    io.write("*        code.)                                      *\n")
    io.write("*                                                    *\n")
    io.write("******************************************************\n")
    io.write("\n")
    os.exit(1)
end


-- arrayEq
-- Given two arrays, tests whether they are equal, using "==" operator
-- on all values.
function arrayEq(a1, a2)
    if #a1 ~= #a2 then
        return false
    end
    for k, v in ipairs(a1) do
        if a2[k] ~= v then
            return false
        end
    end
    return true
end


function checklex(t, prog, expectedOutput, testName, poTest)
    local poCalls = {}
    local function printResults(output, printPOC)
        if printPOC == true then
            io.write(
              "[* indicates preferOp() called before this lexeme]\n")
        end
        local blank = " "
        local i = 1
        while i*2 <= #output do
            local lexstr = '"'..output[2*i-1]..'"'
            if printPOC == true then
               if poCalls[i] then
                   lexstr = "* " .. lexstr
               else
                   lexstr = "  " .. lexstr
               end
            end
            local lexlen = lexstr:len()
            if lexlen < 8 then
                lexstr = lexstr..blank:rep(8-lexlen)
            end
            local catname = lexit.catnames[output[2*i]]
            print(lexstr, catname)
            i = i+1
        end
    end

    local actualOutput = {}

    local count = 1
    local poc = false
    if poTest ~= nil then
        poc = poTest(count, nil, nil)
        if poc then lexit.preferOp() end
    end
    table.insert(poCalls, poc)

    for lexstr, cat in lexit.lex(prog) do
        table.insert(actualOutput, lexstr)
        table.insert(actualOutput, cat)
        count = count+1
        poc = false
        if poTest ~= nil then
            poc = poTest(count, lexstr, cat)
            if poc then lexit.preferOp() end
        end
        table.insert(poCalls, poc)
    end

    local success = arrayEq(actualOutput, expectedOutput)
    t:test(success, testName)
    if exit_on_failure and not success then
        io.write("\n")
        io.write("Input for the last test above:\n")
        io.write('"'..prog..'"\n')
        io.write("\n")
        io.write("Expected output of lexit.lex:\n")
        printResults(expectedOutput)
        io.write("\n")
        io.write("Actual output of lexit.lex:\n")
        printResults(actualOutput, poTest ~= nil)
        printNoteAndExit()
   end
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_catnames(t)
    io.write("Test Suite: Member catnames\n")

    local success =
        #lexit.catnames == 7 and
        lexit.catnames[1] == "Keyword" and
        lexit.catnames[2] == "Identifier" and
        lexit.catnames[3] == "NumericLiteral" and
        lexit.catnames[4] == "StringLiteral" and
        lexit.catnames[5] == "Operator" and
        lexit.catnames[6] == "Punctuation" and
        lexit.catnames[7] == "Malformed"
    t:test(success, "Value of catnames member")
    if exit_on_failure and not success then
        io.write("\n")
        io.write("Array lexit.catnames does not have the required\n")
        io.write("values. See the assignment description, where the\n")
        io.write("proper values are listed in a table.\n")
        printNoteAndExit()
    end
end


function test_idkey(t)
    io.write("Test Suite: Identifiers & Keywords\n")

    checklex(t, "a", {"a",ID}, "single letter")
    checklex(t, "_", {"_",PUNCT}, "single underscore")
    checklex(t, "9", {"9",NUMLIT}, "single digit")
    checklex(t, "ab", {"ab",ID}, "letter then letter")
    checklex(t, "a_", {"a_",ID}, "letter then underscore")
    checklex(t, "a5", {"a5",ID}, "letter then digit")
    checklex(t, "_b", {"_",PUNCT,"b",ID}, "underscore then letter")
    checklex(t, "__", {"_",PUNCT,"_",PUNCT}, "2underscores")
    checklex(t, "_5", {"_",PUNCT,"5",NUMLIT}, "underscore then digit")
    checklex(t, "2b", {"2",NUMLIT,"b",ID}, "digit then letter")
    checklex(t, "2_", {"2",NUMLIT,"_",PUNCT}, "digit then underscore")
    checklex(t, "25", {"25",NUMLIT}, "digit then digit")

    checklex(t, "_a3bb2984_d__", {"_",PUNCT,"a3bb2984_d__",ID},
             "longer ID")
    local astr = "a"
    local longidstr = astr:rep(10000)
    checklex(t, longidstr, {longidstr,ID}, "very long ID #1")
    checklex(t, longidstr.."+", {longidstr,ID,"+",OP},
             "very long ID #2")
    checklex(t, "abc def", {"abc",ID,"def",ID}, "space-separated IDs")

    -- Keywords
    checklex(t, "set", {"set",KEY}, "Single keyword #1")
    checklex(t, "print", {"print",KEY}, "Single keyword #2")
    checklex(t, "nl", {"nl",KEY}, "Single keyword #3")
    checklex(t, "input", {"input",KEY}, "Single keyword #4")
    checklex(t, "if", {"if",KEY}, "Single keyword #5")
    checklex(t, "else", {"else",KEY}, "Single keyword #6")
    checklex(t, "elseif", {"elseif",KEY}, "Single keyword #7")
    checklex(t, "while", {"while",KEY}, "Single keyword #8")
    checklex(t, "end", {"end",KEY}, "Single keyword #9")

    checklex(t, "SET", {"SET",ID}, "Upper-case keyword #1")
    checklex(t, "PRINT", {"PRINT",ID}, "Upper-case keyword #2")
    checklex(t, "NL", {"NL",ID}, "Upper-case keyword #3")
    checklex(t, "INPUT", {"INPUT",ID}, "Upper-case keyword #4")
    checklex(t, "IF", {"IF",ID}, "Upper-case keyword #5")
    checklex(t, "ELSE", {"ELSE",ID}, "Upper-case keyword #6")
    checklex(t, "ELSEIF", {"ELSEIF",ID}, "Upper-case keyword #7")
    checklex(t, "WHILE", {"WHILE",ID}, "Upper-case keyword #8")
    checklex(t, "END", {"END",ID}, "Upper-case keyword #9")

    checklex(t, "setx", {"setx",ID}, "ID starts with keyword #1")
    checklex(t, "printx", {"printx",ID}, "ID starts with keyword #2")
    checklex(t, "nlx", {"nlx",ID}, "ID starts with keyword #3")
    checklex(t, "inputx", {"inputx",ID}, "ID starts with keyword #4")
    checklex(t, "ifx", {"ifx",ID}, "ID starts with keyword #5")
    checklex(t, "elsex", {"elsex",ID}, "ID starts with keyword #6")
    checklex(t, "elseifx", {"elseifx",ID}, "ID starts with keyword #7")
    checklex(t, "whilex", {"whilex",ID}, "ID starts with keyword #8")
    checklex(t, "endx", {"endx",ID}, "ID starts with keyword #9")

    checklex(t, "xset", {"xset",ID}, "ID ends with keyword #1")
    checklex(t, "xprint", {"xprint",ID}, "ID ends with keyword #2")
    checklex(t, "xnl", {"xnl",ID}, "ID ends with keyword #3")
    checklex(t, "xinput", {"xinput",ID}, "ID ends with keyword #4")
    checklex(t, "xif", {"xif",ID}, "ID ends with keyword #5")
    checklex(t, "xelse", {"xelse",ID}, "ID ends with keyword #6")
    checklex(t, "xelseif", {"xelseif",ID}, "ID ends with keyword #7")
    checklex(t, "xwhile", {"xwhile",ID}, "ID ends with keyword #8")
    checklex(t, "xend", {"xend",ID}, "ID ends with keyword #9")

    checklex(t, "3set", {"3",NUMLIT,"set",KEY}, "digit & kwd #1")
    checklex(t, "3print", {"3",NUMLIT,"print",KEY}, "digit & kwd #2")
    checklex(t, "3nl", {"3",NUMLIT,"nl",KEY}, "digit & kwd #3")
    checklex(t, "3input", {"3",NUMLIT,"input",KEY}, "digit & kwd #4")
    checklex(t, "3if", {"3",NUMLIT,"if",KEY}, "digit & kwd #5")
    checklex(t, "3else", {"3",NUMLIT,"else",KEY}, "digit & kwd #6")
    checklex(t, "3elseif", {"3",NUMLIT,"elseif",KEY}, "digit & kwd #7")
    checklex(t, "3while", {"3",NUMLIT,"while",KEY}, "digit & kwd #8")
    checklex(t, "3end", {"3",NUMLIT,"end",KEY}, "digit & kwd #9")

    checklex(t, "s et", {"s",ID,"et",ID}, "Space-broken kwd #1")
    checklex(t, "pr int", {"pr",ID,"int",ID}, "Space-broken kwd #2")
    checklex(t, "n l", {"n",ID,"l",ID}, "Space-broken kwd #3")
    checklex(t, "inp ut", {"inp",ID,"ut",ID}, "Space-broken kwd #4")
    checklex(t, "i f", {"i",ID,"f",ID}, "Space-broken kwd #5")
    checklex(t, "els e", {"els",ID,"e",ID}, "Space-broken kwd #6")
    checklex(t, "elsei f", {"elsei",ID,"f",ID}, "Space-broken kwd #7")
    checklex(t, "whi le", {"whi",ID,"le",ID}, "Space-broken kwd #8")
    checklex(t, "en d", {"en",ID,"d",ID}, "Space-broken kwd #9")

    checklex(t, "else if", {"else",KEY,"if",KEY}, "else & if")

    checklex(t, "a set b print c nl d input e if f else g elseif h "..
                "while i end j",
             {"a",ID,"set",KEY,"b",ID,"print",KEY,"c",ID,"nl",KEY,
              "d",ID,"input",KEY,"e",ID,"if",KEY,"f",ID,"else",KEY,
              "g",ID,"elseif",KEY,"h",ID,"while",KEY,"i",ID,"end",KEY,
              "j",ID},
             "IDs & keywords")
end


function test_oppunct(t)
    io.write("Test Suite: Operators & Punctuation\n")

    -- Operator alone
    checklex(t, "+",  {"+",OP}, "+ alone")
    checklex(t, "-",  {"-",OP}, "- alone")
    checklex(t, "*",  {"*",OP}, "* alone")
    checklex(t, "/",  {"/",OP}, "/ alone")
    checklex(t, "%",  {"%",OP}, "% alone")
    checklex(t, "=",  {"=",OP}, "= alone")
    checklex(t, "==", {"==",OP}, "== alone")
    checklex(t, "!",  {"!",PUNCT}, "! alone")
    checklex(t, "!=", {"!=",OP}, "!= alone")
    checklex(t, "<",  {"<",OP}, "< alone")
    checklex(t, "<=", {"<=",OP}, "<= alone")
    checklex(t, ">",  {">",OP}, "> alone")
    checklex(t, ">=", {">=",OP}, ">= alone")
    checklex(t, "[",  {"[",OP}, "[ alone")
    checklex(t, "]",  {"]",OP}, "] alone")

    -- Operator followed by digit
    checklex(t, "+1",  {"+1",NUMLIT}, "+ then 1")
    checklex(t, "-1",  {"-1",NUMLIT}, "- then 1")
    checklex(t, "*1",  {"*",OP,"1",NUMLIT}, "* then 1")
    checklex(t, "/1",  {"/",OP,"1",NUMLIT}, "/ then 1")
    checklex(t, "%1",  {"%",OP,"1",NUMLIT}, "% then 1")
    checklex(t, "=1",  {"=",OP,"1",NUMLIT}, "= then 1")
    checklex(t, "==1", {"==",OP,"1",NUMLIT}, "== then 1")
    checklex(t, "!1",  {"!",PUNCT,"1",NUMLIT}, "! then 1")
    checklex(t, "!=1", {"!=",OP,"1",NUMLIT}, "!= then 1")
    checklex(t, "<1",  {"<",OP,"1",NUMLIT}, "< then 1")
    checklex(t, "<=1", {"<=",OP,"1",NUMLIT}, "<= then 1")
    checklex(t, ">1",  {">",OP,"1",NUMLIT}, "> then 1")
    checklex(t, ">=1", {">=",OP,"1",NUMLIT}, ">= then 1")
    checklex(t, "[1",  {"[",OP,"1",NUMLIT}, "[ then 1")
    checklex(t, "]1",  {"]",OP,"1",NUMLIT}, "% then 1")

    -- Operator followed by letter
    checklex(t, "+a",  {"+",OP,"a",ID}, "+ then a")
    checklex(t, "-a",  {"-",OP,"a",ID}, "- then a")
    checklex(t, "*a",  {"*",OP,"a",ID}, "* then a")
    checklex(t, "/a",  {"/",OP,"a",ID}, "/ then a")
    checklex(t, "%a",  {"%",OP,"a",ID}, "% then a")
    checklex(t, "=a",  {"=",OP,"a",ID}, "= then a")
    checklex(t, "==a", {"==",OP,"a",ID}, "== then a")
    checklex(t, "!a",  {"!",PUNCT,"a",ID}, "! then a")
    checklex(t, "!=a", {"!=",OP,"a",ID}, "!= then a")
    checklex(t, "<a",  {"<",OP,"a",ID}, "< then a")
    checklex(t, "<=a", {"<=",OP,"a",ID}, "<= then a")
    checklex(t, ">a",  {">",OP,"a",ID}, "> then a")
    checklex(t, ">=a", {">=",OP,"a",ID}, ">= then a")
    checklex(t, "[a",  {"[",OP,"a",ID}, "[ then a")
    checklex(t, "]a",  {"]",OP,"a",ID}, "] then a")

    -- Operator followed by "*"
    checklex(t, "+*",  {"+",OP,"*",OP}, "+ then *")
    checklex(t, "-*",  {"-",OP,"*",OP}, "- then *")
    checklex(t, "**",  {"*",OP,"*",OP}, "* then *")
    checklex(t, "/*",  {"/",OP,"*",OP}, "/ then *")
    checklex(t, "%*",  {"%",OP,"*",OP}, "% then *")
    checklex(t, "=*",  {"=",OP,"*",OP}, "= then *")
    checklex(t, "==*", {"==",OP,"*",OP}, "== then *")
    checklex(t, "!*",  {"!",PUNCT,"*",OP}, "! then *")
    checklex(t, "!=*", {"!=",OP,"*",OP}, "!= then *")
    checklex(t, "<*",  {"<",OP,"*",OP}, "< then *")
    checklex(t, "<=*", {"<=",OP,"*",OP}, "<= then *")
    checklex(t, ">*",  {">",OP,"*",OP}, "> then *")
    checklex(t, ">=*", {">=",OP,"*",OP}, ">= then *")
    checklex(t, "[*",  {"[",OP,"*",OP}, "[ then *")
    checklex(t, "]*",  {"]",OP,"*",OP}, "] then *")

    -- Eliminated operators
    checklex(t, "++",  {"+",OP,"+",OP}, "old operator: ++")
    checklex(t, "--",  {"-",OP,"-",OP}, "old operator: --")
    checklex(t, "--2", {"-",OP,"-2",NUMLIT}, "old operator: -- then 2")
    checklex(t, ".",   {".",PUNCT}, "old operator: .")
    checklex(t, "+=",  {"+",OP,"=",OP}, "old operator: +=")
    checklex(t, "-=",  {"-",OP,"=",OP}, "old operator: -=")
    checklex(t, ".=",   {".",PUNCT,"=",OP}, "old operator: .=")
    checklex(t, ".*",   {".",PUNCT,"*",OP}, "old operator: .*")

    -- More complex stuff
    checklex(t, "=====",  {"==",OP,"==",OP,"=",OP}, "=====")
    checklex(t, "=<<==",  {"=",OP,"<",OP,"<=",OP,"=",OP}, "=<<==")
    checklex(t, "**/ ",  {"*",OP,"*",OP,"/",OP}, "**/ ")
    checklex(t, "= =", {"=",OP,"=",OP}, "= =")
    checklex(t, "--2-", {"-",OP,"-2",NUMLIT,"-",OP}, "--2-")

    -- Punctuation chars
    checklex(t, "(", {"(",PUNCT}, "left parenthesis")
    checklex(t, ")", {")",PUNCT}, "right parenthesis")
    checklex(t, "{", {"{",PUNCT}, "left brace")
    checklex(t, "}", {"}",PUNCT}, "right brace")
    checklex(t, "!@$%^&*()",
             {"!",PUNCT,"@",PUNCT,"$",PUNCT,"%",OP,
              "^",PUNCT,"&",PUNCT,"*",OP,"(",PUNCT,")",PUNCT},
             "assorted punctuation & operators #1")
    checklex(t, ",.;:\\|=+-_`~/?",
             {",",PUNCT,".",PUNCT,";",PUNCT,":",PUNCT,"\\",PUNCT,
              "|",PUNCT,"=",OP,"+",OP,"-",OP,"_",PUNCT,"`",PUNCT,
              "~",PUNCT,"/",OP,"?",PUNCT},
             "assorted punctuation & operators #2")
end


function test_num(t)
    io.write("Test Suite: Numeric Literals\n")

    checklex(t, "3", {"3",NUMLIT}, "single digit")
    checklex(t, "3a", {"3",NUMLIT,"a",ID}, "single digit then letter")

    checklex(t, "123456", {"123456",NUMLIT}, "num, no dot")
    checklex(t, ".123456", {".",PUNCT,"123456",NUMLIT},
             "num, dot @ start")
    checklex(t, "123456.", {"123456",NUMLIT,".",PUNCT},
             "num, dot @ end")
    checklex(t, "123.456", {"123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "num, dot in middle")
    checklex(t, "1.2.3", {"1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                          "3",NUMLIT}, "num, 2 dots")

    checklex(t, "+123456", {"+123456",NUMLIT}, "+num, no dot")
    checklex(t, "+.123456", {"+",OP,".",PUNCT,"123456",NUMLIT},
             "+num, dot @ start")
    checklex(t, "+123456.", {"+123456",NUMLIT,".",PUNCT},
             "+num, dot @ end")
    checklex(t, "+123.456", {"+123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "+num, dot in middle")
    checklex(t, "+1.2.3", {"+1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                           "3",NUMLIT}, "+num, 2 dots")

    checklex(t, "-123456", {"-123456",NUMLIT}, "-num, no dot")
    checklex(t, "-.123456", {"-",OP,".",PUNCT,"123456",NUMLIT},
             "-num, dot @ start")
    checklex(t, "-123456.", {"-123456",NUMLIT,".",PUNCT},
             "-num, dot @ end")
    checklex(t, "-123.456", {"-123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "-num, dot in middle")
    checklex(t, "-1.2.3", {"-1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                           "3",NUMLIT}, "-num, 2 dots")

    checklex(t, "--123456", {"-",OP,"-123456",NUMLIT}, "--num, no dot")
    checklex(t, "--123456", {"-",OP,"-123456",NUMLIT},
             "--num, dot @ end")

    local onestr = "1"
    local longnumstr = onestr:rep(10000)
    checklex(t, longnumstr, {longnumstr,NUMLIT}, "very long num #1")
    checklex(t, longnumstr.."+", {longnumstr,NUMLIT,"+",OP},
             "very long num #2")
    checklex(t, "123 456", {"123",NUMLIT,"456",NUMLIT},
             "space-separated nums")

    -- Exponents
    checklex(t, "123e456", {"123e456",NUMLIT}, "num with exp")
    checklex(t, "123e+456", {"123e+456",NUMLIT}, "num with +exp")
    checklex(t, "123e-456", {"123e-456",NUMLIT}, "num with -exp")
    checklex(t, "+123e456", {"+123e456",NUMLIT}, "+num with exp")
    checklex(t, "+123e+456", {"+123e+456",NUMLIT}, "+num with +exp")
    checklex(t, "+123e-456", {"+123e-456",NUMLIT}, "+num with -exp")
    checklex(t, "-123e456", {"-123e456",NUMLIT}, "-num with exp")
    checklex(t, "-123e+456", {"-123e+456",NUMLIT}, "-num with +exp")
    checklex(t, "-123e-456", {"-123e-456",NUMLIT}, "-num with -exp")
    checklex(t, "123E456", {"123E456",NUMLIT}, "num with Exp")
    checklex(t, "123E+456", {"123E+456",NUMLIT}, "num with +Exp")
    checklex(t, "123E-456", {"123E-456",NUMLIT}, "num with -Exp")
    checklex(t, "+123E456", {"+123E456",NUMLIT}, "+num with Exp")
    checklex(t, "+123E+456", {"+123E+456",NUMLIT}, "+num with +Exp")
    checklex(t, "+123E-456", {"+123E-456",NUMLIT}, "+num with -Exp")
    checklex(t, "-123E456", {"-123E456",NUMLIT}, "-num with Exp")
    checklex(t, "-123E+456", {"-123E+456",NUMLIT}, "-num with +Exp")
    checklex(t, "-123E-456", {"-123E-456",NUMLIT}, "-num with -Exp")

    checklex(t, "1.2e34", {"1",NUMLIT,".",PUNCT,"2e34",NUMLIT},
             "num with dot, exp")
    checklex(t, "12e3.4", {"12e3",NUMLIT,".",PUNCT,"4",NUMLIT},
             "num, exp with dot")

    checklex(t, "e", {"e",ID}, "Just e")
    checklex(t, "E", {"E",ID}, "Just E")
    checklex(t, "e3", {"e3",ID}, "e3")
    checklex(t, "E3", {"E3",ID}, "E3")
    checklex(t, "e+3", {"e",ID,"+3",NUMLIT}, "e+3")
    checklex(t, "E+3", {"E",ID,"+3",NUMLIT}, "E+3")
    checklex(t, "1e3", {"1e3",NUMLIT}, "e+3")
    checklex(t, "123e", {"123",NUMLIT,"e",ID}, "num e")
    checklex(t, "123E", {"123",NUMLIT,"E",ID}, "num E")
    checklex(t, "123ee", {"123",NUMLIT,"ee",ID}, "num ee #1")
    checklex(t, "123Ee", {"123",NUMLIT,"Ee",ID}, "num ee #2")
    checklex(t, "123eE", {"123",NUMLIT,"eE",ID}, "num ee #3")
    checklex(t, "123EE", {"123",NUMLIT,"EE",ID}, "num ee #4")
    checklex(t, "123ee1", {"123",NUMLIT,"ee1",ID}, "num ee  num#1")
    checklex(t, "123Ee1", {"123",NUMLIT,"Ee1",ID}, "num ee num #2")
    checklex(t, "123eE1", {"123",NUMLIT,"eE1",ID}, "num ee num #3")
    checklex(t, "123EE1", {"123",NUMLIT,"EE1",ID}, "num ee num #4")
    checklex(t, "123e+", {"123",NUMLIT,"e",ID,"+",OP}, "num e+ #1")
    checklex(t, "123E+", {"123",NUMLIT,"E",ID,"+",OP}, "num e+ #2")
    checklex(t, "123e-", {"123",NUMLIT,"e",ID,"-",OP}, "num e- #1")
    checklex(t, "123E-", {"123",NUMLIT,"E",ID,"-",OP}, "num e- #2")
    checklex(t, "123e+e7", {"123",NUMLIT,"e",ID,"+",OP,"e7",ID},
             "num e+e7")
    checklex(t, "123e-e7", {"123",NUMLIT,"e",ID,"-",OP,"e7",ID},
             "num e-e7")
    checklex(t, "123e7e", {"123e7",NUMLIT,"e",ID}, "num e7e")
    checklex(t, "123e+7e", {"123e+7",NUMLIT,"e",ID}, "num e+7e")
    checklex(t, "123e-7e", {"123e-7",NUMLIT,"e",ID}, "num e-7e")
    checklex(t, "123f7", {"123",NUMLIT,"f7",ID}, "num f7 #1")
    checklex(t, "123F7", {"123",NUMLIT,"F7",ID}, "num f7 #3")

    checklex(t, "123 e+7", {"123",NUMLIT,"e",ID,"+7",NUMLIT},
             "space-separated exp #1")
    checklex(t, "123 e-7", {"123",NUMLIT,"e",ID,"-7",NUMLIT},
             "space-separated exp #2")
    checklex(t, "123e1 2", {"123e1",NUMLIT,"2",NUMLIT},
             "space-separated exp #3")
    twostr = "2"
    longexp = twostr:rep(10000)
    checklex(t, "3e"..longexp, {"3e"..longexp,NUMLIT}, "long exp #1")
    checklex(t, "3e"..longexp.."-", {"3e"..longexp,NUMLIT,"-",OP},
             "long exp #2")
end


function test_illegal(t)
    io.write("Test Suite: Illegal Characters\n")

    checklex(t, "\001", {"\001",MAL}, "Single illegal character #1")
    checklex(t, "\031", {"\031",MAL}, "Single illegal character #2")
    checklex(t, "a\002bcd\003\004ef",
             {"a",ID,"\002",MAL,"bcd",ID,"\003",MAL,
              "\004",MAL,"ef",ID},
             "Various illegal characters")
    checklex(t, "a#\001\nb", {"a",ID,"b",ID},
             "Illegal character in comment")
    checklex(t, "b'\001'", {"b",ID,"'\001'",STRLIT},
             "Illegal character in single-quoted string")
    checklex(t, "c\"\001\"", {"c",ID,"\"\001\"",STRLIT},
             "Illegal character in double-quoted string")
    checklex(t, "b'\001", {"b",ID,"'\001",MAL},
             "Illegal character in single-quoted partial string")
    checklex(t, "c\"\001", {"c",ID,"\"\001",MAL},
             "Illegal character in double-quoted partial string")
end


function test_comment(t)
    io.write("Test Suite: Space & Comments\n")

    -- Space
    checklex(t, " ", {}, "Single space character #1")
    checklex(t, "\t", {}, "Single space character #2")
    checklex(t, "\n", {}, "Single space character #3")
    checklex(t, "\r", {}, "Single space character #4")
    checklex(t, "\f", {}, "Single space character #5")
    checklex(t, "ab 12", {"ab",ID,"12",NUMLIT},
             "Space-separated lexemes #1")
    checklex(t, "ab\t12", {"ab",ID,"12",NUMLIT},
             "Space-separated lexemes #2")
    checklex(t, "ab\n12", {"ab",ID,"12",NUMLIT},
             "Space-separated lexemes #3")
    checklex(t, "ab\r12", {"ab",ID,"12",NUMLIT},
             "Space-separated lexemes #4")
    checklex(t, "ab\f12", {"ab",ID,"12",NUMLIT},
             "Space-separated lexemes #5")
    blankstr = " "
    longspace = blankstr:rep(10000)
    checklex(t, longspace.."abc"..longspace, {"abc",ID},
             "very long space")

    -- Comments
    checklex(t, "#abcd\n", {}, "Comment")
    checklex(t, "12#abcd\nab", {"12",NUMLIT,"ab",ID},
             "Comment-separated lexemes")
    checklex(t, "12#abcd", {"12",NUMLIT}, "Unterminated comment #1")
    checklex(t, "12#abcd#", {"12",NUMLIT}, "Unterminated comment #2")
    checklex(t, "12#a\n#b\n#c\nab", {"12",NUMLIT,"ab",ID},
             "Multiple comments #1")
    checklex(t, "12#a\n  #b\n \n #c\nab", {"12",NUMLIT,"ab",ID},
             "Multiple comments #2")
    checklex(t, "12#a\n=#b\n.#c\nab",
             {"12",NUMLIT,"=",OP,".",PUNCT,"ab",ID},
             "Multiple comments #3")
    checklex(t, "a##\nb", {"a",ID,"b",ID}, "Comment with # #1")
    checklex(t, "a##b", {"a",ID}, "Comment with # #2")
    checklex(t, "a##b\n\nc", {"a",ID,"c",ID}, "Comment with # #3")
    xstr = "x"
    longcmt = "#"..xstr:rep(10000).."\n"
    checklex(t, "a"..longcmt.."b", {"a",ID,"b",ID}, "very long comment")
end


function test_string(t)
    io.write("Test Suite: String Literals\n")

    checklex(t, "''", {"''",STRLIT}, "Empty single-quoted str")
    checklex(t, "\"\"", {"\"\"",STRLIT}, "Empty double-quoted str")
    checklex(t, "'a'", {"'a'",STRLIT}, "1-char single-quoted str")
    checklex(t, "\"b\"", {"\"b\"",STRLIT}, "1-char double-quoted str")
    checklex(t, "'abc def'", {"'abc def'",STRLIT},
             "longer single-quoted str")
    checklex(t, "\"The quick brown fox.\"",
             {"\"The quick brown fox.\"",STRLIT},
             "longer double-quoted str")
    checklex(t, "'aa\"bb'", {"'aa\"bb'",STRLIT},
             "single-quoted str with double quote")
    checklex(t, "\"cc'dd\"", {"\"cc'dd\"",STRLIT},
             "double-quoted str with single quote")
    checklex(t, "'aabbcc", {"'aabbcc",MAL},
             "partial single-quoted str #1")
    checklex(t, "'aabbcc\"", {"'aabbcc\"",MAL},
             "partial single-quoted str #2")
    checklex(t, "\"aabbcc", {"\"aabbcc",MAL},
             "partial double-quoted str #1")
    checklex(t, "\"aabbcc'", {"\"aabbcc'",MAL},
             "partial double-quoted str #2")
    checklex(t, "'\"'\"'\"", {"'\"'",STRLIT,"\"'\"",STRLIT},
             "multiple strs")
    checklex(t, "'#'#'\n'\n'", {"'#'",STRLIT,"'\n'",STRLIT},
             "strs & comments")
    checklex(t, "\"a\"a\"a\"a\"",
             {"\"a\"",STRLIT,"a",ID,"\"a\"",STRLIT,"a",ID,"\"",MAL},
             "strs & identifiers")
    xstr = "x"
    longstr = "'"..xstr:rep(10000).."'"
    checklex(t, "a"..longstr.."b", {"a",ID,longstr,STRLIT,"b",ID},
             "very long str")
end


function test_preferop(t)
    io.write("Test Suite: Using preferOp\n")

    local function po_false(n,s,c) return false end
    local function po_true(n,s,c) return true end
    local function po_two(n,s,c) return n==2 or n==5 end
    local function po_val(n,s,c)
        return c == NUMLIT or c == ID or (c == PUNCT and s == ")")
    end

    checklex(t, "-1-1-1-1", {"-1",NUMLIT,"-1",NUMLIT,"-1",NUMLIT,
                             "-1",NUMLIT},
             "preferOp never called", po_false)
    checklex(t, "-1-1-1-1", {"-",OP,"1",NUMLIT,"-",OP,"1",NUMLIT,"-",OP,
                             "1",NUMLIT, "-",OP, "1",NUMLIT},
             "preferOp always called", po_true)
    checklex(t, "-1-1-1-1", {"-1",NUMLIT,"-",OP,"1",NUMLIT,"-1",NUMLIT,
                             "-",OP,"1",NUMLIT},
             "preferOp called on lexemes 2 & 5", po_two)
    checklex(t, "-1-1-1-1", {"-1",NUMLIT,"-",OP,"1",NUMLIT,"-",OP,
                             "1",NUMLIT,"-",OP,"1",NUMLIT},
             "preferOp called after values", po_val)
end


function test_program(t)
    io.write("Test Suite: Complete Programs\n")

    local function po_val(n,s,c)
        return c == NUMLIT or c == ID
               or (c == PUNCT and s == ")")
               or (c == OP and s == "]")
    end

    checklex(t, "set a = -34 # var \n"..
                "set bc=a+17e2\n" ..
                "set n[7] = bc+1 # array item\n" ..
                "print bc/3-7 nl # some printing\n" ..
                "if n[7]>2 print 'big' nl # conditional\n",
             {"set",KEY,"a",ID,"=",OP,"-34",NUMLIT,"set",KEY,"bc",ID,
              "=",OP,"a",ID,"+",OP,"17e2",NUMLIT,"set",KEY,"n",ID,
              "[",OP,"7",NUMLIT,"]",OP,"=",OP,"bc",ID,"+",OP,"1",NUMLIT,
              "print",KEY,"bc",ID,"/",OP,"3",NUMLIT,"-",OP,"7",NUMLIT,
              "nl",KEY,"if",KEY,"n",ID,"[",OP,"7",NUMLIT,"]",OP,">",OP,
              "2",NUMLIT,"print",KEY,"'big'",STRLIT,"nl",KEY},
              "Complete program", po_val)

end


function test_lexit(t)
    io.write("TEST SUITES FOR MODULE lex\n")
    test_catnames(t)
    test_idkey(t)
    test_oppunct(t)
    test_num(t)
    test_illegal(t)
    test_comment(t)
    test_string(t)
    test_preferop(t)
    test_program(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_lexit(tester)
io.write("\n")
if tester:allPassed() then
    io.write("All tests successful\n")
else
    io.write("Tests ********** UNSUCCESSFUL **********\n")
    io.write("\n")
    io.write("******************************************************\n")
    io.write("*                                                    *\n")
    io.write("*  NOTE: This program is set to execute all tests.   *\n")
    io.write("*        If you would prefer to stop after the       *\n")
    io.write("*        first failing test and see detailed         *\n")
    io.write("*        results, then set variable exit_on_failure  *\n")
    io.write("*        to true. (See the beginning of the source   *\n")
    io.write("*        code.)                                      *\n")
    io.write("*                                                    *\n")
    io.write("******************************************************\n")
end
io.write("\n")

