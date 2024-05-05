local Poyo = {}

-- DON'T BE FOOLED!
-- When the functions are ran, it doesn't lead to player.character, but instead the player itself!
-- Reason is hard to explain, but meh.

local funcs = {}

local function changeDir(self)
	if not controls:isPressed('Left')
	and not controls:isPressed('Right') then
		return false
	end

	if self.momx > 0 then
		self.dir = 1
	elseif self.momx < 0 then
		self.dir = -1
	end
end

function funcs:init(x, y)
	self.name = "Poyo"
	self.fsm = require("characters.Poyo.fsm")
	self.animation = animations.init("characters/Poyo/animations/", "idle", 15, self)

	self.flags.jumpheld = false

	self.acceleration = 0.3
	self.deceleration = 0.6

	self.changeDirection = changeDir

	self.weapons = {
		bat = {
			use = "bat"
		}
	}

	self.sounds = {
		bat_wall = love.audio.newSource("assets/sounds/bat_wall.wav", "static"),
		run_start = love.audio.newSource("assets/sounds/run_start.wav", "static"),
		jump = love.audio.newSource("assets/sounds/jump.wav", "static"),

		voice_start = love.audio.newSource("assets/sounds/voice_start.wav", "static"),

		step1 = love.audio.newSource("assets/sounds/step1.wav", "static"),
		step2 = love.audio.newSource("assets/sounds/step2.wav", "static"),
		step3 = love.audio.newSource("assets/sounds/step3.wav", "static"),
		step4 = love.audio.newSource("assets/sounds/step4.wav", "static"),
		step5 = love.audio.newSource("assets/sounds/step5.wav", "static"),
		step6 = love.audio.newSource("assets/sounds/step6.wav", "static"),
		step7 = love.audio.newSource("assets/sounds/step7.wav", "static"),
		step8 = love.audio.newSource("assets/sounds/step8.wav", "static")
	}
	self.sounds.voice_start:setVolume(.45)

	self.fsm:changeState(self, "base")
	local state = states.getState(states.nextState)
	if state and state.shash then
		state.shash:update(self, self.x,self.y,self.width,self.height)
	end
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
		player.flags.jumpheld = true
		player.flags.grounded = false
		player.momy = -height
		player.sounds.jump:play()
	end
end

function funcs:collision(obj, type)
	if self.fsm.curState.collision then
		self.fsm.curState:collision(self, obj, type)
	end
end

function funcs:tileCollision(type, obj)
	if self.fsm.curState.tileCollision then
		return self.fsm.curState:tileCollision(self, type, obj)
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