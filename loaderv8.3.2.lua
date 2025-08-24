-- ⚡ MYLF | Hub ⚡ — LOADER (Inspector yok, Magic Bullet toggle eklendi)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.7.lua"))() --normali features2

-- AutoShow=false: inject anında mouse’u çalmaz
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle (fallback’lı)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftControl
local function ToggleMenu() Library:Toggle() end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end
end)

-- Tabs
local Tabs = {
    Rage     = Window:AddTab("🔥 Rage"),
    Visuals  = Window:AddTab("👁 Visuals"),
    Player   = Window:AddTab("🕴 Player"),
    Teleport = Window:AddTab("⚡ Teleport"),
    World    = Window:AddTab("🌍 World"),
    Settings = Window:AddTab("⚙ Settings"),
}

local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end)
end

-- Rage
do
    local g = Tabs.Rage:AddLeftGroupbox("Rage")
    bindToggle(g, "aimbot",   "Enable Aimbot",          features.ToggleAimbot)
    bindToggle(g, "headshotRedirect", "Force Headshot", features.ToggleHeadshotRedirect)
    bindToggle(g, "fireRate", "Hard Fire Rate", features.ToggleFireRate)
    bindToggle(g, "silent",   "Silent Aim",             features.ToggleSilentAim)
    bindToggle(g, "magic",    "Magic Bullet (Fallback)",features.ToggleMagicBullet) -- ✅ eklendi
    bindToggle(g, "killAura", "☠️ Kill Aura", features.ToggleKillAura)
end

-- Visuals
do
    local g = Tabs.Visuals:AddLeftGroupbox("Visuals")
    bindToggle(g, "esp", "Enable ESP", features.ToggleESP)
end

-- Player
do
    local g = Tabs.Player:AddLeftGroupbox("Player Mods")
    bindToggle(g, "speed",     "Speed Boost (50)", features.ToggleSpeed)
    bindToggle(g, "fly",       "Fly (LCtrl down)", features.ToggleFly)
    bindToggle(g, "infjump",   "Infinite Jump",    features.ToggleInfiniteJump)
    bindToggle(g, "godmode", "💀 Godmode", features.ToggleGodmode)
    bindToggle(g, "hardInvis", "👻 Hard Invisible", features.ToggleHardInvisible)
    bindToggle(g, "noclip", "NoClip", features.ToggleNoclip)
end

-- Teleport
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey", "Teleport (T Key)", features.ToggleTeleport)
    bindToggle(g, "autoBehind", "⚡ Always Behind Enemy", features.ToggleAutoBehind)
    bindToggle(g, "autoTP", "⚡ Auto Farm Enemy", features.ToggleAutoTeleportToEnemy)
g:AddSlider("tpX", {Text="X Offset", Min=-50, Max=50, Default=0, Rounding=1})
g:AddSlider("tpY", {Text="Y Offset", Min=-50, Max=50, Default=0, Rounding=1})
g:AddSlider("tpZ", {Text="Z Offset", Min=1, Max=100, Default=25, Rounding=1})

Options.tpX:OnChanged(function(val) features.SetTeleportOffset(val, features._tpY, features._tpZ) end)
Options.tpY:OnChanged(function(val) features.SetTeleportOffset(features._tpX, val, features._tpZ) end)
Options.tpZ:OnChanged(function(val) features.SetTeleportOffset(features._tpX, features._tpY, val) end)



end

-- World
do
    local g = Tabs.World:AddLeftGroupbox("MultiHook")
    bindToggle(g, "multiHook", "🔒 AntiCheat Multi-Hook", features.ToggleMultiHook)
    bindToggle(g, "multiHook", "⚡ Multi-Hook Silent Aim", features.ToggleMultiHook)
    bindToggle(visualsGroup, "miniHB", "⚡ Mini Hitbox", features.ToggleMiniHitbox)
    bindToggle(g, "tinyHitbox", "🛡️ Tiny Hitbox (Hard)", features.ToggleTinyHitbox)

    
end

-- Settings / Tema
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("MYLFHub")
SaveManager:SetFolder("MYLFHub/saves")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Tema: siyah-kırmızı
local th = ThemeManager:CurrentTheme()
th.Accent     = Color3.fromRGB(230, 0, 35)
th.Background = Color3.fromRGB(20, 20, 20)
th.Outline    = Color3.fromRGB(180, 0, 0)
