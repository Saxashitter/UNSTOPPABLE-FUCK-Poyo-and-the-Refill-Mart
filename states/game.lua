local function stayWithinBoundaries(x, y, min_x, min_y, max_x, max_y)
	local new_x,new_y = x,y

	new_x = math.max(min_x, math.min(x, max_x))
	new_y = math.max(min_y, math.min(y, max_y))

	return new_x, new_y, not (new_x == x and new_y == y)
end

local function positionCamera(dt)
	local locked_in = false

	--[[for _,lockin in ipairs(map.c_lockins) do
		if player.x >= lockin.x
		and player.x+player.width <= lockin.x+lockin.width
		and player.y >= lockin.y
		and player.y+player.height <= lockin.y+lockin.height then
			locked_in = true
			player.locked_in = true
		end
	end
	
	if not locked_in and player.locked_in then
		player.locked_in = false
	end]]
	
	local x = player.x+(player.width/2)
	local y = player.y+(player.height/2)
	
	local sw = rs.game_width/2
	local sh = rs.game_height/2
	
	x,y = stayWithinBoundaries(x, y, sw, sh, curMap.width-sw, curMap.height-sh)

	camera.x,camera.y = x,y
end

local function loadMap(mapname, char)
	curMap,player,entities = map:load(mapname, char)

	if not player then
		player = classes.Player(0, 0, char)
	end
end

function load(mapn, character, multiplayer)
	camera = Camera(0,0)
	shash = shash.new(128)
	if not mapn then
		mapn = 'fun'
	end
	if not character then
		character = 'Poyo'
	end
	
	loadMap(mapn, character)

	escape_sequence = false

	positionCamera(1/60)
end

function enter()
	player.sounds.voice_start:play()
	timer(2, function()
		curMap:playMusic()
		player.flags.canmove = true
	end)
end

function update(dt)
	local rate = 4
	player:update(dt)
	
	if player.y > curMap.height then
		switchToMenu()
		return
	end
	
	local song = functions.curPlaying()
	
	--[[for _,i in ipairs(map.music_changes) do
		if not i.passed and player.x >= i.point then
			song = i.music
			i.passed = true
		end
	end]]
	
	if song ~= functions.curPlaying() then
		functions.changeMusic(song, 0)
	end
	positionCamera(dt/(1/60))
end

function draw()
	camera:attach()
	local old_x, old_y, old_w, old_h = love.graphics.getScissor()
	love.graphics.setScissor(rs.get_game_zone())
	for _,layer in pairs(curMap.data) do
		for _,y in pairs(layer) do
			for _,x in pairs(y) do
				x:draw()
			end
		end
	end
	player:draw()

	love.graphics.setScissor(old_x, old_y, old_w, old_h)
	camera:detach()
end