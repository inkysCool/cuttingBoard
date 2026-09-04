local Util=require("things.util")
local Helper=require("things.helper")
local Element = {__type = "element"}

function Element.new(z,name,parent,pos,size,children)
	local self = setmetatable({},{__index = Element})
	
	self.type = "Element"
	self.name = name or ":("
	self.parent = parent or nil
	self.z = z or (parent and #self.parent.children+1 or 1)
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.z]=self
		-- self.offset[1] = self.offset[1]+self.parent.pos[1]+self.parent.offset[1]
		-- self.offset[2] = self.offset[2]+self.parent.pos[2]+self.parent.offset[2]
		self.offset = {self.offset[1]+self.parent.pos[1]+self.parent.offset[1],self.offset[2]+self.parent.pos[2]+self.parent.offset[2]}
	end
	self.children = children or {}
	self.pos = pos or {0,0}
	self.size = size or {0,0}
	self.active = false

	return self
end

function Element:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function Element:press(x,y)
	local active = self:aabb(x,y)

	-- self.active = self.parent and (self.parent.active and self.parent.active or active) or active

	self.active = (self.parent and self.parent.active) or active

	if (not self.parent and self.active) or (self:hasChildOfType("TitleBar") and self.active and active) then
		if selected and selected~=self then
			selected.active = false
		end
		selected = self

		self.parent:SetTopChild(self.name)
	end

	-- self:sortChildren(true)
	if self.children then
		for k,v in pairs(self.children) do
			v:press(x,y)
		end
	end
end

function Element:move(dx,dy)
	-- newPos = {self.pos[1]+dx,self.pos[2]+dy}
	-- ww,wh=love.window.getMode()

	-- if self.parent then
	self.pos={self.pos[1]+dx,self.pos[2]+dy}
	-- else
	-- 	self.pos={clamp(0,newPos[1],ww-self.size[1]+1),clamp(0,newPos[2],wh-self.size[2]+1)}
	-- 	-- not sure if i'll keep this
	-- end

	if self.children~={} then
		for k,v in pairs(self.children) do
			if v.offset then
				v:updateOffset()
			end
		end
	end
end

function Element:updateOffset()
	-- self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	-- self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
	self.offset = {self.parent.pos[1]+self.parent.offset[1],self.parent.pos[2]+self.parent.offset[2]}
	for k,v in pairs(self.children) do
		v:updateOffset()
	end
end

function Element:kill(name)
	if name then
		b,child = self:hasChildWithName(name)
		if b then
			-- print(self.name..child.name.." | "..child.z)
			table.remove(self.children,child.z)
		end
	else
		if self.children~={} then
			for k,v in pairs(self.children) do
				v:kill()
				-- self.children[k]=nil
			end
		end
	end
	self:sortChildren()

	if self.parent and not name then
		self.parent:kill(self.name)
	end

	-- HelperTable:updateContents(Main)
	-- findWithName(self.holder,self.name) = nil
end

function Element:hasChildOfType(type)
	for k,v in pairs(self.children) do
		if v.type==type then
			return true,v
		end
	end
	return false
end

function Element:hasChildWithName(name)
	for k,v in pairs(self.children) do
		if v.name==name then
			return true,v
		end
	end
	return false
end

function Element:SetTopChild(name)
	local b,child = self:hasChildWithName(name)
	-- self:sortChildren()
	for k,v in pairs(self.children) do
		if v.z>child.z then
			v.z = v.z-1
		end
	end
	child.z = #self.children
	self:sortChildren()
end

function Element:sortChildren(desc)
	local tab={}
	for k,v in pairs(self.children) do
		tab[#tab+1]=v
	end
	self.children=tab
	if desc then
		table.sort(self.children,function(a,b)
			return a.z>b.z
		end)
	else
		table.sort(self.children,function(a,b)
			return a.z<b.z
		end)
	end
end

function Element:draw()
	lg=love.graphics
	x,y = self.pos[1]+self.offset[1],self.pos[2]+self.offset[2]
	w,h = self.size[1],self.size[2]

	love.graphics.setColor(0,0,.5,1)
	if self.active then
		love.graphics.setColor(1,0,1,1)
	end
	lg.rectangle("fill",x,y,w,h)

	love.graphics.setColor(1,self.active and 1 or 0,1,1)
	lg.rectangle("line",x,y,w,h)

	love.graphics.setColor(1,1,1,1)
	-- lg.print(self.name..":  "..self.offset[1]+self.pos[1].." "..self.offset[2]+self.pos[2],self.offset[1]+self.pos[1],self.offset[2]-16+self.pos[2])

	-- lg.print(self.name,x,y+self.size[2]-16)

	-- lg.print(self.name.."|"..self.z.."|"..(self.active and "active"or"not active"),x,y+h-16)

	-- if self.children~={} then
		-- self:sortChildren()
		for k,v in pairs(self.children) do
			v:draw()
		end
		-- -- for i=1,#self.children do
		-- -- 	print(self.children[i].type)
		-- -- 	self.children[i]:draw()
		-- -- end
	-- end
end

return Element