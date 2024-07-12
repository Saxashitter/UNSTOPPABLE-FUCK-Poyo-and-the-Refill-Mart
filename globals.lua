LuaObject = require "classic"
script = require"src.manager.script"()
require "require"

for _,i in pairs(require.tree "libs") do
	_G[_] = i
end

profiler = LoveProfiler:new{config = {
	driver = "canvas"
}}

local function printr(...)
	local args = {...}
	for i = 1,#args do
		profiler:addMessage(tostring(args[i]))
	end
end
print = printr

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.0001) end
    end
end

function string:split(sep)
	if sep == nil then
		sep = "%s"
	end

	local split = {}

	for str in self:gmatch("([^"..sep.."]+)") do
		split[#split+1] = str
	end

	return split
end

USFM:addStates("states")

return {
	width = 640,
	height = 440
}