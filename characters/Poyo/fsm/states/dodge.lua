local state = {}

function state:enter(player, state)
	player.dodgetime = 0.25
	player.flags.passtiles = 2
	player.flags.nogravity = true
	player.flags.canchangedir = false
	player.momy = 0
	
	if math.abs(player.momx) < 4 then
		player.momx = 4*player.dir
	end

	if player.momx*player.dir < 0 then
		player.momx = -player.momx
	end
end

function state:update(player, dt)
	player.dodgetime = player.dodgetime - dt
	
	local collisions = {}
	local state = states.getState(states.nextState)
	if state and state.shash then
		state.shash:each(player, function(obj)
			if not (obj.isSlope and obj:isSlope()) then
				table.insert(collisions, obj)
			end
		end)
	end
	
	if player.dodgetime <= 0 
	and #collisions == 0 then
		player:fsm("base")
	end
end

function state:tileCollision(player, type)
	if (type == "left" 
	or type == "right") then
		player.momx = -player.momx
		player.dir = player.dir * -1
		return {true, false}
	end
end

function state:exit(player, state)
	player.flags.passtiles = 0
	player.flags.nogravity = false
	player.dodgetime = nil
	player.lastdodgetype = nil
	player.flags.canchangedir = true
end

return state