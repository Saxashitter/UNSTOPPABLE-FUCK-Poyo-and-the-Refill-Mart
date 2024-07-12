local UFSM = {
	statesList = {},
	curState = {},
	objects = {}
}

local function setupState(state)
	local _load = state.load
	local _enter = state.enter
	local _update = state.update
	local _postupdate = state.postupdate
	local _draw = state.draw
	local _postdraw = state.postdraw -- this exists for cameras

	function state.enter(...)
		if not state._loaded
		and _load then
			_load(...)
		end
		if _enter then
			_enter()
			if not state._loaded then
				state._loaded = true
			end
		end
	end
	function state.update(...)
		if (_update
		and not _update(...))
		or not _update then
			UFSM:updateObjs(...)
		end
		if _postupdate then
			_postupdate(...)
		end
	end
	function state.draw(...)
		if (_draw
		and not _draw(...))
		or not _draw then
			UFSM:drawObjs(...)
		end
		if _postdraw then
			_postdraw(...)
		end
	end
end

local function add(object)
	UFSM.objects[#UFSM.objects+1] = object

	return object
end

local function iterate_through_folder(path)
	local states = {}

	local directory = love.filesystem.getDirectoryItems(path)

	for k,v in pairs(directory) do
		local folder = love.filesystem.getInfo(path.."/"..v)
		if folder.type == "directory" then
			states[v] = iterate_through_folder(path.."/"..v)
		else
			states[v:gsub(".lua", "")] = {add = add}
	
			local stateData = states[v:gsub(".lua", "")]
			local stateFunc = love.filesystem.load(path.."/"..v)
	
			local om = getmetatable(stateData)
			setmetatable(stateData, {__index = _G})
			setfenv(stateFunc, stateData)
			stateFunc()

			setupState(stateData)
		end
	end

	return states
end

function UFSM:addStates(path)
	local path2 = path:gsub("%.", "/")

	local folder = love.filesystem.getInfo(path2, "directory")
	if not folder then error "Directory not found! Be sure you inputted the right directory in your code!" end

	UFSM.statesList = iterate_through_folder(path2)
end

function UFSM:switchState(newState, ...)
	local type = type(newState)
	if (type == "string" and not self.statesList[newState])
	and not type then
		return false
	end
	-- we checked if the state is valid, even if its not on the states list by checking if its a table

	-- init objects after we added them
	self.objects = {}

	local old_State = self.curState
	local new_State

	if type == "table" then
		new_State = newState
	else
		new_State = self.statesList[newState]
	end

	if old_State.exit then
		old_State.exit()
	end
	if new_State.enter then
		new_State.enter(...)
	end
	self.curState = new_State
	return true
end

function UFSM:drawObjs(...)
	for k,v in pairs(self.objects) do
		if v.draw then
			v:draw(...)
		end
	end
end
function UFSM:updateObjs(...)
	for k,v in pairs(self.objects) do
		if v.update then
			v:update(...)
		end
	end
end

setmetatable(UFSM, {
	__index = function(self, key, value)
		if self.curState[key] then return self.curState[key] end
	end
})

return UFSM