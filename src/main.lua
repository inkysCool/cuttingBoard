local Util=require("things.util")
local Helper=require("things.helper")

local Element=require("things.element")
local TitleBar=require("things.titleBar")
local Button=require("things.button")
local TextDisplay=require("things.textDisplay")
local TextInput=require("things.textInput")
local Viewport=require("things.viewport")

love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest","nearest")

function love.load()
	fwn=findWithName
	gfp=getElemFromPath
	HelperTable = Helper.new()
	Main = Element.new(nil,"main")
	Element.new(nil,"hi",Main,{64,32},{80,72})	

	TextDisplay.new(nil,"textTest",fwn(Main,"hi"),{8,32},{0,0},nil,"hi im text")
	Element.new(nil,"test",fwn(Main,"hi"),{64,32},{32,32})
	Element.new(nil,"heyo",gfp({Main,"hi","test"}),{32,64},{80,72})
	-- fwn(fwn(Main,"hi"),"test")

	Element.new(nil,"hey2",fwn(Main,"hi"),{32,64},{80,72})
	TitleBar.new(nil,"title1",fwn(Main,"hi"),16,"test title")

	Button.new(nil,"testButton",fwn(fwn(Main,"hi"),"title1"),{16,16},{"height",16},function(self)
		self.parent.parent:kill()
	end)

	Button.new(nil,"testButton1",fwn(Main,"hi"),{16,16},{32,16},function(self)
		fwn(self.parent,"textTest").text = "pressed!"
	end)

	Button.new(nil,"testButton2",fwn(fwn(Main,"hi"),"hey2"),{16,16},{32,16},function(self)
		self.parent:kill()
		-- print(table.concat(getElemPath(self), ", "))
	end)

	Element.new(nil,"testee",fwn(Main,"hi"),{128,32},{32,32})



	TitleBar.new(elements,"title3",fwn(fwn(Main,"hi"),"test"),8,"aaa title")


	Element.new(nil,"a",Main,{256,64},{256,192})
	TitleBar.new(nil,"title2",fwn(Main,"a"),16,"Love2D killer 3000")
	Button.new(nil,"killWindow",fwn(fwn(Main,"a"),"title2"),{0,0},{"height",16},function(self)
		self.parent.parent:kill()
	end," X")


	TextDisplay.new(nil,"killWindowText",fwn(Main,"a"),{8,24},{0,0},nil,"do YOU want to KILL Love2D?")
	Button.new(nil,"killWindowYes",fwn(Main,"a"),{16,152},{40,24},function(self)
		love.window.close()
	end," YES")
	Button.new(nil,"killWindowNo",fwn(Main,"a"),{200,152},{40,24},function(self)
		fwn(self.parent,"killWindowText").text = "well TOO BAD"
		self:kill()
	end," no :(")

	Element.new(nil,"b",Main,{256+32,128},{512,448})
	TitleBar.new(nil,"bTitle",fwn(Main,"b"),16,"Viewport test")
	Button.new(nil,"killWindowB",fwn(fwn(Main,"b"),"bTitle"),{0,0},{"height",16},function(button)
		button.parent.parent:kill()
	end," X")
	Viewport.new(nil,"viewport",fwn(Main,"b"),{16,32},{512-32,448-48},nil,love.graphics.newImage("package.png"))


	-- Main:shih()

	selected = nil
	-- print(HelperTable:updateContents(Main))
	HelperTable:updateContents(Main)
	-- HelperTable:debugPrint()

	--[[
	TODO

	- fix all update thingies in callback functions n stuff


	]]
end

function love.update(dt)
end

function love.draw()
	if love.window.isVisible() then
		love.graphics.clear()

		love.graphics.setColor(1,1,1,1)
		love.graphics.print(collectgarbage("count"))

		Main:draw()
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if selected and selected:aabb(x,y) then
		selected:press(x,y)
	else
		selected = nil
		Main:press(x,y)
	end
	HelperTable:useQueuedButtons()

	if selected then
		print(selected.name)
	end
	-- HelperTable:updateContents(Main)
end

function love.mousereleased(x, y, button, istouch, presses)
	for k,v in pairs(HelperTable:getOfType("TitleBar")) do
		v.held=false
	end
end

function love.wheelmoved(x,y)
	for k,v in pairs(HelperTable:getOfType("Viewport")) do
		mx,my=love.mouse.getPosition()
		v:updateCanvas("scale",y,mx,my)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if love.window.isVisible() then
		if not selected then
			for k,v in pairs(HelperTable:getOfType("TitleBar")) do
				v:hold(dx,dy)
			end
		elseif selected and selected.type=="Element" then
			b,child = selected:hasChildOfType("TitleBar")
			if b then
				child:hold(dx,dy)
			end
		end
		for k,v in pairs(HelperTable:getOfType("Viewport")) do
			if love.mouse.isDown(3) then
				v:updateCanvas("move",nil,x,y,dx,dy)
			end
		end
	end
end