local tile = LuaObject:extend()

local DATA_PATH = "assets/data/"

function tile:new(layer, x, y, tile)
	local map = layer.map
	self.x = x*map.tWidth
	self.y = y*map.tHeight
	self.width = map.tWidth
	self.height = map.tHeight
	self.scale = 1

	for i = 1,#map.tilesets do
		local tileset = map.tilesets[i]
		local image,quad,data = tileset:getTile(tile)

		if image then
			self.image = image
			self.quad = quad
			if data then
				self.json = data
				if self.json.script then
					self.script = script:require(self.json.script)
				end
			end
			break
		end
	end
end

function tile:draw()
	return love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return tile