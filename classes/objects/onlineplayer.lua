local function setStuff(self, data)
	if not data then return end
	self.x = data.x
	self.y = data.y
	self.momx = data.momx
	self.momy = data.momy
	self.animation.frame = data.frame
	self.animation.name = data.anim
end

return classes['Object']:extend('Online_Player', {
	type2 = "Online_Player",
	width = 32,
	height = 64,
	init = function(self, x, y, anim_path, data)
		self.super.init(self, x, y)
		
		self.animation = animations.init(anim_path)
		setStuff(data)
	end,
	update = function(self, data)
		setStuff(self, data)
	end,
	draw = function(self)
		local img = self.animation.frames[self.animation.curAnim][self.animation.frame].image
		local width = img:getWidth()
		local height = img:getHeight()
		self.animation:draw(self.x+(width/2), self.y+height, 0, self.dir, 1, width/2, height)
	
		--self.super.draw(self)
	end
})