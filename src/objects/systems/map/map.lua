local map = LuaObject:extend()
local layerClass = require "src.objects.systems.map.layer"
local tilesetClass = require "src.objects.systems.map.tileset"

local ASSET_PATH = "assets/maps/"

function map:new(path)
	local map = require(ASSET_PATH..path)

	self.width = map.width
	self.height = map.height
	self.tWidth = map.tilewidth
	self.tHeight = map.tileheight
	self.tilesets = {}
	self.layers = {}

	for i = 1,#map.tilesets do
		local tileset = map.tilesets[i]

		self.tilesets[i] = tilesetClass(tileset)
	end
	for i = 1,#map.layers do
		local layer = map.layers[i]

		self.layers[i] = layerClass(layer, self)
	end
end

function map:defineCollisions(world, camera)
	for _,layer in ipairs(self.layers) do
		if layer.type == "tilelayer" then
			for x,_ in pairs(layer.data) do
				for y,t in pairs(_) do
					world:addToWorld(t, {solid = true, dontAdd = true})
					t.camera = camera
				end
			end
		end
	end
end

function map:draw()
	for _,layer in ipairs(self.layers) do
		layer:draw()
	end
end

return map