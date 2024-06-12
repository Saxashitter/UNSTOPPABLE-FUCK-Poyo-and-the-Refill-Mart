local state = {}

function state:enter(player, state)
	player.time = 0.2
	player.batflip = not player.flags.grounded
	player.flags.candamage = true
	player.flags.canchangedir = false
	player.animation:changeAnim("bat_attack", 15, false)
	
	if player.batflip then
		player.momy = -2 end
	
	if player.batflip then
		if math.abs(player.momx) < 6 then
			player.momx = 6*player.dir end
	else
		player.momx = 240*player.dir
	end
end

function state:update(player, dt)
	player.time = player.time - dt
	
	if player.time <= 0
	and (not player.batflip
		or (player.batflip 
		and player.flags.grounded
		and not controls:isPressed('Down'))) then
			player:fsm("base")
		end

	if player.batflip and controls:isJustPressed('Dodge') then
		player:fsm("dodge")
	end
end

function state:tileCollision(player, type, obj)
	if not player.batflip then return end

	if type == "left"
	or type == "right"
	or type == "top" then
		player.gravity = gravity
		if type == "top" then
			player.momy = -player.momy
		else
			if not controls:isPressed('Up') then
				player.momx = (player.momx+(0.35*player.dir))*-1
				player.momy = -15
				player:changeDirection(true)
			else
				player.momy = -20
				player.momx = -6*player.dir
				player:fsm("base")
			end
		end

		player.sounds.bat_wall:play()
		return {true, true}
	elseif controls:isPressed('Down') then
		local map = states.getState().curMap or nil
		
		player.momx = player.momx + (3*player.dir)
		player.momy = -5
		player.flags.grounded = false
		
		if obj:isSlope() then
			player.gravity = gravity
			player.momy = -8*(math.abs(player.momx/6))
		else
			player.gravity = gravity/1.75
		end
		
		functions.startSound("bat_wall","player")
		return {true, true}
	end
end

function state:exit(player, type)
	player.flags.candamage = false
	player.flags.canchangedir = true
	player.gravity = gravity
end

return state