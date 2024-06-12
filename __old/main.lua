-- json = require('libs.json')
debug = require('libs.print')
class = require('libs.30log')
shash = require('libs.shash')
Camera = require('libs.camera')
animations = require('libs.animations')
slam = require('libs.slam')
moonshine = require('libs.moonshine')
rs = require('libs.resolution_solution')
suit = require('libs.suit')
lovepad = require "libs.lovepad"
sock = require('libs.sock')

controls = require('modules.controls')
map = require('modules.map')
networking = require('modules.networking')
functions = require('modules.functions')
timer = require('libs.timer')
tween = require('libs.tween')
lume = require('libs.lume')

states = require('libs.states')

require('classes')

gravity = 0.5

local stuff = {}

function string:contains(sub)
    return self:find(sub, 1, true) ~= nil
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function string:endswith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

function string:replace(old, new)
    local s = self
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

function string:insert(pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end

function switchToMenu()
		states.switch('menu',
		-- this is VERY long so lets walk thru it together
		-- here we set the music, and find every folder that has a "init.lua"
		function()
			functions.changeMusic('reflexyourpath', 0, true)

			local files = love.filesystem.getDirectoryItems('characters/')
			
			for _,i in pairs(files) do
				local info = love.filesystem.getInfo('characters/'..i)
				if info then
					if info.type == "file" then
						if not i:endswith('.char') then
							table.remove(files, _)
						else
							files[_] = i:gsub('.char', '')
						end
					end
				else
					table.remove(files, _)
				end
			end
			
			return files
		end,
		-- this is what happens if we select it
		-- we will re-switch to the same state, and make it find maps instead
		-- THEN to the loading screen!
		
		-- sorry for the messy code, this is all a placeholder until we
		-- get the assets we need for it
		function(character)
			states.switch('menu',
				function()
					local files = love.filesystem.getDirectoryItems('maps')
			
					for _,i in pairs(files) do
						local info = love.filesystem.getInfo('maps/'..i, 'file')
						
						if info then
							if not i:endswith('.lua') then
								table.remove(files, _)
							else
								files[_] = i:gsub('.lua', '')
							end
						else
							table.remove(files, _)
						end
					end

					return files
				end,
				function(map)
					states.switch('loading', {
						state = "game",
						args = {map, character, false}
					})
				end
			)
		end
	)
end

function love.load()
	rs.conf({
		game_width = 640,
		game_height = 440,
		scale_mode = 1
	})
	rs.setMode(rs.game_width, rs.game_height, {resizable = true})
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	--effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.scanlines)

	mobile = love.system.getOS()
	mobile = (mobile == "iOS" or mobile == "Android")
	require "modules.controls_init"
	--states.switch('multiplayer')
	love.filesystem.createDirectory('characters')
	love.filesystem.createDirectory('maps')
	switchToMenu()
end

-- Necessary to keep the correct values up to date
function love.resize(width, height)
    rs.resize()
end

function love.update(dt)
	controls:update(dt)
	timer:update(dt)
	
	if client then
		client:update()
	end
	
	debug.update(dt)

	local func = states.getState().update
	if func then func(dt) end
end

function love.draw()
	rs.push()
		local func = states.getState().draw
		if func then
			func()
		end
	rs.pop()
	suit.draw()
	debug.draw(dt)
	controls:draw()
end

function love.touchreleased(id)
	if not mobile then return end
	lovepad:touchreleased(id)
end

function love.textedited(text, start, length)
    -- for IME input
    suit.textedited(text, start, length)
end

function love.textinput(t)
	-- forward text input to SUIT
	suit.textinput(t)
end

function love.keypressed(key)
	-- forward keypresses to SUIT
	suit.keypressed(key)
end