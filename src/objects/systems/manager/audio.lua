local audio = LuaObject:extend()

function audio:new(assetPath, ext, type)
	self.__preloaded = {}
	self.__assetPath = assetPath
	self.__ext = ext
	self.__type = type
end

function audio:preload(tag, path, loop)
	self.__preloaded[tag] = love.audio.newSource(self.__assetPath..path.."."..self.__ext, self.__type)
	if loop then
		self.__preloaded[tag]:setLooping(true)
	end
end

function audio:play(tag)
	if not self.__preloaded[tag] then return end

	self.__preloaded[tag]:play()
end
function audio:stop(tag)
	if not self.__preloaded[tag] then return end

	self.__preloaded[tag]:stop()
end
function audio:stopAll()
	for _,audio in pairs(self.__preloaded) do
		audio:stop()
	end
end

return audio