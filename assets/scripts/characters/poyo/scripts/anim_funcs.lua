-- anim funcs
local function _speedByMomx(poyo, anim)
	anim.speed = math.abs(poyo.momx)/4
end

return {
	walk = _speedByMomx,
	run = _speedByMomx
}