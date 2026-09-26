getgenv().hooks = getgenv().hooks or {}

local hooks = {}

hooks.hookvalue = function(inst, callback)
    if not inst then return nil end
    local mt = getrawmetatable(game)
    local old = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(self, key, value)
        if self == inst and key == "Value" then
            value = callback(value, self)
        end
        return old(self, key, value)
    end)
    setreadonly(mt, true)
    return old
end

hooks.hookreadvalue = function(inst, callback)
    if not inst then return nil end
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        local val = old(self, key)
        if self == inst and key == "Value" then
            return callback(val, self)
        end
        return val
    end)
    setreadonly(mt, true)
    return old
end

hooks.hookscript = function(script, callback)
    if not script then return nil end
    local old = getfenv(script)
    local ok = pcall(function()
        hookfunction(script, function(...)
            return callback(script, ...)
        end)
    end)
    return ok
end

hooks.hookremote = function(remote, callback)
    if not remote then return nil end

    local name = remote.Name
    local class = remote.ClassName

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == remote and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local newargs = callback(args, method)
            if newargs then
                return old(self, table.unpack(newargs))
            end
        end
        return old(self, ...)
    end)
    return old
end

hooks.hookremotebyName = function(name, callback)
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and self.Name == name then
            local args = {...}
            local newargs = callback(args, self, method)
            if newargs then
                return old(self, table.unpack(newargs))
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
    return old
end

hooks.hookfunction = function(tbl, key, callback)
    if not tbl or not key then return nil end
    local old = tbl[key]
    tbl[key] = newcclosure(function(...)
        return callback(old, ...)
    end)
    return old
end

hooks.hookproperty = function(inst, prop, callback)
    if not inst or not prop then return nil end
    local mt = getrawmetatable(game)
    local old = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(self, key, value)
        if self == inst and key == prop then
            value = callback(value, self, key)
        end
        return old(self, key, value)
    end)
    setreadonly(mt, true)
    return old
end

hooks.hookmetamethod = function(obj, method, callback)
    local old
    old = hookmetamethod(obj, method, function(self, ...)
        return callback(old, self, ...)
    end)
    return old
end

hooks.hookgetgc = function(callback, filter)
    filter = filter or function() return true end
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and filter(obj) then
            pcall(callback, obj)
        end
    end
end

hooks.hookupvalue = function(fn, name, callback)
    if not fn or not name then return nil end
    local info = debug.getinfo(fn)
    if not info then return nil end

    local ups = debug.getupvalues and debug.getupvalues(fn) or nil
    if not ups and debug.getupvalue then
        ups = {}
        local i = 1
        while true do
            local n, v = debug.getupvalue(fn, i)
            if not n then break end
            ups[n] = v
            i = i + 1
        end
    end

    if ups and ups[name] ~= nil then
        local old = ups[name]
        debug.setupvalue(fn, 1, callback(old))
        return old
    end
    return nil
end

getgenv().hooks = hooks

return hooks