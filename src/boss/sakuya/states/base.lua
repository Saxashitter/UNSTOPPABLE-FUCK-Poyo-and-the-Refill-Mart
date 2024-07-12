local state = {}

function state:enter()
	self.anim:changeAnim("idle")
	self.time = 5
end

function state:update(dt)
	self.time = self.time - dt

	if self.time <= 0 then
		return "attack"
	end
end

function state:exit()
	self.time = nil
end

return state