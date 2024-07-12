local knife = require("src.game.main"):extend()

knife.width = 16
knife.height = 16

function knife:new(x, y, img, quad, _w, _h)
	self.super.new(self, x, y)

	self.img = img
	self.quad = quad
	self._w = _w
	self._h = _h
	self.nogravity = true
end

function knife:draw()
	local angle = lume.angle(0,0,self.momx,self.momy) - math.atan2(90, 0)
	love.graphics.draw(self.img, self.quad, self.x+(self.width/2), self.y+(self.height/2), angle, nil,nil, self._w/2,self._h/2)
	self.super.draw(self)
end

return knife