local state = {}

function state:enter(player, state)
	player.time = 0.2
	player.batflip = not player.flags.grounded
	player.flags.candamage = true
	player.animation:changeAnim("bat_attack", 15, false)
	
	if player.batflip then
		player.momy = -2
	end
end

function state:update(player, dt)
	player.time = player.time - dt
	
	if player.time <= 0
	and (not player.batflip
		or player.batflip 
		and player.flags.grounded) then
		player.fsm:changeState(player, "base")
		end

	if player.batflip and controls:isJustPressed('Dodge') then
		player.fsm:changeState(player, "dodge")
	end
end

function state:tileCollision(player, type)
	if not player.batflip then return end

	if (type == "left"
	or type == "right"
	or type == "top")
	and player.lasthit ~= type then
		if type == "top" then
			player.momy = -player.momy
		else
			player.momx = -7*player.dir
			player.momy = -15
		end
		functions.startSound("bat_wall","player")
		
		player.lasthit = type
	end
end

function state:exit(player, type)
	player.lasthit = nil
	player.flags.candamage = false
end

return state