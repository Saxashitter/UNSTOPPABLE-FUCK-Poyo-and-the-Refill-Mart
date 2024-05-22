local map = {}

local function split_string (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t={}

	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end

	return t
end

-- MAP FUNCTIONS
local function rayCast(self, x, y, direction_x, direction_y, length)
    -- calculate the inverse direction of the ray
    local inverseDirX, inverseDirY = 1 / direction_x, 1 / direction_y

    local inverseSize = 1 / self.tilewidth

    local i = 0.0
    -- prevent infinite loop
    local checkLimit = (length / self.tilewidth) * 2

    local rayLength = 0.0

    while i < checkLimit do
        i = i + 1
        local cx, cy
        if direction_x < 0 then
            cx = math.floor(x * inverseSize) * chunkSize
        else
            cx = math.ceil(x * inverseSize) * self.tilewidth
        end
        if direction_y < 0 then
            cy = math.floor(y * inverseSize) * self.tileheight
        else
            cy = math.ceil(y * inverseSize) * self.tileheight
        end
        -- step distance on x,y distance to cross the chunk
        local px, py = (cx - x) * inverseDirX, (cy - y) * inverseDirY
        -- take the smallest distance
        local step = math.max(0.0, math.min(px, py) * inverseSize)
        -- calculate the distance the ray has travelled
        local stepToEnd = math.min(step * self.tilewidth, math.abs(rayLength - length))

        rayLength = rayLength + step * self.tilewidth

        -- multiply by 1.001 to barely go over the chunk border
        x = x + direction_x * stepToEnd * 1.001
    	y = y + direction_y * stepToEnd * 1.001
    	local block = self:findBlock(x, y)
    	
		if block then return block end

        if rayLength > length then break end
    end

    return false
end

local function preloadMusic(self)
	if not self.music then return end
	functions.preloadMusic(self.music)
end
local function playMusic(self)
	if not self.music then return end
	functions.changeMusic(self.music)
end

local function findBlock(self, x, y, tiles)
	x = math.floor(x/self.tilewidth)
	y = math.floor(y/self.tileheight)

	if tiles[y] and tiles[y][x] then
		return tiles[y][x]
	end
end

local function loadTileLayer(self, map, layer)
	local tiles = {}

	for _,i in ipairs(layer.data) do
		if i > 0 then
			local x = (_-1)
			local y = 0
			
			while x >= map.width do
				y = y + 1
				x = x - map.width
			end

			if not tiles[y] then
				tiles[y] = {}
			end

			tiles[y][x] = classes['Block'](self.images[i], x*map.tilewidth, y*map.tileheight, map.tilewidth, map.tileheight, layer)
		end
	end

	-- run that back, connect the tiles with each other
	for _,y in pairs(tiles) do
		for _,self in pairs(y) do
			local w = self.width
			local h = self.height
			self.lefttile = findBlock(map, self.x-w, self.y, tiles)
			self.toptile = findBlock(map, self.x, self.y-h, tiles)
			self.righttile = findBlock(map, self.x+w, self.y, tiles)
			self.bottomtile = findBlock(map, self.x, self.y+h, tiles)
			
			-- lets also run a function, cause slopes and stuff, cause why not
			self:postTileSet()
		end
	end
	return tiles
end

local function loadBlockLayer(self, map, layer, char)
	local player
	for _,object in ipairs(layer.objects) do
		if object.name == "spawn" then
			local funny = classes[object.type](object.x, object.y+(map.tileheight-classes[object.type].height), char)
			funny.flags.grounded = true
			
			if object.type == "Player" then
				player = funny
				player.map = self
			end
		elseif object.name == "camera" then
			if object.type == "lockin" then
				table.insert(self.c_lockins, object)
			end
		elseif object.name == "segment" then
			table.insert(self.music_changes, {
				point = object.x,
				music = object.type,
				passed = false
			})
		end
	end
	
	return player
end

function map:load(name, char)
	local player
	local self = {}

	if type(name) ~= "string"
	and type(name) ~= "table" then
		return
	end
	self.images = {}
	self.c_lockins = {}
	self.music_changes = {}
	self.data = {}
	local mappath = "maps/"
	local tilesetpath = mappath.."tilesets/"
	local map

	if type(name) == "string" then
		map = mappath..name
		local requirepath = map:gsub('/', '.')
	
		map = require(requirepath)
	elseif type(name) == "table" then
		map = name
	end
	self.width = map.width*map.tilewidth
	self.height = map.height*map.tileheight
	self.tilewidth = map.tilewidth
	self.tileheight = map.tileheight

	for _,i in ipairs(map.tilesets) do
		local startnum = #self.images
		local path = split_string(i.image, '/')
		local path = path[#path]
		local luapath = path:gsub('.png', ".lua")
		local image = love.graphics.newImage(tilesetpath..path)

		for y = 0,i.imageheight/i.grid.height-1 do
			for x = 0,i.imagewidth/i.grid.width-1 do
				table.insert(self.images, {
					image = image,
					quad = love.graphics.newQuad(
						x*i.grid.width,
						y*i.grid.height,
						i.grid.width,
						i.grid.height,
						image
					),
					properties = {}
				})
			end
		end
		
		if love.filesystem.exists(tilesetpath..luapath) then
			local path = tilesetpath..luapath
			path = path:gsub('.lua', '')
			path = path:gsub('/', '.')
			local stuff = require(path)
			
			for _,i in pairs(stuff) do
				if self.images[_] then
					self.images[_].properties = i
				end
			end
		end
	end

	for _,prop in pairs(map.properties) do
		self[_] = prop
	end

	for _,layer in ipairs(map.layers) do
		if layer.type == "tilelayer" then
			self.data[(#self.data or 0) + 1] = loadTileLayer(self, map, layer)
		elseif layer.type == "objectgroup" then
			player = loadBlockLayer(self, map, layer, char)
		end
	end

	self.findBlock = function(self, x, y)
		local blocks
		for layer,data in pairs(self.data) do
			local block = findBlock(self, x, y, data)
			if block and not blocks then blocks = {} end
			if block then
				blocks[layer] = block
			end
		end
		return blocks
	end
	self.raycast = rayCast

	self.preloadMusic = preloadMusic
	self:preloadMusic()

	self.playMusic = playMusic

	return self,player
end

return map