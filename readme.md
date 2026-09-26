# vex

> A third-party Lua API engine built to give developers easy access to the game environment without the hard work.

---

## What is vex?

**vex** is a third-party Lua API engine made to let developers access the game environment easily — without doing the hard work themselves.

- **Created:** 2022, originally as a private internal project.
- **2024:** Released our first admin suite, **vex admin**, later renamed to **trez admin**.
- **Today:** vex corporation has shipped many scripts built on top of the same engine.

---

## Installation

```lua
local vex = loadstring(game:HttpGet("https://raw.githubusercontent.com/G4mg1/vex_api/main/main.lua"))()
```

All modules are exposed through `getgenv()` so any script can use them:

```lua
getgenv().web    -- web requests + webhooks
getgenv().func   -- utility / player / instance helpers
getgenv().hooks  -- metamethod + value + remote hooks
getgenv().tables -- persistent table storage
```

---

## Modules

### `web` — HTTP & Webhooks

Full request support, Roblox API helpers, and Discord webhook tooling.

```lua
local web = getgenv().web

-- basic requests
local body, code = web.get("https://httpbin.org/get")
web.post("https://httpbin.org/post", { hello = "world" })
web.put("https://httpbin.org/put", { x = 1 })
web.patch("https://httpbin.org/patch", { x = 2 })
web.delete("https://httpbin.org/delete")

-- json shortcuts
local data = web.getjson("https://httpbin.org/get")
local res  = web.postjson("https://httpbin.org/post", { a = 1 })

-- spoofed user-agent (Roblox/WinInet)
web.spoof("https://example.com/api", "POST", { key = "value" })

-- batch many calls
local results = web.batch({
    { url = "https://httpbin.org/get",  method = "GET" },
    { url = "https://httpbin.org/post", method = "POST", body = { x = 1 } },
})

-- roblox helpers
web.getuserid("Roblox")     --> 1
web.getusername(1)          --> "Roblox"
web.getgameinfo(1818)
web.getserverlist(1818)
web.asset(123456)
web.thumbnail(123456)

-- files
web.download("https://example.com/file.lua", "file.lua")
web.upload("https://myapi.com/upload", "file.lua")

-- version check
local outdated, latest = web.versioncheck("https://raw.githubusercontent.com/u/r/main/version", "1.0.0")

-- discord webhooks
local URL = "https://discord.com/api/webhooks/xxx/yyy"

web.webhook(URL, "hello from vex")
web.webhook(URL, { content = "loaded", username = "vex" })

web.webhookembed(URL, {
    title = "Status",
    description = "Script loaded",
    color = 65280,
    fields = { { name = "User", value = "g4mg", inline = true } }
})

web.webhookfile(URL, "script.lua", "script.lua", "here is my script")

-- builder style
local b = web.webhookbuilder(URL)
b:setcontent("loaded"):setusername("vex")
local e = b:embed()
e:settitle("Info"):setdescription("Builder test"):setcolor(0x00FF00)
e:addfield("User", "g4mg", true)
e:done()
b:send()
```

**Methods:**
`get` · `post` · `put` · `delete` · `patch` · `getjson` · `postjson` · `spoof` · `batch` · `download` · `upload` · `asset` · `thumbnail` · `useravatar` · `getuserid` · `getusername` · `getgameinfo` · `getserverlist` · `joinexternal` · `getpaste` · `getgithub` · `versioncheck` · `urlencode` · `urldecode` · `generateguid` · `webhook` · `webhookembed` · `webhookfile` · `webhookedit` · `webhookdelete` · `webhookget` · `webhookbuilder`

---

### `func` — Utility & Game Helpers

Everything you'd normally write by hand: player info, character access, teleports, firetouch, metatable tools.

```lua
local func = getgenv().func

-- http
local body, code = func.getrawhttreq("https://httpbin.org/get", "GET")
func.httpget("https://httpbin.org/get")
func.httppost("https://httpbin.org/post", { x = 1 })

-- json
local str  = func.jsonencode({ a = 1 })
local data = func.jsondecode(str)

-- player helpers
local plr  = game.Players.LocalPlayer
local char = func.getchar(plr)
local hum  = func.gethrp(plr) and char:FindFirstChildOfClass("Humanoid")
local root = func.getroot(plr)

-- movement
func.walk(100)
func.jump(75)
func.teleport(Vector3.new(0, 50, 0))
func.bring(game.Players:GetPlayers()[2])

-- interaction
func.firetouch(plr, workspace.Part)
func.fireclick(plr, workspace.Button)
func.fireprox(remote, args)
func.invoke(remote, args)

-- instance search
func.find(workspace, "Baseplate")
func.findall(workspace, "Part", "Part")
func.getall(workspace, "Part")
func.waitfor(workspace, "Baseplate", 10)

-- input
func.keypress(Enum.KeyCode.E)
func.mouseclick()

-- ui
func.notify("vex", "loaded", 5)
func.copyclipboard("hello")
local txt = func.pastein()

-- hooks
func.hookfunc(game.Players.LocalPlayer, "Kick", function(old, ...) end)
func.hookmetamethod(game, "__index", function(old, self, key) return old(self, key) end)

-- env
func.getenv("web")
func.setenv("mykey", 123)

-- misc
func.random(1, 100)
func.round(1.567, 2)
func.tohex(255)
func.time()
func.date()
func.benchmark(function() end)
func.retry(3, 1, function() return true end)
func.debounce(0.5, function() end)
```

---

### `hooks` — Metamethod, Value & Remote Hooks

Hook into any value, property, remote, function, or metatable.

```lua
local hooks = getgenv().hooks

-- lock a value / intercept writes
hooks.hookvalue(workspace.SomeValue, function(v, inst)
    print("changing to:", v)
    return v
end)

-- fake reads
hooks.hookreadvalue(game.Players.LocalPlayer.leaderstats.Cash, function(v)
    return 999999
end)

-- properties
hooks.hookproperty(workspace.Baseplate, "Transparency", function(v)
    return 0.5
end)

-- remotes (specific instance)
hooks.hookremote(game.ReplicatedStorage.Remotes.Attack, function(args, method)
    args[1] = 999
    return args
end)

-- remotes (by name, catches all)
hooks.hookremotebyName("BuyItem", function(args, remote, method)
    args[1] = "free_item"
    return args
end)

-- functions
hooks.hookfunction(game.Players.LocalPlayer, "Kick", function(old, ...)
    print("kick blocked")
end)

-- metamethods
hooks.hookmetamethod(game, "__index", function(old, self, key)
    return old(self, key)
end)

-- walkspeed / jumppower / health / position / gravity
hooks.hookwalkspeed(function(v) return 50 end)
hooks.hookjumppower(function(v) return math.min(v, 100) end)
hooks.hookhealth(function(v) return 100 end)
hooks.hookposition(function(cf) return cf end)
hooks.hookgravity(function(v) return 50 end)

-- scan the gc
hooks.hookgetgc(function(obj) end, function(obj) return true end)

-- upvalues
hooks.hookupvalue(someFunction, "upvalName", function(old) return old end)
```

---

### `tables` — Persistent Storage

Save / load tables to disk and keep them in `getgenv().tables` for other scripts.

```lua
local store = getgenv().tables

-- load everything saved
store.load_tables()

-- one table
store.set_table("guns", { ak47 = 30, m4 = 25 })
print(store.get_table("guns").ak47)     --> 30

-- many tables at once (1k+ safe)
store.set_tables({
    config  = { theme = "dark" },
    weapons = { sword = 10, bow = 5 },
})

-- list names
for _, name in ipairs(store.list_tables()) do
    print(name)
end
```

---

## Quick Example

```lua
-- load vex
local vex = loadstring(game:HttpGet("https://raw.githubusercontent.com/G4mg1/vex_api/main/main.lua"))()

local web   = getgenv().web
local func  = getgenv().func
local hooks = getgenv().hooks

-- notify in-game
func.notify("vex", "loaded successfully", 5)

-- log to discord
web.webhook("https://discord.com/api/webhooks/xxx/yyy", {
    content  = "vex loaded for " .. game.Players.LocalPlayer.Name,
    username = "vex"
})

-- lock walkspeed
hooks.hookwalkspeed(function(v) return 50 end)
```

---

## Notes

- Every module writes into `getgenv()` so any script can grab it after loading.
- All network calls are wrapped in `pcall` — failures return `nil` instead of erroring.
- Hook functions return the original, so you can restore manually if needed.

---

## Credits

**vex corporation** — created 2022, public 2024.
Built on the same engine that powers **trez admin**.
