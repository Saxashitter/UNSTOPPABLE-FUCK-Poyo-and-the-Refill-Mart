local playerClass = require "src.objects.game.enemy.player"
local controlsClass = require "src.objects.systems.input.controls"
local worldClass = require "src.objects.systems.manager.world"
local mapClass = require "src.objects.systems.map.map"

local canvas

local function stayInDeadzone()
	local x = (player.x+(player.width/2))+(player.momx*40)
	local y = (player.y+(player.height/2))
	local deadzoneX = 32*4
	local deadzoneY = 32*6
	if not (camFollow.x and camFollow.y) then
		camFollow.x = x
		camFollow.y = y
	else
		local _x = camFollow.x
		local _y = camFollow.y
		if x < _x-deadzoneX then
			camFollow.x = _x+(x-(_x-deadzoneX))
		elseif x > _x+deadzoneX then
			camFollow.x = _x+(x-(_x+deadzoneX))
		else
			camFollow.x = lume.lerp(camFollow.x, x, 0.025)
		end
		if y < _y-deadzoneY then
			camFollow.y = _y+(y-(_y-deadzoneY))
		elseif y > _y+deadzoneY then
			camFollow.y = _y+(y-(_y+deadzoneY))
		else
			camFollow.y = y
		end
	end
	camera.x = lume.lerp(camera.x, camFollow.x, 0.08)
	camera.y = lume.lerp(camera.y, camFollow.y, 0.1)
end

function load()
	camFollow = {}
	numOfPlayers = 0
	canvas = love.graphics.newCanvas(rs.game_width, rs.game_height)

	controls = controlsClass(require "src.controls.game")

	world = worldClass(add)
	add(world)


	local width = resolution_solution.game_width
	local height = resolution_solution.game_height

	camera = Camera()

	map = mapClass("export")
	map:defineCollisions(world, camera)
	if map.playerPos then
		px,py = map.playerPos.x,map.playerPos.y
	end

	camera.x,camera.y = px,py
	player = playerClass(px,py,"poyo",numOfPlayers)
	player.controls = controls
	world:addToWorld(player)
end

function enter(state) end
function update(dt)
	controls:update(dt)
end
function postupdate(dt)
	stayInDeadzone()
end
function switch(state) end

function draw()
	camera:attach(0,0, rs.game_width, rs.game_height)
	map:draw()
end
function postdraw()
	camera:detach()
end
function drawOutOfBounds()
	controls:draw()
end

function keypressed(key)
	controls:keypressed(key)
end
function keyreleased(key)
	controls:keyreleased(key)
end