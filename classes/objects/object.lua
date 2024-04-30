local function uhm(self,type)
	local collisions = {}
	objhash:each(self, function(obj)
		if self:colliding(obj) then
			table.insert(collisions, obj)
		end
	end)
	
	table.sort(collisions, function(a,b)
		return a.type > b.type
	end)
	
	for _,i in ipairs(collisions) do
		i:collision(self,type)
		self:collision(obj,type)
	end
end

return class('Object', {
	preloaded = false,
	type = 2,
	type2 = "Object",
	width = 32,
	height = 32,
	init = function(self, x, y)
		if self.preloaded then return end

		self.x = x
		self.y = y
		self.prevx = prevx
		self.prevy = prevy

		self.momx = 0
		self.momy = 0

		self.scale = 1
		self.flip = 1

		self.flags = {
			noupdate = false,
			nogravity = false,
			visible = true,
			grounded = false,
			candamage = false,
			passtiles = 0
		}

		self.dir = 1

		objhash:add(self, self.x,self.y,self.width,self.height)
		
		if not objects[self.type] then objects[self.type] = {} end
		if not objects[self.type][self.type2] then objects[self.type][self.type2] = {} end
		table.insert(objects[self.type][self.type2], self)
		self.parent_index = #objects[self.type][self.type2]
		self.parent = objects[self.type][self.type2]
		
		self.preloaded = true
	end,
	update = function(self, dt)
		if self.flags.noupdate then return end
		
		self.t_collisions = {}
		
		self.prevx = 0
		self.prevy = 0

		--local multi = dt/(1/60)
		local multi = dt/(1/60)

		self.x = self.x + (self.momx*multi)
		if self.momx > 0 then
			self.dir = 1
		elseif self.momx < 0 then
			self.dir = -1
		end
		objhash:update(self, self.x,self.y,self.width,self.height)
		uhm(self,false)

		local groundy = 0
		self.wassloping = self.sloping
		self.sloping = false
		if self.flags.grounded then
			objhash:each(self.x,self.y+self.height,self.width,self.height,function(obj)
				if obj.type ~= 1 then return end
				if obj.y1 == nil then
					if obj.y > groundy then
						groundy = obj.y
					end
					return
				end
				
				self.y = obj.y + obj:slope(self.x, self.width) - self.height
				self.sloping = true
			end)
			if not self.sloping and self.wassloping then
				-- if groundy-(self.y+self.height) <= 40
				-- and groundy-(self.y+self.height) > 32 then
					self.y = groundy-self.height
				--end
			end
		end

		if not self.flags.nogravity and not self.sloping then
			self.momy = self.momy + (gravity*multi)
			self.flags.grounded = false
		end

		self.momy = math.max(-gravity*(32*4), math.min(self.momy, gravity*(32*4)))
		self.y = self.y + (self.momy*multi)
		objhash:update(self, self.x,self.y,self.width,self.height)
		uhm(self,true)
	end,
	collision = function(self, obj, type)
	end,
	tileCollision = function(self, type)
		if type == "bottom" then
			self.momy = 0
			self.flags.grounded = true
		end
	end,
	colliding = function(self, obj)
		return self.x < obj.x+obj.width
		and obj.x < self.x+self.width
		and self.y < obj.y+obj.height
		and obj.y < self.y+self.height
	end,
	draw = function(self, dt)
		if not self.flags.visible then return end
		love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
	end,
	remove_from_hash = function(self)
		objhash:remove(self)
	end,
	kill = function(self)
		self.parent[self.parent_index] = nil
	end
})