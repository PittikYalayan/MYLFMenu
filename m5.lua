-- ⚡ MYLF | Hub ⚡ — mmenu9.lua + features9.8.lua (direct bind, Callback safe)

-- KÜTÜPHANELER
local Library, ThemeManager, SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/mmenu9.lua"))()
local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.8.lua"))() -- ← İSTEDİĞİN GİBİ DİREKT

-- PENCERE
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- MENÜ TOGGLE
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
Library.ToggleKeybind = MENU_KEY
local function ToggleMenu() if Library.Toggle then Library:Toggle() elseif Library.ToggleUI then Library:ToggleUI() end end
UIS.InputBegan:Connect(function(inp, gp) if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end end)

-- TABS
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

-- HELPERS (Callback kullanan güvenli bağlayıcılar)
local function addToggle(group, flag, text, fn)
    return group:AddToggle(flag, { Text = text, Default = false, Callback = function(v)
        if type(fn) == "function" then pcall(fn, v) end
    end })
end
local function addSlider(group, flag, cfg, onChange)
    cfg = cfg or {}
    cfg.Callback = function(v) if type(onChange)=="function" then pcall(onChange, v) end end
    return group:AddSlider(flag, cfg)
end

-- 🔥 RAGE
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    addToggle(g, "aimbot",           "Enable Aimbot",           features.ToggleAimbot)
    addToggle(g, "headshotRedirect", "Force Headshot",          features.ToggleHeadshotRedirect)
    addToggle(g, "fireRate",         "Hard Fire Rate",          features.ToggleFireRate)
    addToggle(g, "silent",           "Silent Aim",              features.ToggleSilentAim)
    addToggle(g, "magic",            "Magic Bullet (Fallback)", features.ToggleMagicBullet)
    addToggle(g, "killAura",         "☠️ Kill Aura",           features.ToggleKillAura)

    local r = Tabs.Rage:AddRightGroupbox("Recoil / Spread")
    addToggle(r, "norecoil", "No Recoil", features.ToggleNoRecoil)
    addToggle(r, "nospread", "No Spread", features.ToggleNoSpread)
end

-- 👁 VISUALS
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    addToggle(g, "esp",        "Enable ESP",          features.ToggleESP)
    addToggle(g, "enemyBigHB", "🎯 Enemy Big Hitbox", features.ToggleEnemyBigHitbox)
end

-- 🕴 PLAYER
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    addToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)
    addToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)
    addToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    addToggle(g, "godmode",   "💀 Godmode",       features.ToggleGodmode)
    addToggle(g, "hardInvis", "👻 Hard Invisible",features.ToggleHardInvisible)
    addToggle(g, "noclip",    "NoClip",           features.ToggleNoclip)
end

-- ⚡ TELEPORT (TP offset Slider'ları direct Callback)
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    addToggle(g, "tpkey",      "Teleport (T Key)",          features.ToggleTeleport)
    addToggle(g, "autoBehind", "⚡ Always Behind Enemy",     features.ToggleAutoBehind)
    addToggle(g, "autoTP",     "⚡ Auto Farm Enemy",         features.ToggleAutoTeleportToEnemy)

    local tpX = addSlider(g, "tpX", {Text="X Offset", Min=-50, Max=50,  Default=0,  Rounding=1}, function(v)
        features._tpX = v; features.SetTeleportOffset(features._tpX, features._tpY or 0, features._tpZ or 25)
    end)
    local tpY = addSlider(g, "tpY", {Text="Y Offset", Min=-50, Max=50,  Default=0,  Rounding=1}, function(v)
        features._tpY = v; features.SetTeleportOffset(features._tpX or 0, features._tpY, features._tpZ or 25)
    end)
    local tpZ = addSlider(g, "tpZ", {Text="Z Offset", Min=1,   Max=100, Default=25, Rounding=1}, function(v)
        features._tpZ = v; features.SetTeleportOffset(features._tpX or 0, features._tpY or 0, features._tpZ)
    end)

    -- başlangıçta defaults'u features'a bas
    features._tpX, features._tpY, features._tpZ = tpX.Value, tpY.Value, tpZ.Value
    if type(features.SetTeleportOffset)=="function" then
        pcall(features.SetTeleportOffset, features._tpX, features._tpY, features._tpZ)
    end
end

-- 🌍 WORLD
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    addToggle(g, "multiHook",        "🔒 AntiCheat Multi-Hook",  features.ToggleMultiHook)
    addToggle(g, "multiHookSilent",  "⚡ Multi-Hook Silent Aim", features.ToggleMultiHook)
    addToggle(g, "tinyHitbox",       "🛡️ Tiny Hitbox (Hard)",   features.ToggleTinyHitbox)
end

-- ⚙ SETTINGS / Tema & Save
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema (siyah-kırmızı)
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
