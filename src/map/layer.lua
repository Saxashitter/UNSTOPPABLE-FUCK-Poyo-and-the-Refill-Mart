local layer = LuaObject:extend()

local tileClass = require "src.map.tile"

local function getBlock(self, x, y)
	if not self.data[y] then
		return false
	end
	return self.data[y][x] or false
end

local function _defineTileLayer(self, layer)
	self.x = layer.x+layer.offsetx
	self.y = layer.y+layer.offsety
	self.width = layer.width
	self.height = layer.height
	self.canvas = love.graphics.newCanvas(layer.width*self.map.tWidth, layer.height*self.map.tHeight)
	self.data = {}
	self.block_data = {}

	-- organize data to the data table
	for i,v in pairs(layer.data) do
		if v ~= 0 then
			local x = (i-1) % self.width
			local y = math.max(1, math.ceil(i/self.width))-1
	
			if not self.data[y] then
				self.data[y] = {}
			end
			self.data[y][x] = tileClass(self, x, y, v)
			
		end
	end

	local _canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)

	-- reiterate to get tiles, sort them and run their attached scripts
	for y,_ in pairs(self.data) do
		for x,t in pairs(_) do
			local leftTile = getBlock(self, x-1, y)
			local topTile = getBlock(self, x, y-1)
			local rightTile = getBlock(self, x+1, y)
			local bottomTile = getBlock(self, x, y+1)

			t.leftTile = leftTile
			t.topTile = topTile
			t.rightTile = rightTile
			t.bottomTile = bottomTile
			if t.script
			and t.script.afterTileLink then
				t.script.afterTileLink(t)
			end
			
			t:draw()
		end
	end

	love.graphics.setCanvas(_canvas)
end

local function _defineBlockGroup(self, layer)
	for i,v in pairs(layer.objects) do
		local func = require("src.map.spawntypes."..v.name)

		func(self, v)
	end
end

local typeDef = {
	tilelayer = _defineTileLayer,
	objectgroup = _defineBlockGroup
}

function layer:new(layer, map)
	self.map = map
	self.type = layer.type

	typeDef[layer.type](self, layer)
end

function layer:draw()
	if self.type ~= "tilelayer" then return end

	love.graphics.draw(self.canvas, self.x, self.y)
end

return layer