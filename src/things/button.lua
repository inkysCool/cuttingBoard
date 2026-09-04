local Helper=require("things.helper")
local Button = {__type = "button"}

function Button.new(z,name,parent,pos,size,func,text,index)
	local self = setmetatable({},{__index = Button})

	self.type = "Button"
	self.name = name or ":("
	self.parent = parent or nil
	self.z = z or (parent and #self.parent.children+1 or 1)
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.z]=self
		self.offset[1] = self.offset[1]+self.parent.pos[1]+self.parent.offset[1]
		self.offset[2] = self.offset[2]+self.parent.pos[2]+self.parent.offset[2]
	end
	if self.parent.type=="TitleBar" then
		self.size = {type(size[1])=="number" and size[1] or self.parent.size[2],self.parent.size[2]}
		self.pos = {self.parent.size[1]-self.size[1],0}
	else
		self.size = size or {0,0}
		self.pos = (pos or {0,0})
	end
	self.active = false
	self.func = func or nil
	self.text = text or ""

	return self
end

function Button:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function Button:press(x,y)
	active = self:aabb(x,y)
	self.active = self.parent.active or active

	if active then
		-- self:func()
		HelperTable:queueButton(self)
	end
end

function Button:updateOffset()
	self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
end

function Button:kill()
	if self.parent then
		self.parent.children[self.z]=nil
	end
end

function Button:draw()
	lg=love.graphics
	x,y = self.pos[1]+self.offset[1],self.pos[2]+self.offset[2]
	w,h = self.size[1],self.size[2]
	-- print(self.offset[1])

	love.graphics.setColor(0,.5,.5,1)
	if self.active then
		love.graphics.setColor(0,1,1,1)
	end
	lg.rectangle("fill",x,y,w,h)
	love.graphics.setColor(1,self.active and 1 or 0,1,1)
	lg.rectangle("line",x,y,w,h)
	love.graphics.setColor(1,1,1,1)
	if self.active then
		love.graphics.setColor(0,0,0,1)
	end
	lg.print(self.text,x,y)
end

return Button