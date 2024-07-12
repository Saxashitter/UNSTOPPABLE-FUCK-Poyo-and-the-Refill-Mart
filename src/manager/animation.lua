local animation = LuaObject:extend()

local ASSET_PATH = "assets/images/spritesets/"
 
function animation:new(path, startAnim)
	local data = love.filesystem.read(ASSET_PATH..path..".json")
	local anims = json.decode(data)
	
	self.image = love.graphics.newImage(ASSET_PATH..path..".png")
	self.anims = anims.anims
	for _,anim in pairs(self.anims) do
		for _,frame in pairs(anim.frames) do
			frame.quad = love.graphics.newQuad(frame.x, frame.y, frame.w, frame.h, self.image)
		end
	end

	self.curAnim = startAnim
	self.finished = false
	self._curAnim = self.anims[startAnim]
	-- helper so code doesnt become bs
	self.time = 0
	self.frame = 1
	self.speed = 1
end

function animation:update(dt)
	local fps = self._curAnim.fps or 1
	local loop = self._curAnim.loop or false
	local numFrames = #self._curAnim.frames
	self.time = self.time + (dt*self.speed)

	while self.time >= 1/fps do
		if self.frame < numFrames then
			self.frame = self.frame+1
		elseif loop then
			self.frame = 1
		else
			self.finished = true
		end
		self.time = self.time - 1/fps
	end
end

function animation:changeAnim(newAnim)
	self.curAnim = newAnim
	self._curAnim = self.anims[newAnim]
	self.time = 0
	self.frame = 1
	self.speed = 1
	self.finished = false
end

function animation:getFrame()
	local frame = self._curAnim.frames[self.frame]
	return self.image,frame.quad,frame.w,frame.h
end

return animation