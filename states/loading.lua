local state = {}
local time = 0
local load_state = nil
local loadsong
local load_state_name

function state.load(params)
	state.params = params
end

function state.enter(map, char)
	loadsong = functions.changeMusic('loading')
	time = 0
	
	if state.params.state then
		load_state = states.preload(state.params.state,unpack(state.params.args))
	end
	
	if state.params.on_enter then
		state.params.on_enter()
	end
end

function state.update(dt)
	time = time + dt
	
	if load_state and load_state.preloaded and time > 3 and state.params.state then
		loadsong:stop()
		states.switch(state.params.state)
	end
end

function state.draw()
	local font = love.graphics.getFont()
	local width = rs.game_width
	local height = rs.game_height
	local f_width = font:getWidth('Loading...')
	local f_height = font:getHeight('Loading...')
	love.graphics.print('Loading...', width/2, height/2, time, 1, 1, f_width/2, f_height/2)
end

return state