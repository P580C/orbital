local Orbital_Circle = {}

function Orbital_Circle.new(x, y, diameter, number_of_notes, beats_per_minute, frames_per_second, sequence_data, type)
	local orbitalCircle = {}

	orbitalCircle.xPos = x or 0
	orbitalCircle.yPos = y or 0
	orbitalCircle.circleDiameter = diameter or 10
	orbitalCircle.numberOfNotes = number_of_notes or 16
	orbitalCircle.spaceBetweenNotes = (360 / number_of_notes)
	orbitalCircle.beatsPerSecond = (beats_per_minute / 60)
	orbitalCircle.currentRotation = 0
	orbitalCircle.framesPerSecond = frames_per_second or 15
	orbitalCircle.framesPerFullRotation = (orbitalCircle.numberOfNotes/orbitalCircle.beatsPerSecond)+orbitalCircle.framesPerSecond
	orbitalCircle.degreesPerFrame = 360 / orbitalCircle.framesPerFullRotation
	orbitalCircle.newRotationValue = orbitalCircle.currentRotation + orbitalCircle.degreesPerFrame
	orbitalCircle.sequenceData = sequence_data
	orbitalCircle.type = type

	function orbitalCircle.updateNotes(sq)
		orbitalCircle.sequenceData = sq
	end

	function orbitalCircle.updateBPM(bpm)
		orbitalCircle.beatsPerSecond = (bpm / 60)
	end

	function orbitalCircle.tick()
		orbitalCircle.spaceBetweenNotes = (360 / number_of_notes)
		orbitalCircle.framesPerFullRotation = (orbitalCircle.numberOfNotes/orbitalCircle.beatsPerSecond)*orbitalCircle.framesPerSecond
		orbitalCircle.degreesPerFrame = (360 / orbitalCircle.framesPerFullRotation)
		orbitalCircle.newRotationValue = (orbitalCircle.currentRotation + orbitalCircle.degreesPerFrame)

		if orbitalCircle.newRotationValue > 360 then
			orbitalCircle.currentRotation = 0
		else
			orbitalCircle.currentRotation = orbitalCircle.newRotationValue
		end
	end

	function orbitalCircle.redraw()
		for i=1,orbitalCircle.numberOfNotes do
			if orbitalCircle.sequenceData[i] > 0 then
				if type == "treb" then
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i])
					)
					screen.fill()
				else
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i] * 2)
					)
					screen.stroke()
				end
				screen.update()
			end
		end
	end

	-- utility function to map frequency numbers to relative pixel dimensions (range 32-1024 to range 4-8)
	function map(n)
		local returnValue
		-- draw circles to size based off frequency ranges - can't find a cleaner way to do this
		if n >= 1 and n <= 50 then
			returnValue = 0.5
		elseif n >= 51 and n <= 100 then
			returnValue = 0.5
		elseif n >= 101 and n <= 200 then
			returnValue = 1
		elseif n >= 201 and n <= 300 then
			returnValue = 2
		elseif n >= 301 and n <= 400 then
			returnValue = 2
		elseif n >= 401 and n <= 500 then
			returnValue = 3
		elseif n >= 501 and n <= 600 then
			returnValue = 3
		elseif n >= 601 and n <= 700 then
			returnValue = 4
		elseif n >= 701 and n <= 800 then
			returnValue = 5
		elseif n >= 801 and n <= 900 then
			returnValue = 6
		elseif n >= 901 and n <= 1000 then
			returnValue = 7
		else
			returnValue = 8
		end
		return returnValue
	end

	-- function that returns x and y position
	function orbitalCircle.location()
		local location = {x, y}
		location.x = orbitalCircle.xPos
		location.y = orbitalCircle.yPos
		return location
	end

	return orbitalCircle
end

return Orbital_Circle