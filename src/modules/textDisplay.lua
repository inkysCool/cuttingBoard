local TextDisplay = {__type = "textDisplay"}

function TextDisplay.new(z,name,parent,pos,size,children,text)
	local self = setmetatable({},{__index = TextDisplay})

	self.type = "TextDisplay"
	self.name = name or ":("
	self.parent = parent or nil
	self.z = z or (parent and #self.parent.children+1 or 1)
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.z]=self
		self.offset[1] = self.offset[1]+self.parent.pos[1]+self.parent.offset[1]
		self.offset[2] = self.offset[2]+self.parent.pos[2]+self.parent.offset[2]
	end
	self.pos = pos or {0,0}
	self.size = size or {0,0}
	self.active = false
	self.text = text or ""

	return self
end

function TextDisplay:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function TextDisplay:press(x,y,elem)
	self.active = self.parent.active
end

function TextDisplay:updateOffset()
	self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
end

function TextDisplay:kill()
	if self.parent then
		self.parent.children[self.z]=nil
	end
end

function TextDisplay:draw()
	lg=love.graphics
	x,y = self.pos[1]+self.offset[1],self.pos[2]+self.offset[2]
	w,h = self.size[1],self.size[2]

	love.graphics.setColor(1,self.active and 1 or .5,1,1)

	lg.print(self.text,x,y)

	lg.print(self.z,x,y+h-16)
end

return TextDisplay