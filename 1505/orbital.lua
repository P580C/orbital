-- orbital
-- alpha version 1.1
-- p1505
--
-- enc 1 chooses sequence
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

  - add ability to change sequence length
  - add ability to manually edit sequences
  - get loading and saving of sequence data into an external data file
  - ability to have different BPM on each sequence
  - add an external params file for setting frequency ranges etc

  only then will orbital be considered release 1

  please comment, suggest, tell me where the code is a mess

  enjoy
]]--


--  load the sound engine
engine.name = "PolyPerc"

-- create required variables
--local freqs = {}
local startStop = true
local screen_refresh_metro
local audioMetro
local bbppmm  -- the beats per minute of the track
local framesPerSecond = 15
local selectedSequence = 1

-- default sequences
local sequences = {
  c1Sequence = {pos = 0, length = 16, data = {1, 2, 1, 3, 2, 4, 1, 2, 1, 4, 1, 6, 3, 2, 1, 1}},
  c2Sequence = {pos = 0, length = 16, data = {1, 2, 1, 3, 2, 4, 1, 2, 1, 4, 1, 6, 3, 2, 1, 1}}
}

local orbitalCircle = include('lib/orbital_circle')
-- orbital_circle requires x, y, diameter, scale_factor, number_of_notes, beats_per_second, frames_per_second, sequence_data, sequence type "treb" or "bass"

local circles = {c1, c2}

--  get things started
function init()
  -- set screen antialiasing level
  screen.aa(1)
  screen.line_width(1)

  -- set the bpm to a default value
  bbppmm = 120

  circles.c1 = orbitalCircle.new(38, 28, 16, 16, 120, 15, sequences.c1Sequence.data, "treb")
  circles.c2 = orbitalCircle.new(90, 28, 16, 16, 120, 15, sequences.c2Sequence.data, "bass")

  -- fill the sequences with a new random set
  randomSequence()

  -- we use a metro to trigger n times per second (frameRate)
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    circles.c1.tick()
    circles.c2.tick()

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
  sequences.c1Sequence.pos = sequences.c1Sequence.pos + 1
  if sequences.c1Sequence.pos > sequences.c1Sequence.length then
    sequences.c1Sequence.pos = 1
  end
  engine.hz(sequences.c1Sequence.data[sequences.c1Sequence.pos])
  engine.hz(sequences.c2Sequence.data[sequences.c1Sequence.pos])
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
    circles.c1.updateBPM(bbppmm)
    circles.c2.updateBPM(bbppmm)
    beatsPerSecond = bbppmm/60

	  audioMetro:stop()
    audioMetro:start(60/bbppmm)
    screen_refresh_metro:stop()
    screen_refresh_metro:start(1/framesPerSecond)

  elseif n == 2 then
    if d == -1 then
      if selectedSequence == 1 then
        if math.min(table.unpack(sequences.c1Sequence.data)) > 32 then
          for i, v in ipairs(sequences.c1Sequence.data) do
            sequences.c1Sequence.data[i] = v - 10
          end
        end
      elseif selectedSequence == 2 then
        if math.min(table.unpack(sequences.c2Sequence.data)) > 2 then
          for i, v in ipairs(sequences.c2Sequence.data) do
            sequences.c2Sequence.data[i] = v - 2
          end
        end
      end
    elseif d == 1 then
      if selectedSequence == 1 then
        for i, v in ipairs(sequences.c1Sequence.data) do
          sequences.c1Sequence.data[i] = v + 10
        end
      elseif selectedSequence == 2 then
        for i, v in ipairs(sequences.c2Sequence.data) do
          sequences.c2Sequence.data[i] = v + 2
        end
      end
    end
  else  -- must be encoder 1
    if d == -1 then
      selectedSequence = 1
    else
      selectedSequence = 2
    end
  end
end

-- drawing the graphical interface
function redraw()
  screen.clear()
  screen.level(4)
	screen.rect(0,0,128,64)
	screen.fill()
  screen.level(1)
  
  if selectedSequence == 1 then
    screen.circle(circles.c1.location()[1], circles.c1.location()[2]+28, 2)
    screen.fill()
    screen.circle(circles.c2.location()[1], circles.c2.location()[2]+28, 2)
    screen.stroke()
  else
    screen.circle( circles.c1.location()[1], circles.c1.location()[2]+28, 2)
    screen.stroke()
    screen.circle(circles.c2.location()[1], circles.c2.location()[2]+28, 2)
    screen.fill()
  end

  circles.c1.redraw()
  circles.c2.redraw()
  screen.update()
end

-- function to create a new random sequence, called when button three is pushed
function randomSequence()
  for i=1,sequences.c1Sequence.length do
    sequences.c1Sequence.data[i] = (math.random(32, 512))
    sequences.c2Sequence.data[i] = (math.random(5, 128))
  end
  circles.c1.updateNotes(sequences.c1Sequence.data)
  circles.c2.updateNotes(sequences.c2Sequence.data)
  redraw()
end