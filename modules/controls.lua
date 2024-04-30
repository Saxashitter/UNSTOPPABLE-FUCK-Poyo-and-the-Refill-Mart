local controls = {}
local keys = {}

local function do_press(table, dt)
	if not table.pressed then
		table.justpressed = true
		table.time = 0
	else
		table.justpressed = false
		table.time = table.time + dt
	end

	table.pressed = true
end

local function do_release(table, dt)
	if table.pressed then
		table.released = true
		table.justpressed = false
		table.time = 0
	else
		table.released = false
		table.time = table.time + dt
	end

	table.pressed = false
end

function controls:addKey(table)
	if mobile and table.mobile and table.mobile.image then
		table.mobile.image = love.graphics.newImage(table.mobile.image)
	end

	table.justpressed = false
	table.pressed = false
	table.released = false
	table.time = 0

	keys[table.name] = table
end

function controls:init(...)
	--[[
	LAYOUT:
	{
		name = "Control Name",
		keyboard = ...,
		mobile = {
			key = ...,
			image = ...,
			x = ...,
			y = ...,
			width = ...,
			height = ...
		},
		gamepad = ...
	}]]

	local args = {...}

	for _,i in ipairs(args) do
		self:addKey(i)
	end
	lovepad:setGamePad(nil, nil, true, true)
end

function controls:update(dt)
	lovepad:update()
	for _,key in pairs(keys) do
		local pressed = false

		if love.keyboard.isDown(key.keyboard) then
			pressed = true
		end
		if lovepad:isDown(key.mobile or key.name) then
			pressed = true
		end
		
		if not pressed then
			do_release(key, dt)
		else
			do_press(key, dt)
		end
	end
end

function controls:isPressed(key)
	return keys[key].pressed
end
function controls:isJustPressed(key)
	return keys[key].justpressed
end
function controls:isReleased(key)
	return keys[key].released
end

function controls:draw()
	if not mobile then return end
	
	lovepad:draw()
end

return controls