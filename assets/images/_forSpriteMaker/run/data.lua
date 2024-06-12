return {
	onStart = function(player)
		player.sounds.run_start:play()
	end,
	onFrameChange = function(frame, player)
		if frame ~= 1 and frame ~= 3 then return end
		player.sounds['step'..love.math.random(8)]:play()
	end
}