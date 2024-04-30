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

local function loadTileLayer(self, map, layer)
	for _,i in ipairs(layer.data) do
		if i > 0 then
			local x = (_-1)*map.tilewidth
			local y = 0
			
			while x >= map.width*map.tilewidth do
				y = y + map.tileheight
				x = x - (map.width*map.tilewidth)
			end

			classes['Block'](self.images[i], x, y, map.tilewidth, map.tileheight, layer)
		end
	end
end

local function loadBlockLayer(self, map, layer, char)
	for _,object in ipairs(layer.objects) do
		if object.name == "spawn" then
			classes[object.type](object.x, object.y-(classes[object.type].height/2), char)
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
end

function map:load(name, char)
	if type(name) ~= "string"
	and type(name) ~= "table" then
		return
	end
	self.images = {}
	self.c_lockins = {}
	self.music_changes = {}
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
			loadTileLayer(self, map, layer)
		elseif layer.type == "objectgroup" then
			loadBlockLayer(self, map, layer, char)
		end
	end
end

function map:playMusic()
	if not self.music then return end
	functions.changeMusic(self.music, 0, true)
end

return map