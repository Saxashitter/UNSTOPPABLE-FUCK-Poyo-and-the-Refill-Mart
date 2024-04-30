local animations = {}

local function split_string (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t={}

	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end

	return t
end

local function addAnimation(self, path)
	local shit = split_string(path, '/')

	for _,file in ipairs(love.filesystem.getDirectoryItems(path)) do
		if file:endswith('.png') then
			if not self.frames then self.frames = {} end
			if not self.frames[shit[#shit]] then
				self.frames[shit[#shit]] = {}
				if love.filesystem.exists(path.."data.lua") then
					local erm = path.."data.lua"
					erm = erm:gsub('.lua', '')
					erm = erm:gsub('/', '.')
					
					local data = require(erm)
					
					for _,i in pairs(data) do
						self.frames[shit[#shit]][_] = i
					end
				end
			end
			
			local data = {
				image = love.graphics.newImage(path..file)
			}
			table.insert(self.frames[shit[#shit]], data)
		end
	end
end

local function update(self, dt)
	self.time = self.time + (dt*self.speed)

	while self.time > self.framerate do
		self.frame = self.frame + 1
		if self.frame > #self.frames[self.curAnim] then
			if self.loop then
				self.frame = 1
			else
				self.frame = #self.frames[self.curAnim]
			end
		end
		if self.frames[self.curAnim].onFrameChange then
			self.frames[self.curAnim].onFrameChange(self.frame, self.parent)
		end
		self.time = self.time - self.framerate
	end
end

local function draw(self, x, y, r, sx, sy, ox, oy)
	r = r or 0
	ox = ox or 0
	oy = oy or 0
	sx = sx or 1
	sy = sy or 1
	
	if self.frames[self.curAnim].offsets then
		ox = ox+(self.frames[self.curAnim].offsets.x*sx)
		oy = oy+(self.frames[self.curAnim].offsets.y*sy)
	end
	return love.graphics.draw(self.frames[self.curAnim][self.frame].image, x,y,r,sx,sy,ox,oy)
end

local function changeAnim(self, animation, framerate, loop, obj)
	if not self.frames[animation] then return end
	self.curAnim = animation
	self.frame = 1
	self.time = 0
	self.loop = loop
	if self.loop == nil then self.loop = true end
	self.framerate = 1/framerate
	
	if self.frames[self.curAnim].onStart then
		self.frames[self.curAnim].onStart(self.parent)
	end
	if self.frames[self.curAnim].onFrameChange then
		self.frames[self.curAnim].onFrameChange(self.frame, self.parent)
	end
end

function animations.init(path, animation, framerate, obj)
	local self = {}
	self.path = path
	for _,file in ipairs(love.filesystem.getDirectoryItems(path)) do
		local info = love.filesystem.getInfo(path..file)
		
		if info.type == "directory" then
			addAnimation(self, path..file.."/")
		end
	end

	self.framerate = 1/framerate
	self.frame = 1
	self.speed = 1
	self.time = 0
	self.loop = true
	self.curAnim = animation
	
	self.update = update
	self.draw = draw
	self.changeAnim = changeAnim
	self.parent = obj
	
	if self.frames[self.curAnim].onStart then
		self.frames[self.curAnim].onStart(self.parent)
	end
	if self.frames[self.curAnim].onFrameChange then
		self.frames[self.curAnim].onFrameChange(self.frame, self.parent)
	end
	
	return self
end


return animations