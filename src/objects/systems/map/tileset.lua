local tileset = LuaObject:extend()

local ASSET_PATH = "assets/images/tilesets/"
local DATA_PATH = "assets/data/tilesets/"

function tileset:new(tileset)
	local path = tileset.image:split("/")
	local filePath = path[#path]

	self.image = love.graphics.newImage(ASSET_PATH..filePath)
	self.quads = {}
	self.firstgid = tileset.firstgid

	local jsonPath = DATA_PATH..(filePath:gsub(".png", ".json"))

	if love.filesystem.getInfo(jsonPath) then
		self.json = json.decode(love.filesystem.read(jsonPath))
	end

	local tw = tileset.tilewidth
	local th = tileset.tilewidth
	local w = self.image:getWidth()
	local h = self.image:getHeight()

	local rows = h/th

	for y = 1,rows do
		for x = 1,tileset.columns do
			self.quads[#self.quads+1] = love.graphics.newQuad((x-1)*tw, (y-1)*th, tw, th, self.image)
		end
	end
end

function tileset:getTile(i)
	return self.image, self.quads[i-self.firstgid+1], self.json.data[tostring(i-self.firstgid+1)]
end

return tileset