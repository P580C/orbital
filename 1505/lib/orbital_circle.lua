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

	orbitalCircle.redrawMetro = metro.init()
	orbitalCircle.redrawMetro.event = function()
		orbitalCircle.tick()
	end

	orbitalCircle.redrawMetro:start(1/15)

	function orbitalCircle.updateNotes(sq)
		orbitalCircle.sequenceData = sq
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
		screen.level(1)
		for i=1,orbitalCircle.numberOfNotes do
			if orbitalCircle.sequenceData[i] > 0 then
				print("sequence data position 1 is: "..orbitalCircle.sequenceData[1])
				if type == "treb" then
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i], 32, 1024, 1, 12)
					)
					screen.fill()
				else
					screen.circle(
						math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
						math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
						map(orbitalCircle.sequenceData[i], 5, 128, 1, 8)
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