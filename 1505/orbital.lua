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
  - add ability to change sequence lengths - UI done
  - add ability to manually edit sequences - UI done
  - get loading and saving of sequence data into an external data file

  only then will orbital be considered release 1

  please comment, suggest, and tell me where the code is a mess

  enjoy
]]--


--  load the sound engine
engine.name = "PolyPerc"

-- create required variables
local startStop = true
local screen_refresh_metro
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
local circles = {c1, c2}
local unpack = unpack or table.unpack

--  get things started
function init()
  -- set screen antialiasing level
  screen.aa(1)
  screen.line_width(1)

  -- set the bpm to a default value
  seqOneBPM = 120
  seqTwoBPM = 120
  bbppmm = 120

  circles.c1 = orbitalCircle.new(45, 32, 16, 16, 120, 15, sequences.c1Sequence.data, "treb")
  circles.c2 = orbitalCircle.new(96, 32, 16, 16, 120, 15, sequences.c2Sequence.data, "bass")

  -- fill the sequences with a new random set
  randomSequence("all")

  -- we use a metro to trigger n times per second (frameRate)
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
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
end

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
        seqOneMetro:stop()
        seqTwoMetro:stop()
        circles.c1.stop()
        circles.c2.stop()
      else
        startStop = true
        seqOneMetro:start(60/seqOneBPM)
        seqTwoMetro:start(60/seqTwoBPM)
        circles.c1.start()
        circles.c2.start()
      end
    end
  end
end

function enc(n,d)
  if n == 1 then
    selectedSequence = util.clamp(selectedSequence + d, 1, 20)
  end

  if n == 2 then
    if selectedSequence >= 1 and selectedSequence <= 5 then
      --[[for i, v in ipairs(sequences.c1Sequence.data) do
        sequences.c1Sequence.data[i] = v + (10*d) 
      end]]
      sequences.c1Sequence.data = adjust(sequences.c1Sequence.data, (10*d), 12, 1024)
      circles.c1.updateNotes(sequences.c1Sequence.data)
    end

    --data=adjust(data,-1)

    if selectedSequence >= 11 and selectedSequence <= 15 then
      --[[for i, v in ipairs(sequences.c2Sequence.data) do
       sequences.c2Sequence.data[i] = v + (10*d) 
      end]]
      sequences.c2Sequence.data = adjust(sequences.c2Sequence.data, (10*d), 2, 256)
      circles.c2.updateNotes(sequences.c2Sequence.data)
    end

    if selectedSequence >= 6 and selectedSequence <= 10 then
      -- we are now editing the first sequence's length
    end

    if selectedSequence >= 16 and selectedSequence <= 20 then
      -- we are now editing the second sequence's length
    end
  end

  if n == 3 then
    if selectedSequence >= 1 and selectedSequence <= 5 then
      -- sequence 1 selected
      seqOneBPM = util.clamp(seqOneBPM + d, 1, 250)
      circles.c1.updateBPM(seqOneBPM)
      seqOneMetro.time = (60/seqOneBPM)
    elseif selectedSequence >= 11 and selectedSequence <= 15 then
      -- sequence 2 selected
      seqTwoBPM = util.clamp(seqTwoBPM + d, 1, 250)
      circles.c2.updateBPM(seqTwoBPM)
      seqTwoMetro.time = (60/seqTwoBPM)
    elseif selectedSequence >= 6 and selectedSequence <= 10 then
      -- we are now editing the first sequence
      -- encoder 3 will select note
    elseif selectedSequence >= 16 and selectedSequence <= 20 then
      -- we are now editing the second sequence
      -- encoder 3 will select note
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

  -- draw the menu parts
  screen.circle(8, 7, 1)
  screen.fill()
  screen.circle(6, 40, 1)
  screen.fill()
  screen.circle(10, 40, 1)
  screen.fill()

  if selectedSequence >= 1 and selectedSequence <= 5 then
    --drawSeqIcon(5, 5, "true")
    drawDot(8, 15, "true")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 6 and selectedSequence <= 10 then
    --drawSeqIcon(5, 5, "false")
    drawDot(8, 15, "false")
    drawSequence(4, 21, "true")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 11 and selectedSequence <= 15 then
    --drawSeqIcon(5, 5, "false")
    drawDot(8, 15, "false")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "true")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 16 and selectedSequence <= 20 then
    --drawSeqIcon(5, 5, "false")
    drawDot(8, 15, "false")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "true")
    -- go to fourth menu item
  end

  --screen.level(1)
  circles.c1.redraw()
  circles.c2.redraw()
  screen.update()
end

function drawDot(x, y, state)
  if state == "true" then
    screen.level(6)
    screen.circle(x, y, 3)
    screen.stroke()
    screen.circle(x, y, 1)
    screen.fill()
  else
    screen.level(1)
    screen.circle(x, y, 2)
    screen.fill()
  end
end

function drawSequence(x, y, state)
  if state == "true" then
    screen.level(6)
    screen.rect(x, y, 1, 4)
    screen.rect(x+2, y, 1, 4)
    screen.rect(x+5, y, 1, 4)
    screen.rect(x+7, y, 1, 4)
    screen.fill()
  else
    screen.level(1)
    screen.rect(x, y, 1, 4)
    screen.rect(x+2, y, 1, 4)
    screen.rect(x+5, y, 1, 4)
    screen.rect(x+7, y, 1, 4)
    screen.fill()
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

function randomSequence(type)             --create a random sequence
  if type == "all" then
    for i=1,sequences.c1Sequence.length do
      sequences.c1Sequence.data[i] = (math.random(128, 512))
      sequences.c2Sequence.data[i] = (math.random(64, 128))
    end
  else
    if selectedSequence >= 1 and selectedSequence <= 5 then
      for i=1,sequences.c1Sequence.length do
        sequences.c1Sequence.data[i] = (math.random(128, 512))
      end
      circles.c1.updateNotes(sequences.c1Sequence.data)
    elseif selectedSequence >= 11 and selectedSequence <= 15 then
      for i=1,sequences.c1Sequence.length do
        sequences.c2Sequence.data[i] = (math.random(64, 128))
      end
      circles.c2.updateNotes(sequences.c2Sequence.data)
    end
  end
  redraw()
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

function min(...)                       --return minimum of all elements
  local ans = select(1,...)
  if type(ans) == 'table' then ans = min(unpack(ans)) end
  for _,n in ipairs { select(2,...) } do
    if type(n) == 'table' then n = min(unpack(n)) end
    if n < ans then ans = n end
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

function max(...)                       --return maximum of all elements
  local ans = select(1,...)
  if type(ans) == 'table' then ans = max(unpack(ans)) end
  for _,n in ipairs { select(2,...) } do
    if type(n) == 'table' then n = max(unpack(n)) end
    if n > ans then ans = n end
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

function adjust(t,val,m,mx)             --adjust table value up and down within given limits
  if min(t)+val < m or max(t)+val > mx then return t end
  ans = {}
  for _,x in ipairs(t) do
    ans[#ans+1] = x+val
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------

function pt(t)                          --unpack and print a table
  unpacked  = table.unpack(t)
  return unpacked
end

--------------------------------------------------------------------------------------------------------------------------------------------------------