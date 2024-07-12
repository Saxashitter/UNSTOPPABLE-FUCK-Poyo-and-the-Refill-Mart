local player = require "src.game.enemy.player"

return function(self, block)
	self.map.playerPos = {
		x = block.x+(player.width/2),
		y = block.y+block.height-player.height
	}
end