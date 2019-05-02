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

  - fix a bug where pausing the playback stops the screen updating
  - add ability to change sequence length
  - add ability to manually edit sequences
  - get loading and saving of sequence data into an external data file
  - ability to have different BPM on each sequence - done
  - add an external params file for setting frequency ranges etc

  only then will orbital be considered release 1

  please comment, suggest, and tell me where the code is a mess

  enjoy
]]--


--  load the sound engine
engine.name = "PolyPerc"

-- create required variables
--local freqs = {}
local startStop = true
local screen_refresh_metro
local audioMetro
local seqOneMetro
local seqTwoMetro
local seqOneBPM
local seqTwoBPM
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
  seqOneBPM = 120
  seqTwoBPM = 120
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

  
  -- set up the metros for audio sequences
  seqOneMetro = metro.init()
  seqOneMetro.event = function()
    seqOneStep()
  end

  seqTwoMetro = metro.init()
  seqTwoMetro.event = function()
    seqTwoStep()
  end

  seqOneMetro:start(60/bbppmm)
  seqTwoMetro:start(60/bbppmm)
  

--[[
  audioMetro = metro.init()
  audioMetro.event = function()
    step()
  end
  audioMetro:start(60/bbppmm)
  ]]
end

-- every time our clock triggers
--[[
function step()
  sequences.c1Sequence.pos = sequences.c1Sequence.pos + 1
  if sequences.c1Sequence.pos > sequences.c1Sequence.length then
    sequences.c1Sequence.pos = 1
  end
  engine.hz(sequences.c1Sequence.data[sequences.c1Sequence.pos])
  engine.hz(sequences.c2Sequence.data[sequences.c1Sequence.pos])
end
]]

function seqOneStep()
  sequences.c1Sequence.pos = sequences.c1Sequence.pos + 1
  if sequences.c1Sequence.pos > sequences.c1Sequence.length then
    sequences.c1Sequence.pos = 1
  end
  engine.hz(sequences.c1Sequence.data[sequences.c1Sequence.pos])
end

function seqTwoStep()
  sequences.c2Sequence.pos = sequences.c2Sequence.pos + 1
  if sequences.c2Sequence.pos > sequences.c2Sequence.length then
    sequences.c2Sequence.pos = 1
  end
  engine.hz(sequences.c2Sequence.data[sequences.c2Sequence.pos])
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
        --audioMetro:stop()
        seqOneMetro:stop()
        seqTwoMetro:stop()
        screen_refresh_metro:stop()
      else
        startStop = true
        --audioMetro:start(60/bbppmm)
        seqOneMetro:start(60/seqOneBPM)
        seqTwoMetro:start(60/seqTwoBPM)
        screen_refresh_metro:start(1/framesPerSecond)
      end
    end
  end
end

function enc(n,d)
  if n == 3 then
    if selectedSequence >= 11 and selectedSequence <= 20 then
      -- sequence 1 selected
      seqOneBPM = util.clamp(seqOneBPM + d, 1, 250)
      circles.c1.updateBPM(seqOneBPM)
      seqOneMetro:stop()
      seqOneMetro:start(60/seqOneBPM)
    elseif selectedSequence >= 21 and selectedSequence <= 30 then
      -- sequence 2 selected
      seqTwoBPM = util.clamp(seqTwoBPM + d, 1, 250)
      circles.c2.updateBPM(seqTwoBPM)
      seqTwoMetro:stop()
      seqTwoMetro:start(60/seqTwoBPM)
    end

    --bbppmm = util.clamp(bbppmm + d, 1, 250)
    --circles.c1.updateBPM(bbppmm)
    --circles.c2.updateBPM(bbppmm)
    --beatsPerSecond = bbppmm/60

	  --audioMetro:stop()
    --audioMetro:start(60/bbppmm)
    screen_refresh_metro:stop()
    screen_refresh_metro:start(1/framesPerSecond)

  elseif n == 2 then
    if d == -1 then
      if selectedSequence >= 11 and selectedSequence <= 20 then
        if math.min(table.unpack(sequences.c1Sequence.data)) > 32 then
          for i, v in ipairs(sequences.c1Sequence.data) do
            sequences.c1Sequence.data[i] = v - 10
          end
        end
      elseif selectedSequence >= 21 and selectedSequence <= 30 then
        if math.min(table.unpack(sequences.c2Sequence.data)) > 2 then
          for i, v in ipairs(sequences.c2Sequence.data) do
            sequences.c2Sequence.data[i] = v - 2
          end
        end
      end
    elseif d == 1 then
      if selectedSequence >= 11 and selectedSequence <= 20 then
        for i, v in ipairs(sequences.c1Sequence.data) do
          sequences.c1Sequence.data[i] = v + 10
        end
      elseif selectedSequence >= 21 and selectedSequence <= 30 then
        for i, v in ipairs(sequences.c2Sequence.data) do
          sequences.c2Sequence.data[i] = v + 2
        end
      end
    end
  else  -- must be encoder 1
    selectedSequence = util.clamp(selectedSequence + d, 0, 40)
  end
end

-- drawing the graphical interface
function redraw()
  screen.clear()
  screen.level(4)
	screen.rect(0,0,128,64)
	screen.fill()
  screen.level(1)

  if selectedSequence >= 1 and selectedSequence <= 10 then
    drawSeqIcon(10, 54, "true")
    drawDot(circles.c1.location()[1], circles.c1.location()[2]+28, "false")
    drawDot(circles.c2.location()[1], circles.c2.location()[2]+28, "false")
  elseif selectedSequence >= 11 and selectedSequence <= 20 then
    drawSeqIcon(10, 54, "false")
    drawDot(circles.c1.location()[1], circles.c1.location()[2]+28, "true")
    drawDot(circles.c2.location()[1], circles.c2.location()[2]+28, "false")
  elseif selectedSequence >= 21 and selectedSequence <= 30 then
    drawSeqIcon(10, 54, "false")
    drawDot(circles.c1.location()[1], circles.c1.location()[2]+28, "false")
    drawDot(circles.c2.location()[1], circles.c2.location()[2]+28, "true")
  elseif selectedSequence >= 31 and selectedSequence <= 40 then
    drawSeqIcon(10, 54, "false")
    drawDot(circles.c1.location()[1], circles.c1.location()[2]+28, "false")
    drawDot(circles.c2.location()[1], circles.c2.location()[2]+28, "false")
    -- go to fourth menu item
  end

  screen.level(2)
  circles.c1.redraw()
  circles.c2.redraw()
  screen.update()
end

function drawSeqIcon(x, y, state)
  if state == "true" then
    screen.level(6)
    screen.rect(x, y+1, 10, 1)
    screen.fill()
    screen.rect(x, y+3, 10, 1)
    screen.fill()
  else
    screen.level(1)
    screen.rect(x, y+1, 10, 1)
    screen.fill()
    screen.rect(x, y+3, 10, 1)
    screen.fill()
  end
end

function drawDot(x, y, state)
  if state == "true" then
    screen.level(6)
    screen.circle(x, y, 2)
    screen.fill()
  else
    screen.level(1)
    screen.circle(x, y, 2)
    screen.fill()
  end
end

-- function to create a new random sequence, called when button three is pushed
function randomSequence()
  if selectedSequence >= 11 and selectedSequence <= 20 then
    for i=1,sequences.c1Sequence.length do
      sequences.c1Sequence.data[i] = (math.random(32, 512))
    end
    circles.c1.updateNotes(sequences.c1Sequence.data)
  elseif selectedSequence >= 21 and selectedSequence <= 30 then
    for i=1,sequences.c1Sequence.length do
      sequences.c2Sequence.data[i] = (math.random(5, 128))
    end
    circles.c2.updateNotes(sequences.c2Sequence.data)
  end
  redraw()
end