--states.lua
--
--By S. Baranov (spellsweaver@gmail.com)
--For love2d 11.1
-------------
--How to use
-------------
--In main.lua
--states = require("states")
--in love.load() call states.setup()
--From now on, states library will redirect love2d callbacks from your main.lua to state files
--Each state file should be located in "states/" directory and return a table of callbacks that correspond to love2d callbacks
--If you want your callbacks to be state-independant, keep them in your main.lua. This way states library will not redirect them to states.
--If you want a callback to have both state-dependant and state-independant part, 
--keep in in main.lua and call states.(callback name) within love 2d callback
--To switch states (you should probably do this immediately after initialising) use states.switch(filename,params)
--Filename is a name of your state file, while params is a table that will be caught by .open callback within according state file
--Through params you can transfer data to your state files conveniently

--------------

local states = {}

--private variables
local stateFiles = {}

local currentState = "default"

--private functions
local function defaultInitialize(stateFile)
	--fill in dummy functions instead of omitted ones
end

local function add(stateName)
	local stateFunc = love.filesystem.load("states/"..stateName..".lua")
	local state = {}

	setfenv(stateFunc, state)
	setmetatable(state, {__index = _G})
	stateFunc()

	stateFiles[stateName] = state
	defaultInitialize(stateFiles[stateName])
end

--public functions
function states.setup()
	
end

--MODDED FUNCTION TO DO DA FUNNY
function states.preload(newState,...)

	if not stateFiles[newState] then
		add(newState)
	end
	
	if stateFiles[newState].load and not stateFiles[newState].preloaded then
		states.nextState = newState
		stateFiles[newState].preloaded = true
		stateFiles[newState].load(...)
	end
	
	return stateFiles[newState]
end

function states.switch(newState,...)
	if not stateFiles[newState] then
		add(newState)
	end

	if stateFiles[currentState] then
		stateFiles[currentState].preloaded = false
	end

	if stateFiles[currentState] and stateFiles[currentState].exit then
		stateFiles[currentState].exit()
	end

	states.preload(newState,...)

	if stateFiles[newState].enter then
		stateFiles[newState].enter()
	end

	currentState = newState
end

--shit lol
function states.getState(name)
	if not name then 
		name = currentState
		if not name then 
			return 
		end
	end
	if not stateFiles[name] then add(name) end

	return stateFiles[name]
end

return states