getgenv().web = getgenv().web or {}

local http = game:GetService("HttpService")

local web = {}

web.get = function(url, headers)
    headers = headers or {}
    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "GET",
            Headers = headers
        })
    end)
    if ok and res then
        return res.Body, res.StatusCode, res.Headers
    end
    return nil, 0, nil
end

web.post = function(url, body, headers)
    headers = headers or {}
    headers["Content-Type"] = headers["Content-Type"] or "application/json"
    if type(body) == "table" then
        body = http:JSONEncode(body)
    end
    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
    if ok and res then
        return res.Body, res.StatusCode, res.Headers
    end
    return nil, 0, nil
end

web.put = function(url, body, headers)
    headers = headers or {}
    headers["Content-Type"] = headers["Content-Type"] or "application/json"
    if type(body) == "table" then
        body = http:JSONEncode(body)
    end
    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "PUT",
            Headers = headers,
            Body = body
        })
    end)
    if ok and res then
        return res.Body, res.StatusCode, res.Headers
    end
    return nil, 0, nil
end

web.delete = function(url, headers)
    headers = headers or {}
    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "DELETE",
            Headers = headers
        })
    end)
    if ok and res then
        return res.Body, res.StatusCode, res.Headers
    end
    return nil, 0, nil
end

web.patch = function(url, body, headers)
    headers = headers or {}
    headers["Content-Type"] = headers["Content-Type"] or "application/json"
    if type(body) == "table" then
        body = http:JSONEncode(body)
    end
    local ok, res = pcall(function()
        return request({
            Url = url,
            Method = "PATCH",
            Headers = headers,
            Body = body
        })
    end)
    if ok and res then
        return res.Body, res.StatusCode, res.Headers
    end
    return nil, 0, nil
end

web.getjson = function(url, headers)
    local body = web.get(url, headers)
    if not body then return nil end
    local ok, res = pcall(function()
        return http:JSONDecode(body)
    end)
    return ok and res or nil
end

web.postjson = function(url, body, headers)
    local res = web.post(url, body, headers)
    if not res then return nil end
    local ok, data = pcall(function()
        return http:JSONDecode(res)
    end)
    return ok and data or nil
end

web.download = function(url, savepath)
    local body = web.get(url)
    if not body then return false end
    local ok = pcall(function()
        if writefile then
            writefile(savepath, body)
        end
    end)
    return ok
end

web.upload = function(url, filepath, headers)
    if not readfile then return nil end
    local ok, data = pcall(readfile, filepath)
    if not ok or not data then return nil end
    return web.post(url, data, headers)
end

web.asset = function(id)
    return "https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(id)
end

web.thumbnail = function(id, size)
    size = size or "420x420"
    return "https://thumbnails.roblox.com/v1/assets?assetIds=" .. tostring(id) .. "&size=" .. size .. "&format=Png"
end

web.useravatar = function(id)
    return "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(id) .. "&size=420x420&format=Png"
end

web.getuserid = function(username)
    local body = web.postjson("https://users.roblox.com/v1/usernames/users", {
        usernames = {username},
        excludeBannedUsers = false
    })
    if body and body.data and body.data[1] then
        return body.data[1].id
    end
    return nil
end

web.getusername = function(userid)
    local body = web.getjson("https://users.roblox.com/v1/users/" .. tostring(userid))
    return body and body.name or nil
end

web.getgameinfo = function(universeid)
    return web.getjson("https://games.roblox.com/v1/games?universeIds=" .. tostring(universeid))
end

web.getserverlist = function(placeid)
    return web.getjson("https://games.roblox.com/v1/games/" .. tostring(placeid) .. "/servers/Public?limit=100")
end

web.joinexternal = function(url)
    local ok = pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(url)
    end)
    return ok
end

web.getpaste = function(id)
    return web.get("https://pastebin.com/raw/" .. tostring(id))
end

web.getgithub = function(repo, path, branch)
    branch = branch or "main"
    return web.get("https://raw.githubusercontent.com/" .. repo .. "/" .. branch .. "/" .. path)
end

web.versioncheck = function(url, current)
    local body = web.get(url)
    if not body then return false end
    body = body:gsub("%s+", "")
    current = tostring(current):gsub("%s+", "")
    return body ~= current, body
end

web.urlencode = function(str)
    return http:UrlEncode(str)
end

web.urldecode = function(str)
    local ok, res = pcall(function()
        return http:UrlDecode(str)
    end)
    return ok and res or nil
end

web.generateguid = function(wrap)
    local ok, res = pcall(function()
        return http:GenerateGUID(wrap ~= false)
    end)
    return ok and res or nil
end

web.spoof = function(url, method, body, headers)
    method = method or "GET"
    headers = headers or {}
    headers["User-Agent"] = headers["User-Agent"] or "Roblox/WinInet"
    headers["Content-Type"] = headers["Content-Type"] or "application/json"
    if type(body) == "table" then
        body = http:JSONEncode(body)
    end
    local ok, res = pcall(function()
        return http_request({
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
end

web.batch = function(requests)
    local results = {}
    for i, req in ipairs(requests) do
        local method = (req.method or "GET"):upper()
        if method == "GET" then
            results[i] = {web.get(req.url, req.headers)}
        elseif method == "POST" then
            results[i] = {web.post(req.url, req.body, req.headers)}
        elseif method == "PUT" then
            results[i] = {web.put(req.url, req.body, req.headers)}
        elseif method == "DELETE" then
            results[i] = {web.delete(req.url, req.headers)}
        elseif method == "PATCH" then
            results[i] = {web.patch(req.url, req.body, req.headers)}
        end
    end
    return results
end

web.webhook = function(url, content, options)
    options = options or {}
    if type(content) == "table" then
        options = content
        content = nil
    end

    local payload = {
        content = content or options.content or "",
        username = options.username or "vex",
        avatar_url = options.avatar_url,
        tts = options.tts or false,
        embeds = options.embeds,
        allowed_mentions = options.allowed_mentions
    }

    for k, v in pairs(payload) do
        if v == nil then payload[k] = nil end
    end

    local body, code = web.post(url, payload)
    return (code == 200 or code == 204), body, code
end

web.webhookembed = function(url, embed, options)
    options = options or {}
    return web.webhook(url, {
        content = options.content or "",
        username = options.username or "vex",
        avatar_url = options.avatar_url,
        embeds = {embed}
    })
end

web.webhookfile = function(url, filepath, filename, content)
    if not readfile then return false end
    local ok, data = pcall(readfile, filepath)
    if not ok or not data then return false end

    filename = filename or filepath:match("([^/\\]+)$") or "file.txt"

    local boundary = "----vexboundary" .. tostring(math.random(100000, 999999))
    local body = table.concat({
        "--" .. boundary,
        'Content-Disposition: form-data; name="content"',
        "",
        content or "",
        "--" .. boundary,
        'Content-Disposition: form-data; name="file"; filename="' .. filename .. '"',
        "Content-Type: application/octet-stream",
        "",
        data,
        "--" .. boundary .. "--",
        ""
    }, "\r\n")

    local ok2, res = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = body
        })
    end)
    return ok2 and res and (res.StatusCode == 200 or res.StatusCode == 204), res and res.Body, res and res.StatusCode
end

web.webhookedit = function(url, messageid, content, options)
    options = options or {}
    local payload = {
        content = content or options.content or "",
        username = options.username,
        embeds = options.embeds
    }
    for k, v in pairs(payload) do
        if v == nil then payload[k] = nil end
    end
    local body, code = web.patch(url .. "/messages/" .. tostring(messageid), payload)
    return code == 200, body, code
end

web.webhookdelete = function(url, messageid)
    local body, code = web.delete(url .. "/messages/" .. tostring(messageid))
    return code == 204, body, code
end

web.webhookget = function(url, messageid)
    local endpoint = url .. (messageid and ("/messages/" .. tostring(messageid)) or "")
    local body, code = web.get(endpoint)
    if code ~= 200 then return nil end
    return body, code
end

web.webhookbuilder = function(url)
    return {
        content = nil,
        username = "vex",
        avatar_url = nil,
        embeds = {},
        _url = url,

        setcontent = function(self, text)
            self.content = text
            return self
        end,

        setusername = function(self, name)
            self.username = name
            return self
        end,

        setavatar = function(self, url)
            self.avatar_url = url
            return self
        end,

        addembed = function(self, embed)
            table.insert(self.embeds, embed)
            return self
        end,

        embed = function(self)
            local e = {
                title = nil,
                description = nil,
                color = nil,
                fields = {},
                footer = nil,
                thumbnail = nil,
                image = nil,
                author = nil,
                timestamp = nil,
                _parent = self
            }

            e.settitle = function(s, t) s.title = t; return s end
            e.setdescription = function(s, d) s.description = d; return s end
            e.setcolor = function(s, c) s.color = c; return s end
            e.setfooter = function(s, f) s.footer = {text = f}; return s end
            e.setthumbnail = function(s, u) s.thumbnail = {url = u}; return s end
            e.setimage = function(s, u) s.image = {url = u}; return s end
            e.setauthor = function(s, n, u, i) s.author = {name = n, url = u, icon_url = i}; return s end
            e.settimestamp = function(s, t) s.timestamp = t; return s end
            e.addfield = function(s, n, v, inline)
                table.insert(s.fields, {name = n, value = v, inline = inline or false})
                return s
            end
            e.done = function(s)
                s._parent:addembed(s)
                s._parent = nil
                return s
            end
            return e
        end,

        send = function(self)
            local payload = {
                content = self.content or "",
                username = self.username,
                avatar_url = self.avatar_url,
                embeds = #self.embeds > 0 and self.embeds or nil
            }
            for k, v in pairs(payload) do
                if v == nil then payload[k] = nil end
            end
            return web.post(self._url, payload)
        end,
    }
end

getgenv().web = web

return web