local http = game:GetService("HttpService")
local players = game:GetService("Players")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = players.LocalPlayer

getgenv().func = getgenv().func or {}

local func = {

    getrawhttreq = function(url, method, body, headers)
        method = method or "GET"
        headers = headers or {}
        headers["Content-Type"] = headers["Content-Type"] or "application/json"
        local ok, res = pcall(function()
            return request({
                Url = url,
                Method = method,
                Headers = headers,
                Body = body
            })
        end)
        if ok and res then
            return res.Body, res.StatusCode, res.Headers
        end
        return nil, 0, nil
    end,

    httpget = function(url, headers)
        return func.getrawhttreq(url, "GET", nil, headers)
    end,

    httppost = function(url, body, headers)
        if type(body) == "table" then
            body = http:JSONEncode(body)
        end
        return func.getrawhttreq(url, "POST", body, headers)
    end,

    jsonencode = function(tbl)
        local ok, res = pcall(function()
            return http:JSONEncode(tbl)
        end)
        return ok and res or nil
    end,

    jsondecode = function(str)
        local ok, res = pcall(function()
            return http:JSONDecode(str)
        end)
        return ok and res or nil
    end,

    getasset = function(id)
        return "rbxassetid://" .. tostring(id)
    end,

    getthumbnail = function(id, size)
        size = size or "420x420"
        local url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(id) .. "&width=" .. size:match("(%d+)") .. "&height=" .. size:match("x(%d+)") .. "&format=png"
        return url
    end,

    getavatar = function(id)
        return "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. tostring(id) .. "&size=420x420&format=Png"
    end,

    getuserid = function(name)
        local body, code = func.getrawhttreq("https://users.roblox.com/v1/usernames/users", "POST", http:JSONEncode({usernames = {name}, excludeBannedUsers = false}))
        if body then
            local data = func.jsondecode(body)
            if data and data.data and data.data[1] then
                return data.data[1].id
            end
        end
        return nil
    end,

    getusername = function(id)
        local body = func.getrawhttreq("https://users.roblox.com/v1/users/" .. tostring(id))
        if body then
            local data = func.jsondecode(body)
            return data and data.name or nil
        end
        return nil
    end,

    getgameinfo = function(placeid)
        local body = func.getrawhttreq("https://games.roblox.com/v1/games?universeIds=" .. tostring(placeid))
        if body then
            return func.jsondecode(body)
        end
        return nil
    end,

    getplayers = function()
        return players:GetPlayers()
    end,

    getchar = function(plr)
        plr = plr or lp
        return plr.Character or plr.CharacterAdded:Wait()
    end,

    gethrp = function(plr)
        local char = func.getchar(plr)
        return char and char:FindFirstChildOfClass("Humanoid") or nil
    end,

    getroot = function(plr)
        local char = func.getchar(plr)
        return char and char:FindFirstChild("HumanoidRootPart") or nil
    end,

    gethrp = function(plr)
        local char = func.getchar(plr)
        return char and char:FindFirstChild("HumanoidRootPart") or nil
    end,

    walk = function(speed, plr)
        local hum = func.gethrp(plr) and func.getchar(plr):FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end,

    jump = function(power, plr)
        local hum = func.getchar(plr):FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = power
        end
    end,

    teleport = function(target, plr)
        local root = func.getroot(plr)
        if root then
            if typeof(target) == "Vector3" then
                root.CFrame = CFrame.new(target)
            elseif typeof(target) == "CFrame" then
                root.CFrame = target
            elseif typeof(target) == "Instance" then
                root.CFrame = target.CFrame
            end
        end
    end,

    bring = function(targetplr, plr)
        local root = func.getroot(targetplr)
        local myroot = func.getroot(plr)
        if root and myroot then
            root.CFrame = myroot.CFrame
        end
    end,

    keypress = function(key)
        local ok = pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
        end)
        return ok
    end,

    mouseclick = function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end,

    notify = function(title, text, duration)
        duration = duration or 5
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration
            })
        end)
    end,

    copyclipboard = function(text)
        pcall(function()
            setclipboard(tostring(text))
        end)
    end,

    pastein = function()
        local ok, res = pcall(function()
            return getclipboard()
        end)
        return ok and res or nil
    end,

    waitfor = function(inst, timeout)
        timeout = timeout or 10
        local ok, res = pcall(function()
            return inst:WaitForChild(inst.Name, timeout)
        end)
        return ok and res or nil
    end,

    find = function(parent, name, class)
        for _, v in ipairs(parent:GetDescendants()) do
            if v.Name == name then
                if not class or v.ClassName == class then
                    return v
                end
            end
        end
        return nil
    end,

    findall = function(parent, name, class)
        local found = {}
        for _, v in ipairs(parent:GetDescendants()) do
            if v.Name == name then
                if not class or v.ClassName == class then
                    table.insert(found, v)
                end
            end
        end
        return found
    end,

    getall = function(parent, class)
        local found = {}
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA(class) then
                table.insert(found, v)
            end
        end
        return found
    end,

    firetouch = function(plr, part)
        local root = func.getroot(plr)
        if root and part then
            firetouchinterest(root, part, 0)
            task.wait(0.05)
            firetouchinterest(root, part, 1)
        end
    end,

    fireclick = function(plr, part)
        local root = func.getroot(plr)
        if root and part then
            fireclickdetector(part:FindFirstChildOfClass("ClickDetector") or part, 0)
        end
    end,

    fireprox = function(remote, ...)
        if remote then
            remote:FireServer(...)
        end
    end,

    invoke = function(remote, ...)
        if remote then
            return remote:InvokeServer(...)
        end
    end,

    hookmetamethod = function(obj, method, callback)
        local old
        old = hookmetamethod(obj, method, function(self, ...)
            return callback(old, self, ...)
        end)
        return old
    end,

    hookfunc = function(tbl, key, callback)
        local old = tbl[key]
        tbl[key] = function(...)
            return callback(old, ...)
        end
        return old
    end,

    getenv = function(key)
        return getgenv()[key]
    end,

    setenv = function(key, value)
        getgenv()[key] = value
        return value
    end,

    random = function(min, max)
        return math.random(min, max)
    end,

    round = function(num, places)
        places = places or 0
        local mult = 10 ^ places
        return math.floor(num * mult + 0.5) / mult
    end,

    tohex = function(num)
        return string.format("0x%X", num)
    end,

    time = function()
        return os.time()
    end,

    date = function(format)
        format = format or "%Y-%m-%d %H:%M:%S"
        return os.date(format)
    end,

    benchmark = function(cb)
        local start = os.clock()
        cb()
        return os.clock() - start
    end,

    retry = function(times, delay, cb)
        delay = delay or 1
        for i = 1, times do
            local ok, res = pcall(cb)
            if ok then return res end
            task.wait(delay)
        end
        return nil
    end,

    debounce = function(delay, cb)
        local last = 0
        return function(...)
            if os.clock() - last >= delay then
                last = os.clock()
                return cb(...)
            end
        end
    end,
}

getgenv().func = func

return func