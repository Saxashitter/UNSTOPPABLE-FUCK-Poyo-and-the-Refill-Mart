local Poyo = {}

-- DON'T BE FOOLED!
-- When the functions are ran, it doesn't lead to player.character, but instead the player itself!
-- Reason is hard to explain, but meh.

local funcs = {}

function funcs:init(x, y)
	self.name = "Poyo"
	self.fsm = require("characters.Poyo.fsm")
	self.animation = animations.init("characters/Poyo/animations/", "idle", 15, self)

	self.flags.jumped = false
	self.flags.jumpheld = false

	self.acceleration = 0.3
	self.deceleration = 0.6

	self.weapons = {
		bat = {
			use = "bat"
		}
	}

	self.fsm:changeState(self, "base")
	objhash:update(self, self.x,self.y,self.width,self.height)
end

function funcs:update(dt)
	self.fsm.curState:update(self, dt)
	self.animation:update(dt, self)

	self.super.update(self, dt)
end

function funcs:draw()
	local img = self.animation.frames[self.animation.curAnim][self.animation.frame].image
	local width = img:getWidth()
	local height = img:getHeight()
	self.animation:draw(self.x+(self.width/2), self.y+self.height, 0, self.dir, 1, width/2, height)

	self.super.draw(self)
end

function funcs:jump(player, height)
	if player.flags.grounded and controls:isJustPressed('Jump') then
		player.flags.jumped = true
		player.flags.jumpheld = true
		player.flags.grounded = false
		player.momy = -height
		functions.startSound('jump')
	end
end

function funcs:collision(obj, type)
	if self.fsm.curState.collision then
		self.fsm.curState:collision(self, obj, type)
	end
end

function funcs:tileCollision(type)
	if self.fsm.curState.tileCollision then
		self.fsm.curState:tileCollision(self, type)
	end
end

local function load()
	local poyo = {}
	
	for _,func in pairs(funcs) do
		poyo[_] = func
	end
	
	return poyo
end

return load()