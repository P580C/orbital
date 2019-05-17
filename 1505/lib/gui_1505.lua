--[[
	ball receives a tick event
	ball updates itself each time
	ball draws to the screen
]]

local gui_1505 = {}


--------------------------------------------------------------------------------------------------------------------------------------------------------
--radio button

function gui_1505.radio_button.new(x, y, state)
	local radio_button = {}

	radio_button.x = x or 10
	radio_button.y = y or 10
	radio_button.state = state or false

	function ball.redraw()
		if state == "true" then
			screen.level(6)
			screen.circle(x, y, 3)
			screen.stroke()
			screen.circle(x, y, 2)
			screen.fill()
		  else
			screen.level(1)
			screen.circle(x, y, 3)
			screen.fill()
		  end
		screen.update()
	end
	return radio_button
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
--linked/unlinked icon



--------------------------------------------------------------------------------------------------------------------------------------------------------
--sequence icon



--------------------------------------------------------------------------------------------------------------------------------------------------------
--sequencer note



--------------------------------------------------------------------------------------------------------------------------------------------------------
--vertical menu



--------------------------------------------------------------------------------------------------------------------------------------------------------
--horizontal menu

return gui_1505