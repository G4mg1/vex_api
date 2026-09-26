local main = {}

local config = "/home/g4mg/vex/config.json"
local http = game:GetService("HttpService")
local latestversion = game:HttpGet("https://raw.githubusercontent.com/G4mg1/vex_api/main/version.txt")

checkhttp = function()
    local success, decode = pcall(function()
        return http:JsonDecode(readfile(config))
    end)
    if success and decode then
        getgenv().decoded = decode
        return true
    end
    return false
end

if checkhttp() then
    local http_use = getgenv().decoded["http_use"]
    local logo = getgenv().decoded["logo"]
    local path = getgenv().decoded["path"]
    local version = getgenv().decoded["version"]

    if version and latestversion then
        if tostring(version):gsub("%s+", "") ~= tostring(latestversion):gsub("%s+", "") then
            warn("[vex] outdated version: " .. tostring(version) .. " (latest: " .. tostring(latestversion) .. ")")
        end
    end

    if logo then
        local ok, data = pcall(game.HttpGet, game, logo)
        if ok and data then
            local targets = { "New_Logo.png", "new_logo.png", "Logo.png" }
            for _, name in ipairs(targets) do
                if isfile(name) then
                    pcall(delfile, name)
                end
            end
            pcall(writefile, "New_Logo.png", data)
        end
    end

    if path then
        for name, url in pairs(path) do
            local ok, src = pcall(game.HttpGet, game, url)
            if ok and src then
                local chunk = loadstring(src)
                if chunk then
                    local ran, err = pcall(chunk)
                    if not ran then
                        warn("[vex] failed to load " .. tostring(name) .. ": " .. tostring(err))
                    end
                else
                    warn("[vex] could not compile " .. tostring(name))
                end
            else
                warn("[vex] could not fetch " .. tostring(name) .. " from " .. tostring(url))
            end
        end
    end
end

return main
