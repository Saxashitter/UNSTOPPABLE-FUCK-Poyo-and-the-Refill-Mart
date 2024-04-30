return {
	onStart = function(player)
		functions.startSound("run_start", "player")
	end,
	onFrameChange = function(frame, player)
		if frame ~= 1 and frame ~= 3 then return end
		functions.startSound('step'..love.math.random(8), 'player')
	end
}