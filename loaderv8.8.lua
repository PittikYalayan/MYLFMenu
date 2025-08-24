-- ⚡ MYLF | Hub ⚡ — LOADER (Inspector yok, Magic Bullet toggle eklendi)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features9.3.lua"))() --normali features2

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
    bindToggle(g, "multiHook", "⚡ Multi-Hook Silent Aim", features.ToggleMultiHook)
    bindToggle(g, "silent",   "Silent Aim",             features.ToggleSilentAim)
    bindToggle(g, "magic",    "Magic Bullet (Fallback)",features.ToggleMagicBullet) -- ✅ eklendi
    bindToggle(g, "killaura", "Kill Aura",              features.ToggleKillAura)
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
    bindToggle(g, "god",       "God Mode",         features.ToggleGodmode)
    bindToggle(g, "invisible", "Invisible",        features.ToggleInvisible)
end

-- Teleport
do
    local g = Tabs.Teleport:AddLeftGroupbox("Teleport")
    bindToggle(g, "tpkey", "Teleport (T Key)", features.ToggleTeleport)
    bindToggle(g, "autoBehind", "⚡ Always Behind Enemy", features.ToggleAutoBehind)
    -- Toggle
g:AddToggle("tpEnemy", {
    Text = "⚡ Auto Farm Enemy",
    Default = false,
    Callback = function(on) features.ToggleAutoTeleportToEnemy(on) end
})

-- Offset Sliderları
g:AddSlider("tpX", {
    Text = "Offset X",
    Default = 0,
    Min = -10, Max = 10, Rounding = 1,
    Callback = function(val) features.SetTeleportOffset(val, Toggles.tpY.Value, Toggles.tpZ.Value) end
})

g:AddSlider("tpY", {
    Text = "Offset Y",
    Default = 0,
    Min = -10, Max = 10, Rounding = 1,
    Callback = function(val) features.SetTeleportOffset(Toggles.tpX.Value, val, Toggles.tpZ.Value) end
})

g:AddSlider("tpZ", {
    Text = "Offset Z (Ön mesafe)",
    Default = 25,
    Min = 1, Max = 50, Rounding = 1,
    Callback = function(val) features.SetTeleportOffset(Toggles.tpX.Value, Toggles.tpY.Value, val) end
})



end

-- World
do
    local g = Tabs.World:AddLeftGroupbox("World")
    bindToggle(g, "noclip", "NoClip", features.ToggleNoclip)
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
