-- twine
-- "to form by twisting,
-- intertwining,
-- or interlacing..."
--
-- by: @cfd90
--
-- ENC1 volume
-- KEY2 randomize 1
-- KEY3 randomize 2
-- ENC2 seek 1
-- ENC3 seek 2

engine.name = "Glut"

local g
local x = 1
local y = 1

local function setup_params()
  params:add_separator("reverb")
  
  params:add_taper("reverb_mix", "* mix", 0, 100, 50, 0, "%")
  params:set_action("reverb_mix", function(value) engine.reverb_mix(value / 100) end)

  params:add_taper("reverb_room", "* room", 0, 100, 50, 0, "%")
  params:set_action("reverb_room", function(value) engine.reverb_room(value / 100) end)

  params:add_taper("reverb_damp", "* damp", 0, 100, 50, 0, "%")
  params:set_action("reverb_damp", function(value) engine.reverb_damp(value / 100) end)
  
  params:add_separator("samples")
  
  for i=1,2 do
    params:add_file(i .. "sample", i .. " sample")
    params:set_action(i .. "sample", function(file) engine.read(i, file) end)
    
    params:add_taper(i .. "volume", i .. " volume", -60, 20, 0, 0, "dB")
    params:set_action(i .. "volume", function(value) engine.volume(i, math.pow(10, value / 20)) end)
  
    params:add_taper(i .. "speed", i .. " speed", -400, 400, 0, 0, "%")
    params:set_action(i .. "speed", function(value) engine.speed(i, value / 100) end)
  
    params:add_taper(i .. "jitter", i .. " jitter", 0, 500, 0, 5, "ms")
    params:set_action(i .. "jitter", function(value) engine.jitter(i, value / 1000) end)
  
    params:add_taper(i .. "size", i .. " size", 1, 500, 100, 5, "ms")
    params:set_action(i .. "size", function(value) engine.size(i, value / 1000) end)
  
    params:add_taper(i .. "density", i .. " density", 0, 512, 20, 6, "hz")
    params:set_action(i .. "density", function(value) engine.density(i, value) end)
  
    params:add_taper(i .. "pitch", i .. " pitch", -48, 48, 0, 0, "st")
    params:set_action(i .. "pitch", function(value) engine.pitch(i, math.pow(0.5, -value / 12)) end)
  
    params:add_taper(i .. "spread", i .. " spread", 0, 100, 0, 0, "%")
    params:set_action(i .. "spread", function(value) engine.spread(i, value / 100) end)
    
    params:add_taper(i .. "fade", i .. " att / dec", 1, 9000, 1000, 3, "ms")
    params:set_action(i .. "fade", function(value) engine.envscale(i, value / 1000) end)
    
    params:add_taper(i .. "seek", i .. " seek", 0, 100, 0, 0, "%")
    params:set_action(i .. "seek", function(value) engine.seek(i, value / 100) end)
    
    params:hide(i .. "volume")
    params:hide(i .. "speed")
    params:hide(i .. "jitter")
    params:hide(i .. "size")
    params:hide(i .. "density")
    params:hide(i .. "pitch")
    params:hide(i .. "spread")
    params:hide(i .. "fade")
    params:hide(i .. "seek")
  end

  params:bang()
end

local function grid_redraw()
  g:all(0)
  g:led(x, y, 15)
  g:refresh()
end

local function setup_grid()
  g = grid.connect()
  g.key = grid_key
end

local function randomize(n)
  local jitter = math.random(0, 500)
  local size = math.random(0, 500)
  local density = math.random(1, 20)
  local spread = math.random(0, 100)
  local pitches = {-12, -5, 0, 12, 7,}
  local pitch_idx = math.random(1, #pitches)
  local pitch = pitches[pitch_idx]
  
  params:set(n .. "jitter", jitter)
  params:set(n .. "size", size)
  params:set(n .. "density", density)
  params:set(n .. "spread", spread)
  params:set(n .. "pitch", pitch)
end

local function setup_engine()
  engine.seek(1, 0)
  engine.gate(1, 1)
  
  engine.seek(2, 0)
  engine.gate(2, 1)

  randomize(1)
  randomize(2)
end

local function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function init()
  setup_params()
  setup_grid()
  setup_engine()
  grid_redraw()
end

function grid_key(_x, _y, z)
  if z == 0 then
    return
  end
  
  x = _x
  y = _y

  local grid_size = g.rows * g.cols
  local this_idx = ((_y - 1) * g.rows) + _x
  local pct = this_idx / grid_size
  
  params:set("1seek", pct * 100)
  params:set("2seek", pct * 100)
  
  grid_redraw()
  redraw()
end

function redraw()
  screen.clear()
  screen.move(0, 10)
  screen.level(15)
  screen.text("jitter: ")
  screen.level(5)
  screen.text(params:get("1jitter"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:get("2jitter"))
  screen.move(0, 20)
  screen.level(15)
  screen.text("size: ")
  screen.level(5)
  screen.text(params:get("1size"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:get("2size"))
  screen.move(0, 30)
  screen.level(15)
  screen.text("density: ")
  screen.level(5)
  screen.text(params:get("1density"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:get("2density"))
  screen.move(0, 40)
  screen.level(15)
  screen.text("spread: ")
  screen.level(5)
  screen.text(params:get("1spread"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:get("2spread"))
  screen.move(0, 50)
  screen.level(15)
  screen.text("pitch: ")
  screen.level(5)
  screen.text(params:get("1pitch"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:get("2pitch"))
  screen.move(0, 60)
  screen.level(15)
  screen.text("seek: ")
  screen.level(5)
  screen.text(round(params:get("1seek"), 2))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(round(params:get("2seek"), 2))
  screen.update()
end

function enc(n, d)
  if n == 1 then
    params:delta("1volume", d)
    params:delta("2volume", d)
  elseif n == 2 then
    params:delta("1seek", d)
  elseif n == 3 then
    params:delta("2seek", d)
  end
  
  redraw()
end

function key(n, z)
  if z == 0 then
    return
  end
  
  if n == 2 then
    randomize(1)
  elseif n == 3 then
    randomize(2)
  end
  
  redraw()
end