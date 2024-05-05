local functions = {}

local song_priority = 0
local curName
local curMusic

function functions.preloadMusic(name)
	curName = name
	curMusic = love.audio.newSource('assets/music/'..name..".ogg", "stream")
end

function functions.changeMusic(name, priority, loop)
	if not priority then priority = 0 end
	if song_priority > priority then return end

	if name ~= curName then
		if curMusic then
			curMusic:stop()
		end
		functions.preloadMusic(name)
	end

	if loop == nil then loop = true end
	curMusic:setLooping(loop)
	curMusic:play()
	curMusic:setVolume(.7)
	song_priority = priority
	
	return curMusic
end

function functions.startSound(name,tag,vol)
	local sound = love.audio.newSource("assets/sounds/"..name..".wav", "static"):play()
end

function functions.setMusicPriority(value)
	if not value then return end
	song_priority = value
end

function functions.curPlaying()
	return curMusic
end

function functions.startEscapeSequence()
	local state = states.getState()
	
	if state.escape_sequence then return end
	
	functions.changeMusic('skedaddle')
	state.escape_sequence = true
end

return functions