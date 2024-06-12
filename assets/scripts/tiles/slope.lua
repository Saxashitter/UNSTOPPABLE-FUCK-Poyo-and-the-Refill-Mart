isSlope = true

function calculateSlopeSide(y1, y2)
	if y1 > y2 then
		return 1
	elseif y2 > y1 then
		return -1
	end
	return 0
end

function slope(self, x, width)
	-- OUR SLOPE FUNCTION!!
	-- remember, y1 is the left sides top, y2 is the bottom right
	-- we also use this for general slope y finding
	local x = x
	local y1 = (self.json and self.json.y1 or 0)*self.height
	local y2 = (self.json and self.json.y2 or 0)*self.height
	if not y2 then
		-- if y2 isnt a thing, make y2 equal to y1
		y2 = y1
	end

	if y1 == y2 then
		-- and then return that shit because is the slopes y for both left and right
		-- "why didnt u do that earlier-" bc theres a chance someone will do it in their map for half platforms or smth
		return y1 or 0
	end

	local side = calculateSlopeSide(y1, y2)
	local midp = x+(width/2)
	
	midp = midp+((width/2)*side)
	-- feel free to omit the side code if your making the center do slope collision
	-- be warned: youll have to do extra shit, and nobody likes extra shit

	local mx = (y2-y1)/self.width
	local b = y1-(mx*self.x)
	-- finally, calculate :D
	
	return self.y+math.min(self.height, math.max(0, ((mx*midp)+b)))
	-- slopes like to fuck up when your too down or too up, so return with some clamping
end

function afterTileLink(tile)
	if tile.rightTile then
		tile.rightTile.script = script:require("tiles.slope_side")
	end
	if tile.leftTile then
		tile.leftTile.script = script:require("tiles.slope_side")
	end
end

function onColResolve(tile, obj, type)
	if type == "x" then
		return 2
	end

	if type == "y" then
		local y = slope(tile, obj.x, obj.width*obj.scale)
		if not obj.grounded then
			if obj.y+obj.height >= y then
				obj.y = y-(obj.height*obj.scale)
				if obj.momy >= 0 then
					obj.momy = 0
					obj.grounded = true
				end
				return 1
			end
		end
		-- check objects.game.main.lua for sticking to slope code
		
		return 2
	end
end