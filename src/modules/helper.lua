local Helper = {__type = "helper"}

function Helper.new()
    local self = setmetatable({},{__index = Helper})

    self.contents = {}
    self.buttonQueue = {}
    
    return self
end

function Helper:updateContents(holder,tab)
    if not tab then
        print("Updating contents!")
    end
    local t=tab or {}
    t[#t+1]=holder
    if holder.children then
        for k,v in pairs(holder.children) do
            if v.children~={} then
                t=self:updateContents(v,t)
            else
                t[#t+1]=v
            end
        end
    end
    self.contents = t
    return t
end

function Helper:queueButton(button)
    self.buttonQueue[#self.buttonQueue+1]=button
end

function Helper:useQueuedButtons()
    if self.buttonQueue~={} then
        for k,v in pairs(self.buttonQueue) do
            if selected==v.parent or (v.parent.type=="TitleBar" and selected==v.parent.parent) or v.parent.active then
                v:func()
            end
        end
        self.buttonQueue={}
    end
end

-- function Helper:

function Helper:getOfType(type)
    local t = {}
    for k,v in pairs(self.contents) do
        if v.type==type then t[#t+1]=v end
    end
    return t
end

function Helper:debugPrint()
    for k,v in pairs(self.contents) do
        print(k..": "..v.name.." | "..v.type)
    end
    print(#self.contents)
end

return Helper