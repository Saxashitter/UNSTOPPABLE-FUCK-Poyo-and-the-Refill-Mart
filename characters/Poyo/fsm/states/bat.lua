local state = {}

function state:enter(player, state)
	player.time = 0.2
	player.batflip = not player.flags.grounded
	player.flags.candamage = true
	player.animation:changeAnim("bat_attack", 15, false)
	
	if player.batflip then
		player.momy = -2 end
	
	if math.abs(player.momx) < 6 then
		player.momx = 6*player.dir end
end

function state:update(player, dt)
	player.time = player.time - dt
	
	if player.time <= 0
	and (not player.batflip
		or (player.batflip 
		and player.flags.grounded
		and not controls:isPressed('Down'))) then
			player.fsm:changeState(player, "base")
		end

	if player.batflip and controls:isJustPressed('Dodge') then
		player.fsm:changeState(player, "dodge")
	end
end

function state:tileCollision(player, type, obj)
	if not player.batflip then return end

	if type == "left"
	or type == "right"
	or type == "top" then
		if type == "top" then
			player.momy = -player.momy
		else
			if not controls:isPressed('Up') then
				player.momx = player.momx*-1
				player.momy = -15
	
				if not player:changeDirection() then
					player.dir = player.dir * -1
				end
			else
				player.momy = -20
				player.momx = -6*player.dir
				player.fsm:changeState(player, "base")
			end
		end

		player.sounds.bat_wall:play()
		return {true, true}
	elseif controls:isPressed('Down') then
		local map = states.getState().curMap or nil
		
		player.momx = player.momx + (2*player.dir)
		player.momy = -6
		player.flags.grounded = false
		
		if obj:isSlope() then
			player.momy = -8*(math.abs(player.momx/6))
			print "slope"
		end
		
		functions.startSound("bat_wall","player")
		return {true, true}
	end
end

function state:exit(player, type)
	player.flags.candamage = false
end

return state