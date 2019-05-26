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
local framesPerSecond = 15
local selectedSequence = 1
local orbitalCircle = include('lib/orbital_circle')
local circles = {c1, c2}
local unpack = unpack or table.unpack
local btnTwoHeld = false
local seqOneSelected = 1
local seqTwoSelected = 1
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

  seqOneBPM = 82
  seqTwoBPM = 21

  circles.c1 = orbitalCircle.new(45, 32, 16, 16, seqOneBPM, sequences.c1Sequence.data, "treb")
  circles.c2 = orbitalCircle.new(96, 32, 16, 16, seqTwoBPM, sequences.c2Sequence.data, "bass")

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

  seqOneMetro:start(60/seqOneBPM)
  seqTwoMetro:start(60/seqTwoBPM)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------





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





--------------------------------------------------------------------------------------------------------------------------------------------------------
--button input

function key (n,z)
  if selectedSequence >= 1 and selectedSequence <= 5 then
    if n == 2 then
      if z == 1 then
        randomSequence()
      end
    end

    if n == 3 then
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

  if selectedSequence >= 6 and selectedSequence <= 10 then
    if n == 2 then
      if z == 1 then
        btnTwoHeld = true
      else
        btnTwoHeld = false
      end
    end
  end

  if selectedSequence >= 11 and selectedSequence <= 15 then
    if n == 2 then
      if z == 1 then
        randomSequence()
      end
    end

    if n == 3 then
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

  if selectedSequence >= 16 and selectedSequence <= 20 then
    if n == 2 then
      if z == 1 then
        btnTwoHeld = true
      else
        btnTwoHeld = false
      end
    end
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------





--------------------------------------------------------------------------------------------------------------------------------------------------------
--encoder input

function enc(n,d)
  if n == 1 then --if encorder 1
    selectedSequence = util.clamp(selectedSequence + d, 1, 20)  --stops the user from being able to scroll off the ui. ranges are used to make the ui less skittish
  end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--update the pitch of notes being played

  if n == 2 then  --if encoder 2
    if selectedSequence >= 1 and selectedSequence <= 5 then  --if on ui element 1, sequence one basic controls
      circles.c1.setEditMode(false)
      circles.c2.setEditMode(false)
      sequences.c1Sequence.data = adjust(sequences.c1Sequence.data, (10*d), 1, 4096)  --adjust frequency of notes
      circles.c1.updateNotes(sequences.c1Sequence.data)  --update the circle instance to ensure the ui is in sync
    end

    if selectedSequence >= 11 and selectedSequence <= 15 then  --if on ui element 3, sequence two basic controls
      circles.c1.setEditMode(false)
      circles.c2.setEditMode(false)
      sequences.c2Sequence.data = adjust(sequences.c2Sequence.data, (10*d), 1, 4096)  --adjust frequency of notes
      circles.c2.updateNotes(sequences.c2Sequence.data)  --update the circle instance to ensure the ui is in sync
    end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--edit sequence one length

    if selectedSequence >= 6 and selectedSequence <= 10 then  --if on ui element 2, sequence 1 additional controls
      circles.c1.setEditMode(true)
      if d == 1 then  --if encoder two turned clockwise
        seqOneCounter = seqOneCounter + 1  --increase the length of the sequence counter
        if (seqOneCounter % 5 == 0) then  --some mod just to make the input less instant
          if (#sequences.c1Sequence.data) < 32 then  --if the sequence is less than 32, add a note
            sequences.c1Sequence.data[(#sequences.c1Sequence.data + 1)] = math.random(128, 768)  --the note dded to the sequence
            circles.c1.updateNotes(sequences.c1Sequence.data)  --update the ui
          end
        end
      elseif d == -1 then  --or i the encoder was turned anti clockwise
        seqOneCounter = seqOneCounter - 1
        if (seqOneCounter % 5 == 0) then
          if (#sequences.c1Sequence.data) > 2 then
            sequences.c1Sequence.data[(#sequences.c1Sequence.data)] = nil  --kill the last note in the sequence
            circles.c1.updateNotes(sequences.c1Sequence.data)  --and update the ui
          end
        end
      end
    end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--edit sequence two length

    if selectedSequence >= 16 and selectedSequence <= 20 then
      circles.c2.setEditMode(true)
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

--------------------------------------------------------------------------------------------------------------------------------------------------------
--edit the bpm of the sequences

  if n == 3 then
    if selectedSequence >= 1 and selectedSequence <= 5 then
      circles.c1.setEditMode(false)
      circles.c2.setEditMode(false)
      seqOneBPM = util.clamp(seqOneBPM + d, 1, 250)
      circles.c1.updateBPM(seqOneBPM)
      seqOneMetro.time = (60/seqOneBPM)
    elseif selectedSequence >= 11 and selectedSequence <= 15 then
      circles.c1.setEditMode(false)
      circles.c2.setEditMode(false)
      seqTwoBPM = util.clamp(seqTwoBPM + d, 1, 250)
      circles.c2.updateBPM(seqTwoBPM)
      seqTwoMetro.time = (60/seqTwoBPM)

--------------------------------------------------------------------------------------------------------------------------------------------------------
--edit the pitch of the notes of sequence 1

    elseif selectedSequence >= 6 and selectedSequence <= 10 then
      circles.c1.setEditMode(true)
      if d == 1 and btnTwoHeld == false then
        if seqOneSelected == (#sequences.c1Sequence.data) then
          seqOneSelected = 0
        else
          seqOneSelected = seqOneSelected +1
          circles.c1.selectNote(seqOneSelected)
        end
      end

      if d == 1 and btnTwoHeld == true then
        sequences.c1Sequence.data[seqOneSelected] = (sequences.c1Sequence.data[seqOneSelected]) + (10)
      end

      if d == -1 and btnTwoHeld == false then
        if seqOneSelected == 1 then
          seqOneSelected = (#sequences.c1Sequence.data)
        else
          seqOneSelected = seqOneSelected -1
          circles.c1.selectNote(seqOneSelected)
        end
      end

      if d == -1 and btnTwoHeld == true then
        sequences.c1Sequence.data[seqOneSelected] = (sequences.c1Sequence.data[seqOneSelected]) - (10)
      end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--edit the pitch of the notes of sequence 2

    elseif selectedSequence >= 16 and selectedSequence <= 20 then
      circles.c2.setEditMode(true)
      if d == 1 and btnTwoHeld == false then
        if seqTwoSelected == (#sequences.c2Sequence.data) then
          seqTwoSelected = 0
        else
          seqTwoSelected = seqTwoSelected +1
          circles.c2.selectNote(seqTwoSelected)
        end
      end

      if d == 1 and btnTwoHeld == true then
        sequences.c2Sequence.data[seqTwoSelected] = (sequences.c2Sequence.data[seqTwoSelected]) + (10)
      end

      if d == -1 and btnTwoHeld == false then
        if seqTwoSelected == 1 then
          seqTwoSelected = (#sequences.c2Sequence.data)
        else
          seqTwoSelected = seqTwoSelected -1
          circles.c2.selectNote(seqTwoSelected)
        end
      end

      if d == -1 and btnTwoHeld == true then
        sequences.c2Sequence.data[seqTwoSelected] = (sequences.c2Sequence.data[seqTwoSelected]) - (10)
      end
    end
  end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------





--------------------------------------------------------------------------------------------------------------------------------------------------------
--draw the graphical interface

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
--unpack a table

function pt(t)
  unpacked  = table.unpack(t)
  return unpacked
end

--------------------------------------------------------------------------------------------------------------------------------------------------------