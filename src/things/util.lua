function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function findWithName(holder,name)
    for k,v in pairs(holder.children) do
        if v.name==name then
            return v
        end
    end
    return nil
end

function getElemFromPath(path,i)
    path = path
    i = i or 1
    for k,v in pairs(path[i].children) do
        if v.name==path[i+1] then
            i=i+1
            path[i]=v
            getElemFromPath(path,i)
        end
    end
    return path[#path]
end

function getElemPath(elem,tab)
    local t = tab or {}
    if elem.parent then
        t[#t+1] = elem.name
        getElemPath(elem.parent,t)
    else
        t[#t+1] = elem
    end

    if not tab then
        for n=1,#t/2+.5 do
            t[n],t[#t-n+1]=t[#t-n+1],t[n]
        end
    end

    return t
end

function findParentless(holder,type)
    local t = {}
    for k,v in pairs(table) do
        if not v.parent then
            if type=="key" then
                t[#t+1]=k
            elseif type=="elem" then
                t[#t+1]=v
            end
        end
    end
    return t
end