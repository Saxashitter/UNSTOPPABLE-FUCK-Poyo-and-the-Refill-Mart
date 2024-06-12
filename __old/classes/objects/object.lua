local function uhm(self,type)
	local collisions = {}
	local collided = false
	local state = states.getState(states.nextState)
	state.shash:each(self, function(obj)
		if self:colliding(obj) then
			table.insert(collisions, obj)
		end
	end)
	
	table.sort(collisions, function(a,b)
		return a.type > b.type
	end)
	
	for _,i in ipairs(collisions) do
		collided = true
		i:collision(self,type)
		self:collision(obj,type)
	end

	return collided
end

return class('Object', {
	preloaded = false,
	type = 2,
	type2 = "Object",
	width = 32,
	height = 32,
	angle = 0,
	lerpangle = 0,
	lerpangle_amount = 0.45,
	init = function(self, x, y)
		if self.preloaded then return end

		self.x = x
		self.y = y
		self.gravity = gravity

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
			lerpangle = false,
			passtiles = 0
		}

		self.dir = 1

		local state = states.getState(states.nextState)
		if state and state.shash then
			state.shash:add(self, self.x,self.y,self.width,self.height)
		end

		self.preloaded = true
	end,
	update = function(self, dt)
		if self.flags.noupdate then return end

		self:move(dt)
		self:changeDirection()

		if self.flags.lerpangle then
			self.angle = lume.smooth(self.angle, self.lerpangle, self.lerpangle_amount)
		end
	end,
	changeDirection = function(self)
		if self.momx > 0 then
			self.dir = 1
		elseif self.momx < 0 then
			self.dir = -1
		end
	end,
	move = function(self, dt)
		local mom = self.momx
		if math.abs(self.momy) > math.abs(self.momx) then
			mom = self.momy
		end
		local rate = math.floor(math.abs(mom)/8)+1
		local state = states.getState(states.nextState)

		for i = 1,rate do
			local multi = (dt/(1/60))/rate
			self.t_collisions = {}
			self.x = self.x + (self.momx*multi)
	
			if state and state.shash then
				state.shash:update(self, self.x,self.y,self.width,self.height)
			end
			uhm(self,false)
			self.wassloping = self.sloping
			self.sloping = nil
			if self.flags.grounded then
				state.shash:each(self.x,self.y+self.height,self.width,self.height,function(obj)
					if obj.type ~= 1 then return end
					if not obj:isSlope() then return end
					
					self.y = obj.y + obj:slope(self.x, self.width) - self.height
					self.sloping = obj
				end)
				if not self.sloping and self.wassloping then
					-- if groundy-(self.y+self.height) <= 40
					-- and groundy-(self.y+self.height) > 32 then
						self.y = self.wassloping.y+self.wassloping.height-self.height
					--end
				end
			end
	
			if not self.flags.nogravity and not self.sloping then
				self.momy = self.momy + (self.gravity*multi)
				self.flags.grounded = false
			end
			self.y = self.y + (self.momy*multi)
			if state and state.shash then
				state.shash:update(self, self.x,self.y,self.width,self.height)
			end
			uhm(self,true)
		end
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
	end
})