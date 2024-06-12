local time = 0
local load_state = nil
local loadsong
local load_state_name
local params

function load(_params)
	params = _params
end

function enter(map, char)
	loadsong = functions.changeMusic('loading')
	time = 0
	
	if params.state then
		load_state = states.preload(params.state,unpack(params.args))
	end
	
	if params.on_enter then
		params.on_enter()
	end
end

function update(dt)
	time = time + dt

	if load_state and load_state.preloaded and time > 3 and params.state then
		loadsong:stop()
		states.switch(params.state)
	end
end

function draw()
	local font = love.graphics.getFont()
	local width = rs.game_width
	local height = rs.game_height
	local f_width = font:getWidth('Loading...')
	local f_height = font:getHeight('Loading...')
	love.graphics.print('Loading...', width/2, height/2, time, 1, 1, f_width/2, f_height/2)
end