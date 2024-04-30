local state = {}

function state.load(find_items, select)
	state.items = find_items()
	state.select = select
	
	state.curSel = 1
end

function state.enter()
	
end

local function changeOption(value)
	if not value then return end
	if value == 0 then return end

	state.curSel = math.max(1, math.min(state.curSel+value, #state.items))
end

function state.update(dt)
	local dir = 0
	
	if controls:isJustPressed('Up') then
		dir = -1
	elseif controls:isJustPressed('Down') then
		dir = 1
	end

	changeOption(dir)
	
	if controls:isJustPressed('Jump') then
		state.select(state.items[state.curSel])
	end
end

function state.draw()
	local font = love.graphics.getFont()
	local width = rs.game_width
	local height = rs.game_height
	
	for _,i in ipairs(state.items) do
		if _ == state.curSel then
			love.graphics.setColor(1,1,0)
		end

		local f_width = font:getWidth(i)
		local f_height = font:getHeight(i)
		love.graphics.print(i, width/2, 6+(16*(_-1)), time, 1, 1, f_width/2, f_height/2)

		love.graphics.setColor(1,1,1)
	end
end

return state