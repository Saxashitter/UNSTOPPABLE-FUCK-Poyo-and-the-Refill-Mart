local state = {}

local function handleAnimations(player)
	if not player.flags.grounded then
		if player.momy < 0 then
			if player.animation.curAnim ~= "jump" then
				player.animation:changeAnim("jump", 1)
			end
		else
			if player.animation.curAnim ~= "fall" then
				player.animation:changeAnim("fall", 1)
			end
		end
	elseif math.abs(player.momx) > 0 then
		if math.abs(player.momx) <= 5 and player.animation.curAnim ~= "walk" then
			player.animation:changeAnim("walk", 15)
		elseif math.abs(player.momx) > 5 and player.animation.curAnim ~= "run" then
			player.animation:changeAnim("run", 15)
		end
	else
		if player.animation.curAnim ~= "idle" then
			player.animation:changeAnim("idle", 15)
		end
	end

	if player.animation.curAnim == "walk"
	or player.animation.curAnim == "run" then
		player.animation.speed = math.abs(player.momx)/4*1.25
	end
	
	if player.animation.curAnim == "fall" then
		player.animation.speed = math.abs(player.momy)*4
	end
end

local function lerp_clamp(val, min, max, del)
	if val < min then
		val = val + del
		if val > min then
			val = min
		end
	end
	if val > max then
		val = val - del
		if val < min then
			val = max
		end
	end
	return val
end

function state:update(player, dt)
	local speed = 4
	local dir = 0
	local mult = (1/60)/dt
	
	if controls:isPressed('Run') then
		speed = 8
	end
	
	if controls:isPressed('Left') then
		dir = -1
	elseif controls:isPressed('Right') then
		dir = 1
	end
	
	if not player.flags.canmove then
		dir = 0
	end

	if dir == 0 then
		speed = 0
	end


	local decel = player.deceleration/mult
	local accel = player.acceleration/mult
	
	if not player.flags.grounded then
		accel = accel*0.75
		decel = decel*0.75
	end
	if dir == -player.dir then
		accel = accel*2.3
	end
	
	local keepMomentum = controls:isPressed('Run') or not player.flags.grounded
	if keepMomentum
	and (dir == player.dir 
		and math.abs(player.momx) < speed 
		or dir ~= player.dir)
	or not keepMomentum then
		player.momx = lerp_clamp(player.momx+(accel*dir), -speed, speed, decel)
	end

	if player.flags.canmove
	and player.flags.grounded
	and controls:isJustPressed('Jump') then
		player.flags.jumpheld = true
		player.gravity = gravity/1.5
		player.flags.grounded = false
		player.momy = -14/1.5
		player.sounds.jump:play()
	end

	handleAnimations(player)

	if player.flags.jumpheld and (not controls:isPressed('Jump') or player.momy >= 0) then
		player.flags.jumpheld = false
		player.gravity = gravity
		if player.momy < 0 then
			player.momy = player.momy*0.35
		end
	end

	if player.flags.grounded and player.flags.jumpheld then
		player.flags.jumpheld = false
	end

	if controls:isJustPressed('Weapon') then
		player:fsm("bat")
		return
	end
	if controls:isJustPressed('Dodge') then
		player:fsm("dodge")
		return
	end
end

function state:exit(player)
	player.flags.jumpheld = false
	player.gravity = gravity
end

function state:tileCollision(player, type)
	
end

return state