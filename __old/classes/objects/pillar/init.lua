return classes.Object:extend('Pillar', {
	type2 = "Pillar",
	width = 128,
	height = 224,
	init = function(self, x, y)
		self.super.init(self, x, y)
		
		self.animation = animations.init("classes/objects/pillar/animations/", "idle", 15)
	end,
	update = function(self, dt)
		if self.flags.noupdate then return end
		self.super.update(self, dt)
		
		self.animation:update(dt)
	end,
	draw = function(self)
		self.animation:draw(self.x, self.y)
	end,
	collision = function(self, obj, type)
		if not obj then return end
		if obj.type2 ~= "Player" then return end
		if obj.flags.passtiles == 2 then return end
		if not obj.flags.candamage then return end
		objhash:remove(self)
		functions.startEscapeSequence()
	end
})