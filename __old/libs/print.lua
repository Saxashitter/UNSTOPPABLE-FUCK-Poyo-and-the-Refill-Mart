local debug = {}
local prints = {}

function print(str)
	table.insert(prints, {name = tostring(str), time = 5})
	if #prints > 16 then
		table.remove(prints, 1)
	end
end

function debug.update(dt)
	for _,i in ipairs(prints) do
		if i.time <= 0 then
			table.remove(prints, _)
		else
			i.time = i.time - dt
		end
	end
end

function debug.draw()
	for _,print in ipairs(prints) do
		love.graphics.print(print.name, 2, 2+(12*(_-1)))
	end
end

return debug