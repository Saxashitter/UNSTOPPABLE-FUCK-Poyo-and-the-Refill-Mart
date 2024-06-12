local buttonClass = require "src.objects.ui.button"

function load()
	local width,height = rs.game_width,rs.game_height
	singlePlayerButton = buttonClass(width/2-64, height/2-16-32, 64*2, 32, "Singleplayer")
	singlePlayerButton.onPress = function(self)
		USFM:switchState('game')
	end
	add(singlePlayerButton)
end