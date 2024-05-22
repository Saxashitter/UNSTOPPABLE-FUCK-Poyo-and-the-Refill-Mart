local function resolveCollision(self, obj, woh)
	local size = woh and "height" or "width"
	local pos = woh and "y" or "x"

	local self_area = self[pos]+(self[size]/2)
	local obj_area = obj[pos]+(obj[size]/2)
	local type = woh and "top" or "left"

	local og_pos = self[pos]

	if self_area > obj_area then
		self_area = self[pos]
		obj_area = obj[pos]+obj[size]
	else
		self_area = self[pos]+self[size]
		obj_area = obj[pos]
		type = woh and "bottom" or "right"
	end

	if self.t_collisions[type] then
		return end

	-- if were resolving via height and the objs area is equal to the top
	-- which means is a top collision
	if woh and obj_area == obj[pos] then
		obj_area = obj[pos] + obj:slope(self.x, self.width)
		-- we slope it via a function we bundled in with our block object
		if not (self[pos] <= obj_area+obj[size]
		and obj_area <= self[pos]+self[size]) then
			return
		end
		-- yea tbh i forgot what this check is but it doesnt do anything bad rn
	end

	self[pos] = self[pos] - (self_area - obj_area)
	local state = states.getState(states.nextState)
	if state and state.shash then
		state.shash:update(self, self.x,self.y,self.width,self.height)
	end
	self.t_collisions[type] = true

	return type,og_pos
end

return classes['Object']:extend('Block', {
	type = 1,
	type2 = "Block",
	init = function(self, image, x, y, width, height)
		self.super.init(self, x, y)
		
		self.collisions = {}

		self.width = width
		self.height = height

		--self.flags.noupdate = true
		self.image = image
		
		for _,i in pairs(self.image.properties) do
			self[_] = i
		end

		local state = states.getState(states.nextState)
		if state and state.shash then
			state.shash:update(self, self.x,self.y,self.width,self.height)
		end
	end,
	postTileSet = function(self)
		local isSlope = self:isSlope()

		if isSlope then
			if self.lefttile then
				self.lefttile.collision_x = false
			end
			if self.righttile then
				self.righttile.collision_x = false
			end
		end
	end,
	draw = function(self)
		local x,y,w,h = rs.get_game_zone()
		
		w,h = rs.game_width,rs.game_height -- just to be sure
		
		local camera = (states and states.getState()) and states.getState().camera
		
		x = (camera and camera.x or w/2) - w/2
		y = (camera and camera.y or h/2) - h/2

		if not (self.x < x+w and
	    x < self.x+self.width and
	    self.y < y+h and
	    y < self.y+self.height) then return end
		love.graphics.draw(self.image.image, self.image.quad, self.x, self.y)
	end,
	calculateSlopeSide = function(self)
		if self:isSlope() then
			if self.y1 > self.y2 then
				return 1
			elseif self.y2 > self.y1 then
				return -1
			end
		end
		
		return 0
	end,
	slope = function(self, x, width)
		-- OUR SLOPE FUNCTION!!
		-- remember, y1 is the left sides top, y2 is the bottom right
		-- we also use this for general slope y finding
		local x = x
		local y1 = self.y1
		local y2 = self.y2
		if not y2 then
			-- if y2 isnt a thing, make y2 equal to y1
			y2 = y1
		end
	
		if y1 == y2 then
			-- and then return that shit because is the slopes y for both left and right
			-- "why didnt u do that earlier-" bc theres a chance someone will do it in their map for half platforms or smth
			return y1 or 0
		end
	
		local side = self:calculateSlopeSide()
		local midp = x+(width/2)
		
		midp = midp+((width/2)*side)
		-- feel free to omit the side code if your making the center do slope collision
		-- be warned: youll have to do extra shit, and nobody likes extra shit
	
		local mx = (y2-y1)/self.width
		local b = y1-(mx*self.x)
		-- finally, calculate :D
		
		return math.min(self.height, math.max(0, ((mx*midp)+b)))
		-- slopes like to fuck up when your too down or too up, so return with some clamping
	end,
	isSlope = function(self)
		return (self.y2 ~= nil and self.y1 ~= nil) and (self.y1 ~= self.y2)
	end,
	canCollide = function(self, obj, type)
		if obj.type ~= 2 then return false end
		if not self.collidable then return false end
		if self.escape ~= nil then
			return self.escape == states.getState().escape_sequence
		end
		if self.collision_x == false and type == false then
			return false
		end
	
		if self.dodgable
		and obj.flags.passtiles == 2
		or obj.flags.passtiles == 1 then return false end

		if self.y1 and not type then
			return false
		end
		
		return true
	end,
	collision = function(self, obj, type)
		if not self:canCollide(obj, type) then return end

		local type = resolveCollision(obj, self, type)
		if type then
			local collisions = obj:tileCollision(type, self) or {false, false}
			if (type == "left"
			or type == "right")
			and not collisions[1] then
				obj.momx = 0
			elseif not collisions[2] then
				obj.momy = 0
			end
		end
	end
})