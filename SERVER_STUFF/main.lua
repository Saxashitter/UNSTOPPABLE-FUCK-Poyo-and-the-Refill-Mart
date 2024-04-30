local sock = require "sock"
local device = love.system.getOS()

-- we gotsa keep our amount of-a playas
local players = {}
local clientids = {}

-- map to send to connected clients
local map = require "maps.export"

-- used so we dont multitask downloads
local downloading_character = false

local show_debug_info = true

function string:endswith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

-- server.lua
function love.load()
	-- Change IP to * (asterisk) if you wanna open your server to the world.
	-- You HAVE to port forward to host. If you just wanna host a server...
	-- ...by yourself for some reason, leave as is.
	
	-- The second number is the port itself. Any port that...
	-- ...hasn't been taken by another program, and you...
	-- ported forward to is available.
	
	love.filesystem.createDirectory("characters")
	love.filesystem.createDirectory("maps")
    server = sock.newServer("127.0.0.1", 22122)
    
    -- Called when someone connects to the server
    server:on("connect", function(data, client)
    	if show_debug_info then
    		print(data, client)
    	end
    	clientids[client] = math.random(2048)
    	for _,i in pairs(clientids) do
    		if clientids[client] == i then
    			clientids[client] = math.random(2048)
    		end
    	end
		client:send("welcome-player", {map, clientids[client]})
    end)
    server:on("disconnect", function(data, client)
    	if show_debug_info then
    		print(data, client)
    	end
    	server:sendToAll("remove-client", clientids[client])
		players[clientids[client]] = nil
    end)
    
    -- Called when a player is updated.
    server:on("update-player", function(data, client)
    	players[clientids[client]] = {
    		x = data.x or 0,
    		y = data.y or 0,
    		dir = data.dir or 1,
    		frame = data.frame or 1,
    		anim = data.anim or "idle",
    		char = data.char or "characters/Poyo",
    		animpath = data.animpath or "characters/Poyo/animations/"
    	}
    	if not downloading_character and players[clientids[client]].char:endswith('.char') and not love.filesystem.exists(players[clientids[client]].char) then
    		print "Downloading character..."
    		print(players[clientids[client]].char)
    		client:send("get-character")
    		downloading_character = true
    	end
    end)
    
    -- Called when a character file gets sent to the server.
    server:on("receive-character", function(data, client)
    	local success, message = love.filesystem.write(data[2], data[1])
    	
    	
    	if success then
    		print "Downloaded character!"
    	else
    		print("ERROR: "..message)
    	end
    	downloading_character = false
    end)
    
    -- Called when a client needs a character.
    server:on("give-character", function(characterpath, client)
    	if not love.filesystem.exists(characterpath) then return end
    	
    	local char = love.filesystem.newFileData(characterpath)
    	client:send("receive-character", {char:getString(), characterpath})
    end)
end

function love.update(dt)
  	server:sendToAll("position-players", players)
    server:update()
    if not show_debug_info then
	    if device == "Linux" then
			os.execute "clear"
	    elseif device == "Windows" then
			os.execute "cls"
		end
	    print "POYO GAME SERVER V0.1 - THINGS WILL BE CHANGED"
	    print "MADE WITH SOCK.LUA"
	    print " "
	    print " "
	    print " "
	    print("Players: "..#players)
    end
end