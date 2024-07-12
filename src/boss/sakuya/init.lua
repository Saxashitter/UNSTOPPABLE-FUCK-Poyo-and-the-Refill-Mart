local path = (...)
local animationClass = require "src.manager.animation"

local sakuya = require("src.game.main"):extend()

local knifeClass = require(path..".subclass.knife")

local states = {
	["base"] = require(path..".states.base");
	["attack"] = require(path..".states.attack");
}

local function _changeState(self, state)
	if self.state
	and self.state.exit then
		self.state.exit(self)
	end

	self.state = states[state]
	if self.state.enter then
		self.state.enter(self)
	end
end

function sakuya:new(x, y)
	self.super.new(self, x,y)
	self.anim = animationClass("bosses/sakuya", "idle")
	self.knives = {}
	self.dir = -1
	_changeState(self, "base")
end

function sakuya:spawnKnife(x,y)
	local entities = USFM.curState.entities
	local frame = self.anim.anims['knife'].frames[1]
	local knife = knifeClass(x,y,self.anim.image,frame.quad,frame.w,frame.h)
	table.insert(entities, knife)

	return knife
end

local function _iterate(t, dt)
	for _,k in pairs(t) do
		k:update(dt)
	end
end

function sakuya:update(dt)
	local ns = self.state.update(self, dt)
	if ns then
		_changeState(self, ns)
	end
	_iterate(self.knives, dt)
	self.anim:update(dt)
end

function sakuya:draw()
	local img, quad, w, h = self.anim:getFrame()
	love.graphics.draw(img, quad, self.x+(self.width/2), self.y+self.height, 0, self.dir*self.scale, 1, w/2, h-2)

	for _,k in pairs(self.knives) do
		k:draw()
	end

	self.super.draw(self)
end

return sakuya