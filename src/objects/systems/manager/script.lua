local script = LuaObject:extend()

local ASSET_PATH = "assets/scripts/"

function script:new()
end

local function loadScript(path)
	local data = {}
	setmetatable(data, {__index = _G})
	local func = love.filesystem.load(path)
	setfenv(func, data)
	func(path:gsub("/", "."):gsub(".lua", ""))

	return data
end

function script:require(path)
	local filePath = ASSET_PATH..(path:gsub("%.", "/"))
	local exists = love.filesystem.getInfo(filePath)

	if not exists then
		filePath = filePath..".lua"
		exists = love.filesystem.getInfo(filePath)
		if not exists then
			error("Invalid path! "..filePath)
		end
	end

	if exists.type == "file" then
		return loadScript(filePath)
	elseif love.filesystem.getInfo(filePath.."/init.lua") then
		return loadScript(filePath.."/init.lua")
	else
		error("Invalid path! "..filePath)
	end
end

return script