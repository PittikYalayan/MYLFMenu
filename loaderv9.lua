-- ⚡ MYLF | Hub ⚡ — LOADER (Inspector yok, Magic Bullet toggle eklendi)

local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local features = loadstring(game:HttpGet("https://raw.githubusercontent.com/PittikYalayan/MYLFMenu/main/features2.lua"))()

-- AutoShow=false: inject anında mouse’u çalmaz
local Window = Library:CreateWindow({ Title = "⚡ MYLF | Hub ⚡", Center = true, AutoShow = false })

-- Menü toggle (fallback’lı)
local UIS = game:GetService("UserInputService")
local MENU_KEY = Enum.KeyCode.LeftShift
local function ToggleMenu() Library:Toggle() end
Library.ToggleKeybind = MENU_KEY
UIS.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == MENU_KEY then ToggleMenu() end
end)

-- Tabs
local Tabs = {
    Rage     = Window:AddTab("AimBot"),
    Visuals  = Window:AddTab("Esp"),
    Player   = Window:AddTab("Player"),
    Teleport = Window:AddTab("Teleport"),
    World    = Window:AddTab("World"),
    Settings = Window:AddTab("Settings"),
}

local function bindToggle(group, flag, text, fn)
    group:AddToggle(flag, { Text = text, Default = false })
        :OnChanged(function(v) if type(fn)=="function" then pcall(fn, v) end end)
end

-- Rage
do
    local g = Tabs.Rage:AddLeftGroupbox("AimBot")
    bindToggle(g, "aimbot",   "Aimbot",          features.ToggleAimbot)
    bindToggle(g, "silent",   "Silent Aim",             features.ToggleSilentAim)
    bindToggle(g, "magic",    "Magic Bullet (Fallback)",features.ToggleMagicBullet) -- ✅ eklendi
    bindToggle(g, "rapid",    "Rapid Fire",             features.ToggleRapidFire)
    bindToggle(g, "killaura", "Kill Aura",              features.ToggleKillAura)
end

-- Visuals
do
    local g = Tabs.Visuals:AddLeftGroupbox("Esp")
    bindToggle(g, "espRainbow", "🌈 Rainbow Name", features.ToggleESPRainbow)
    bindToggle(g, "espSkeleton", "🦴 Skeleton", features.ToggleESPSkeleton)
    bindToggle(g, "espGlow", "✨ Glow", features.ToggleESPGlow)
    bindToggle(g, "espBox", "▣ 3D Box", features.ToggleESPBox)
    bindToggle(g, "espStripes", "≡ Box Stripes", features.ToggleESPStripes)
    bindToggle(g, "espDist", "📏 Distance", features.ToggleESPDistance)
    bindToggle(g, "espHP", "❤️ Health Bar", features.ToggleESPHealth)
    bindToggle(g, "espTracers", "〽 Tracers", features.ToggleESPTracers)
    bindToggle(g, "espArrows", "⬅ Offscreen Arrows", features.ToggleESPArrows)
    bindToggle(g, "espCorner", "⌞⌝ Corner Box 2D", features.ToggleESPCorner)
    bindToggle(g, "espTeam", "👥 Team Check", features.ToggleESPTeam)
    bindToggle(g, "espLOS", "🔭 LOS Only", features.ToggleESPLos)
    bindToggle(g, "espRange", "📡 Range 300", features.ToggleESPRange)
    bindToggle(g, "espFriend", "⭐ Friend Ignore", features.ToggleESPFriends)

end

-- Player
do
    local g = Tabs.Player:AddLeftGroupbox("Player")
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
