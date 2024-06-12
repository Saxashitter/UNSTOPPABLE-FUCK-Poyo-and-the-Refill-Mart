-- UnsFuck Engine, by Saxashitter.
-- This engine aims to make platformer games in Love2D easier to make.
-- You can use this in commercial/non-commercial projects for FREE. But all I ask is credit.

require "globals"

game = {}
local canvas

-- LÖVE 0.10.2 fixed timestep loop, Lua version

function love.load()
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	resolution_solution.conf({
		width = 960,
		height = 540,
		scale_mode = 1
	})
	rs = resolution_solution
	rs.setMode(960, 540, {resizable = true})
	canvas = love.graphics.newCanvas(rs.get_game_size())
	USFM:switchState("main_menu")
end

for _,h in pairs(love.handlers) do
	love[_] = function(...)
		if USFM[_] then
			USFM[_](...)
		end
		if _ == "resize" then
			resolution_solution.resize()
			game.width,game.height = ...
		end
	end
end

function love.update(...)
	if USFM.update then
		USFM.update(...)
	end
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	if USFM.draw then
		USFM:draw()
	end
	love.graphics.setCanvas()

	resolution_solution.push()
	love.graphics.draw(canvas)
	resolution_solution.pop()

	love.graphics.rectangle("line", rs.get_game_zone())
	if USFM.drawOutOfBounds then
		USFM.drawOutOfBounds()
	end
	profiler:start()
end