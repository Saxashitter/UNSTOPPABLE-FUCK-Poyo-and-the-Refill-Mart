local buttonClass = require "src.objects.ui.button"
local audioClass = require "src.objects.systems.manager.audio"

function load()
	local width,height = rs.game_width,rs.game_height
	singlePlayerButton = buttonClass(width/2-64, height/2-16-32, 64*2, 32, "Singleplayer")
	singlePlayerButton.onPress = function(self)
		USFM:switchState('game')
	end

	add(singlePlayerButton)

	audio = audioClass("assets/music/", "ogg", "stream")
	audio:preload("music", "withyou", true)
end

function enter()
	audio:play("music")
end

function exit()
	audio:stopAll()
end