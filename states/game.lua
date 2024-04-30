local state = {}
local player

local function positionCamera(dt)

	local locked_in = false
	for _,lockin in ipairs(map.c_lockins) do
		if player.x >= lockin.x
		and player.x+player.width <= lockin.x+lockin.width
		and player.y >= lockin.y
		and player.y+player.height <= lockin.y+lockin.height then
			locked_in = true
			player.locked_in = true
		end
	end
	
	if not locked_in and player.locked_in then
		--[[camera:setWorld(0,0,map.width,map.height)
		camera:setScale(1)]]
		player.locked_in = false
	end
	
	local x = player.x+(player.width/2)
	local y = player.y+(player.height/2)
	
	camera.x,camera.y = x,y
end

local function loadMap(mapname, char)
	for _,i in pairs(tiles) do
		i:remove_from_hash()
		tiles[_] = nil
	end
	objects = {}

	map:load(mapname, char)

	if not (objects[2] and objects[2].Player and objects[2].Player[1]) then
		objects[2].Player[1] = classes.Player(0, 0, character)
	end
end

local function updateOnlinePlayer(player)
	local data = {}
	
	data.x = player.x or 0
	data.y = player.y or 0
	data.dir = player.dir or 1
	data.frame = player.animation.frame or 1
	data.anim = player.animation.curAnim or "idle"
	data.char = player.char_path or "characters/Poyo"
	data.animpath = player.animation.path or "characters/Poyo/animations/"
	
	client:send("update-player", data)
end

function state.load(mapn, character, multiplayer)
	camera = Camera(0,0)
	if not mapn then
		mapn = 'fun'
	end
	if not character then
		character = 'Poyo'
	end
	
	loadMap(mapn, character)

	state.escape_sequence = false
	state.multiplayer = multiplayer
	
	player = objects[2].Player[1]

	positionCamera(1/60)
end

function state.enter()
	functions.startSound("voice_start", "player", 0.45)
	timer(2, function()
		map:playMusic()
		player.flags.canmove = true
	end)
end

function state.update(dt)
	local rate = 4
	for i = 1,rate do
		for _,entry in pairs(objects) do
			for _,type in pairs(entry) do
				for _,object in pairs(type) do
					object:update(dt/rate)
				end
			end
		end
	end
	
	local player = objects[2].Player[1]
	local song = functions.curPlaying()
	
	for _,i in ipairs(map.music_changes) do
		if not i.passed and player.x >= i.point then
			song = i.music
			i.passed = true
		end
	end
	
	if song ~= functions.curPlaying() then
		functions.changeMusic(song, 0)
	end
	positionCamera(dt/(1/60))
end

function state.draw()
	camera:attach()
	local old_x, old_y, old_w, old_h = love.graphics.getScissor()
	love.graphics.setScissor(rs.get_game_zone())
	for _,tile in pairs(tiles) do
		tile:draw()
	end
	
	for _,entry in pairs(objects) do
		for _,type in pairs(entry) do
			for _,object in pairs(type) do
				object:draw()
			end
		end
	end
	love.graphics.setScissor(old_x, old_y, old_w, old_h)
	camera:detach()
end

return state