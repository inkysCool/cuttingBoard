local Util=require("things.util")
local Viewport = {__type = "Viewport"}

function Viewport.new(holder,name,parent,pos,size,children,image)
	local self = setmetatable({},{__index = Viewport})

	self.holder = holder
	self.type = "Viewport"
	self.name = name or ":("
	self.parent = parent or nil
	self.z = z or (parent and #self.parent.children+1 or 1)
	self.offset = {0,0}
	if self.parent then
		self.parent.children[self.z]=self
		self.offset[1] = self.offset[1]+self.parent.pos[1]+self.parent.offset[1]
		self.offset[2] = self.offset[2]+self.parent.pos[2]+self.parent.offset[2]
	end
	self.children = children or {}
	self.pos = pos or {0,0}
	self.size = size or {0,0}
	self.active = false

	self.display = {
		image = image or nil,
		canvas = love.graphics.newCanvas(),
		pivot = {0,0},
		offset = {0,0},
		scale = 1
	}

	self:redrawCanvas()

	return self
end

function Viewport:aabb(x2,y2)
	x,y = x2-self.pos[1]-self.offset[1],y2-self.pos[2]-self.offset[2]
	w,h = self.size[1],self.size[2]

	return x>0 and x<w and y>0 and y<h
end

function Viewport:press(x,y,elem)
	active = self:aabb(x,y)

	self.active = self.parent and (self.parent.active and self.parent.active or active) or active

	if self.children then
		for k,v in pairs(self.children) do
			if (elem and k~=elem.name) or not elem then
				v:press(x,y)
			end
		end
	end
end

function Viewport:updateOffset()
	self.offset[1] = self.parent.pos[1]+self.parent.offset[1]
	self.offset[2] = self.parent.pos[2]+self.parent.offset[2]
	for k,v in pairs(self.children) do
		v:updateOffset()
	end
end

function Viewport:kill()
	if self.children~={} then
		for k,v in pairs(self.children) do
			self.children[k]=nil
			v:kill()
		end
	end
	if self.parent then
		self.parent.children[self.z]=nil
	end
	-- self.holder[self.name]=nil
end

function Viewport:updateCanvas(mode,scroll,x,y,dx,dy)
	d=self.display
	b,child = self.parent:hasChildOfType("TitleBar")

	if b and not child.held then
		if self:aabb(x,y) and mode=="scale" then
			if d.scale>=1/2 and d.scale<=16 then
				d.pivot = {x-self.offset[1]-self.pos[1],y-self.offset[2]-self.pos[2]}
			end

		    mult = scroll>0 and d.scale<16 and 2 or (scroll<0 and d.scale>1/2 and 1/2 or 1)

			d.scale=clamp(1/2, d.scale*mult, 16)

		    d.offset[1]=d.pivot[1]+mult*(d.offset[1]-d.pivot[1])
			d.offset[2]=d.pivot[2]+mult*(d.offset[2]-d.pivot[2])

			-- d.offset[1]=clamp(0,d.pivot[1]+mult*(d.offset[1]-d.pivot[1]),d.image:getWidth()*d.scale)
		end

		if self.active and mode=="move" then
			d.offset[1] = d.offset[1]+dx
			d.offset[2] = d.offset[2]+dy
			
			-- if d.image:getWidth()*d.scale<=self.size[1] then
			-- 	d.offset[1] = clamp(0,d.offset[1]+dx,self.size[1]-d.image:getWidth()*d.scale)
			-- else
			-- 	d.offset[1] = d.offset[1]+dx
			-- end

			-- if d.image:getHeight()*d.scale<=self.size[2] then
			-- 	d.offset[2] = clamp(0,d.offset[2]+dy,self.size[2]-d.image:getHeight()*d.scale)
			-- else
			-- 	d.offset[2] = d.offset[2]+dy
			-- end
			
		end

		self:redrawCanvas()
	end
end

function Viewport:redrawCanvas()
	d=self.display
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas(d.canvas)
	love.graphics.clear(0,0,0,1)
	love.graphics.draw(d.image,d.offset[1],d.offset[2],0,d.scale,d.scale)

	love.graphics.circle("line", d.offset[1],d.offset[2], 8, 16)
	love.graphics.circle("line", d.offset[1]+d.image:getWidth()*d.scale,d.offset[2], 8, 16)
	love.graphics.circle("line", d.offset[1],d.offset[2]+d.image:getHeight()*d.scale, 8, 16)
	love.graphics.circle("line", d.offset[1]+d.image:getWidth()*d.scale,d.offset[2]+d.image:getHeight()*d.scale, 8, 16)
	
	love.graphics.circle("line", d.pivot[1],d.pivot[2], 8, 16)

	love.graphics.setCanvas()
end

function Viewport:draw()
	lg=love.graphics
	canv = self.display.canvas

	x,y = self.pos[1]+self.offset[1],self.pos[2]+self.offset[2]
	w,h = self.size[1],self.size[2]

	love.graphics.setColor(1,1,1,1)

	love.graphics.setScissor(x,y,w,h)

	lg.draw(canv,x,y)

	love.graphics.setScissor()

	if self.children~={} then
		local i=1
		for k,v in pairs(self.children) do
			i=i+1
			v:draw()
		end
	end
end

return Viewport