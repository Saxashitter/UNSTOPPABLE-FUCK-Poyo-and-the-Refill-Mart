function load(find_items, _select)
	items = find_items()
	select = _select
	
	curSel = 1
end

function enter()
	
end

local function changeOption(value)
	if not value then return end
	if value == 0 then return end

	curSel = math.max(1, math.min(curSel+value, #items))
end

function update(dt)
	local dir = 0
	
	if controls:isJustPressed('Up') then
		dir = -1
	elseif controls:isJustPressed('Down') then
		dir = 1
	end

	changeOption(dir)
	
	if controls:isJustPressed('Jump') then
		select(items[curSel])
	end
end

function draw()
	local font = love.graphics.getFont()
	local width = rs.game_width
	local height = rs.game_height
	
	for _,i in ipairs(items) do
		if _ == curSel then
			love.graphics.setColor(1,1,0)
		end

		local f_width = font:getWidth(i)
		local f_height = font:getHeight(i)
		love.graphics.print(i, width/2, 6+(16*(_-1)), time, 1, 1, f_width/2, f_height/2)

		love.graphics.setColor(1,1,1)
	end
end