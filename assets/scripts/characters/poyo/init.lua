local animationClass = require "src.manager.animation"
local accel = .5
local decel = .25
local speed = 4

local path = (...):gsub(".init", "")

local animFuncs = require(path..".scripts.anim_funcs")

function new(poyo)
	anim = animationClass("characters/poyo", "idle")
	poyo.dir = 1
	poyo.jumped = false
end

local function handleAnims(poyo)
	local curAnim = "idle"
	if poyo.momx < 0 then
		poyo.dir = -1
	elseif poyo.momx > 0 then
		poyo.dir = 1
	end
	--print(poyo.momx)

	if poyo.grounded then
		if math.abs(poyo.momx) >= 0.05 then
			curAnim = "walk"
		end
		if math.abs(poyo.momx) > 4 then
			curAnim = "run"
		end
	else
		if poyo.momy < 0 then
			curAnim = "jump"
		else
			curAnim = "fall"
		end
	end

	if anim.curAnim ~= curAnim then
		anim:changeAnim(curAnim)
	end
	if animFuncs[curAnim] then
		animFuncs[curAnim](poyo, anim)
	end
end

function update(poyo, dt)
	local dir = poyo:getDir()
	poyo:defaultMovement(dir, accel, decel, speed)

	if poyo.grounded
	and poyo.controls:check(poyo.num, "Jump", "pressed") then
		poyo.momy = -12
		poyo.grounded = false
		poyo.jumped = true
	end
	if poyo.momy < 0
	and poyo.jumped
	and not (poyo.controls:check(poyo.num, "Jump") and not poyo.grounded) then
		if poyo.momy < 0
		and not poyo.grounded then
			poyo.momy = poyo.momy*0.25
		end
		poyo.jumped = false
	end
end

function postUpdate(poyo, dt)
	handleAnims(poyo)
	anim:update(dt)
end

function draw(poyo)
	local img, quad, w, h = anim:getFrame()

	poyo.super.draw(poyo)
	love.graphics.draw(img, quad, poyo.x+(poyo.width/2), poyo.y+poyo.height, poyo.rot, poyo.dir*poyo.scale, 1, w/2, h-2)
end