local TitleBar = {__type = "titleBar"}

function TitleBar.new(z,name,parent,height,displayText)
	local self = setmetatable({},{__index = TitleBar})

	self.type = "TitleBar"
	self.name = name or ":("
	self.parent = parent or nil
	self.z = z or (parent and #self.parent.children+1 or 1)
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.z]=self
		self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
		self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
	end
	self.children = {}
	self.pos = {0,0}
	self.size = {self.parent.size[1],height or 0}
	self.active = false
	self.held = false
	self.displayText = displayText or ":("

	return self
end

function TitleBar:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function TitleBar:updateOffset()
	self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
	for k,v in pairs(self.children) do
		v:updateOffset()
	end
end

function TitleBar:press(x,y)
	active = self:checkHold(x,y)
	self.active = active
	if self.active then
		self.parent.active=true
	end

	if self.children then
		for k,v in pairs(self.children) do
			v:press(x,y)
		end
	end
end

function TitleBar:checkHold(x,y)
	self.held = self:aabb(x,y)
	return self.held
end

function TitleBar:hold(dx,dy)
	if self.held then
		self.parent:move(dx,dy)
	end
end

function TitleBar:kill()
	if self.children~={} then
		for k,v in pairs(self.children) do
			self.children[k]=nil
			v:kill()
		end
	end
	if self.parent then
		self.parent.children[self.z]=nil
	end
end

function TitleBar:draw()
	lg=love.graphics
	x,y = self.offset[1],self.offset[2]
	w,h = self.size[1],self.size[2]

	love.graphics.setColor(.5,0,0,1)
	if self.active then
		love.graphics.setColor(1,0,0,1)
	end
	lg.rectangle("fill",x,y,w,h)

	love.graphics.setColor(1,1,self.active and 1 or 0,1)
	lg.rectangle("line",x,y,w,h)

	love.graphics.setColor(1,1,1,1)
	lg.print(self.displayText,x,y)

	-- lg.print(self.name..":  "..self.offset[1]+self.pos[1].." "..self.offset[2]+self.pos[2],self.offset[1]+self.pos[1],self.offset[2]-16+self.pos[2])


	if self.children~={} then
		local i=1
		for k,v in pairs(self.children) do
			-- lg.print(k,x,y+i*16)
			i=i+1

			v:draw()
		end
	end
end

return TitleBar