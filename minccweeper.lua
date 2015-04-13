--[[
  +---=== minccweeper ===---+
  | This is a 'receation'   |
  | of minesweeper for the  |
  | Minecraft modification  |
  | computercraft.          |
  +-------------------------+
          Made by Neui
]]

local currVer = 0 -- Version of this program
local w, h = term.getSize() -- Size of the screen
local running = true -- Program runs

local f = {} -- Functions
f.draw = {} -- Drawing functions

local v = {} -- Variables
v.state = 1 -- State 0 = startup, 1 = Main menu, 2 = Ingame
v.sel = {}
v.sel.title = 1
v.sel.customField = 0
v.titleSelection = {}
v.field = {}
v.field.width = 9
v.field.height = 9
v.field.mines = 10
v.time = 0
v.draw = {}
v.draw.fieldMoved = true
v.draw.redraw = true

local c = {} -- constants
c.name = "minCCweeper"
c.title = "~[ " .. c.name .. " ]~"
c.field = {}
c.field.maxwidth = 30  -- Taken from windows minesweeper lol
c.field.maxheight = 24
c.field.minmines = 10
c.field.maxmines = 668
c.field.draw = {}
c.field.draw.unknown = { ["char"] = '#'; ["fgmono"] = colors.white; ["bgadv"] = colors.gray; ["bgmono"] = colors.black; }
c.field.draw.nothing = { ["char"] = ' '; }
c.field.draw.mine = { ["char"] = 'O'; ["fgadv"] = colors.red; }
c.field.draw.mightMine = { ["char"] = 'P'; ["fgadv"] = colors.lightGray; }
c.field.draw.numbers = { ["fg"] = { colors.blue, colors.green, colors.red, colors.blue, colors.brown, colors.lightBlue, colors.gray, colors.lightGray }; }
c.field.presets = {} -- Also taken form windows minesweeper
c.field.presets.beginner = { ["name"] = "Beginner"; ["width"] =  9; ["height"] =  9; ["mines"] = 10; }
c.field.presets.advanced = { ["name"] = "Advanced"; ["width"] = 16; ["height"] = 16; ["mines"] = 40; }
c.field.presets.pro =  { ["name"] = "Professional"; ["width"] = 30; ["height"] = 16; ["mines"] = 99; }

local playfield = {} -- Contains all of the bombs etc.
local playerfiled = {} -- What the players sees

local function csleep(sec)
  local timer, p1 = os.startTimer(tonumber(sec or 0))
  repeat
    local _, p1 = os.pullEventRaw("timer")
  until p1 == timer
end

-- Main Drawing Loop
function f.drawLoop()
  while running do
    if v.draw.redraw then
      f.draw.setTBGColor(term, colors.white, colors.black)
      term.clear()
    end
    if v.state == 1 or v.state == 2 then -- Main Selection
      f.draw.title(term, w, h)
      f.draw.titleSelection(term, w, h)
      f.draw.fieldSizeAndWidth(term, w, h)
      if v.state == 2 then
        term.setCursorPos(w, h-1)
        term.setCursorBlink(true)
      else
        
      end 
    elseif v.state == 3 then -- ingame
      if v.draw.fieldMoved or v.draw.redraw then
        f.draw.field(term, w, h, field)
      end
      f.draw.footer(term, w, h)
    end
    csleep(0)
  end
end

function f.draw.field(term, w, h, field)

end

function f.draw.footer(term, w, h)
  -- [FHxFW MI     TIMEs]
  f.draw.setBGColor(term, colors.black)
  term.setCursorPos(1, h)
  f.draw.setTextColor(term, colors.green)
  term.write(tostring(v.field.width))
  f.draw.setTextColor(term, colors.white)
  term.write("x")  
  f.draw.setTextColor(term, colors.green)
  term.write(tostring(v.field.height))
  f.draw.setTextColor(term, colors.brown)
  term.write(" " .. tostring(v.field.mines))
end

function f.draw.title(term, w, h)
  term.setCursorPos((w/2)-(#c.title/2), h/#v.titleSelection)
  term.write(c.title)
end

function f.draw.titleSelection(term, w, h)
  for k, val in ipairs(v.titleSelection) do
    term.setCursorPos((w/2)-((#val.name+2)/2), (h/2)-(#v.titleSelection/2)+k)
    if k == v.sel.title then
      f.draw.setTBGColor(term, colors.black, colors.lightGray, colors.white)
    else
      f.draw.setTBGColor(term, colors.white, colors.black)  
    end
    term.write(" " .. val.name .. " ")
  end
end

function f.draw.fieldSizeAndWidth(term, w, h)
  term.setCursorPos(w/2-7, h-1)
  f.draw.setTBGColor(term, colors.white, colors.black)
  term.write("  x       Mines")
  
  term.setCursorPos(w/2-7, h-1)
  f.draw.setTBGColor(term, colors.orange, colors.black, colors.white)
  if v.field.width < 10 then
    term.write("0")
  end
  term.write(tostring(v.field.width))
  
  term.setCursorPos(w/2-4, h-1)
  if v.field.height < 10 then
    term.write("0")
  end
  term.write(tostring(v.field.height))
  
  term.setCursorPos(w/2-1, h-1)
  if v.field.mines < 100 then
    term.write("0")
  elseif v.field.mines < 10 then
    term.write("00")
  end
  term.write(tostring(v.field.mines))
end

function f.draw.setTextColor(term, adv, mono)
  local mono, adv = tonumber(mono) or tonumber(adv) or 1, tonumber(adv) or 1
  if term.isColor and term.isColor() then
    term.setTextColor(adv)
  else
    term.setTextColor(mono)
  end
end

function f.draw.setBGColor(term, adv, mono)
  local mono, adv = tonumber(mono) or tonumber(adv) or colors.black, tonumber(adv) or colors.black
  if term.isColor and term.isColor() then
    term.setBackgroundColor(adv)
  else
    term.setBackgroundColor(mono)
  end
end

function f.draw.setTBGColor(term, advt, advbg, monot, monobg)
  f.draw.setTextColor(term, advt, monot)
  f.draw.setBGColor(term, advbg, monobg)
end

function f.getFromFieldPos(x, y, field)
  return field[x*y]
end

function f.doSelection(sel, tsel, field)
  if tsel[sel]["function"] == "exit" then
    running = false
  elseif tsel[sel]["function"] == "custom" then
     
  else
    v.state = 3
  end
end

function f.inputLoop()
  while running do
    local ev, p1, p2, p3, p4, p5 = os.pullEventRaw()
    if ev == "terminate" then
      running = false
    elseif ev == "term.resize" then
      w, h = term.getSize()
    elseif ev == "key" then
      if v.state == 1 then -- Main menu
        if p1 == 200 then -- Up Arrow
          v.sel.title = ((v.sel.title - 2) % #v.titleSelection) + 1
        elseif p1 == 208 then -- Down Arrow
          v.sel.title = (v.sel.title % #v.titleSelection) + 1
        elseif p1 == 28 then -- Enter
          f.doSelection(v.sel.title, v.titleSelection, v.field)
        end
        if not v.titleSelection[v.sel.title]["function"] then
          v.field.width = v.titleSelection[v.sel.title]["width"]
          v.field.height = v.titleSelection[v.sel.title]["height"]
          v.field.mines = v.titleSelection[v.sel.title]["mines"]
        end
      elseif v.mode == 2 then -- Custom selection
        
      elseif v.mode == 3 then -- Ingame
      
      end
    end
  end
end

-- Main Program
local function main()
  parallel.waitForAny(f.inputLoop, f.drawLoop)
end

-- Initalise
local function init()
  local notice = false
  f.draw.setTextColor(term, colors.white)
  
  -- Setup the titlescreen selection
  for k, val in pairs(c.field.presets) do
    v.titleSelection[#v.titleSelection + 1] = val
  end
  v.titleSelection[#v.titleSelection + 1] = {["name"] = "Custom"; ["function"] = "custom";}
  v.titleSelection[#v.titleSelection + 1] = {["name"] = "Exit"; ["function"] = "exit"; }
  
  
  if notice and running then
    write("\nPress a key to continue... (or wait 10s)")
    local tim, ev, p1 = os.startTimer(10)
    repeat
      ev, p1 = os.pullEventRaw()
    until (ev == "key") or (ev == "timer" and p1 == tim)
  end
end

local est, emsg = pcall(init)
if not running or not est then -- error
  if not est then
   write(string.format("\nAn error happend during init:\n%s\n", tostring(emsg)))
  else
   write("\nProgram terminated.\n")
  end
else
  local _gsStart = os.clock()
  local est, emsg = pcall(main)
  term.setTextColor(1)
  term.setBackgroundColor(32768)
  term.clear()
  term.setCursorPos(1,1)
  if not est then
   write(string.format("An error happend:\n%s\n", tostring(emsg)))
  else
   write("Program terminated.\n")
  end
  local _gs = math.floor(os.clock() - _gsStart + 0.5)
  local _h, _m, _s = _gs / 3600, (_gs / 60) % 60, _gs % 60
  write(string.format("Ran for %uh%um%us (%us)\n", _h, _m, _s, _gs))
end