local animationClass = require "src.manager.animation"

local player = require "src.game.main":extend()

-- you may be wondering why theres 2 player classes
-- well my bro
-- thats because its a different engine

-- unlike the platformer engine, this restricts your movement heavily and gives you health
-- it also removes custom character support sadly
-- :(

function player:new(x, y, character, num)
	self.super.new(self, x, y)
	self.num = (num or 0)+1
	self.dir = 1
	self.grounded = false
	self.jumped = false
	self.dashCooldown = 0
	self.health = 1
	self.hitCooldown = 0
	self.anim = animationClass("characters/"..character, "idle")
end

function player:canDamage()
	return math.abs(self.momx) > 5 or not self.grounded
end

function player:canBeDamaged()
	return self.hitCooldown == 0
end

function player:update(dt)
	local dir = 0
	if self.controls:check(self.num, "Left") then
		dir = -1
	elseif self.controls:check(self.num, "Right") then
		dir = 1
	end

	if dir ~= 0 then
		local clmp = math.max
		if dir < 0 then
			clmp = math.min
		end
		self.momx = clmp(4*dir, self.momx-(0.05*dir))
	else
		self.momx = 0
	end
	self.dir = dir ~= 0 and dir or self.dir

	if self.grounded
	and self.controls:check(self.num, "Jump", "pressed") then
		self.jumped = true
		self.grounded = false
		self.momy = -10
	end

	if self.jumped
	and (not self.controls:check(self.num, "Jump") or self.grounded) then
		if self.momy < 0 then
			self.momy = self.momy*0.6
		end
		self.jumped = false
	end

	if self.dashCooldown > 0 then
		self.dashCooldown = math.max(self.dashCooldown - dt, 0)
	end

	if self.dashCooldown == 0
	and self.controls:check(self.num, "Run", "pressed") then
		self.momx = 7*dir
		self.dashCooldown = 2
	end

	self.super.update(self, dt)

	-- ANIM TIME
	local anim = "idle"
	if self.grounded
	and self.momx ~= 0 then
		if math.abs(self.momx) >= 5 then
			anim = "run"
		else
			anim = "walk"
		end
	elseif not self.grounded then
		anim = "fall"
	end
	if self.anim.curAnim ~= anim then
		self.anim:changeAnim(anim)
	end
	self.anim:update(dt)
end

function player:draw()
	local img, quad, w, h = self.anim:getFrame()
	love.graphics.draw(img, quad, self.x+(self.width/2), self.y+self.height, 0, self.dir*self.scale, 1, w/2, h-2)

	self.super.draw(self)
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