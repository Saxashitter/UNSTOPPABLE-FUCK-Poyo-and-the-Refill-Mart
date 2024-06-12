local player = require "src.objects.game.main":extend()

function player:new(x, y, character, num)
	self.super.new(self, x, y)
	self.script = script:require("characters."..character)
	if self.script.new then
		self.script.new(self)
	end
	self.num = (num or 0)+1
	self.dir = 1
end

local function getClampByMom(momx)
	if momx < 0 then
		return math.min
	end
	return math.max
end

local function canAccelerate(self, dir, maxspeed)
	return dir ~= 0
	and self.momx*dir < maxspeed
end

function player:defaultMovement(dir, accel, decel, maxspeed)
	local controls = self.controls

	if controls:check(self.num, "Run") then
		maxspeed = maxspeed * 2
	end

	if not canAccelerate(self, dir, maxspeed) then
		local dir = dir ~= 0 and dir or lume.sign(self.momx)
		self.momx = getClampByMom(self.momx)(self.momx - (decel*dir), 0)
		return
	end
	if (self.momx*dir)+accel > maxspeed then return end

	self.momx = self.momx + (accel*dir)
	if self.momx < 0 then
		self.momx = math.max(-maxspeed, self.momx)
	else
		self.momx = math.min(maxspeed, self.momx)
	end
end

function player:getDir()
	local controls = self.controls

	if controls:check(self.num, "Left") then
		return -1
	end
	if controls:check(self.num, "Right") then
		return 1
	end
	return 0
end

function player:update(dt)
	if self.script.update and self.script.update(self, dt) then
		if self.script.postUpdate then
			self.script.postUpdate(self, dt)
		end
		return
	end

	if not (self.script.postUpdate
	and self.script.postUpdate(self, dt)) then
		self.super.update(self, dt)
	end
end

function player:draw()
	if self.script.draw then
		self.script.draw(self)
	end
end

function player:updatePosition(step)
	self.super.updatePosition(self, step)
end

function player:collide(type)
	if type == "down" then
		self.grounded = true
	end
end

return player