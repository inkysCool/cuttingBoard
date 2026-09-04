local TextInput = {__type = "textInput"}

function TextInput.new(holder,name,parent,pos,size,children,text)
	local self = setmetatable({},{__index = TextInput})

	self.holder = holder
	self.type = "TextDisplay"
	self.name = name or ":("
	self.parent = parent or nil
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.name]=self
		self.offset[1] = self.offset[1]+self.parent.pos[1]+self.parent.offset[1]
		self.offset[2] = self.offset[2]+self.parent.pos[2]+self.parent.offset[2]
	end
	self.pos = pos or {0,0}
	self.size = size or {0,0}
	self.active = false
	self.text = text or ""

	return self
end

function TextInput:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function TextInput:press(x,y,elem)
	active = self:aabb(x,y)

	self.active = self.parent and (self.parent.active and self.parent.active or active) or active
end

function TextInput:move(dx,dy)
	newPos = {self.pos[1]+dx,self.pos[2]+dy}
	ww,wh=love.window.getMode()

	if not self.parent then
		self.pos={math.max(0,math.min(ww-self.size[1]+1,newPos[1])),math.max(0,math.min(wh-self.size[2]+1,newPos[2]))}
	else
		self.pos={newPos[1],newPos[2]}
	end
end

function TextInput:updateOffset()
	self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
end

function TextInput:kill()
	if self.parent then
		self.parent.children[self.name]=nil
	end
	self.holder[self.name]=nil
end

function TextInput:draw()
	lg=love.graphics
	x,y = self.pos[1]+self.offset[1],self.pos[2]+self.offset[2]
	w,h = self.size[1],self.size[2]

	love.graphics.setColor(1,self.active and 1 or .5,1,1)

	lg.print(self.text,x,y)
end

return TextInput