local state = {}

function state:enter(player, state)
	player.dodgetime = 0.5
	player.flags.passtiles = 2
	player.flags.nogravity = true
	player.momy = 0
end

function state:update(player, dt)
	player.dodgetime = player.dodgetime - dt
	
	local collisions = {}
	objhash:each(player, function(obj)
		if not (obj.y1 or obj.y2) then
			table.insert(collisions, obj)
		end
	end)
	
	if player.dodgetime <= 0 
	and #collisions == 0 then
		player.fsm:changeState(player, "base")
	end
end

function state:tileCollision(player, type)
	if (type == "left" 
	or type == "right")
	and player.lastdodgetype ~= type then
		player.momx = -player.momx
		player.lastdodgetype = type
	end
end

function state:exit(player, state)
	player.flags.passtiles = 0
	player.flags.nogravity = false
	player.dodgetime = nil
	player.lastdodgetype = nil
end

return state