local functions = {}

local song_priority = 0
local curMusic = nil

function functions.changeMusic(name, priority, loop)
	if not priority then priority = 0 end
	if song_priority > priority then return end

	TEsound.stop('music')
	local play = TEsound.play
	if loop then play = TEsound.playLooping end

	local val1 = loop and nil or 0.5
	local val2 = loop and 0.5 or nil
	play("assets/music/"..name..".ogg", "stream", {"music"}, val1, val2)
	song_priority = priority
	
	curMusic = name
end

function functions.startSound(name,tag,vol)
	TEsound.play("assets/sounds/"..name..".wav", "static", {"sound", tag}, vol)
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
	
	functions.changeMusic('skedaddle', 1)
	state.escape_sequence = true
end

return functions