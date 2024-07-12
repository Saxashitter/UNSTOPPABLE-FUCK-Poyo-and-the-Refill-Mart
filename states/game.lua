local playerClass = require "src.game.enemy.player"
local controlsClass = require "src.controls"
local worldClass = require "src.manager.world"
local audioClass = require "src.manager.audio"
local mapClass = require "src.map.map"

local canvas

local function getForCByMom(momx)
	if momx < 0 then
		return math.ceil
	end
	return math.floor
end

local function linearLerp(val1, val2, amount)
	if val1 < val2 then
		return math.min(val1+amount, val2)
	end
	return math.max(val1-amount, val2)
end

local function stayInDeadzone(target, camera, camFollow)
	camFollow.x = target.x+target.width/2
	camFollow.y = target.y+target.height/2
	camera.x = camFollow.x
	camera.y = camFollow.y
end

local function setupMapAndWorld()
	world = worldClass(add)
	map = mapClass("export")

	if map.playerPos then
		px,py = map.playerPos.x,map.playerPos.y
	end
	
	camera.x,camera.y = px,py
	player.x,player.y = px,py

	map:defineCollisions(world, camera)
	world:addToWorld(player, {dontAdd = true})
	if multiplayer then
		world:addToWorld(player2, {dontAdd = true})
	end
end

function load(multi)
	multiplayer = (multi)
	numOfPlayers = 0
	canvas = love.graphics.newCanvas(rs.game_width, rs.game_height)

	controls = controlsClass(require "controls.game")

	local width = resolution_solution.game_width
	local height = resolution_solution.game_height

	camera = Camera()
	camFollow = {}
	if multiplayer then
		camera2 = Camera()
		camFollow2 = {}
	end

	player = playerClass(0,0,"poyo",0)
	player.controls = controls
	add(player)
	if multiplayer then
		player2 = playerClass(0,0,"poyo",1)
		player2.controls = controls
		add(player2)
	end

	music = audioClass("assets/music/", "ogg", "stream")

	setupMapAndWorld()
	if map.properties
	and map.properties.music then
		music:preload("music", map.properties.music, true)
	end
end

function enter(state)
	music:play("music")
end
function update(dt)
	controls:update(dt)
end
function postupdate(dt)
	stayInDeadzone(player, camera, camFollow)
	if multiplayer then
		stayInDeadzone(player2, camera2, camFollow2)
	end
end
function switch(state) end

function draw()
	local x,y,w,h = 0,0,rs.game_width,rs.game_height
	if multiplayer then
		h = rs.game_height/2
	end
	camera:attach(x,y,w,h)
		map:draw()
		USFM:drawObjs()
	camera:detach()

	if multiplayer then
		camera2:attach(0,rs.game_height/2,rs.game_width,rs.game_height/2)
			map:draw()
			USFM:drawObjs()
		camera2:detach()
	end
	return true
end
function postdraw()
	--camera:detach()
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