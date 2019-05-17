local Orbital_Circle = {}

function Orbital_Circle.new(x, y, diameter, number_of_notes, beats_per_minute, sequence_data, type)
	local orbitalCircle = {}

	orbitalCircle.xPos = x or 0
	orbitalCircle.yPos = y or 0
	orbitalCircle.circleDiameter = diameter or 10
	orbitalCircle.numberOfNotes = number_of_notes
	orbitalCircle.spaceBetweenNotes = math.rad(360 / number_of_notes)
	orbitalCircle.beatsPerMinute = beats_per_minute
	orbitalCircle.beatsPerSecond = (orbitalCircle.beatsPerMinute / 60)
	orbitalCircle.currentRotation = 0
	orbitalCircle.framesPerSecond =  15
	orbitalCircle.framesPerFullRotation = (orbitalCircle.framesPerSecond) / (orbitalCircle.beatsPerSecond / orbitalCircle.numberOfNotes)
	orbitalCircle.degreesPerFrame = 360 / orbitalCircle.framesPerFullRotation
	orbitalCircle.newRotationValue = orbitalCircle.currentRotation + orbitalCircle.degreesPerFrame
	orbitalCircle.sequenceData = sequence_data
	orbitalCircle.type = type
	--orbitalCircle.degreesPerSecond = (((orbitalCircle.beatsPerMinute / orbitalCircle.numberOfNotes) * 360) / 60)
	--orbitalCircle.framesPerFullRotation = (360/orbitalCircle.degreesPerSecond)*15
	
	function orbitalCircle.updateNotes(sq)
		orbitalCircle.sequenceData = sq
		orbitalCircle.numberOfNotes = (#sq)
		orbitalCircle.spaceBetweenNotes = (360 / orbitalCircle.numberOfNotes)
		print("SBN: "..orbitalCircle.spaceBetweenNotes)
	end

	function orbitalCircle.updateBPM(bpm)
		orbitalCircle.beatsPerSecond = (bpm / 60)
	end

	function orbitalCircle.stop()
		orbitalCircle.redrawMetro:stop()
	end

	function orbitalCircle.start()
		orbitalCircle.redrawMetro:start(1/15)
	end

	function orbitalCircle.tick()
		orbitalCircle.spaceBetweenNotes = math.rad(360 / orbitalCircle.numberOfNotes)
		orbitalCircle.framesPerFullRotation = (orbitalCircle.framesPerSecond) / (orbitalCircle.beatsPerSecond / orbitalCircle.numberOfNotes)--(orbitalCircle.numberOfNotes/orbitalCircle.beatsPerSecond)*orbitalCircle.framesPerSecond
		orbitalCircle.degreesPerFrame = (360 / orbitalCircle.framesPerFullRotation)
		orbitalCircle.newRotationValue = (orbitalCircle.currentRotation + orbitalCircle.degreesPerFrame)

		if orbitalCircle.newRotationValue >= 360 then
			orbitalCircle.currentRotation = 0
		else
			orbitalCircle.currentRotation = orbitalCircle.newRotationValue
		end
	end

	function orbitalCircle.redraw()
		screen.level(3)
		screen.circle(orbitalCircle.xPos, orbitalCircle.yPos, orbitalCircle.circleDiameter)
		screen.stroke()
		screen.level(1)
		for i=1, (#orbitalCircle.sequenceData) do
			if orbitalCircle.sequenceData[i] > 0 then
				if type == "treb" then
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i], 1, 2048, 0.5, 12)
					)
					screen.fill()
				else
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i], 1, 512, 0.5, 12)
					)
					screen.stroke()
				end
				screen.update()
			end
		end
	end

	-- utility function to map frequency numbers to relative pixel dimensions
	function map(n, m, mx, rm, rmx)
		local returnValue = rm + ((rmx - rm) / (mx - m)) * (n - m)
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