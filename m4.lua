-- ⚡ MYLF | Hub ⚡ — mmenu9.lua + features9.8.lua (robust loader, OnChanged/Callback uyumlu)

-- === Universal fetch (syn.request / http_request / request / HttpGetAsync) ===
local function fetch(url)
    local ok, res
    if syn and syn.request then ok, res = pcall(syn.request, {Url=url, Method="GET"}); if ok and res and res.Body then return res.Body end end
    if http_request          then ok, res = pcall(http_request, {Url=url, Method="GET"}); if ok and res and res.Body then return res.Body end end
    if request               then ok, res = pcall(request,      {Url=url, Method="GET"}); if ok and res and res.Body then return res.Body end end
    if game and game.HttpGet then ok, res = pcall(function() return game:HttpGet(url) end); if ok and res then return res end end
    ok, res = pcall(function() return game:HttpGetAsync(url) end); if ok and res then return res end
    error("HTTP fetch failed for: "..tostring(url))
end

local MMENU9_URL   = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"
local FEATURES_URL = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"

-- === Load mmenu9 (Library, ThemeManager, SaveManager) ===
local libFn, lfErr = loadstring(fetch(MMENU9_URL)); assert(libFn, "mmenu9 compile err: "..tostring(lfErr))
local r1, r2, r3 = libFn()
local Library, ThemeManager, SaveManager
if type(r1)=="table" and r1.CreateWindow then
    Library, ThemeManager, SaveManager = r1, r2, r3
elseif type(r1)=="table" and r1.Library then
    Library, ThemeManager, SaveManager = r1.Library, r1.ThemeManager, r1.SaveManager
else
    error("mmenu9.lua expected to return Library (CreateWindow).")
end

-- Stubs (mmenu9 farklı dönerse loader kırılmasın)
if not ThemeManager then
    local __theme = { Accent=Color3.fromRGB(230,57,70), Background=Color3.fromRGB(16,16,18), Outline=Color3.fromRGB(255,255,255) }
    local mt = { __newindex=function(_,k,v) __theme[k]=v; if Library.SetTheme then Library:SetTheme({[k]=v}) end end,
                 __index=function(_,k) return __theme[k] end }
    ThemeManager = {
        SetLibrary=function()end, SetFolder=function()end, ApplyToTab=function()end,
        CurrentTheme=function() return setmetatable({}, mt) end
    }
end
if not SaveManager then
    SaveManager = {
        SetLibrary=function()end, SetFolder=function()end, IgnoreThemeSettings=function()end,
        SetIgnoreIndexes=function()end, BuildConfigSection=function()end
    }
end

-- === Load features ===
local featFn, feErr = loadstring(fetch(FEATURES_URL)); assert(featFn, "features compile err: "..tostring(feErr))
local features = featFn()

-- === Window (AutoShow=false) ===
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- === Menu toggle (LeftControl) ===
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
Library.ToggleKeybind = MENU_KEY
local function ToggleMenu() if Library.Toggle then Library:Toggle() elseif Library.ToggleUI then Library:ToggleUI() end end
UIS.InputBegan:Connect(function(inp, gp) if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end end)

-- === Tabs ===
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- ---- Helpers: mmenu9 (Callback) + eski sürüm (OnChanged) uyum katmanı ----
local function bindToggle(group, flag, text, fn)
    local obj = group:AddToggle(flag, { Text = text, Default = false, Callback = function(v)
        if type(fn)=="function" then pcall(fn, v) end
    end})
    if obj and obj.OnChanged then obj:OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end) end
    return obj
end
local function bindSlider(group, flag, cfg, onChange)
    cfg = cfg or {}; cfg.Callback = function(v) if type(onChange)=="function" then pcall(onChange, v) end end
    local obj = group:AddSlider(flag, cfg)
    if obj and obj.OnChanged then obj:OnChanged(function(v) if type(onChange)=="function" then pcall(onChange, v) end end) end
    return obj
end

-- === 🔥 RAGE ===
do
    local g  = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g,"aimbot","Enable Aimbot",features.ToggleAimbot)
    bindToggle(g,"headshotRedirect","Force Headshot",features.ToggleHeadshotRedirect)
    bindToggle(g,"fireRate","Hard Fire Rate",features.ToggleFireRate)
    bindToggle(g,"silent","Silent Aim",features.ToggleSilentAim)
    bindToggle(g,"magic","Magic Bullet (Fallback)",features.ToggleMagicBullet)
    bindToggle(g,"killAura","☠️ Kill Aura",features.ToggleKillAura)

    local r = Tabs.Rage:AddRightGroupbox("Recoil / Spread")
    bindToggle(r,"norecoil","No Recoil",features.ToggleNoRecoil)
    bindToggle(r,"nospread","No Spread",features.ToggleNoSpread)
end

-- === 👁 VISUALS ===
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g,"esp","Enable ESP",features.ToggleESP)
    bindToggle(g,"enemyBigHB","🎯 Enemy Big Hitbox",features.ToggleEnemyBigHitbox)
end

-- === 🕴 PLAYER ===
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g,"speed","Speed Boost (50)",features.ToggleSpeed)
    bindToggle(g,"fly","Fly (LCtrl down)",features.ToggleFly)
    bindToggle(g,"infjump","Infinite Jump",features.ToggleInfiniteJump)
    bindToggle(g,"godmode","💀 Godmode",features.ToggleGodmode)
    bindToggle(g,"hardInvis","👻 Hard Invisible",features.ToggleHardInvisible)
    bindToggle(g,"noclip","NoClip",features.ToggleNoclip)
end

-- === ⚡ TELEPORT ===
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g,"tpkey","Teleport (T Key)",features.ToggleTeleport)
    bindToggle(g,"autoBehind","⚡ Always Behind Enemy",features.ToggleAutoBehind)
    bindToggle(g,"autoTP","⚡ Auto Farm Enemy",features.ToggleAutoTeleportToEnemy)

    local Options = getgenv().Options or _G.Options or Library.Options
    local function pushOffsets()
        local x = (Options and Options.tpX and Options.tpX.Value) or 0
        local y = (Options and Options.tpY and Options.tpY.Value) or 0
        local z = (Options and Options.tpZ and Options.tpZ.Value) or 25
        features._tpX, features._tpY, features._tpZ = x, y, z
        if type(features.SetTeleportOffset)=="function" then pcall(features.SetTeleportOffset, x, y, z) end
    end

    bindSlider(g,"tpX",{Text="X Offset", Min=-50, Max=50,  Default=0,  Rounding=1}, pushOffsets)
    bindSlider(g,"tpY",{Text="Y Offset", Min=-50, Max=50,  Default=0,  Rounding=1}, pushOffsets)
    bindSlider(g,"tpZ",{Text="Z Offset", Min=1,   Max=100, Default=25, Rounding=1}, pushOffsets)

    -- Options tarafı varsa (mmenu9 global), onun üzerinden de dinle:
    task.defer(function()
        local Opt = getgenv().Options or _G.Options or Library.Options
        if Opt and Opt.tpX and Opt.tpX.OnChanged then Opt.tpX:OnChanged(pushOffsets) end
        if Opt and Opt.tpY and Opt.tpY.OnChanged then Opt.tpY:OnChanged(pushOffsets) end
        if Opt and Opt.tpZ and Opt.tpZ.OnChanged then Opt.tpZ:OnChanged(pushOffsets) end
        pushOffsets()
    end)
end

-- === 🌍 WORLD ===
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    bindToggle(g,"multiHook","🔒 AntiCheat Multi-Hook",features.ToggleMultiHook)
    bindToggle(g,"multiHookSilent","⚡ Multi-Hook Silent Aim",features.ToggleMultiHook)
    bindToggle(g,"tinyHitbox","🛡️ Tiny Hitbox (Hard)",features.ToggleTinyHitbox)
end

-- === ⚙ Settings / Theme & Save ===
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Siyah-kırmızı tema
do
    local th = ThemeManager:CurrentTheme()
    th.Accent     = Color3.fromRGB(230, 0, 35)
    th.Background = Color3.fromRGB(20, 20, 20)
    th.Outline    = Color3.fromRGB(180, 0, 0)
end
