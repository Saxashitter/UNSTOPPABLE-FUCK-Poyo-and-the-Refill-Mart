local fsm = {}

fsm.states = {}
fsm.curState = nil

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

addStates('characters/Poyo/fsm/states/')

function fsm:changeState(player, state)
	if not self.states[state] then error('INVALID STATE, STUPID!') return end

	if self.curState and self.curState.exit then
		self.curState:exit(player, state)
	end

	self.curState = self.states[state]
	
	if self.curState and self.curState.enter then
		self.curState:enter(player, state)
	end
end

return fsm