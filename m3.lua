-- ⚡ MYLF | Hub ⚡ — mmenu9 + features9.8 (OnChanged-unsafe FIX)

-- URLs
local MMENU9_URL   = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"
local FEATURES_URL = "https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"

-- basit fetch (senin executorda game:HttpGet çalışıyorsa yeter)
local function GET(u)
    return game:HttpGet(u)
end

-- Library / ThemeManager / SaveManager yükle
local L1, L2, L3 = loadstring(GET(MMENU9_URL))()
local Library, ThemeManager, SaveManager
if type(L1) == "table" and L1.CreateWindow then
    Library, ThemeManager, SaveManager = L1, L2, L3
elseif type(L1) == "table" and L1.Library then
    Library, ThemeManager, SaveManager = L1.Library, L1.ThemeManager, L1.SaveManager
else
    error("mmenu9.lua beklenen arayüzü döndürmedi")
end

-- features
local features = loadstring(GET(FEATURES_URL))()

-- pencere
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- toggle tuşu
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
Library.ToggleKeybind = MENU_KEY
local function ToggleMenu()
    if Library.Toggle then Library:Toggle() elseif Library.ToggleUI then Library:ToggleUI() end
end
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode == MENU_KEY then ToggleMenu() end end)

-- sekmeler
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- ------ Helpers: OnChanged/Callback uyum katmanı ------

local function hookToggle(toggleObj, cb)
    -- mmenu8 tarzı: toggleObj:OnChanged(fn)
    if toggleObj and typeof(toggleObj)=="table" and toggleObj.OnChanged then
        toggleObj:OnChanged(function(v) if type(cb)=="function" then pcall(cb, v) end end)
        return
    end
    -- mmenu9 tarzı: AddToggle(... { Callback = fn })
    -- (Callback’ı AddToggle çağrısında vereceğiz; burada ekstra yok)
end

local function safeAddToggle(group, flag, text, cb)
    -- Callback alanına da veriyoruz (mmenu9)
    local obj = group:AddToggle(flag, { Text = text, Default = false, Callback = function(v)
        if type(cb)=="function" then pcall(cb, v) end
    end })
    -- varsa OnChanged de bağla (mmenu8 uyumu)
    hookToggle(obj, cb)
    return obj
end

local function hookSlider(sliderObj, cb)
    if sliderObj and typeof(sliderObj)=="table" then
        if sliderObj.OnChanged then
            sliderObj:OnChanged(function(v) if type(cb)=="function" then pcall(cb, v) end end)
        elseif sliderObj.SetValue then
            -- bazı sürümlerde OnChanged yok; Callback AddSlider tarafında verilecek
            -- burada ekstra gerekmez
        end
    end
end

local function safeAddSlider(group, flag, cfg, cb)
    cfg = cfg or {}
    cfg.Callback = function(v) if type(cb)=="function" then pcall(cb, v) end end -- mmenu9
    local obj = group:AddSlider(flag, cfg)
    hookSlider(obj, cb) -- mmenu8
    return obj
end

-- ------ RAGE ------
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    safeAddToggle(g, "aimbot",           "Enable Aimbot",           features.ToggleAimbot)
    safeAddToggle(g, "headshotRedirect", "Force Headshot",          features.ToggleHeadshotRedirect)
    safeAddToggle(g, "fireRate",         "Hard Fire Rate",          features.ToggleFireRate)
    safeAddToggle(g, "silent",           "Silent Aim",              features.ToggleSilentAim)
    safeAddToggle(g, "magic",            "Magic Bullet (Fallback)", features.ToggleMagicBullet)
    safeAddToggle(g, "killAura",         "☠️ Kill Aura",           features.ToggleKillAura)

    local g2 = Tabs.Rage:AddRightGroupbox("Recoil / Spread")
    safeAddToggle(g2, "norecoil", "No Recoil", features.ToggleNoRecoil)
    safeAddToggle(g2, "nospread", "No Spread", features.ToggleNoSpread)
end

-- ------ VISUALS ------
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    safeAddToggle(g, "esp",        "Enable ESP",          features.ToggleESP)
    safeAddToggle(g, "enemyBigHB", "🎯 Enemy Big Hitbox", features.ToggleEnemyBigHitbox)
end

-- ------ PLAYER ------
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    safeAddToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)
    safeAddToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)
    safeAddToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    safeAddToggle(g, "godmode",   "💀 Godmode",       features.ToggleGodmode)
    safeAddToggle(g, "hardInvis", "👻 Hard Invisible",features.ToggleHardInvisible)
    safeAddToggle(g, "noclip",    "NoClip",           features.ToggleNoclip)
end

-- ------ TELEPORT ------
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    safeAddToggle(g, "tpkey",      "Teleport (T Key)",          features.ToggleTeleport)
    safeAddToggle(g, "autoBehind", "⚡ Always Behind Enemy",     features.ToggleAutoBehind)
    safeAddToggle(g, "autoTP",     "⚡ Auto Farm Enemy",         features.ToggleAutoTeleportToEnemy)

    local function pushOffsets()
        local x = (Options and Options.tpX and Options.tpX.Value) or 0
        local y = (Options and Options.tpY and Options.tpY.Value) or 0
        local z = (Options and Options.tpZ and Options.tpZ.Value) or 25
        features._tpX, features._tpY, features._tpZ = x, y, z
        if type(features.SetTeleportOffset)=="function" then pcall(features.SetTeleportOffset, x, y, z) end
    end

    safeAddSlider(g, "tpX", {Text="X Offset", Min=-50, Max=50,  Default=0,  Rounding=1},  function() pushOffsets() end)
    safeAddSlider(g, "tpY", {Text="Y Offset", Min=-50, Max=50,  Default=0,  Rounding=1},  function() pushOffsets() end)
    safeAddSlider(g, "tpZ", {Text="Z Offset", Min=1,   Max=100, Default=25, Rounding=1},  function() pushOffsets() end)

    -- Eğer Options global yoksa mmenu9 yine oluşturur; ama garanti olsun:
    getgenv().Options = getgenv().Options or _G.Options or {}
    pushOffsets()
end

-- ------ WORLD ------
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    safeAddToggle(g, "multiHook",        "🔒 AntiCheat Multi-Hook",  features.ToggleMultiHook)
    safeAddToggle(g, "multiHookSilent",  "⚡ Multi-Hook Silent Aim", features.ToggleMultiHook)
    safeAddToggle(g, "tinyHitbox",       "🛡️ Tiny Hitbox (Hard)",   features.ToggleTinyHitbox)
end

-- ------ SETTINGS (Tema & Save) ------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- siyah-kırmızı tema
do
    local th = ThemeManager:CurrentTheme()
    th.Accent     = Color3.fromRGB(230, 0, 35)
    th.Background = Color3.fromRGB(20, 20, 20)
    th.Outline    = Color3.fromRGB(180, 0, 0)
end
