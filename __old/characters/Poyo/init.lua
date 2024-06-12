local path = {...}
path = path[1]

local Poyo = {}

-- DON'T BE FOOLED!
-- When the functions are ran, it doesn't lead to player.character, but instead the player itself!
-- Reason is hard to explain, but meh.

local funcs = {}

local function changeDir(self, bool)
	if not (self.flags.canchangedir or bool ~= nil) then return end
	
	if bool == nil then
		bool = self.flags.grounded
	end

	if bool then
		if self.momx > 0 then
			self.dir = 1
		elseif self.momx < 0 then
			self.dir = -1
		end
	else
		if controls:isPressed('Left') then
			self.dir = -1
		elseif controls:isPressed('Right') then
			self.dir = 1
		end
	end
end

function funcs:init(x, y)
	self.name = "Poyo"
	self.fsm = require(path..".fsm")
	self.animation = animations.init(path:replace(".", "/").."/animations/", "idle", 15, self)

	self.flags.jumpheld = false
	self.flags.canchangedir = true
	self.flags.lerpangle = true

	self.acceleration = 0.3
	self.deceleration = 0.45

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

	self:fsm("base")
	local state = states.getState(states.nextState)
	if state and state.shash then
		state.shash:update(self, self.x,self.y,self.width,self.height)
	end
end

function funcs:update(dt)
	self.fsm:update(self, dt)
	self.animation:update(dt, self)
	local state = states.getState()

	local angle = 0
	if self.map then
		local block = self.map:raycast(self.x+(self.width/2), self.y, 0, 1, self.height*2)
		if block then
			block = block[1]
		end
		if self.flags.grounded 
		and block
		and block:isSlope() then
			print "Slope"
			angle = lume.angle(block.x,
				block.y+block.y1,
				block.x+block.width,
				block.y+block.y2
			)
		end
	end

	self.lerpangle = angle

	self.super.update(self, dt)
end

function funcs:draw()
	local img = self.animation.frames[self.animation.curAnim][self.animation.frame].image
	local width = img:getWidth()/2
	local height = img:getHeight()
	
	local pos_width = (self.width/2)+(20*(-math.sin(self.angle)))
	local pos_height = self.height+1
	
	self.animation:draw(self.x+pos_width, self.y+pos_height, self.angle, self.dir, 1, width, height)

	self.super.draw(self)
end

function funcs:collision(obj, type)
	if self.fsm.collision then
		self.fsm:collision(self, obj, type)
	end
end

function funcs:tileCollision(type, obj)
	if self.fsm.tileCollision then
		return self.fsm:tileCollision(self, type, obj)
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