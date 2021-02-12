-- twine
-- by: @cfd90
--
-- KEY2 randomize pads 1
-- KEY3 randomize pads 2
-- ENC2 seek offset 1
-- ENC3 seek offset 2

engine.name = "Glut"

local g
local matrix = {}

local selx = 1
local sely = 1

local sk1 = 0
local sk2 = 0

function init()
  params:add_separator()

  params:add_file("sample", "1 sample")
  params:set_action("sample", function(file) engine.read(1, file) end)
  
  params:add_file("2sample", "2 sample")
  params:set_action("2sample", function(file) engine.read(2, file) end)
  
  params:add_taper("volume", "1 volume", -60, 20, 0, 0, "dB")
  params:set_action("volume", function(value) engine.volume(1, math.pow(10, value / 20)) end)

  params:add_taper("speed", "1 speed", -400, 400, 0, 0, "%")
  params:set_action("speed", function(value) engine.speed(1, value / 100) end)

  params:add_taper("jitter", "1 jitter", 0, 500, 0, 5, "ms")
  params:set_action("jitter", function(value) engine.jitter(1, value / 1000) end)

  params:add_taper("size", "1 size", 1, 500, 100, 5, "ms")
  params:set_action("size", function(value) engine.size(1, value / 1000) end)

  params:add_taper("density", "1 density", 0, 512, 20, 6, "hz")
  params:set_action("density", function(value) engine.density(1, value) end)

  params:add_taper("pitch", "1 pitch", -48, 48, 0, 0, "st")
  params:set_action("pitch", function(value) engine.pitch(1, math.pow(0.5, -value / 12)) end)

  params:add_taper("spread", "1 spread", 0, 100, 0, 0, "%")
  params:set_action("spread", function(value) engine.spread(1, value / 100) end)

  params:add_taper("2volume", "2 volume", -60, 20, 0, 0, "dB")
  params:set_action("2volume", function(value) engine.volume(2, math.pow(10, value / 20)) end)

  params:add_taper("2speed", "2 speed", -400, 400, 0, 0, "%")
  params:set_action("2speed", function(value) engine.speed(2, value / 100) end)

  params:add_taper("2jitter", "2 jitter", 0, 500, 0, 5, "ms")
  params:set_action("2jitter", function(value) engine.jitter(2, value / 1000) end)

  params:add_taper("2size", "2 size", 1, 500, 100, 5, "ms")
  params:set_action("2size", function(value) engine.size(2, value / 1000) end)

  params:add_taper("2density", "2 density", 0, 512, 20, 6, "hz")
  params:set_action("2density", function(value) engine.density(2, value) end)

  params:add_taper("2pitch", "2 pitch", -48, 48, 0, 0, "st")
  params:set_action("2pitch", function(value) engine.pitch(2, math.pow(0.5, -value / 12)) end)

  params:add_taper("2spread", "2 spread", 0, 100, 0, 0, "%")
  params:set_action("2spread", function(value) engine.spread(2, value / 100) end)

  params:add_taper("2fade", "2 att / dec", 1, 9000, 1000, 3, "ms")
  params:set_action("2fade", function(value) engine.envscale(2, value / 1000) end)
  
  params:hide("volume")
  params:hide("speed")
  params:hide("jitter")
  params:hide("size")
  params:hide("density")
  params:hide("pitch")
  params:hide("spread")
  params:hide("fade")
  params:hide("2volume")
  params:hide("2speed")
  params:hide("2jitter")
  params:hide("2size")
  params:hide("2density")
  params:hide("2pitch")
  params:hide("2spread")
  params:hide("2fade")

  params:bang()
  
  g = grid.connect()
  g.key = grid_key
  
  for x=1,g.rows do
    matrix[x] = {}
    
    for y=1,g.cols do
      matrix[x][y] = {}
    end
  end
  
  randomize(1)
  randomize(2)
  
  grid_redraw()
  
  engine.seek(1, 0)
  engine.gate(1, 1)
  
  engine.seek(2, 0)
  engine.gate(2, 1)
  
  apply(selx, sely)
end

function randomize(n)
  for x=1,g.rows do
    for y=1,g.cols do
      local jitter = math.random(0, 500)
      local size = math.random(0, 500)
      local density = math.random(1, 20)
      local spread = math.random(0, 100)
      
      local pitches = {-12, -5, 0, 12, 7,}
      local pitch_idx = math.random(1, #pitches)
      local pitch = pitches[pitch_idx]
      
      local jitter2 = math.random(0, 500)
      local size2 = math.random(0, 500)
      local density2 = math.random(1, 20)
      local spread2 = math.random(0, 100)
      
      local pitches2 = {-12, -5, 0, 12, 7,}
      local pitch_idx2 = math.random(1, #pitches2)
      local pitch2 = pitches2[pitch_idx2]
      
      local t = {}
      
      if n == 1 then
        matrix[x][y].jitter = jitter
        matrix[x][y].size = size
        matrix[x][y].density = density
        matrix[x][y].spread = spread
        matrix[x][y].pitch = pitch
        sk1 = 0
      elseif n == 2 then
        matrix[x][y].jitter2 = jitter2
        matrix[x][y].size2 = size2
        matrix[x][y].density2 = density2
        matrix[x][y].spread2 = spread2
        matrix[x][y].pitch2 = pitch2
        sk2 = 0
      end
    end
  end
end

function apply(x, y)
  local m = matrix[x][y]
  
  params:set("jitter", m.jitter)
  params:set("size", m.size)
  params:set("density", m.density)
  params:set("spread", m.spread)
  params:set("pitch", m.pitch)
  
  params:set("2jitter", m.jitter2)
  params:set("2size", m.size2)
  params:set("2density", m.density2)
  params:set("2spread", m.spread2)
  params:set("2pitch", m.pitch2)
end

function grid_key(x, y, z)
  if z == 1 then
    selx = x
    sely = y
    
    local m = matrix[selx][sely]
    
    local pct = (((y-1)*g.rows) + x) / (g.rows * g.cols)
    engine.seek(1, pct)
    engine.seek(2, pct)
    
    sk1 = 0
    sk2 = 0
    
    apply(x, y)
  end
  
  grid_redraw()
  redraw()
end

function grid_redraw()
  g:all(0)
  g:led(selx, sely, 15)
  g:refresh()
end

function redraw()
  local m = matrix[selx][sely]
  
  screen.clear()
  screen.move(0, 10)
  screen.level(15)
  screen.text("jitter: ")
  screen.level(5)
  screen.text(m.jitter)
  screen.text(" / ")
  screen.text(m.jitter2)
  screen.move(0, 20)
  screen.level(15)
  screen.text("size: ")
  screen.level(5)
  screen.text(m.size)
  screen.text(" / ")
  screen.text(m.size2)
  screen.move(0, 30)
  screen.level(15)
  screen.text("density: ")
  screen.level(5)
  screen.text(m.density)
  screen.text(" / ")
  screen.text(m.density2)
  screen.move(0, 40)
  screen.level(15)
  screen.text("spread: ")
  screen.level(5)
  screen.text(m.spread)
  screen.text(" / ")
  screen.text(m.spread2)
  screen.move(0, 50)
  screen.level(15)
  screen.text("pitch: ")
  screen.level(5)
  screen.text(m.pitch)
  screen.text(" / ")
  screen.text(m.pitch2)
  screen.move(0, 60)
  screen.level(15)
  screen.text("seek offset: ")
  screen.level(5)
  screen.text(sk1)
  screen.text(" / ")
  screen.text(sk2)
  screen.update()
end

function enc(n, d)
  if n == 2 then
    if d > 0 then
      sk1 = sk1 + 0.01
    elseif d < 0 then
      sk1 = sk1 - 0.01
    end  
  elseif n == 3 then
    if d > 0 then
      sk2 = sk2 + 0.01
    elseif d < 0 then
      sk2 = sk2 - 0.01
    end  
  end
  
  local pct = ((sely*g.rows) + selx) / (g.rows * g.cols)
  engine.seek(1, pct + sk1)
  engine.seek(2, pct + sk2)
  
  redraw()
end

function key(n, z)
  if n == 2 and z == 1 then
    randomize(1)
  elseif n == 3 and z == 1 then
    randomize(2)
  end
  apply(selx, sely)
  redraw()
end