return {
	onFrameChange = function(frame, player)
		if frame ~= 1
		and frame ~= 5 then return end

		functions.startSound('step'..love.math.random(8), 'player')
	end
}