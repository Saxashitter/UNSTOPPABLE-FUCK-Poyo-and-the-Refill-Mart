local types = {
	['Player'] = require "src.objects.game.enemy.player"
}

return function(self, block)
	local object = types[block.type]

	return object(block.x+(object.width/2), block.y+block.height-object.height)
end