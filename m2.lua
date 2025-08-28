-- ⚡ MYLF | Hub ⚡ — mmenu9.lua + features9.8.lua LOADER (robust)

--[[
  Notlar:
  - HTTP fetch robust: syn.request / http_request / request → game:HttpGet → HttpGetAsync
  - ThemeManager / SaveManager mmenu9'dan dönmüyorsa, crash olmasın diye stub var.
  - AutoShow=false → ilk açılışta gizli; LeftControl ile Library:Toggle() çalışır.
--]]

local function fetch(url)
    local ok, res
    if syn and syn.request then
        ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if http_request then
        ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if request then
        ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if game and game.HttpGet then
        ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then return res end
    end
    ok, res = pcall(function() return game:HttpGetAsync(url) end)
    if ok and res then return res end
    error("HTTP fetch failed: "..tostring(url))
end

--== Load Library (mmenu9.lua) ==--
local MMENU9_URL   = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"
local FEATURES_URL = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"

local libA, thA, svA
do
    local chunk = fetch(MMENU9_URL)
    local fn = loadstring(chunk)
    libA, thA, svA = fn()
end

-- mmenu9 farklı şekillerde dönebilir → esnek ayrıştır
local Library, ThemeManager, SaveManager
if type(libA) == "table" and libA.CreateWindow then
    Library, ThemeManager, SaveManager = libA, thA, svA
elseif type(libA) == "table" and libA.Library then
    Library, ThemeManager, SaveManager = libA.Library, libA.ThemeManager, libA.SaveManager
else
    error("mmenu9.lua beklenen Library arayüzünü döndürmedi.")
end

-- Theme/Save yoksa stub (loader kodun bozulmasın)
if not ThemeManager then
    local themeTable = { Accent=Color3.fromRGB(230,57,70), Background=Color3.fromRGB(16,16,18), Outline=Color3.fromRGB(255,255,255) }
    local proxyMt = {
        __newindex = function(_, k, v)
            themeTable[k] = v
            if Library.SetTheme then
                local t = {}; t[k]=v; Library:SetTheme(t)
            end
        end,
        __index = function(_, k) return themeTable[k] end
    }
    ThemeManager = {
        SetLibrary = function() end,
        SetFolder = function() end,
        ApplyToTab = function() end,
        CurrentTheme = function() return setmetatable({}, proxyMt) end
    }
end
if not SaveManager then
    SaveManager = {
        SetLibrary = function() end,
        SetFolder = function() end,
        IgnoreThemeSettings = function() end,
        SetIgnoreIndexes = function() end,
        BuildConfigSection = function() end
    }
end

--== Load features ==--
local features = (loadstring(fetch(FEATURES_URL)))()

--== Window ==--
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

--== Menu Toggle (LeftControl) ==--
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
local function ToggleMenu() if Library.Toggle then Library:Toggle() elseif Library.ToggleUI then Library:ToggleUI() end end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp) if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end end)

--== Tabs ==--
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- Helper
local function bindToggle(group, flag, text, fn)
    local t = group:AddToggle(flag, { Text = text, Default = false })
    if t and t.OnChanged then t:OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end) end
    return t
end

--== 🔥 RAGE ==--
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot",           "Enable Aimbot",           features.ToggleAimbot)
    bindToggle(g, "headshotRedirect", "Force Headshot",          features.ToggleHeadshotRedirect)
    bindToggle(g, "fireRate",         "Hard Fire Rate",          features.ToggleFireRate)
    bindToggle(g, "silent",           "Silent Aim",              features.ToggleSilentAim)
    bindToggle(g, "magic",            "Magic Bullet (Fallback)", features.ToggleMagicBullet)
    bindToggle(g, "killAura",         "☠️ Kill Aura",           features.ToggleKillAura)

    local g2 = Tabs.Rage:AddRightGroupbox("Recoil / Spread")
    bindToggle(g2, "norecoil", "No Recoil", features.ToggleNoRecoil)
    bindToggle(g2, "nospread", "No Spread", features.ToggleNoSpread)
end

--== 👁 VISUALS ==--
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp",        "Enable ESP",          features.ToggleESP)
    bindToggle(g, "enemyBigHB", "🎯 Enemy Big Hitbox", features.ToggleEnemyBigHitbox)
end

--== 🕴 PLAYER ==--
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)
    bindToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)
    bindToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    bindToggle(g, "godmode",   "💀 Godmode",       features.ToggleGodmode)
    bindToggle(g, "hardInvis", "👻 Hard Invisible",features.ToggleHardInvisible)
    bindToggle(g, "noclip",    "NoClip",           features.ToggleNoclip)
end

--== ⚡ TELEPORT ==--
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey",      "Teleport (T Key)",          features.ToggleTeleport)
    bindToggle(g, "autoBehind", "⚡ Always Behind Enemy",     features.ToggleAutoBehind)
    bindToggle(g, "autoTP",     "⚡ Auto Farm Enemy",         features.ToggleAutoTeleportToEnemy)

    -- Slider objelerini da al (Options fallback da ekli)
    local sX = g:AddSlider("tpX", {Text="X Offset", Min=-50, Max=50,  Default=0,  Rounding=1})
    local sY = g:AddSlider("tpY", {Text="Y Offset", Min=-50, Max=50,  Default=0,  Rounding=1})
    local sZ = g:AddSlider("tpZ", {Text="Z Offset", Min=1,   Max=100, Default=25, Rounding=1})

    local Options = getgenv().Options or _G.Options or Library.Options
    local function push()
        local x = (sX and sX.Value) or (Options and Options.tpX and Options.tpX.Value) or 0
        local y = (sY and sY.Value) or (Options and Options.tpY and Options.tpY.Value) or 0
        local z = (sZ and sZ.Value) or (Options and Options.tpZ and Options.tpZ.Value) or 25
        features._tpX, features._tpY, features._tpZ = x, y, z
        if type(features.SetTeleportOffset)=="function" then pcall(features.SetTeleportOffset, x, y, z) end
    end

    if sX and sX.OnChanged then sX:OnChanged(push) end
    if sY and sY.OnChanged then sY:OnChanged(push) end
    if sZ and sZ.OnChanged then sZ:OnChanged(push) end

    if Options and Options.tpX and Options.tpX.OnChanged then Options.tpX:OnChanged(push) end
    if Options and Options.tpY and Options.tpY.OnChanged then Options.tpY:OnChanged(push) end
    if Options and Options.tpZ and Options.tpZ.OnChanged then Options.tpZ:OnChanged(push) end

    push()
end

--== 🌍 WORLD ==--
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    bindToggle(g, "multiHook",        "🔒 AntiCheat Multi-Hook",   features.ToggleMultiHook)
    bindToggle(g, "multiHookSilent",  "⚡ Multi-Hook Silent Aim",  features.ToggleMultiHook)
    bindToggle(g, "tinyHitbox",       "🛡️ Tiny Hitbox (Hard)",    features.ToggleTinyHitbox)
end

--== ⚙ SETTINGS / Tema & Save ==--
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema: siyah-kırmızı (anında uygular)
do
    local th = ThemeManager:CurrentTheme()
    th.Accent     = Color3.fromRGB(230, 0, 35)
    th.Background = Color3.fromRGB(20, 20, 20)
    th.Outline    = Color3.fromRGB(180, 0, 0)
end
