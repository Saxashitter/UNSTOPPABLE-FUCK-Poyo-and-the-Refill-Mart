local controls = LuaObject:extend()
-- houston we got a problem
-- idk why lovepad is true
local lovepad = type(lovepad) == "table" and lovepad or nil

--[[
format: {
	name = "Control Name" -- will be used to check for presses or shit
	keys = {
		{player1keys},
		{player2keys},
		...
	},
	mobile = "Key name on Lovepad."
}
]]--

function controls:new(controls)
	self.inputs = {}
	self._keys = {}
	if lovepad then
		lovepad:setGamePad(nil, nil, true, true)
	end

	for _,tbl in ipairs(controls) do
		self.inputs[tbl.name] = {keys = {}}

		for playernum,keys in ipairs(tbl.keys) do
			self.inputs[tbl.name].keys[playernum] = keys
		end
		self.inputs[tbl.name].mobile = tbl.mobile
	end
end

function controls:keypressed(key)
	self._keys[key] = 2
end
function controls:keyreleased(key)
	self._keys[key] = nil
end

function controls:update(dt)
	for _,i in pairs(self._keys) do
		self._keys[_] = math.max(0, self._keys[_] - 1)
	end
	if lovepad then
		lovepad:update(dt)
	end
end

function controls:draw()
	if lovepad then
		lovepad:draw()
	end
end

local function _keyPressed(self, key)
	return (self._keys[key] and self._keys[key] > 0)
end
local function _keyDown(self, key)
	return love.keyboard.isDown(key)
end

local ntf = {
	["down"] = _keyDown,
	["pressed"] = _keyPressed,
}
local ntf_m
if lovepad then
	ntf_m = {
		["down"] = lovepad.isDown,
		["pressed"] = lovepad.isPressed,
	}
end

function controls:check(player, ctrl, type)
	if not type then type = "down" end
	if self.inputs
	and self.inputs[ctrl] then
		local ctrl = self.inputs[ctrl]

		if ctrl.keys 
		and ctrl.keys[player] then
			for _,key in pairs(ctrl.keys[player]) do
				if ntf[type](self, key) then
					return true
				end
			end
		end

		if not isDown
		and player == 1
		and lovepad
		and ctrl.mobile then
			if ntf_m[type](lovepad, ctrl.mobile) then
				return true
			end
		end
	end
	
	return false
end

return controls