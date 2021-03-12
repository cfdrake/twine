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

local function setup_params()
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
    
    params:add_control(i .. "seek", i .. " seek", controlspec.new(0, 100, "lin", 0.1, 0, "%", 0.1/100))
    params:set_action(i .. "seek", function(value) engine.seek(i, value / 100) end)
    
    params:hide(i .. "speed")
    params:hide(i .. "jitter")
    params:hide(i .. "size")
    params:hide(i .. "density")
    params:hide(i .. "pitch")
    params:hide(i .. "spread")
    params:hide(i .. "fade")
  end

  params:add_separator("reverb")
  
  params:add_taper("reverb_mix", "* mix", 0, 100, 50, 0, "%")
  params:set_action("reverb_mix", function(value) engine.reverb_mix(value / 100) end)

  params:add_taper("reverb_room", "* room", 0, 100, 50, 0, "%")
  params:set_action("reverb_room", function(value) engine.reverb_room(value / 100) end)

  params:add_taper("reverb_damp", "* damp", 0, 100, 50, 0, "%")
  params:set_action("reverb_damp", function(value) engine.reverb_damp(value / 100) end)
  
  params:add_separator("randomizer")
  
  params:add_taper("min_jitter", "jitter (min)", 0, 500, 0, 5, "ms")
  params:add_taper("max_jitter", "jitter (max)", 0, 500, 500, 5, "ms")
  
  params:add_taper("min_size", "size (min)", 1, 500, 1, 5, "ms")
  params:add_taper("max_size", "size (max)", 1, 500, 500, 5, "ms")
  
  params:add_taper("min_density", "density (min)", 0, 512, 0, 6, "hz")
  params:add_taper("max_density", "density (max)", 0, 512, 40, 6, "hz")
  
  params:add_taper("min_spread", "spread (min)", 0, 100, 0, 0, "%")
  params:add_taper("max_spread", "spread (max)", 0, 100, 100, 0, "%")
  
  params:add_taper("pitch_1", "pitch (1)", -48, 48, -12, 0, "st")
  params:add_taper("pitch_2", "pitch (2)", -48, 48, -5, 0, "st")
  params:add_taper("pitch_3", "pitch (3)", -48, 48, 0, 0, "st")
  params:add_taper("pitch_4", "pitch (4)", -48, 48, 7, 0, "st")
  params:add_taper("pitch_5", "pitch (5)", -48, 48, 12, 0, "st")

  params:bang()
end

local function random_float(l, h)
    return l + math.random()  * (h - l);
end

local function randomize(n)
  local jitter = random_float(params:get("min_jitter"), params:get("max_jitter"))
  local size = random_float(params:get("min_size"), params:get("max_size"))
  local density = random_float(params:get("min_density"), params:get("max_density"))
  local spread = random_float(params:get("min_spread"), params:get("max_spread"))
  local pitches = {params:get("pitch_1"), params:get("pitch_2"), params:get("pitch_3"),
                   params:get("pitch_4"), params:get("pitch_5")}
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

function init()
  setup_params()
  setup_engine()
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

function redraw()
  screen.clear()
  screen.move(0, 10)
  screen.level(15)
  screen.text("jitter: ")
  screen.level(5)
  screen.text(params:string("1jitter"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2jitter"))
  screen.move(0, 20)
  screen.level(15)
  screen.text("size: ")
  screen.level(5)
  screen.text(params:string("1size"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2size"))
  screen.move(0, 30)
  screen.level(15)
  screen.text("density: ")
  screen.level(5)
  screen.text(params:string("1density"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2density"))
  screen.move(0, 40)
  screen.level(15)
  screen.text("spread: ")
  screen.level(5)
  screen.text(params:string("1spread"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2spread"))
  screen.move(0, 50)
  screen.level(15)
  screen.text("pitch: ")
  screen.level(5)
  screen.text(params:string("1pitch"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2pitch"))
  screen.move(0, 60)
  screen.level(15)
  screen.text("seek: ")
  screen.level(5)
  screen.text(params:string("1seek"))
  screen.level(1)
  screen.text(" / ")
  screen.level(5)
  screen.text(params:string("2seek"))
  screen.update()
end