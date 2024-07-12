local world = LuaObject:extend()

world.gravity = 0.5

local function isColliding(obj, obj2)
	if obj2.parent.script
	and obj2.parent.script.isColliding then
		return obj2.parent.script.isColliding(obj2, obj)
	end

	return (obj.x < obj2.x+(obj2.width*obj2.scale)
	and obj2.x < obj.x+(obj.width*obj.scale)
	and obj.y < obj2.y+(obj2.height*obj2.scale)
	and obj2.y < obj.y+(obj.height*obj.scale))
end

local function setPositionInWorld(self, obj, type)
	if not obj._worldref then return end

	if type == "x" then
		obj._worldref.x = obj.x
	elseif type == "y" then
		obj._worldref.y = obj.y
	end

	self._shash:update(obj._worldref,
		obj._worldref.x,
		obj._worldref.y,
		obj._worldref.width*obj._worldref.scale,
		obj._worldref.height*obj._worldref.scale
	)
end

local function getCell(self, cx, cy)
	return self.cells[cy] and self.cells[cy][cx] or {}
end

function world:getNearbyObjects(obj)
	local cx = obj._worldref.cellX
	local cy = obj._worldref.cellY

	local cells = {}
	local objects = {}

	table.insert(cells, getCell(self, cx, cy))

	table.insert(cells, getCell(self, cx-1, cy))
	table.insert(cells, getCell(self, cx+1, cy))
	table.insert(cells, getCell(self, cx, cy-1))
	table.insert(cells, getCell(self, cx, cy+1))

	table.insert(cells, getCell(self, cx-1, cy-1))
	table.insert(cells, getCell(self, cx+1, cy-1))
	table.insert(cells, getCell(self, cx-1, cy+1))
	table.insert(cells, getCell(self, cx+1, cy+1))

	for _,cell in ipairs(cells) do
		for _obj,_ in pairs(cell) do
			if _obj ~= obj then
				table.insert(objects, _obj._worldref)
			end
		end
	end

	return objects
end

function world:new(addFunction, size)
	self._shash = shash.new(size)
	self._add = addFunction
	self.objects = {}
	self.cells = {}
end

function world:addToWorld(object, properties)
	if not self._add then return end

	self.objects[(#self.objects or 0)+1] = {
		x = object.x,
		y = object.y,
		width = object.width,
		height = object.height,
		scale = object.scale,
		properties = properties or {},
		parent = object
	}
	object.world = self
	object._worldref = self.objects[#self.objects]
	self._shash:add(object._worldref,
		object._worldref.x,
		object._worldref.y,
		object._worldref.width*object._worldref.scale,
		object._worldref.height*object._worldref.scale
	)
	if not object._worldref.properties.dontAdd then
		self._add(object)
	end
end

local function getmp(obj)
	return {
		x = obj.x+((obj.width*obj.scale)/2),
		y = obj.y+((obj.height*obj.scale)/2)
	}
end

function world:resolveCollision(obj1, obj2, type)
	local obj1_mp = getmp(obj1)
	local obj2_mp = getmp(obj2)

	local scriptCollide = obj2.parent
	and obj2.parent.script
	and obj2.parent.script.onColResolve
	and obj2.parent.script.onColResolve(obj2.parent, obj1.parent, type)

	if scriptCollide == 2 then
		return false
	end
	if scriptCollide == 1 then
		return true
	end
	if obj2.properties.solid then
		if type == "x" then
			print( ("obj1: %d, %d - obj2: %d, %d"):format(obj1_mp.x, obj1_mp.y, obj2_mp.x, obj2_mp.y))
			if obj1_mp.x >= obj2_mp.x then
				obj1.x = obj2.x+(obj2.width*obj2.scale)
				self._shash:update(obj1, obj2.x+(obj2.width*obj2.scale), obj1.y)
			else
				obj1.x = obj2.x-(obj1.width*obj1.scale)
				self._shash:update(obj1, obj1.x, obj2.x-(obj1.width*obj1.scale), obj1.y)
			end
		end
		if type == "y" then
			if obj1_mp.y >= obj2_mp.y then
				obj1.y = obj2.y+(obj2.height*obj2.scale)
				self._shash:update(obj1, obj1.x, obj2.y+(obj2.height*obj2.scale))
			else
				obj1.y = obj2.y-(obj1.height*obj1.scale)
				self._shash:update(obj1, obj1.x, obj2.y-(obj1.height*obj1.scale))
			end
		end
		return true
	end
	return false
end

function world:updateObject(object)
	-- first we step x and resolve the x collision, then step y and check for y collisions

	local worldobj = object._worldref
	local hasResolvedX = false
	local hasResolvedY = false
	if not worldobj then return end

	worldobj.width = object.width
	worldobj.height = object.height
	worldobj.scale = object.scale

	setPositionInWorld(self, object, "x")
	self._shash:each(worldobj, function(wobj)
		if isColliding(worldobj, wobj)
		and self:resolveCollision(worldobj, wobj, "x") then
			hasResolvedX = true
		end
	end)
	setPositionInWorld(self, object, "y")
	self._shash:each(worldobj, function(wobj)
		if isColliding(worldobj, wobj)
		and self:resolveCollision(worldobj, wobj, "y") then
			hasResolvedY = true
		end
	end)

	return hasResolvedX,hasResolvedY
end

return world