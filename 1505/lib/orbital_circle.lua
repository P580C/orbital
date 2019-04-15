local Orbital_Circle = {}

function Orbital_Circle.new(x, y, diameter, scale_factor, number_of_notes, beats_per_minute, frames_per_second, sequence_data)
	local orbitalCircle = {}

  print("Orbital_Circle running")
	orbitalCircle.xPos = x or 0
	orbitalCircle.yPos = y or 0
	orbitalCircle.circleDiameter = diameter or 10
	orbitalCircle.scalingFactor = scale_factor or 1.7
	orbitalCircle.numberOfNotes = number_of_notes or 16
	orbitalCircle.spaceBetweenNotes = number_of_notes / 360
	orbitalCircle.beatsPerSecond = (beats_per_minute / 60) or 120
	orbitalCircle.currentRotation = 0
	orbitalCircle.framesPerSecond = frames_per_second or 15
	orbitalCircle.framesPerFullRotation = (orbitalCircle.numberOfNotes/orbitalCircle.beatsPerSecond)+orbitalCircle.framesPerSecond
	orbitalCircle.degreesPerFrame = 360 / orbitalCircle.framesPerFullRotation
	orbitalCircle.newRotationValue = orbitalCircle.currentRotation + orbitalCircle.degreesPerFrame
	orbitalCircle.sequenceData = sequence_data
	
	function orbitalCircle.testFunc(param)
		local p = param
		return p * 2
	end
	
	function orbitalCircle.updateNotes(sequence_data)
		orbitalCircle.sequenceData = sequence_data
	end
	
	function orbitalCircle.updateBPM(beats_per_minute)
		orbitalCircle.beatsPerSecond = beats_per_minute/60
		print("Updated BPS to: " .. orbitalCircle.beatsPerSecond)
	end

	function orbitalCircle.redraw()
		for i=1,orbitalCircle.numberOfNotes do
			if orbitalCircle.sequenceData[i] > 0 then
				screen.circle(
					math.cos(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.xPos,
					math.sin(math.rad(orbitalCircle.newRotationValue)+(orbitalCircle.spaceBetweenNotes*i))*orbitalCircle.circleDiameter + orbitalCircle.yPos,
					orbitalCircle.sequenceData[i] / orbitalCircle.scalingFactor
				)
			screen.fill()
			end
		end
	end

	return orbitalCircle
end

return Orbital_Circle