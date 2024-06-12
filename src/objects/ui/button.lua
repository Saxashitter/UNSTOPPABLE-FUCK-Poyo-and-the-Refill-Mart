local button = LuaObject:extend()

function button:new(x, y, width, height, text)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.text = text
	self.pressed = false
end

function button:getFixedXY(x, y)
	local width,height = love.graphics.getDimensions()
	local gWidth,gHeight = resolution_solution.game_width,resolution_solution.game_height
	local gx = rs.game_zone.x
	local gy = rs.game_zone.y
	local scaleX = gWidth/width
	local scaleY = gHeight/height

	return x,y
end

local function isInButton(self, x, y)
	local _x,_y = self.x,self.y
	return (x >= _x and x <= _x+self.width)
	and (y >= _y and y <= _y+self.height)
end

function buton:isClicked()
	local isClicked = false
	for _,touch in pairs(touches) do
		local x,y = love.touch.getPosition(touch)
		x,y = rs.to_game(x,y)
		if isInButton(self, x,y) then
			isClicked = true
		end
	end
	if love.mouse.isDown(1) then
		local x,y = love.mouse.getPosition()
		x,y = rs.to_game(x,y)
		if isInButton(self, x,y) then
			isClicked = true
		end
	end

	return isClicked
end

function button:update(dt)
	local touches = love.touch.getTouches()
	local isClicked = self:isClicked()

	self.wasPressed = self.pressed
	self.pressed = isClicked
	if self.pressed
	and not self.wasPressed
	and self.onPress then
		self:onPress()
	end
end

function button:drawTextInBox(x, y, width, height, text)
	local font = love.graphics.getFont()
	local drawY = y+(height/2)-(font:getHeight(text)/2)

	love.graphics.printf(text, x, drawY, width, "center")
end

function button:draw()
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	button:drawTextInBox(self.x, self.y, self.width, self.height, self.text)
end

return button