Orbital_Circle = {}

-- set up variables
local xPos
local yPos
local circleDiameter
local scalingFactor
local numberOfNotes
local spaceBetweenNotes
local beatsPerSecond
local currentRotation
local framesPerSecond
local framesPerFullRotation
local degreesPerFrame
local newRotationValue
local sequenceData


function Orbital_Circle.new(x, y, diameter, scale_factor, number_of_notes, beats_per_second, frames_per_second, sequence_data)
	xPos = x
	yPos = y
	circleDiameter = diameter
	scalingFactor = scale_factor
	numberOfNotes = number_of_notes
	spaceBetweenNotes = number_of_notes / 360
	beatsPerSecond = beats_per_second
	currentRotation = 0
	framesPerSecond = frames_per_second
	framesPerFullRotation = (number_of_notes/beats_per_second)+frames_per_second
	degreesPerFrame = 360 / framesPerFullRotation
	newRotationValue = currentRotation + degreesPerFrame
	sequenceData = sequence_data
end

function Orbital_Circle:updateNotes(sequence_data)
	sequenceData = sequence_data
end

function Orbital_Circle:updateBPM(beats_per_second)
	beatsPerSecond = beats_per_second
end

function Orbital_Circle:redraw()
	for i=1,numberOfNotes do
		if sequenceData[i] > 0 then
			screen.circle(
			math.cos(math.rad(newRotationValue)+(spaceBetweenNotes*i))*circleDiameter + xPos,
			math.sin(math.rad(newRotationValue)+(spaceBetweenNotes*i))*circleDiameter + yPos,
			sequenceData[i]/scalingFactor
			)
		screen.fill()
		end
	end
end

return Orbital_Circle