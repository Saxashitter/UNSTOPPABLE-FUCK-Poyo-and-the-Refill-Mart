local state = {}

local function launchKnife(self)
	local x = self.x+(self.width/2)
	local y = self.y+(self.height/2)
	local knife = self:spawnKnife(x+((self.width/2)*self.dir), y)
	local angle = lume.angle(0,0,self.dir,0)


	knife.momx = 6*math.cos(angle)
	knife.momy = 6*math.sin(angle)
end

function state:enter()
	self.anim:changeAnim("attack1")
	self.time = 0.1
	launchKnife(self)
	self.knivesthrown = (self.knivesthrown or 0)+1
end

function state:update(dt)
	if self.anim.finished then
		self.anim:changeAnim("idle")
	end
	if self.anim.curAnim == "idle" then
		self.time = self.time - dt
		if self.time <= 0 then
			if self.knivesthrown >= 20 then
				return "base"
			end
			state.enter(self)
		end
	end
end

function state:exit()
	self.knivesthrown = nil
end

return state