local textboxClass = require "src.objects.ui.textbox"
local buttonClass = require "src.objects.ui.button"

local ASSET_PATH = "assets/images/_forSpriteMaker/"

local MAX_WIDTH = 528

local function isXCollide(obj, obj2)
	return obj.x < obj2.x+obj2.w
	and obj2.x < obj.x+obj.w
end
local function isYCollide(obj, obj2)
	return obj.y < obj2.y+obj2.h
	and obj2.y < obj.y+obj.h
end

function addSpriteToCanvas(image)
	local lastSpriteData = spriteData[#spriteData]
	
	local x = 0
	local y = 0
	local w = image:getWidth()
	local h = image:getHeight()
	
	if lastSpriteData then
		x = lastSpriteData.x+lastSpriteData.w
		y = lastSpriteData.y
	end
	if x+w > MAX_WIDTH then
		x = 0
		y = y+_h
	end

	-- check for colliding sprites

	spriteSheetWidth = math.max(spriteSheetWidth, x+w)
	spriteSheetHeight = math.max(spriteSheetHeight, y+h)

	table.insert(spriteData, {
		x = x,
		y = y,
		w = w,
		h = h,
		i = image
	})
	for _,spr in pairs(spriteData) do
		for _,spr2 in pairs(spriteData) do
			if spr ~= spr2 then
				if isXCollide(spr,spr2) then
					spr2.x = spr.x+spr.w
				end
				if x+w > MAX_WIDTH then
					x = 0
					y = y+_h
				end
				if isYCollide(spr,spr2) then
					spr2.y = spr.y+spr.h
				end
			
				-- check for colliding sprites
			
				spriteSheetWidth = math.max(spriteSheetWidth, x+w)
				spriteSheetHeight = math.max(spriteSheetHeight, y+h)
			end
		end
	end
	if not dotYoyFile[animName.text] then
		dotYoyFile[animName.text] = {
			fps = tonumber(animFPS.text),
			loop = (tonumber(animLoop.text) == 1),
			frames = {}
		}
	end

	dotYoyFile[animName.text].frames[#dotYoyFile[animName.text].frames+1] = {
		x = x,
		y = y,
		w = w,
		h = h
	}
end

function saveSheet()
	spriteSheet = love.graphics.newCanvas(spriteSheetWidth, spriteSheetHeight)
	love.graphics.setCanvas(spriteSheet)
	for _,i in pairs(spriteData) do
		love.graphics.draw(i.i, i.x, i.y)
	end
	love.graphics.setCanvas()
	spriteSheet:newImageData():encode("png", "sprite.png")
	love.filesystem.write("sprite.xml", json.encode(dotYoyFile))
end

function load()
	spriteData = {}
	dotYoyFile = {}
	spriteSheet = nil

	spriteSheetWidth = 0
	spriteSheetHeight = 0
	_startOfNewY = 1

	spritePath = textboxClass(0,100,100,64,"sprite path")
	animName = textboxClass(0,100+(64),100,64,"anim name",true)
	animFrame = textboxClass(0,100+(64*2),100,64,"current frame",true)
	animFPS = textboxClass(0,100+(64*3),100,64,"anim fps",true)
	animLoop = textboxClass(0,100+(64*4),100,64,"loop (0=no, 1=yes)",true)
	saveButton = buttonClass(0,100+(64*5),100,64,"save",true)

	add(spritePath)
	add(animName)
	add(animFrame)
	add(animFPS)
	add(animLoop)
	add(saveButton)

	spritePath.onEnd = function(self,t)
		if not love.filesystem.getInfo(ASSET_PATH..t..".png", "file") then return end
		addSpriteToCanvas(love.graphics.newImage(ASSET_PATH..t..".png"))
	end
	saveButton.onPress = saveSheet
end

function draw()
	for _,i in pairs(spriteData) do
		love.graphics.draw(i.i, i.x, i.y)
	end
end

function textinput(t)
	spritePath:textinput(t)
	animName:textinput(t)
	animFrame:textinput(t)
	animFPS:textinput(t)
	animLoop:textinput(t)
end

function keypressed(key)
	spritePath:keypressed(key)
	animName:keypressed(key)
	animFrame:keypressed(key)
	animFPS:keypressed(key)
	animLoop:keypressed(key)
end