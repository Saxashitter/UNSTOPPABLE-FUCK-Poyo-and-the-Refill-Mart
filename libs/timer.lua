local timer = {}

local function init(self, time, onFinish, ...)
	local shit = {
		onFinish = onFinish,
		time = time,
		finished = false,
		args = {...}
	}
	setmetatable(shit, {__tostring = function()
		return "timer_t"
	end})
	table.insert(self, shit)
	
	return shit
end
setmetatable(timer, {__call = init})

function timer:update(dt)
	for k,v in pairs(self) do
		if tostring(v) == "timer_t" then
			if v.time > 0 then
				v.time = v.time - dt
			end
			if v.time <= 0 then
				v.finished = true
				if v.onFinish then
					v.onFinish(unpack(v.args))
				end
				table.remove(timer, k)
			end
		end
	end
end

return timer