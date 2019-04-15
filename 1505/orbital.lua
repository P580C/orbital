-- orbital
-- alpha version 1
-- p1505
--
-- btn 2 randomises sequence
-- enc 2 changes pitch
--
-- btn 3 starts/stops sequence
-- enc 3 changes BPM

--[[
  hello
  
  welcome to orbital, version 1 (alpha)
  
  orbital is an experiment in simple sequences and interface design
  it was created to learn Lua scripting for norns
  
  it is very much a work in progress
  the code is messy, the capability small

  designed for polyperc, but Haven sounds immense
  my own engines are being worked on
  
  orbital has a roadmap, the things still to do are...
  
  - move trig calculations into external class
  - add ability to change sequence length
  - add up to 4 sequences
  - test out different engines / using samples
  - possibly change the name
  - get loading and saving of sequence data into an external data file
  - possibly rotate a marker instead of the circles to make it easier to read - less cool though
  
  only then will orbital be considered release 1
  
  please comment, suggest, tell me where the code is a mess
  
  enjoy
]]--


--  load the sound engine
engine.name = "PolyPerc"

-- create required variables
local freqs = {}
local startStop = true
local screen_refresh_metro
local audioMetro
local bbppmm  -- the beats per minute of the track
local initSequence = {number = 1, pos = 0, length = 16, data = {1,2,1,2,1,1,2,1,2,1,2,1,2,1,2,1}}
local framesPerSecond = 15

-- keeping track of the trig
local gapBetweenDots
local currentRotation
local newRotationValue
local beatsPerSecond
local framesPerFullRotation
local degreesPerFrame

-- testing oop
local orbitalCircle = include('lib/orbital_circle')
-- orbital_circle requires x, y, diameter, scale_factor, number_of_notes, beats_per_second, frames_per_second, sequence_data

local c1Sequence = {1, 2, 1, 3, 2, 4, 1, 2, 1, 4, 1, 6, 3, 2, 1, 1}
local c1


--  get things started
function init()
  -- set screen antialiasing level
  screen.aa(1)
  
  c1 = orbitalCircle.new(20, 42, 18, 1.7, 16, 62, 15, c1Sequence)
  --c1:updateBPM(120)

  -- create a random sequence to start with
  for i=1,initSequence.length do
    freqs[i] = (math.random(2, 512))
    initSequence.data[i] = (math.random(0,6))
  end

  -- set the bpm to a default value
  bbppmm = 62

  -- set the new english properties
  gapBetweenDots = (360 / initSequence.length)
  beatsPerSecond = bbppmm/60
  currentRotation = 0
  framesPerSecond = 15
  framesPerFullRotation = (initSequence.length/beatsPerSecond)*framesPerSecond
  degreesPerFrame = 360 / framesPerFullRotation
  newRotationValue = currentRotation + degreesPerFrame

  -- we use a metro to trigger n times per second (frameRate)
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    -- update the english variables
	gapBetweenDots = (360 / initSequence.length)
	
	framesPerFullRotation = (initSequence.length/beatsPerSecond)*framesPerSecond
  degreesPerFrame = 360 / framesPerFullRotation
  newRotationValue = currentRotation + degreesPerFrame

	if newRotationValue > 360 then
	  currentRotation = 0
	 else
	  currentRotation = newRotationValue
  end

	redraw()
  end
  screen_refresh_metro:start(1/framesPerSecond)
  
  audioMetro = metro.init()
  audioMetro.event = function()
    step()
  end
  audioMetro:start(60/bbppmm)
end

-- every time our clock triggers
function step()
  initSequence.pos = initSequence.pos + 1
  if initSequence.pos > initSequence.length then
    initSequence.pos = 1
  end

  if initSequence.data[initSequence.pos] > 0 then
    engine.hz(freqs[initSequence.data[initSequence.pos]])
  end
end

-- input handling
function key (n,z)
  if n == 2 then
    if z == 1 then
      randomSequence()
    end
  elseif n == 3 then
    if z == 1 then
      if startStop == true then
        startStop = false
        --clk:stop()
        audioMetro:stop()
        screen_refresh_metro:stop()
      else
        startStop = true
        audioMetro:start(60/bbppmm)
        screen_refresh_metro:start(1/framesPerSecond)
      end
    end
  end
end

function enc(n,d)
  if n == 3 then
    bbppmm = util.clamp(bbppmm + d, 1, 250)
    
    if bbppmm <= 0 then
      print("Damn!")
    end
	  
	  beatsPerSecond = bbppmm/60
	  audioMetro:stop()
	  audioMetro:start(60/bbppmm)

  elseif n == 2 then
    for i=1, 16 do
      freqs[i] = freqs[i] + (d * 20)
    end
  end
end

-- drawing the graphical interface
function redraw()
  screen.clear()

  --c1:redraw()
	
	screen.level(4)
	screen.rect(0,0,128,64)
	screen.fill()
	screen.level(3)
	screen.circle(64,32,18)
	screen.stroke()
	
	screen.level(1)

	for i=1,initSequence.length do
    if initSequence.data[i] > 0 then
      screen.circle(
        math.cos(math.rad(newRotationValue)+(gapBetweenDots*i))*18 + 64,
        math.sin(math.rad(newRotationValue)+(gapBetweenDots*i))*18 + 32,
        initSequence.data[i]/1.2
      )
    screen.fill()
    end
  end
  screen.update()
end

-- function to create a new random sequence, called when button three is pushed
function randomSequence()
  for i=1,initSequence.length do
    initSequence.data[i] = (math.random(0, 6))
    freqs[i] = (math.random(32, 512))
  end
  redraw()
end