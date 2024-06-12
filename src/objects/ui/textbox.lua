local textbox = require "src.objects.ui.button":extend()

local utf8 = require("utf8")

function textbox:new(...)
	local args = {...}
	self.super.new(self, ...)

	self.keepTextOnEnd = args[6] or false

	self.active = false
end

local function isInButton(self, x, y)
	return (x >= self.x and x <= self.x+self.width)
	and (y >= self.y and y <= self.y+self.height)
end

function textbox:update(dt)
	local touches = love.touch.getTouches()
	local isClicked = 0

	for _,touch in pairs(touches) do
		local x,y = love.touch.getPosition(touch)
		x,y = rs.to_game(x,y)
		if isInButton(self, x,y) then
			isClicked = 2
		else
			isClicked = 1
			break
		end
	end

	if isClicked == 2
	and not self.active then
		self.active = true
		love.keyboard.setTextInput(true)
	end
	if isClicked == 1
	and self.active then
		self.active = false
		if self.onAbruptEnd then
			self:onAbruptEnd(self.text)
		end
		love.keyboard.setTextInput(false)
	end
end

function textbox:textinput(t)
	if self.active then
		self.text = self.text..t
	end
end

function textbox:keypressed(key)
	if not self.active then return end
	if key == "backspace" then
		local byteoffset = utf8.offset(self.text, -1)

        if byteoffset then
			self.text = string.sub(self.text, 1, byteoffset - 1)
        end
        return
	end
	if key == "return" then
		love.keyboard.setTextInput(false)
		if self.onEnd then
			self:onEnd(self.text)
		end
		if not self.keepTextOnEnd then
			self.text = ""
		end
		self.active = false
		return
	end
end

return textbox