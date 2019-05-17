-- orbital
-- alpha version 1.1
-- p1505
--
-- enc 1 accesses menu
--
-- btn 2 randomises sequence
-- enc 2 changes pitch and sequence length
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
  - add ability to change sequence lengths - done
  - add ability to manually edit sequences - current
  - add ability to stop circles independantly
  - get loading and saving of sequence data into an external data file
  
  and bugs to fix...
   - allow user to drop frequency as far as they want, but dont allow negative values - done
   - same with upper values - done
   - add variety to circle sizes
   - ensure ui and audio in sync - current

  only then will orbital be considered release 1

  please comment, suggest, and tell me where the code is a mess

  enjoy
]]--

--------------------------------------------------------------------------------------------------------------------------------------------------------
--sound engine

engine.name = "PolyPerc"

--------------------------------------------------------------------------------------------------------------------------------------------------------
--variables

local startStop = true
local screen_refresh_metro
local seqOneMetro
local seqTwoMetro
local seqOneBPM
local seqTwoBPM
local bbppmm
local framesPerSecond = 15
local selectedSequence = 1
local orbitalCircle = include('lib/orbital_circle')
local circles = {c1, c2}
local unpack = unpack or table.unpack
local seqOneCounter = 0
local seqTwoCounter = 0
local sequences = {
  c1Sequence = {pos = 0, length = 16, data = {1, 2, 1, 3, 2, 4, 1, 2, 1, 4, 1, 6, 3, 2, 1, 1}},
  c2Sequence = {pos = 0, length = 16, data = {1, 2, 1, 3, 2, 4, 1, 2, 1, 4, 1, 6, 3, 2, 1, 1}}
}

--------------------------------------------------------------------------------------------------------------------------------------------------------
--basic setup

function init()
  screen.aa(1)
  screen.line_width(1)

  seqOneBPM = 120
  seqTwoBPM = 120
  bbppmm = 120

  circles.c1 = orbitalCircle.new(45, 32, 16, 16, 120, sequences.c1Sequence.data, "treb")
  circles.c2 = orbitalCircle.new(96, 32, 16, 16, 120, sequences.c2Sequence.data, "bass")

  randomSequence("all")

  --------------------------------------------------------------------------------------------------------------------------------------------------------
  --create metros
  
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    redraw()
  end

  screen_refresh_metro:start(1/framesPerSecond)

  ui_refresh_metro = metro.init()
  ui_refresh_metro.event = function()
    circles.c1.tick()
    circles.c2.tick()
  end

  ui_refresh_metro:start(1/framesPerSecond)

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

--------------------------------------------------------------------------------------------------------------------------------------------------------
--sequence position tracking

function seqOneStep()
  sequences.c1Sequence.pos = sequences.c1Sequence.pos + 1
  if sequences.c1Sequence.pos > sequences.c1Sequence.length then
    sequences.c1Sequence.pos = 1
  end
  
  if sequences.c1Sequence.data[sequences.c1Sequence.pos] ~= nill then
    engine.hz(sequences.c1Sequence.data[sequences.c1Sequence.pos])
  end
end

function seqTwoStep()
  sequences.c2Sequence.pos = sequences.c2Sequence.pos + 1
  if sequences.c2Sequence.pos > sequences.c2Sequence.length then
    sequences.c2Sequence.pos = 1
  end
  
  if sequences.c2Sequence.data[sequences.c2Sequence.pos] ~= nill then
    engine.hz(sequences.c2Sequence.data[sequences.c2Sequence.pos])
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--button input

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
        ui_refresh_metro:stop()
      else
        startStop = true
        seqOneMetro:start(60/seqOneBPM)
        seqTwoMetro:start(60/seqTwoBPM)
        ui_refresh_metro:start(1/framesPerSecond)
      end
    end
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--encoder input

function enc(n,d)
  if n == 1 then
    selectedSequence = util.clamp(selectedSequence + d, 1, 20)
  end

  if n == 2 then
    if selectedSequence >= 1 and selectedSequence <= 5 then
      sequences.c1Sequence.data = adjust(sequences.c1Sequence.data, (10*d), 1, 4096)
      circles.c1.updateNotes(sequences.c1Sequence.data)
    end

    if selectedSequence >= 11 and selectedSequence <= 15 then
      sequences.c2Sequence.data = adjust(sequences.c2Sequence.data, (10*d), 1, 4096)
      circles.c2.updateNotes(sequences.c2Sequence.data)
    end

    if selectedSequence >= 6 and selectedSequence <= 10 then
      if d == 1 then
        seqOneCounter = seqOneCounter + 1
        if (seqOneCounter % 5 == 0) then
          if (#sequences.c1Sequence.data) < 32 then
            sequences.c1Sequence.data[(#sequences.c1Sequence.data + 1)] = math.random(128, 768)
            circles.c1.updateNotes(sequences.c1Sequence.data)
          end
        end
      elseif d == -1 then
        seqOneCounter = seqOneCounter - 1
        if (seqOneCounter % 5 == 0) then
          if (#sequences.c1Sequence.data) > 2 then
            sequences.c1Sequence.data[(#sequences.c1Sequence.data)] = nil
            circles.c1.updateNotes(sequences.c1Sequence.data)
          end
        end
      end
    end

    if selectedSequence >= 16 and selectedSequence <= 20 then
      if d == 1 then
        seqTwoCounter = seqTwoCounter + 1
        if (seqTwoCounter % 5 == 0) then
          if (#sequences.c2Sequence.data) < 32 then
            sequences.c2Sequence.data[(#sequences.c2Sequence.data + 1)] = math.random(32, 128)
            circles.c2.updateNotes(sequences.c2Sequence.data)
          end
        end
      elseif d == -1 then
        seqTwoCounter = seqTwoCounter - 1
        if (seqTwoCounter % 5 == 0) then
          if (#sequences.c2Sequence.data) > 2 then
            sequences.c2Sequence.data[(#sequences.c2Sequence.data)] = nil
            circles.c2.updateNotes(sequences.c2Sequence.data)
          end
        end
      end
    end
  end

  if n == 3 then
    if selectedSequence >= 1 and selectedSequence <= 5 then
      seqOneBPM = util.clamp(seqOneBPM + d, 1, 250)
      print("seqOneBPM is: "..seqOneBPM)
      circles.c1.updateBPM(seqOneBPM)
      seqOneMetro.time = (60/seqOneBPM)
    elseif selectedSequence >= 11 and selectedSequence <= 15 then
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

--------------------------------------------------------------------------------------------------------------------------------------------------------
--draw the graphical interface

function redraw()
  screen.clear()
  screen.level(4)
	screen.rect(0,0,128,64)
	screen.fill()
  screen.level(1)

  -- draw the middle mark
  screen.circle(71,32,2)
  screen.fill()

  -- draw the menu parts
  screen.circle(8, 7, 1)
  screen.fill()
  screen.circle(6, 40, 1)
  screen.fill()
  screen.circle(10, 40, 1)
  screen.fill()

  if selectedSequence >= 1 and selectedSequence <= 5 then
    drawDot(8, 15, "true")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 6 and selectedSequence <= 10 then
    drawDot(8, 15, "false")
    drawSequence(4, 21, "true")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 11 and selectedSequence <= 15 then
    drawDot(8, 15, "false")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "true")
    drawSequence(4, 54, "false")
  elseif selectedSequence >= 16 and selectedSequence <= 20 then
    drawDot(8, 15, "false")
    drawSequence(4, 21, "false")
    drawDot(8, 48, "false")
    drawSequence(4, 54, "true")
  end

  circles.c1.redraw()
  circles.c2.redraw()
  screen.update()
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--functions to create different UI elements
--will be migrated to UI librarty in time

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

function drawLinkIcon(x, y, state)
  if state == "unlinkedtrue" then
    screen.level(6)
    screen.circle(x-2, y, 5)
    screen.circle(x+2, y, 5)
    screen.stroke()
  elseif state == "unlinkedfalse" then
    screen.level(6)
    screen.circle(x-4, y, 5)
    screen.circle(x+4, y, 5)
    screen.stroke()
  elseif state == "linkedtrue" then
    screen.level(6)
    screen.circle(x-2, y, 5)
    screen.circle(x+2, y, 5)
    screen.stroke()
  elseif state == "linkedfalse" then
    screen.level(1)
    screen.circle(x-2, y, 5)
    screen.circle(x+2, y, 5)
    screen.stroke()
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--create a random sequence

function randomSequence(type)
  if type == "all" then
    for i=1,(#sequences.c1Sequence.data) do
      sequences.c1Sequence.data[i] = (math.random(128, 512))
    end
    for i=1,(#sequences.c2Sequence.data) do
      sequences.c2Sequence.data[i] = (math.random(32, 128))
    end
    circles.c1.updateNotes(sequences.c1Sequence.data)
    circles.c2.updateNotes(sequences.c2Sequence.data)
  else
    if selectedSequence >= 1 and selectedSequence <= 5 then
      for i=1,(#sequences.c1Sequence.data) do
        sequences.c1Sequence.data[i] = (math.random(128, 512))
      end
      circles.c1.updateNotes(sequences.c1Sequence.data)
    elseif selectedSequence >= 11 and selectedSequence <= 15 then
      for i=1,(#sequences.c2Sequence.data) do
        sequences.c2Sequence.data[i] = (math.random(32, 128))
      end
      circles.c2.updateNotes(sequences.c2Sequence.data)
    end
  end
  redraw()
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--return minimum of all elements

function min(...)
  local ans = select(1,...)
  if type(ans) == 'table' then ans = min(unpack(ans)) end
  for _,n in ipairs { select(2,...) } do
    if type(n) == 'table' then n = min(unpack(n)) end
    if n < ans then ans = n end
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--return maximum of all elements

function max(...)
  local ans = select(1,...)
  if type(ans) == 'table' then ans = max(unpack(ans)) end
  for _,n in ipairs { select(2,...) } do
    if type(n) == 'table' then n = max(unpack(n)) end
    if n > ans then ans = n end
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--adjust table value up and down within given limits

function adjust(t,val,m,mx)
  if min(t)+val < m or max(t)+val > mx then return t end
  ans = {}
  for _,x in ipairs(t) do
    ans[#ans+1] = x+val
  end
  return ans
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--unpack and print a table

function pt(t)
  unpacked  = table.unpack(t)
  return unpacked
end

--------------------------------------------------------------------------------------------------------------------------------------------------------