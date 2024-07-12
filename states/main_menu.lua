local buttonClass = require "src.ui.button"
local audioClass = require "src.manager.audio"

function load()
	local width,height = rs.game_width,rs.game_height

	singlePlayerButton = buttonClass(width/2-64, height/2-16-(32*3), 64*2, 32, "Singleplayer")
	singlePlayerButton.onPress = function(self)
		USFM:switchState('game')
	end

	multiPlayerButton = buttonClass(width/2-64, height/2-16-32, 64*2, 32, "Multiplayer")
	multiPlayerButton.onPress = function(self)
		USFM:switchState('game', true)
	end

	bossButton = buttonClass(width/2-64, height/2-16+32, 64*2, 32, "Boss Engine")
	bossButton.onPress = function(self)
		USFM:switchState('boss')
	end

	add(singlePlayerButton)
	add(multiPlayerButton)
	add(bossButton)

	audio = audioClass("assets/music/", "ogg", "stream")
	audio:preload("music", "withyou", true)
end

function enter()
	audio:play("music")
end

function exit()
	audio:stopAll()
end