local main = LuaObject:extend()

main.width  = 28
main.height = 50
main.type = "Main"

local max_step_time = 1/60

function main:new(x, y)
	self.x = x
	self.y = y
	self.grounded = false
	self._grounded = self.grounded
	self.momx = 0
	self.momy = 0
	self.scale = 1
	self.rot = 0
end

function main:updateGravity()
	local grav = self.world.gravity
	if self.momy < 0 then
		grav = grav/2
	end
	self.momy = self.momy + (self.world.gravity)
end

local function updateXPos(self, dt)
	dt = dt/(1/60)
	local momx = self.momx
	local x = self.x
	local momx_steps = math.ceil(math.max(1, (self.momx*dt)/8))
	local typeCollision
	for momxStep = 1,momx_steps do
		self.x = self.x + ((self.momx/momx_steps)*dt)

		if (self.momx < 0
		and self.x < x+(self.momx*dt))
		or (self.momx >= 0
		and self.x > x+(self.momx*dt)) then
			self.x = x+(self.momx*dt)
		end

		local collision = self.world:updateObject(self) -- collision check here
		if collision then
			self.momx = 0
			typeCollision = "left"
			if self._worldref.x < self.x then
				typeCollision = "right"
			end
			self.x = self._worldref.x
			break
		end
	end
	return typeCollision
end

local function updateYPos(self, dt)
	dt = dt/(1/60)
	local momy = self.momy
	local y = self.y
	local typeCollision
	local momy_steps = math.ceil(math.max(1, (self.momy*dt)/8))
	
	for momyStep = 1,momy_steps do
		self.y = self.y + ((self.momy/momy_steps)*dt)

		if (self.momy < 0
		and self.y < y+(self.momy*dt))
		or (self.momy >= 0
		and self.y > y+(self.momy*dt)) then
			self.y = y+(self.momy*dt)
		end

		local _,collision = self.world:updateObject(self) -- collision check here
		if collision then
			self.momy = 0
			typeCollision = "up"
			if self._worldref.y < self.y then
				typeCollision = "down"
				self.grounded = true
			end
			self.y = self._worldref.y
			break
		end
		local y = false
		for _,obj in pairs(self.world:getNearbyObjects(self)) do
			if obj.x <= self.x+self.width
			and self.x <= obj.x+obj.width then
				if obj.parent.script
				and obj.parent.script.isSlope then
					local sy = obj.parent.script.slope(obj.parent, self.x, self.width*self.scale)
					if y == false
					or sy < y then
						y = sy
					end
				end
			end
		end
		if y ~= false
		and (self.grounded or self._grounded)
		and y-(self.y+self.height) <= 8 then
			print(y-(self.y+self.height))
			self.y = y-self.height
			self.grounded = true
		end
	end
	return typeCollision
end

function main:updatePosition(dt)
	self._grounded = self.grounded
	self.grounded = false

	local coltypeX,coltypeY

	coltypeX = updateXPos(self, dt)
	coltypeY = updateYPos(self, dt)

	if coltypeX
	and self.collide then
		self:collide(coltypeX)
	end
	if coltypeY
	and self.collide then
		self:collide(coltypeY)
	end
end

function main:update(dt)
	self:updateGravity()
	self:updatePosition(dt)
end

function main:draw()
	return love.graphics.rectangle("fill", self.x, self.y, self.width*self.scale, self.height*self.scale)
end

return main