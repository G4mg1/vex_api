local main = {}

local config = "/home/g4mg/vex/config.json"
local http = game:GetService("HttpService")
local latestversion = game:HttpGet("https://github.com/G4mg/vex_api/version")

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
    for i, v in pairs(getgenv().decoded) do
        if v then
            local http_use = v["http_use"]
            local logo = v["logo"]
            local path = v["path"]
            local version = v["version"]
            local tables_path = {}
            for _, file in ipairs(listfiles(path)) do
                table.insert(tables_path, file)
            end
            if tables_path then
                function main._new()
                   local main = tables_path["main"]
                   local tables = tables_path["tables"]
                   local func = tables_path["func"]
                   local web = tables_path["web"]
                   local hook = tables_path["hook"]

                   if tables and func and web and hook then
                     if tables then
                        return getgenv().tables == tables
                     end
                     if func then
                        return getgenv().func == func
                     end
                     if web then
                        return getgenv().web == web
                     end
                     if hook then
                        return getgenv().hook
                     end
                   end
                end
            end
        end
    end
end