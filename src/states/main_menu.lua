local buttonClass = require "src.objects.ui.button"

function load()
	local width,height = love.graphics.getDimensions()
	singlePlayerButton = buttonClass(width/2-64, height/2-16-32, 64*2, 32, "Singleplayer")
	spriteTestButton = buttonClass(width/2-64, height/2-16, 64*2, 32, "Spritesheet Helper")
	singlePlayerButton.onPress = function(self)
		USFM:switchState('game')
	end
	spriteTestButton.onPress = function(self)
		USFM:switchState('spritemaker')
	end
	add(singlePlayerButton)
	add(spriteTestButton)
end