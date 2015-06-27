-- Graph by Neui

--[[
  This lets you draw a graph based on history.
  
  Arguments:
  history_table  - Array with all the data
  max_value      - The max value it can be; if a value is over it, then it will not draw it
  
  width          - Width of the visible graph
  height         - Height of the visible graph
  from_beginning - If false, it starts reading from the end else from the beginning
  draw_method    - Either - a function that accepts x, y, char while char can be \-/|+
                          - a 1 for outputting a table in the format as {"-\ /-","  -  "}
                          - a 0 for outputting a table in the format as {{x, y, char},...}
  type_checking  - If true then it disables some type checking
  
  History Table (Data) structure:
  [1] = value
  [2] = value
  [3] = value
   ... And so on
]]
local function draw_history_graph(history_table, max_value, zero_point, width, height, from_beginning, draw_method, type_checking)
  -- Put some brackets here to completly disable type checking
  assert(type(history_table) == "table", "Expected table for history_table, got " .. type(history_table))
  assert(type(max_value) == "number", "Expected number for max_value, got " .. type(max_value))
  local width = tonumber(width) or (term.getSize and (term.getSize())[1])
  local height = tonumber(height) or (term.getSize and (term.getSize())[2])
  local zero_point = tonumber(zero_point) or 0
  if not type_checking then
    assert(width, "Expected number for width, got " .. type(width))
    assert(height, "Expected number for height, got " .. type(height))
    assert(type(draw_method) == "function" or (type(draw_method) == "number" and draw_method >= 0 and draw_method <= 1),
      "Expected function or number[0-1] for draw_method, got " .. tpnumber(draw_method) or type(draw_method))
  end
  --]]
  if type(draw_method) == "number" then
    local _draw_table = {}
    if draw_method == 0 then
      local function draw_method(x, y, char)
        local str = (_draw_table[y] or string.rep(" ", width))
        _draw_table[y] = str:sub(1, y - 1) .. char .. str:sub(y + 1)
      end
    else -- draw_method is 1
      local function draw_method(x, y, char)
        _draw_table[#draw_table + 1] = { x, y, char }
      end
    end
  end
  
  local _start, _end, step = 1, math.min(#history_table, width), 1
  if from_beginning then
    _start, _end, step = #history_table, math.max(#history_table - width, 1), -1
  end
  
  for i = _start, _end, step do
    if history_table[i] <= max_value then
      local ypos = history_table[i] / max_value * height
      
      --[[ TODO
        Find a way how the /-_\| should be calculated
        Idea:
        Calculate every Y value and then calculate an "angle"
        From a table, calculate what chars at wich angles should be
      ]]
    end
  end
  return _draw_table
end


--[[
  This lets you draw a graph based on history.
  This one is more simple in the coding for reducing file size (and perfomance)
   and less features
  
  Arguments:
  history_table - Array with all the data
  max_value     - The max value it can be; if a value is over it, then it will not draw it
  width         - Width of the visible graph
  height        - Height of the visible graph
  from_beginning - If false, it starts reading from the end else from the beginning
  
  It gives you a table with all the points and coordinates:
  {{x, y}, {x, y}}
  
  History Table (Data) structure:
  [1] = value
  [2] = value
  [3] = value
   ... And so on
]]
local function draw_history_graph_simple(history_table, max_value, width, height, from_beginning)
  -- Put some brackets here to completly disable type checking
  assert(type(history_table) == "table", "Expected table for history_table, got " .. type(history_table))
  assert(type(max_value) == "number", "Expected number for max_value, got " .. type(max_value))
  local width = tonumber(width) or (term.getSize and (term.getSize())[1])
  local height = tonumber(height) or (term.getSize and (term.getSize())[2])
  local zero_point = tonumber(zero_point) or 0
  local _draw_table = {}
  
  local _start, _end, step = 1, math.min(#history_table, width), 1
  if from_beginning then
    _start, _end, step = #history_table, math.max(#history_table - width, 1), -1
  end
  
  for i = _start, _end, step do
    if history_table[i] <= max_value then
      local ypos = history_table[i] / max_value * height
      _draw_table[#_draw_table + 1] = { i, height - ypos }
    end
  end
  return _draw_table
end