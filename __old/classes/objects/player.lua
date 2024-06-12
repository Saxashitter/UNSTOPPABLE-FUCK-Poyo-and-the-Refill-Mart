return classes['Object']:extend('Player', {
	type2 = "Player",
	width = 28,
	height = 50,
	init = function(self, x, y, char)
		local x = x or 0
		local y = y or 0

		self.camx = 0
		self.camy = 0

		self.super.init(self, x, y)
		self.flags.canmove = false
		
		self.char_path = "characters/"..char
		if not love.filesystem.getInfo("characters/"..char) then
			love.filesystem.mount("characters/"..char..".char", "characters/"..char)
			self.char_path = self.char_path..".char"
		end
		
		self.character = require("characters."..char)
		self.character.init(self, x, y)
	end,
	update = function(self, dt)
		self.character.update(self, dt)
	end,
	draw = function(self)
		self.character.draw(self)
	end,
	collision = function(self,obj,type)
		if self.character.collision then
			self.character.collision(self, obj, type)
		end
	end,
	tileCollision = function(self,type,obj)
		self.super.tileCollision(self,type,obj)
		if self.character.tileCollision then
			return self.character.tileCollision(self, type, obj)
		end
	end
})