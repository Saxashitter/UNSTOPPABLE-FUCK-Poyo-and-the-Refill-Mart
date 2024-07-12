local worldClass = require "src.manager.world"
local audioClass = require "src.manager.audio"
local playerClass = require "src.boss.player"
local sakuyaClass = require "src.boss.sakuya"
local controlsClass = require "src.controls"

local function _collide(obj, obj2)
	return obj.x < obj2.x+obj2.width
	and obj2.x < obj.x+obj.width
	and obj.y < obj2.y+obj2.height
	and obj2.y < obj.y+obj.height
end

function load()
	world = worldClass(add)
	entities = {}
	entitylimit = 10
	blocks = {
		{
			x = 0,
			y = rs.game_height/1.5,
			width = rs.game_width,
			height = rs.game_height/1.5,
			scale = 1
		},
		{
			x = 0,
			y = 0,
			width = 32,
			height = rs.game_height/1.5,
			scale = 1
		},
		{
			x = rs.game_width-32,
			y = 0,
			width = 32,
			height = rs.game_height/1.5,
			scale = 1
		},
		{
			x = 32,
			y = 0,
			width = rs.game_width-64,
			height= 32,
			scale = 1
		}
	}
	controls = controlsClass(require "controls.game")
	for _,b in ipairs(blocks) do
		world:addToWorld(b, {dontAdd = true, solid = true})
	end

	player = playerClass(32,0,"poyo",0)
	player.y = (rs.game_height/1.5)-player.height
	player.controls = controls

	boss = sakuyaClass(rs.game_width-64,rs.game_height/1.5)
	boss.target = player
	boss.y = boss.y-boss.height

	world:addToWorld(player)
	world:addToWorld(boss)
end

function update(dt)
	controls:update(dt)
end

function postupdate(dt)
	local r = {}
	for i = 1,math.max(0, #entities-entitylimit) do
		table.remove(entities, 1)
	end

	for _,e in pairs(entities) do
		e:update(dt)
		if _collide(player, e)
		and player:canBeDamaged() then
			table.insert(r, e)
		end
	end

	for _,e in pairs(r) do
		for _,enty in pairs(entities) do
			if e == enty then
				table.remove(entities, _)
				break
			end
		end
	end
end

function draw()
	for _,b in ipairs(blocks) do
		love.graphics.rectangle("line", b.x, b.y, b.width, b.height)
	end
end
function postdraw()
	for _,e in pairs(entities) do
		e:draw()
	end
end

function drawOutOfBounds()
	controls:draw()
end