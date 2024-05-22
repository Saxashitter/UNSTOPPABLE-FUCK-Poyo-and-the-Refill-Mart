local path = (...):replace(".", "/")
local fsm = {}
local curState

local function changeState(fsm, player, state)
	if not fsm.states[state] then error('INVALID STATE, STUPID!') return end

	if curState and curState.exit then
		curState:exit(player, state)
	end

	curState = fsm.states[state]
	
	if curState and curState.enter then
		curState:enter(player, state)
	end
end

setmetatable(fsm, {
	__call = changeState,
	__index = function(self, key)
		if not curState then return end
		return curState[key]
	end
})

fsm.states = {}

local function addStates(dir)
	for _,file in ipairs(love.filesystem.getDirectoryItems(dir)) do
		local info = love.filesystem.getInfo(dir..file)
		
		if info.type == "folder" then
			addStates(dir..i.."/")
		else
			local name = file:gsub('.lua', '')
			local path = dir:gsub('/', '.')..name

			fsm.states[name] = require(path)
		end
	end
end

addStates(path..'/states/')

return fsm