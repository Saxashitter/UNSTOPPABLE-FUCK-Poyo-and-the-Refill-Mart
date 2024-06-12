return {
	onFrameChange = function(frame, player)
		if frame ~= 1
		and frame ~= 5 then return end

		player.sounds['step'..love.math.random(8)]:play()
	end
}