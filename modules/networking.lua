local networking = {
	ut = 1/12,
	hosting = false,
	connected = false,
	t = 0
}
local listOfIPs = {}

function networking:load()
	self.udp = socket.udp()
	udp:settimeout(0)
end

function networking:connect(address, port)
	udp:setpeername(address, port)
	self.connected = true
end

function networking:host(port)
	udp:setpeername('*', port)
	self.hosting = true
end

function networking:send(name, data, dt)
	if not self.hosting
	or self.connected then
		return
	end

	if not name then return end
	if not data then return end
	if type(data) ~= "table" then return end

	data.NETWORKINGSTUFF_NAME = name

	self.t = self.t+dt
	if self.t >= self.ut then
		if not self.connected then
			networking.udp:send("POYO GAME NETWORKING DATA "..json.encode(data))
		else
			for _,i in ipairs(listOfIPs) do
				networking.udp:sendto("POYO GAME NETWORKING DATA "..json.encode(data))
			end
		end
		self.t = 0
	end
end

function networking:receive()
	if not networking.hosting
	or networking.connected then
		return
	end
	local received = {}
	local raw_data
	local ips

	if networking.connected then
		raw_data = networking.udp:receive()
	else
		raw_data,ips = networking.udp:receivefrom()
	end

	for _,i in ipairs(raw_data) do
		if i:startswith("POYO GAME NETWORKING DATA ") then
			local data = json.decode(i:gsub("POYO GAME NETWORKING DATA "))
			if not received[data.NETWORKINGSTUFF_NAME] then
				received[data.NETWORKINGSTUFF_NAME] = {}
			end
			table.insert(received[data.NETWORKINGSTUFF_NAME], data)
			
			print "got smth"
		else
			print("WOAH! AN UNRECOGNIZED COMMAND!: "..i)
		end
	end

	listOfIPs = {}

	if ips then
		for _,i in ipairs(ips) do
			table:insert(listOfIPs, i)
		end
	end

	return received
end
return networking