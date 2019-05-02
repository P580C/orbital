--[[
	ball receives a tick event
	ball updates itself each time
	ball draws to the screen
]]

local ball = {}

function ball.new(x, y, diameter, xVel, yVel, type)
	local ball_object = {}

	ball_object.x = x or 10
	ball_object.y = y or 10
	ball_object.diameter = diameter or 10
	ball_object.xVel = xVel or 0
	ball_object.yVel = yVel or 0
	ball_object.type = type or "dark"

	function ball.tick()
		--do
	end

	function ball.redraw()
		screen.level(4)
		screen.circle(ball_object.x, ball_object.y, ball_object.diameter)
		screen.fill()
		screen.update()
	end

	return ball_object
end

return ball