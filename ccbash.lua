-- CCBASH - Made by Neui

--[[
Features not included yet:
- Deamon (start programs in background)

Featues that won't be included:
- Locale
- 
]]

local oldShell = {} -- backup old shell

local history = {}
local maxHistory = 100 -- 100 is default
local aliases = {}
local env = {
  ["PS1"] = nil;
  ["PS2"] = nil;
  ["PS3"] = nil;
  ["PS4"] = nil;
  
  ["TERM"] = "ccterm"; -- Does it have a official name?
  ["COLUMNS"] = term.getSize and ({term.getSize()})[1] or 51;
  ["ROWS"] = term.getSize and ({term.getSize()})[2] or 19;
  
  ["PWD"] = "/";
  
  ["USER"] = "anon"; -- Will be OS specific
  ["LOGNAME"] = "anon";
  
  ["EDITOR"] = "/rom/programs/edit"; -- Probably
}

local f = {} -- Functions

local builtin = { -- [command] = function(command, args, env)
  ["type"] = nil;
  ["cd"] = nil;
  ["echo"] = nil;
  ["export"] = nil;
  ["set"] = nil;
  ["unset"] = nil;
  ["kill"] = nil;
  ["alias"] = nil;
}


function f.runProgram(path, args)


end

-- Accepts string and converts them into a table
function f.argToTable(args)
  
end